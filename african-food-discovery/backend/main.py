"""
African Food Discovery Platform - FastAPI Backend
Main entry point for the API server
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
import logging
import os

from config import settings
from database import engine
import models

# Create database tables
models.Base.metadata.create_all(bind=engine)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("âœ… Application starting up...")
    yield
    logger.info("í»‘ Application shutting down...")

app = FastAPI(
    title="African Food Discovery Platform API",
    description="API for discovering African food in the United States",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Middleware - Allow frontend to call backend
allowed_origins = os.getenv(
    "ALLOWED_ORIGINS",
    "http://localhost:5173,http://localhost:3000"
).split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Trusted Host Middleware - Security
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["localhost", "127.0.0.1"]
)

# TODO: Include routers when ready
# from auth import routes as auth_routes
# from products import routes as product_routes
# from places import routes as place_routes
# from reviews import routes as review_routes
# from qa import routes as qa_routes
# from search import routes as search_routes
# from analytics import routes as analytics_routes

# app.include_router(auth_routes.router, prefix="/api/auth", tags=["auth"])
# app.include_router(product_routes.router, prefix="/api/products", tags=["products"])
# app.include_router(place_routes.router, prefix="/api/places", tags=["places"])
# app.include_router(review_routes.router, prefix="/api/reviews", tags=["reviews"])
# app.include_router(qa_routes.router, prefix="/api/qa", tags=["qa"])
# app.include_router(search_routes.router, prefix="/api/search", tags=["search"])
# app.include_router(analytics_routes.router, prefix="/api/analytics", tags=["analytics"])

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint - used for monitoring"""
    return {"status": "ok", "message": "API is running"}

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API info"""
    return {
        "message": "Welcome to African Food Discovery Platform API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
