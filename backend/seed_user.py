import asyncio
import sys

# Add the app directory to the sys path if needed
from app.db.database import AsyncSessionLocal
from app.models.user import User
from app.core.security import hash_password
from sqlalchemy import select

async def seed_user():
    async with AsyncSessionLocal() as session:
        # Check if user exists
        result = await session.execute(select(User).where(User.email == "agborsynthia5@gmail.com"))
        user = result.scalar_one_or_none()
        if user:
            print("User already exists, updating password...")
            user.password_hash = hash_password("synthia123")
            await session.commit()
            print("Password updated successfully.")
            return

        print("Creating user agborsynthia5@gmail.com...")
        new_user = User(
            name="Agbor Synthia",
            email="agborsynthia5@gmail.com",
            phone="+237 678901234",
            password_hash=hash_password("synthia123"),
            role="landlord",
            is_verified=True,
        )
        session.add(new_user)
        await session.commit()
        print("User created successfully with password: synthia123")

if __name__ == "__main__":
    asyncio.run(seed_user())
