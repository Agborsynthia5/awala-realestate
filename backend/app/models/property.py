import uuid
import enum
from sqlalchemy import Column, String, Boolean, Enum, Text, DateTime, Integer, Numeric, ARRAY, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from geoalchemy2 import Geography
from app.db.database import Base


class PropertyType(str, enum.Enum):
    room = "room"
    studio = "studio"
    apartment = "apartment"
    villa = "villa"


class Property(Base):
    __tablename__ = "properties"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    type = Column(Enum(PropertyType, name="property_type"), nullable=False)
    price = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(5), default="XAF")
    furnished = Column(Boolean, default=False)
    bedrooms = Column(Integer, default=1)
    bathrooms = Column(Integer, default=1)
    location_name = Column(String(200), nullable=True)
    location = Column(Geography(geometry_type="POINT", srid=4326), nullable=True)
    neighborhood = Column(String(100), nullable=True)
    city = Column(String(100), default="Buea")
    amenities = Column(JSONB, default=list)
    images = Column(ARRAY(Text), default=list)
    whatsapp_number = Column(String(20), nullable=True)
    phone_number = Column(String(20), nullable=True)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    view_count = Column(Integer, default=0)
    distance_from_molyko_km = Column(Numeric(6, 2), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
