import uuid
from sqlalchemy import Column, String, Boolean, Enum, Text, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from app.db.database import Base
import enum


class UserRole(str, enum.Enum):
    student = "student"
    landlord = "landlord"
    agent = "agent"
    admin = "admin"


class UserLanguage(str, enum.Enum):
    en = "en"
    fr = "fr"


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=False, index=True)
    phone = Column(String(20), nullable=True)
    password_hash = Column(Text, nullable=False)
    role = Column(Enum(UserRole, name="user_role"), default=UserRole.student)
    is_verified = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    preferred_language = Column(Enum(UserLanguage, name="user_language"), default=UserLanguage.en)
    avatar_url = Column(Text, nullable=True)
    fcm_token = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
