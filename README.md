# Awala RealEstate Monorepo

```
awala-realestate/
├── mobile/              # Flutter mobile app (Android + iOS)
├── backend/             # FastAPI backend
│   ├── app/
│   │   ├── api/routes/  # auth, properties, users, search
│   │   ├── core/        # config, security
│   │   ├── db/          # database session
│   │   ├── models/      # SQLAlchemy models
│   │   └── schemas/     # Pydantic schemas
│   ├── db/init.sql      # PostgreSQL + PostGIS schema
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .env.example
├── scripts/
│   └── seed_data.py     # 52 realistic Buea listings
└── docker-compose.yml   # PostgreSQL, Redis, Meilisearch, FastAPI
```

## Quick Start (Local Dev)

### 1. Clone & setup environment
```bash
cd awala-realestate/backend
cp .env.example .env
# Edit .env with your Cloudinary credentials
```

### 2. Start all services
```bash
docker-compose up -d
```

### 3. Seed the database
```bash
cd backend
pip install -r requirements.txt
python ../scripts/seed_data.py
```

### 4. View API docs
Open http://localhost:8001/docs

### 5. Run Flutter app
```bash
cd mobile
flutter pub get
flutter run
```

## Services
| Service | URL |
|---|---|
| FastAPI API | http://localhost:8001 |
| Swagger Docs | http://localhost:8001/docs |
| Meilisearch | http://localhost:7700 |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |

## Test Credentials (after seeding)
| Role | Email | Password |
|---|---|---|
| Student | eric.tabi@student.cm | Password123! |
| Landlord | landlord1@awala.cm | Password123! |
