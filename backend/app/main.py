from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager

from app.core.config import settings
from app.api.routes import auth, properties, users, search, uploads


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    Path(settings.UPLOAD_DIR).mkdir(parents=True, exist_ok=True)
    (Path(settings.UPLOAD_DIR) / "properties").mkdir(parents=True, exist_ok=True)

    # Startup: configure Meilisearch index settings
    try:
        import meilisearch
        client = meilisearch.Client(settings.MEILI_URL, settings.MEILI_MASTER_KEY)
        index = client.index("properties")
        index.update_searchable_attributes([
            "title", "description", "location_name", "neighborhood", "amenities"
        ])
        index.update_filterable_attributes([
            "type", "price", "furnished", "city", "neighborhood", "is_active", "is_verified"
        ])
        index.update_sortable_attributes(["price", "created_at", "view_count"])
        index.update_ranking_rules([
            "words", "typo", "proximity", "attribute", "sort", "exactness"
        ])
        print("✅ Meilisearch index configured")
    except Exception as e:
        print(f"⚠️  Meilisearch not available: {e}")

    yield
    # Shutdown cleanup (if needed)


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Rapid real estate search engine API for Buea, Cameroon.",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# ─── CORS ─────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_origin_regex=settings.ALLOW_ORIGIN_REGEX,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Routers ──────────────────────────────────────────────────────────
app.include_router(auth.router, prefix="/api/v1")
app.include_router(properties.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(search.router, prefix="/api/v1")
app.include_router(uploads.router, prefix="/api/v1")

app.mount("/static", StaticFiles(directory=settings.UPLOAD_DIR), name="static")


# ─── Health Check ─────────────────────────────────────────────────────
@app.get("/health", tags=["Health"])
async def health():
    return {
        "status": "ok",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }


@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Welcome to Awala RealEstate API 🏠",
        "docs": "/docs",
        "version": settings.APP_VERSION,
    }
