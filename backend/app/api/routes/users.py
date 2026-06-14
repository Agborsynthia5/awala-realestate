from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from uuid import UUID

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.misc import SavedProperty, SearchAlert, Notification
from app.schemas.user import UserOut, UserUpdate
from app.schemas.property import PropertyOut, PropertyListResponse
from app.models.property import Property
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


router = APIRouter(prefix="/users", tags=["Users"])


# ─── Profile ─────────────────────────────────────────────────────────
@router.get("/me", response_model=UserOut)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=UserOut)
async def update_me(
    payload: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(current_user, field, value)
    await db.flush()
    await db.refresh(current_user)
    return current_user


# ─── Saved Properties ────────────────────────────────────────────────
@router.get("/me/saved", response_model=PropertyListResponse)
async def get_saved(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Property)
        .join(SavedProperty, SavedProperty.property_id == Property.id)
        .where(SavedProperty.user_id == current_user.id)
        .offset((page - 1) * page_size).limit(page_size)
    )
    props = result.scalars().all()
    return PropertyListResponse(total=len(props), page=page, page_size=page_size,
                                results=[PropertyOut.model_validate(p) for p in props])


@router.post("/me/saved/{property_id}", status_code=201)
async def save_property(
    property_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    existing = await db.execute(
        select(SavedProperty).where(
            SavedProperty.user_id == current_user.id,
            SavedProperty.property_id == property_id,
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Already saved")
    db.add(SavedProperty(user_id=current_user.id, property_id=property_id))
    return {"message": "Saved"}


@router.delete("/me/saved/{property_id}", status_code=204)
async def unsave_property(
    property_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await db.execute(
        delete(SavedProperty).where(
            SavedProperty.user_id == current_user.id,
            SavedProperty.property_id == property_id,
        )
    )


# ─── Search Alerts ────────────────────────────────────────────────────
class AlertCreate(BaseModel):
    query: Optional[str] = None
    filters: dict = {}
    notify_email: bool = True
    notify_push: bool = True
    notify_sms: bool = False


class AlertOut(BaseModel):
    id: UUID
    query: Optional[str]
    filters: dict
    notify_email: bool
    notify_push: bool
    notify_sms: bool
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


@router.get("/me/alerts", response_model=List[AlertOut])
async def get_alerts(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(SearchAlert).where(SearchAlert.user_id == current_user.id)
    )
    return result.scalars().all()


@router.post("/me/alerts", response_model=AlertOut, status_code=201)
async def create_alert(
    payload: AlertCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    alert = SearchAlert(user_id=current_user.id, **payload.model_dump())
    db.add(alert)
    await db.flush()
    await db.refresh(alert)
    return alert


@router.delete("/me/alerts/{alert_id}", status_code=204)
async def delete_alert(
    alert_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await db.execute(
        delete(SearchAlert).where(
            SearchAlert.id == alert_id,
            SearchAlert.user_id == current_user.id,
        )
    )


# ─── Notifications ────────────────────────────────────────────────────
class NotificationOut(BaseModel):
    id: UUID
    title: str
    body: str
    type: str
    data: dict
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True


@router.get("/me/notifications", response_model=List[NotificationOut])
async def get_notifications(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .order_by(Notification.created_at.desc())
        .limit(50)
    )
    return result.scalars().all()


@router.put("/me/notifications/{notification_id}/read", status_code=200)
async def mark_read(
    notification_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Notification).where(
            Notification.id == notification_id,
            Notification.user_id == current_user.id,
        )
    )
    notif = result.scalar_one_or_none()
    if notif:
        notif.is_read = True
    return {"message": "Marked as read"}
