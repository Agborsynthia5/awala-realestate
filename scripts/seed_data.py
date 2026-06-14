#!/usr/bin/env python3
"""
Seed script: generates 50+ realistic property listings for Buea, Cameroon.
Run: python scripts/seed_data.py
"""
import asyncio
import random
import math
from datetime import datetime, timedelta
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from app.core.config import settings
from app.core.security import hash_password
from app.models.user import User, UserRole, UserLanguage
from app.models.property import Property, PropertyType
from app.db.database import Base

# ─── Buea Neighborhoods ───────────────────────────────────────────────
NEIGHBORHOODS = [
    ("Molyko", 4.1527, 9.2345),
    ("Bonduma", 4.1580, 9.2290),
    ("Mile 16", 4.1450, 9.2200),
    ("Small Soppo", 4.1600, 9.2400),
    ("Great Soppo", 4.1650, 9.2450),
    ("Bokwango", 4.1700, 9.2500),
    ("Buea Town", 4.1560, 9.2310),
    ("Clerk's Quarters", 4.1510, 9.2370),
    ("GRA", 4.1490, 9.2280),
    ("Muea", 4.1390, 9.2150),
]

AMENITIES_POOL = [
    "WiFi", "Running Water", "24/7 Electricity", "Generator",
    "Parking", "Security", "CCTV", "Furnished Kitchen",
    "Air Conditioning", "Balcony", "Garden", "Borehole",
    "Solar Power", "Tiled Floors", "POP Ceiling", "Wardrobe",
]

PROPERTY_TITLES = {
    PropertyType.room: [
        "Spacious Self-Contained Room", "Clean Single Room with Toilet",
        "Nice Room Near UB Campus", "Furnished Self-Contain",
        "Affordable Room in Quiet Area", "Student-Friendly Room",
        "Modern Self-Contained Room", "Well-Ventilated Single Room",
    ],
    PropertyType.studio: [
        "Modern Studio Apartment", "Cozy Studio Near Molyko",
        "Newly Built Studio", "Furnished Studio with Kitchen",
        "Compact Studio Apartment", "Studio with Running Water",
        "Clean Studio for Professional", "Budget Studio Apartment",
    ],
    PropertyType.apartment: [
        "2-Bedroom Apartment in Molyko", "3-Bedroom Family Apartment",
        "Executive 2-Bedroom Apartment", "Spacious 1-Bedroom Apartment",
        "Furnished 2-Bedroom Flat", "Modern 3-Bedroom with Parking",
        "Affordable 2-Room Apartment", "1-Bedroom Apartment Near UB",
    ],
    PropertyType.villa: [
        "4-Bedroom Villa with Garden", "Executive Villa with Parking",
        "Luxury Villa in GRA", "Spacious Family Villa",
    ],
}

MOLYKO_LAT = settings.MOLYKO_JUNCTION_LAT
MOLYKO_LNG = settings.MOLYKO_JUNCTION_LNG


def haversine_km(lat1, lon1, lat2, lon2):
    R = 6371
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    return round(R * 2 * math.asin(math.sqrt(a)), 2)


def jitter(coord, max_offset=0.008):
    return coord + random.uniform(-max_offset, max_offset)


PRICE_RANGES = {
    PropertyType.room: (15000, 45000),
    PropertyType.studio: (35000, 80000),
    PropertyType.apartment: (60000, 200000),
    PropertyType.villa: (150000, 400000),
}

DESCRIPTIONS = [
    "Located in a serene and secure environment, this property offers comfortable living with easy access to transport.",
    "Ideal for students and young professionals. Close to shops, pharmacies, and public transport.",
    "Well-maintained property with reliable water and electricity supply. Available immediately.",
    "Quiet neighborhood, perfect for families. Walking distance from schools and markets.",
    "Newly painted and tiled. Solar backup ensures 24/7 electricity. Very clean.",
    "Security is top-notch with 24/7 watchman. Neighbours are friendly and cooperative.",
    "This property comes with a borehole so water is never a problem. Great for long stay.",
    "Affordable and cozy. Perfect for someone looking to live near the University of Buea.",
]


async def seed():
    engine = create_async_engine(settings.DATABASE_URL, echo=False)
    Session = async_sessionmaker(engine, expire_on_commit=False)

    async with Session() as db:
        # ─── Create sample users ──────────────────────────────────────
        landlords = []
        for i in range(5):
            user = User(
                name=f"Landlord {['Ngwa', 'Mbah', 'Tabe', 'Nkemdirim', 'Ayuk'][i]}",
                email=f"landlord{i+1}@awala.cm",
                phone=f"+23767{random.randint(1000000, 9999999)}",
                password_hash=hash_password("Password123!"),
                role=UserRole.landlord,
                is_verified=True,
                preferred_language=random.choice([UserLanguage.en, UserLanguage.fr]),
            )
            db.add(user)
            landlords.append(user)

        # Sample student user
        student = User(
            name="Eric Tabi",
            email="eric.tabi@student.cm",
            phone="+237677123456",
            password_hash=hash_password("Password123!"),
            role=UserRole.student,
            preferred_language=UserLanguage.en,
        )
        db.add(student)
        await db.flush()

        # ─── Create properties ────────────────────────────────────────
        all_types = [PropertyType.room] * 25 + [PropertyType.studio] * 15 + \
                    [PropertyType.apartment] * 10 + [PropertyType.villa] * 2
        random.shuffle(all_types)

        for i, ptype in enumerate(all_types):
            neighborhood, base_lat, base_lng = random.choice(NEIGHBORHOODS)
            lat = jitter(base_lat)
            lng = jitter(base_lng)
            distance_km = haversine_km(lat, lng, MOLYKO_LAT, MOLYKO_LNG)
            min_p, max_p = PRICE_RANGES[ptype]
            price = random.randrange(min_p, max_p, 5000)
            amenity_count = random.randint(3, 8)
            amenities = random.sample(AMENITIES_POOL, amenity_count)
            bedrooms = 1 if ptype in (PropertyType.room, PropertyType.studio) else random.randint(1, 3)
            days_ago = random.randint(0, 60)

            prop = Property(
                owner_id=random.choice(landlords).id,
                title=random.choice(PROPERTY_TITLES[ptype]),
                description=random.choice(DESCRIPTIONS),
                type=ptype,
                price=price,
                currency="XAF",
                furnished=random.choice([True, False]),
                bedrooms=bedrooms,
                bathrooms=1 if ptype == PropertyType.room else random.randint(1, 2),
                location_name=f"{neighborhood}, Buea",
                location=f"SRID=4326;POINT({lng} {lat})",
                neighborhood=neighborhood,
                city="Buea",
                amenities=amenities,
                images=[],  # placeholder — real images added via Cloudinary
                whatsapp_number=f"+23767{random.randint(1000000, 9999999)}",
                phone_number=f"+23767{random.randint(1000000, 9999999)}",
                is_active=True,
                is_verified=random.choice([True, False]),
                view_count=random.randint(0, 200),
                distance_from_molyko_km=distance_km,
            )
            db.add(prop)

        await db.commit()
        print(f"✅ Seeded 52 properties and 6 users successfully.")
        print(f"   Login: eric.tabi@student.cm / Password123!")
        print(f"   Admin: landlord1@awala.cm / Password123!")

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed())
