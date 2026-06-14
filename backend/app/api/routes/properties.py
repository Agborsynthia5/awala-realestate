from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, text
from sqlalchemy.dialects.postgresql import insert
from typing import Optional
from uuid import UUID

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.property import Property
from app.models.misc import SavedProperty
from app.schemas.property import PropertyCreate, PropertyUpdate, PropertyOut, PropertyListResponse
from app.core.config import settings
from geoalchemy2.functions import ST_MakePoint, ST_SetSRID, ST_Distance, ST_DWithin

router = APIRouter(prefix="/properties", tags=["Properties"])

MOLYKO_LAT = settings.MOLYKO_JUNCTION_LAT
MOLYKO_LNG = settings.MOLYKO_JUNCTION_LNG


def _molyko_point():
    return ST_SetSRID(ST_MakePoint(MOLYKO_LNG, MOLYKO_LAT), 4326)


@router.get("", response_model=PropertyListResponse)
async def list_properties(
    type: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    furnished: Optional[bool] = None,
    neighborhood: Optional[str] = None,
    owner_id: Optional[UUID] = None,
    include_inactive: bool = False,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_by: str = Query("created_at", regex="^(price|created_at|distance)$"),
    db: AsyncSession = Depends(get_db),
):
    """List properties with filters and pagination."""
    query = select(Property)
    if not include_inactive:
        query = query.where(Property.is_active == True)
    if owner_id:
        query = query.where(Property.owner_id == owner_id)

    if type:
        query = query.where(Property.type == type)
    if min_price is not None:
        query = query.where(Property.price >= min_price)
    if max_price is not None:
        query = query.where(Property.price <= max_price)
    if furnished is not None:
        query = query.where(Property.furnished == furnished)
    if neighborhood:
        query = query.where(Property.neighborhood.ilike(f"%{neighborhood}%"))

    # Count
    count_result = await db.execute(select(func.count()).select_from(query.subquery()))
    total = count_result.scalar()

    # Sort
    if sort_by == "price":
        query = query.order_by(Property.price.asc())
    elif sort_by == "distance":
        query = query.order_by(Property.distance_from_molyko_km.asc().nullslast())
    else:
        query = query.order_by(Property.created_at.desc())

    # Paginate
    query = query.offset((page - 1) * page_size).limit(page_size)
    results = await db.execute(query)
    properties = results.scalars().all()

    items = []
    for p in properties:
        item = PropertyOut.model_validate(p)
        items.append(item)

    return PropertyListResponse(total=total, page=page, page_size=page_size, results=items)


@router.get("/nearby", response_model=PropertyListResponse)
async def nearby_properties(
    lat: float = Query(..., ge=-90, le=90),
    lng: float = Query(..., ge=-180, le=180),
    radius_km: float = Query(5.0, ge=0.1, le=50),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    """Find properties within radius_km of a given point (user's location)."""
    user_point = ST_SetSRID(ST_MakePoint(lng, lat), 4326)

    query = (
        select(Property)
        .where(Property.is_active == True)
        .where(ST_DWithin(Property.location, user_point, radius_km * 1000))
        .order_by(ST_Distance(Property.location, user_point).asc())
    )

    count_result = await db.execute(select(func.count()).select_from(query.subquery()))
    total = count_result.scalar()

    query = query.offset((page - 1) * page_size).limit(page_size)
    results = await db.execute(query)
    properties = results.scalars().all()

    return PropertyListResponse(
        total=total, page=page, page_size=page_size,
        results=[PropertyOut.model_validate(p) for p in properties]
    )


@router.get("/{property_id}", response_model=PropertyOut)
async def get_property(property_id: UUID, db: AsyncSession = Depends(get_db)):
    """Get a single property by ID and increment view count."""
    result = await db.execute(select(Property).where(Property.id == property_id))
    prop = result.scalar_one_or_none()
    if not prop:
        raise HTTPException(status_code=404, detail="Property not found")
    prop.view_count += 1
    return PropertyOut.model_validate(prop)


@router.post("", response_model=PropertyOut, status_code=status.HTTP_201_CREATED)
async def create_property(
    payload: PropertyCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new property listing (authenticated users)."""
    location = None
    distance_km = None

    if payload.latitude and payload.longitude:
        location = f"SRID=4326;POINT({payload.longitude} {payload.latitude})"
        # Haversine approximate distance to Molyko Junction
        import math
        lat1, lon1 = math.radians(payload.latitude), math.radians(payload.longitude)
        lat2, lon2 = math.radians(MOLYKO_LAT), math.radians(MOLYKO_LNG)
        dlat, dlon = lat2 - lat1, lon2 - lon1
        a = math.sin(dlat/2)**2 + math.cos(lat1)*math.cos(lat2)*math.sin(dlon/2)**2
        distance_km = round(6371 * 2 * math.asin(math.sqrt(a)), 2)

    prop = Property(
        owner_id=current_user.id,
        title=payload.title,
        description=payload.description,
        type=payload.type,
        price=payload.price,
        currency=payload.currency,
        furnished=payload.furnished,
        bedrooms=payload.bedrooms,
        bathrooms=payload.bathrooms,
        location_name=payload.location_name,
        location=location,
        neighborhood=payload.neighborhood,
        city=payload.city,
        amenities=payload.amenities,
        images=payload.images,
        whatsapp_number=payload.whatsapp_number,
        phone_number=payload.phone_number,
        distance_from_molyko_km=distance_km,
    )
    db.add(prop)
    await db.flush()
    await db.refresh(prop)
    return PropertyOut.model_validate(prop)


@router.put("/{property_id}", response_model=PropertyOut)
async def update_property(
    property_id: UUID,
    payload: PropertyUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update a property (owner only)."""
    result = await db.execute(select(Property).where(Property.id == property_id))
    prop = result.scalar_one_or_none()
    if not prop:
        raise HTTPException(status_code=404, detail="Property not found")
    if prop.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your property")

    for field, value in payload.model_dump(exclude_unset=True).items():
        if field not in ("latitude", "longitude"):
            setattr(prop, field, value)

    if payload.latitude and payload.longitude:
        prop.location = f"SRID=4326;POINT({payload.longitude} {payload.latitude})"

    return PropertyOut.model_validate(prop)


@router.delete("/{property_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_property(
    property_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a property (owner only)."""
    result = await db.execute(select(Property).where(Property.id == property_id))
    prop = result.scalar_one_or_none()
    if not prop:
        raise HTTPException(status_code=404, detail="Property not found")
    if prop.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your property")
    await db.delete(prop)
