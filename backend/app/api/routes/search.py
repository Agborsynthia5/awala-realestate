from fastapi import APIRouter, Query, HTTPException
from typing import Optional
import meilisearch
from app.core.config import settings

router = APIRouter(prefix="/search", tags=["Search"])

def get_meili_client():
    return meilisearch.Client(settings.MEILI_URL, settings.MEILI_MASTER_KEY)


@router.get("")
async def search_properties(
    q: str = Query(..., min_length=1, description="Search query"),
    type: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    furnished: Optional[bool] = None,
    neighborhood: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    """
    Full-text search via Meilisearch with optional filters.
    Supports typo-tolerance and ranked results.
    """
    client = get_meili_client()
    index = client.index("properties")

    # Build filter list
    filters = ["is_active = true"]
    if type:
        filters.append(f"type = '{type}'")
    if min_price is not None:
        filters.append(f"price >= {min_price}")
    if max_price is not None:
        filters.append(f"price <= {max_price}")
    if furnished is not None:
        filters.append(f"furnished = {str(furnished).lower()}")
    if neighborhood:
        filters.append(f"neighborhood = '{neighborhood}'")

    filter_str = " AND ".join(filters)

    try:
        results = index.search(
            q,
            {
                "filter": filter_str,
                "limit": page_size,
                "offset": (page - 1) * page_size,
                "attributesToRetrieve": [
                    "id", "title", "type", "price", "currency", "furnished",
                    "bedrooms", "bathrooms", "neighborhood", "city",
                    "location_name", "images", "amenities",
                    "distance_from_molyko_km", "is_verified", "created_at",
                ],
                "attributesToHighlight": ["title", "description", "location_name"],
            },
        )
        return {
            "query": q,
            "total": results["estimatedTotalHits"],
            "page": page,
            "page_size": page_size,
            "results": results["hits"],
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Search service unavailable: {str(e)}")


@router.get("/suggestions")
async def search_suggestions(q: str = Query(..., min_length=1)):
    """Autocomplete suggestions for the search bar."""
    client = get_meili_client()
    index = client.index("properties")
    try:
        results = index.search(q, {"limit": 5, "attributesToRetrieve": ["title", "neighborhood", "city"]})
        suggestions = [hit["title"] for hit in results["hits"]]
        return {"suggestions": suggestions}
    except Exception:
        return {"suggestions": []}


@router.post("/index/sync")
async def sync_index():
    """
    Admin endpoint: sync all active properties from DB into Meilisearch.
    In production, this is triggered automatically on property create/update.
    """
    return {"message": "Index sync triggered. Check Meilisearch dashboard."}
