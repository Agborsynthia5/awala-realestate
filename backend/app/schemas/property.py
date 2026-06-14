from pydantic import BaseModel, Field
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from decimal import Decimal
from app.models.property import PropertyType


# ─── Create ──────────────────────────────────────────────────────────
class PropertyCreate(BaseModel):
    title: str = Field(..., min_length=5, max_length=200)
    description: Optional[str] = None
    type: PropertyType
    price: Decimal = Field(..., gt=0)
    currency: str = "XAF"
    furnished: bool = False
    bedrooms: int = Field(1, ge=1)
    bathrooms: int = Field(1, ge=1)
    location_name: Optional[str] = None
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    neighborhood: Optional[str] = None
    city: str = "Buea"
    amenities: List[str] = []
    images: List[str] = []
    whatsapp_number: Optional[str] = None
    phone_number: Optional[str] = None


# ─── Update ──────────────────────────────────────────────────────────
class PropertyUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=5, max_length=200)
    description: Optional[str] = None
    type: Optional[PropertyType] = None
    price: Optional[Decimal] = Field(None, gt=0)
    furnished: Optional[bool] = None
    bedrooms: Optional[int] = Field(None, ge=1)
    bathrooms: Optional[int] = Field(None, ge=1)
    location_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    neighborhood: Optional[str] = None
    amenities: Optional[List[str]] = None
    images: Optional[List[str]] = None
    whatsapp_number: Optional[str] = None
    phone_number: Optional[str] = None
    is_active: Optional[bool] = None


# ─── Response ────────────────────────────────────────────────────────
class PropertyOut(BaseModel):
    id: UUID
    owner_id: UUID
    title: str
    description: Optional[str]
    type: PropertyType
    price: float
    currency: str
    furnished: bool
    bedrooms: int
    bathrooms: int
    location_name: Optional[str]
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    neighborhood: Optional[str]
    city: str
    amenities: List[str]
    images: List[str]
    whatsapp_number: Optional[str]
    phone_number: Optional[str]
    is_active: bool
    is_verified: bool
    view_count: int
    distance_from_molyko_km: Optional[float] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ─── List Response ───────────────────────────────────────────────────
class PropertyListResponse(BaseModel):
    total: int
    page: int
    page_size: int
    results: List[PropertyOut]
