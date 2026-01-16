#!/bin/bash

# African Food Discovery Platform - Complete Project Generator
# Creates full frontend and backend folder structure with all files
# Usage: bash setup_project.sh

set -e  # Exit on any error

echo "��� Creating African Food Discovery Platform Project Structure..."
echo ""

# Create root directory
PROJECT_NAME="african-food-discovery"
rm -rf $PROJECT_NAME  # Remove if exists
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Create .gitignore for project root
cat > .gitignore << 'EOF'
# Environment variables
.env
.env.local
.env.*.local

# Node
node_modules/
dist/
build/

# Python
venv/
__pycache__/
*.pyc
*.pyo
*.egg-info/
.pytest_cache/
.coverage

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
EOF

# Create root README
cat > README.md << 'EOF'
# African Food Discovery Platform

A product-first web application for African diaspora communities to discover African foods and where they are sold in the United States.

## Project Structure

```
african-food-discovery/
├── backend/          # FastAPI server
├── frontend/         # React-Vite app
└── README.md
```

## Quick Start

### Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your database URL
python main.py
```

Backend runs at: http://localhost:8000

### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

Frontend runs at: http://localhost:5173

## Documentation

- [Backend README](./backend/README.md)
- [Frontend README](./frontend/README.md)
- [Database Schema](./backend/SCHEMA.md)
- [API Documentation](./backend/API.md)

## Timeline

- Week 1-2: Planning & Design
- Week 3-4: Backend Foundation
- Week 5-6: Frontend Foundation
- Week 7-8: Core Features
- Week 9-10: Community & Polish
- Week 11: Testing & Optimization
- Week 12: Launch

## Tech Stack

- **Backend:** FastAPI (Python)
- **Frontend:** React 18 + Vite
- **Database:** PostgreSQL
- **Hosting:** Railway (backend), Vercel (frontend)
- **Images:** Cloudinary
- **Maps:** Mapbox or Google Maps

## Team

- [Add your name here]

EOF

echo "��� Creating BACKEND directory structure..."

# ============================================
# BACKEND SETUP
# ============================================

mkdir -p backend
cd backend

# Create subdirectories
mkdir -p {auth,products,places,reviews,qa,search,analytics,migrations,tests}

# ============================================
# Backend: main.py
# ============================================

cat > main.py << 'EOF'
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
    logger.info("✅ Application starting up...")
    yield
    logger.info("��� Application shutting down...")

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
EOF

# ============================================
# Backend: config.py
# ============================================

cat > config.py << 'EOF'
"""
Configuration settings for the application
Load from environment variables
"""

from pydantic_settings import BaseSettings
import os

class Settings(BaseSettings):
    # Database Configuration
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://postgres@localhost:5432/african_food_us"
    )
    
    # JWT Security Configuration
    SECRET_KEY: str = os.getenv(
        "SECRET_KEY",
        "change-this-to-a-long-random-string-in-production"
    )
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Cloudinary Configuration (for image uploads)
    CLOUDINARY_CLOUD_NAME: str = os.getenv("CLOUDINARY_CLOUD_NAME", "")
    CLOUDINARY_API_KEY: str = os.getenv("CLOUDINARY_API_KEY", "")
    CLOUDINARY_API_SECRET: str = os.getenv("CLOUDINARY_API_SECRET", "")
    
    # Application Settings
    APP_NAME: str = "African Food Discovery Platform"
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    ALLOWED_ORIGINS: str = os.getenv(
        "ALLOWED_ORIGINS",
        "http://localhost:5173,http://localhost:3000"
    )
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
EOF

# ============================================
# Backend: database.py
# ============================================

cat > database.py << 'EOF'
"""
Database connection and session management
SQLAlchemy setup for PostgreSQL
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from config import settings

# Create database engine
engine = create_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    pool_pre_ping=True,  # Verify connections before using
    pool_size=10,
    max_overflow=20
)

# Create session factory
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Base class for all models
Base = declarative_base()

# Dependency to get database session
def get_db():
    """
    Dependency injection for database session
    Usage: def my_route(db: Session = Depends(get_db)):
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOF

# ============================================
# Backend: models.py (COMPLETE DATABASE SCHEMA)
# ============================================

cat > models.py << 'EOF'
"""
SQLAlchemy ORM models
Defines all database tables
"""

from sqlalchemy import (
    Column, Integer, String, Float, Boolean, DateTime, 
    Text, ForeignKey, Enum as SQLEnum
)
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

# ============================================
# USERS TABLE
# ============================================

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    first_name = Column(String)
    last_name = Column(String)
    phone = Column(String)
    location_zip = Column(String)
    location_city = Column(String)
    location_state = Column(String)
    preferred_language = Column(String, default="en")
    reputation_score = Column(Integer, default=0)
    verified_shopper = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    reviews = relationship("Review", back_populates="user", cascade="all, delete-orphan")
    qa_questions = relationship("QA", back_populates="user", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="user", cascade="all, delete-orphan")

# ============================================
# PLACES TABLE (Stores, Restaurants, Markets)
# ============================================

class Place(Base):
    __tablename__ = "places"
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, index=True)
    description = Column(Text)
    address = Column(String, nullable=False)
    city = Column(String, nullable=False, index=True)
    state = Column(String)
    zip_code = Column(String)
    country = Column(String, default="US")
    latitude = Column(Float)
    longitude = Column(Float)
    phone = Column(String)
    website_url = Column(String)
    whatsapp_number = Column(String)
    email = Column(String)
    place_type = Column(String)  # grocery, restaurant, butcher, bakery, market
    specialization = Column(String)  # West African, East African, Pan-African
    description_short = Column(Text)
    languages_spoken = Column(Text)  # JSON: ["English", "Yoruba", "Spanish"]
    accepts_cash = Column(Boolean, default=True)
    accepts_card = Column(Boolean, default=True)
    accepts_mobile_payment = Column(Boolean, default=False)
    has_parking = Column(Boolean, default=False)
    delivery_available = Column(Boolean, default=False)
    delivery_services = Column(Text)  # JSON: ["DoorDash", "UberEats"]
    delivery_notes = Column(String)  # Free delivery, minimum order, etc
    
    # Hours (HH:MM-HH:MM format, e.g., "09:00-21:00")
    hours_monday = Column(String)
    hours_tuesday = Column(String)
    hours_wednesday = Column(String)
    hours_thursday = Column(String)
    hours_friday = Column(String)
    hours_saturday = Column(String)
    hours_sunday = Column(String)
    
    # Rating and metrics
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    views_count = Column(Integer, default=0)
    owner_verified = Column(Boolean, default=False)
    owner_name = Column(String)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    products = relationship("PlaceProduct", back_populates="place", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="place", cascade="all, delete-orphan")
    qa = relationship("QA", back_populates="place", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="place", cascade="all, delete-orphan")

# ============================================
# PRODUCTS TABLE
# ============================================

class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, index=True)
    description = Column(Text)
    category = Column(String)  # grains, spices, proteins, produce, pantry
    cuisine_region = Column(String)  # West African, East African, Southern African
    english_name = Column(String)
    alternative_names = Column(Text)  # JSON: ["Gari", "Fermented cassava"]
    spanish_name = Column(String)
    brand = Column(String)
    origin_country = Column(String)  # Ghana, Nigeria, Cameroon, etc
    image_url = Column(String)
    image_thumbnail_url = Column(String)
    search_keywords = Column(Text)  # For SEO: "cassava, gari, flour"
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    places = relationship("PlaceProduct", back_populates="product", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="product", cascade="all, delete-orphan")
    qa = relationship("QA", back_populates="product", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="product", cascade="all, delete-orphan")

# ============================================
# PLACE_PRODUCTS TABLE (Inventory Mapping)
# ============================================

class PlaceProduct(Base):
    __tablename__ = "place_products"
    
    id = Column(Integer, primary_key=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False, index=True)
    
    # Availability (not real-time, just "commonly available here?")
    commonly_available = Column(Boolean, default=True)
    typical_price = Column(Float)
    currency = Column(String, default="USD")
    notes = Column(String)  # "Fresh on weekends", "Frozen only", etc
    last_verified_at = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    place = relationship("Place", back_populates="products")
    product = relationship("Product", back_populates="places")

# ============================================
# REVIEWS TABLE
# ============================================

class Review(Base):
    __tablename__ = "reviews"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    
    # Review content
    rating = Column(Integer, nullable=False)  # 1-5
    title = Column(String)
    review_text = Column(Text, nullable=False)
    review_type = Column(String)  # general, product_availability, freshness, service, pricing
    
    # Product-specific fields
    product_availability = Column(String)  # In stock, Out of stock, Just arrived
    freshness_rating = Column(String)  # Fresh today, Looks good, Older stock
    
    # Media
    photos = Column(Text)  # JSON array of URLs
    photo_count = Column(Integer, default=0)
    
    # Engagement
    helpful_count = Column(Integer, default=0)
    unhelpful_count = Column(Integer, default=0)
    
    # Moderation
    approved = Column(Boolean, default=False)
    flagged = Column(Boolean, default=False)
    flag_reason = Column(String)
    
    # Owner response
    owner_response = Column(Text)
    owner_response_date = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="reviews")
    place = relationship("Place", back_populates="reviews")
    product = relationship("Product", back_populates="reviews")

# ============================================
# QA TABLE (Questions)
# ============================================

class QA(Base):
    __tablename__ = "qa"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True, index=True)
    
    question_text = Column(Text, nullable=False)
    question_category = Column(String)  # product, place, delivery, availability, recommendation
    
    # Engagement
    answer_count = Column(Integer, default=0)
    answered = Column(Boolean, default=False)
    helpful_count = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="qa_questions")
    place = relationship("Place", back_populates="qa")
    product = relationship("Product", back_populates="qa")
    answers = relationship("QAAnswer", back_populates="qa", cascade="all, delete-orphan")

# ============================================
# QA_ANSWERS TABLE (Answers to Questions)
# ============================================

class QAAnswer(Base):
    __tablename__ = "qa_answers"
    
    id = Column(Integer, primary_key=True)
    qa_id = Column(Integer, ForeignKey("qa.id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    answer_text = Column(Text, nullable=False)
    place_verified = Column(Boolean, default=False)
    helpful_count = Column(Integer, default=0)
    unhelpful_count = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    qa = relationship("QA", back_populates="answers")

# ============================================
# FAVORITES TABLE (Bookmarks)
# ============================================

class Favorite(Base):
    __tablename__ = "favorites"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="favorites")
    place = relationship("Place", back_populates="favorites")
    product = relationship("Product", back_populates="favorites")

# ============================================
# ANALYTICS_EVENTS TABLE
# ============================================

class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    event_type = Column(String, nullable=False, index=True)  # product_search, place_view, click_directions
    search_query = Column(String)
    
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=True)
    
    location_zip = Column(String)
    location_city = Column(String)
    location_state = Column(String)
    
    user_device = Column(String)  # mobile, desktop
    event_data = Column(Text)  # JSON for additional context
    
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
EOF

# ============================================
# Backend: requirements.txt
# ============================================

cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
pydantic==2.5.0
pydantic-settings==2.1.0
python-multipart==0.0.6
python-jose==3.3.0
passlib==1.7.4
bcrypt==4.1.1
pyjwt==2.8.1
email-validator==2.1.0
cloudinary==1.36.0
python-dotenv==1.0.0
pytest==7.4.3
httpx==0.25.2
cors==1.0.1
EOF

# ============================================
# Backend: .env.example
# ============================================

cat > .env.example << 'EOF'
# Database Configuration
DATABASE_URL=postgresql://postgres@localhost:5432/african_food_us

# JWT Security (change these in production!)
SECRET_KEY=your-super-secret-key-at-least-32-characters-long-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Cloudinary (for image uploads)
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Application
DEBUG=True
PORT=8000
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
EOF

# ============================================
# Backend: Create route placeholder files
# ============================================

cat > auth/__init__.py << 'EOF'
"""Authentication module"""
EOF

cat > auth/routes.py << 'EOF'
"""
Authentication routes
Handles user signup, login, token refresh
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement auth routes
# POST /auth/register - User signup
# POST /auth/login - User login
# GET /auth/me - Get current user
# POST /auth/logout - Logout
# POST /auth/refresh - Refresh token
EOF

cat > products/__init__.py << 'EOF'
"""Products module"""
EOF

cat > products/routes.py << 'EOF'
"""
Product routes
Handles product search, listing, and details
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement product routes
# GET /products - List all products
# GET /products/search - Search products
# GET /products/{id} - Get product details
# GET /products/{id}/places - Get places carrying product
# POST /products - Create product (admin only)
EOF

cat > places/__init__.py << 'EOF'
"""Places module (Stores, Restaurants, etc)"""
EOF

cat > places/routes.py << 'EOF'
"""
Place routes
Handles store/restaurant listings and details
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement place routes
# GET /places - List places with filters
# GET /places/search - Search places
# GET /places/{id} - Get place details
# GET /places/{id}/products - Get products at place
# POST /places - Create place (admin/owner only)
# PUT /places/{id} - Update place
EOF

cat > reviews/__init__.py << 'EOF'
"""Reviews module"""
EOF

cat > reviews/routes.py << 'EOF'
"""
Review routes
Handles review creation, display, and moderation
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement review routes
# GET /places/{id}/reviews - Get place reviews
# POST /places/{id}/reviews - Create review
# GET /products/{id}/reviews - Get product reviews
# POST /products/{id}/reviews - Create product review
# PUT /reviews/{id} - Edit review
# DELETE /reviews/{id} - Delete review
# POST /reviews/{id}/helpful - Mark helpful
EOF

cat > qa/__init__.py << 'EOF'
"""Q&A module"""
EOF

cat > qa/routes.py << 'EOF'
"""
Q&A routes
Handles questions, answers, and voting
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement Q&A routes
# GET /places/{id}/qa - Get place Q&A
# POST /places/{id}/qa - Ask question about place
# GET /products/{id}/qa - Get product Q&A
# POST /products/{id}/qa - Ask question about product
# POST /qa/{id}/answers - Answer question
# POST /qa/{id}/answers/{aid}/helpful - Mark answer helpful
EOF

cat > search/__init__.py << 'EOF'
"""Search module"""
EOF

cat > search/routes.py << 'EOF'
"""
Search routes
Combined product and place search
"""

from fastapi import APIRouter, Query, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement search routes
# GET /search - Combined search (products + places)
#   Query params: q, zip, radius, place_type, delivery_only, limit
EOF

cat > analytics/__init__.py << 'EOF'
"""Analytics module"""
EOF

cat > analytics/routes.py << 'EOF'
"""
Analytics routes
Event tracking for user behavior
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db

router = APIRouter()

# TODO: Implement analytics routes
# POST /analytics/events - Track event (async)
EOF

# ============================================
# Backend: README.md
# ============================================

cat > README.md << 'EOF'
# African Food Discovery Platform - Backend

FastAPI backend for the African Food Discovery Platform.

## Quick Start

### 1. Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Setup Database
```bash
# Create PostgreSQL database
createdb african_food_us

# Copy environment file
cp .env.example .env

# Edit .env with your database credentials and API keys
nano .env
```

### 4. Create Database Tables
```bash
python init_db.py
```

### 5. Run Server
```bash
python main.py
```

Server will run at: **http://localhost:8000**

## API Documentation

- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **Health Check:** http://localhost:8000/health

## Project Structure

```
backend/
├── main.py                 # Entry point
├── config.py              # Configuration
├── database.py            # Database setup
├── models.py              # SQLAlchemy models
├── requirements.txt       # Python dependencies
├── .env.example          # Environment template
├── auth/                 # Authentication
│   ├── routes.py
│   └── __init__.py
├── products/             # Product endpoints
│   ├── routes.py
│   └── __init__.py
├── places/               # Place endpoints
│   ├── routes.py
│   └── __init__.py
├── reviews/              # Review endpoints
│   ├── routes.py
│   └── __init__.py
├── qa/                   # Q&A endpoints
│   ├── routes.py
│   └── __init__.py
├── search/               # Search endpoints
│   ├── routes.py
│   └── __init__.py
├── analytics/            # Analytics endpoints
│   ├── routes.py
│   └── __init__.py
└── tests/                # Tests
```

## Key Endpoints

### Authentication
- `POST /api/auth/register` - Signup
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Current user

### Products
- `GET /api/products` - List products
- `GET /api/products/search` - Search products
- `GET /api/products/{id}` - Product details
- `GET /api/products/{id}/places` - Places carrying product

### Places
- `GET /api/places` - List places
- `GET /api/places/{id}` - Place details
- `GET /api/places/{id}/products` - Products at place

### Reviews
- `GET /api/places/{id}/reviews` - Place reviews
- `POST /api/places/{id}/reviews` - Create review

### Q&A
- `GET /api/places/{id}/qa` - Q&A for place
- `POST /api/places/{id}/qa` - Ask question

### Search
- `GET /api/search` - Combined search

See [API.md](./API.md) for full documentation.

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| DATABASE_URL | PostgreSQL connection string | Yes |
| SECRET_KEY | JWT signing key | Yes |
| CLOUDINARY_CLOUD_NAME | Cloudinary cloud name | Yes |
| CLOUDINARY_API_KEY | Cloudinary API key | Yes |
| CLOUDINARY_API_SECRET | Cloudinary API secret | Yes |
| DEBUG | Enable debug mode | No |
| PORT | Server port | No |
| ALLOWED_ORIGINS | CORS origins (comma-separated) | No |

## Development

### Run Tests
```bash
pytest
```

### Database Migrations
```bash
# Create migration
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

## Troubleshooting

### Database Connection Error
```bash
# Check PostgreSQL is running
psql -U postgres

# Verify DATABASE_URL format
DATABASE_URL=postgresql://user:password@localhost:5432/african_food_us
```

### Module Not Found
```bash
# Reinstall dependencies
pip install -r requirements.txt
```

## Next Steps

1. Implement authentication routes (`auth/routes.py`)
2. Implement product endpoints (`products/routes.py`)
3. Implement place endpoints (`places/routes.py`)
4. Implement review system (`reviews/routes.py`)
5. Implement Q&A system (`qa/routes.py`)
6. Implement search (`search/routes.py`)
7. Implement analytics (`analytics/routes.py`)
8. Write tests (`tests/`)
9. Deploy to production

EOF

# Create init_db.py file
cat > init_db.py << 'EOF'
"""
Initialize database - Create all tables
Run this once to set up the database schema
"""

from database import engine
import models

def init_db():
    """Create all database tables"""
    models.Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully!")

if __name__ == "__main__":
    init_db()
EOF

# Back to root
cd ..

echo "✅ Backend setup complete!"
echo ""
echo "��� Creating FRONTEND directory structure..."

# ============================================
# FRONTEND SETUP
# ============================================

# Create frontend with Vite (non-interactive)
npm create vite@latest frontend -- --template react --no-save

cd frontend

# Install dependencies
npm install axios react-router-dom

echo "✅ Installing frontend dependencies..."

# ============================================
# Frontend: Environment files
# ============================================

cat > .env.development << 'EOF'
VITE_API_URL=http://localhost:8000/api
VITE_CLOUDINARY_CLOUD_NAME=your-cloud-name
EOF

cat > .env.production << 'EOF'
VITE_API_URL=https://your-backend.railway.app/api
VITE_CLOUDINARY_CLOUD_NAME=your-cloud-name
EOF

# ============================================
# Frontend: Create directories
# ============================================

mkdir -p src/{pages,components,services,hooks,context,styles,utils,assets/{images,icons}}

# ============================================
# Frontend: API Services
# ============================================

cat > src/services/api.js << 'EOF'
/**
 * API Client Setup
 * Configures axios for all API calls with JWT token handling
 */

import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add JWT token to all requests
apiClient.interceptors.request.use(
  (config) => {
    const token = sessionStorage.getItem('authToken')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Handle 401 (token expired)
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      sessionStorage.removeItem('authToken')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default apiClient
EOF

cat > src/services/auth.js << 'EOF'
/**
 * Authentication API calls
 */

import apiClient from './api'

export const signup = async (email, username, password, firstName, lastName) => {
  const response = await apiClient.post('/auth/register', {
    email,
    username,
    password,
    first_name: firstName,
    last_name: lastName,
  })
  return response.data
}

export const login = async (email, password) => {
  const response = await apiClient.post('/auth/login', { email, password })
  return response.data
}

export const getCurrentUser = async () => {
  const response = await apiClient.get('/auth/me')
  return response.data
}

export const logout = async () => {
  await apiClient.post('/auth/logout')
}
EOF

cat > src/services/products.js << 'EOF'
/**
 * Product API calls
 */

import apiClient from './api'

export const searchProducts = async (query, params = {}) => {
  const response = await apiClient.get('/products/search', {
    params: { q: query, ...params },
  })
  return response.data
}

export const getProduct = async (productId) => {
  const response = await apiClient.get(`/products/${productId}`)
  return response.data
}

export const getProductPlaces = async (productId) => {
  const response = await apiClient.get(`/products/${productId}/places`)
  return response.data
}
EOF

cat > src/services/places.js << 'EOF'
/**
 * Place API calls (Stores, Restaurants, Markets)
 */

import apiClient from './api'

export const getPlaces = async (params = {}) => {
  const response = await apiClient.get('/places', { params })
  return response.data
}

export const getPlace = async (placeId) => {
  const response = await apiClient.get(`/places/${placeId}`)
  return response.data
}

export const getPlaceProducts = async (placeId) => {
  const response = await apiClient.get(`/places/${placeId}/products`)
  return response.data
}
EOF

cat > src/services/search.js << 'EOF'
/**
 * Combined search API calls
 */

import apiClient from './api'

export const search = async (query, params = {}) => {
  const response = await apiClient.get('/search', {
    params: { q: query, ...params },
  })
  return response.data
}
EOF

cat > src/services/reviews.js << 'EOF'
/**
 * Review API calls
 */

import apiClient from './api'

export const getPlaceReviews = async (placeId, params = {}) => {
  const response = await apiClient.get(`/places/${placeId}/reviews`, { params })
  return response.data
}

export const createReview = async (placeId, reviewData) => {
  const response = await apiClient.post(`/places/${placeId}/reviews`, reviewData)
  return response.data
}

export const markReviewHelpful = async (reviewId) => {
  const response = await apiClient.post(`/reviews/${reviewId}/helpful`)
  return response.data
}
EOF

cat > src/services/qa.js << 'EOF'
/**
 * Q&A API calls
 */

import apiClient from './api'

export const getPlaceQA = async (placeId, params = {}) => {
  const response = await apiClient.get(`/places/${placeId}/qa`, { params })
  return response.data
}

export const askQuestion = async (placeId, questionData) => {
  const response = await apiClient.post(`/places/${placeId}/qa`, questionData)
  return response.data
}

export const answerQuestion = async (qaId, answerData) => {
  const response = await apiClient.post(`/qa/${qaId}/answers`, answerData)
  return response.data
}
EOF

# ============================================
# Frontend: Hooks
# ============================================

cat > src/hooks/useAuth.js << 'EOF'
/**
 * Authentication Hook
 */

import { useState, useEffect } from 'react'

export const useAuth = () => {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const storedToken = sessionStorage.getItem('authToken')
    if (storedToken) {
      setToken(storedToken)
    }
    setLoading(false)
  }, [])

  const login = (userData, authToken) => {
    setUser(userData)
    setToken(authToken)
    sessionStorage.setItem('authToken', authToken)
  }

  const logout = () => {
    setUser(null)
    setToken(null)
    sessionStorage.removeItem('authToken')
  }

  return { user, token, loading, login, logout }
}
EOF

# ============================================
# Frontend: Pages
# ============================================

cat > src/pages/HomePage.jsx << 'EOF'
/**
 * Home Page
 */

export default function HomePage() {
  return (
    <div className="home-page">
      <h1>African Food Discovery</h1>
      <p>Find African foods in the United States</p>
      {/* TODO: Add search bar and featured content */}
    </div>
  )
}
EOF

cat > src/pages/ProductSearchPage.jsx << 'EOF'
/**
 * Product Search Results Page
 */

export default function ProductSearchPage() {
  return (
    <div className="search-page">
      <h1>Search Results</h1>
      {/* TODO: Add search results */}
    </div>
  )
}
EOF

cat > src/pages/ProductDetailPage.jsx << 'EOF'
/**
 * Single Product Detail Page
 */

export default function ProductDetailPage() {
  return (
    <div className="product-page">
      <h1>Product Details</h1>
      {/* TODO: Add product info */}
    </div>
  )
}
EOF

cat > src/pages/PlaceDetailPage.jsx << 'EOF'
/**
 * Single Place Detail Page
 */

export default function PlaceDetailPage() {
  return (
    <div className="place-page">
      <h1>Place Details</h1>
      {/* TODO: Add place info */}
    </div>
  )
}
EOF

cat > src/pages/MapPage.jsx << 'EOF'
/**
 * Map View Page
 */

export default function MapPage() {
  return (
    <div className="map-page">
      <h1>Map View</h1>
      {/* TODO: Add map */}
    </div>
  )
}
EOF

cat > src/pages/LoginPage.jsx << 'EOF'
/**
 * Login Page
 */

export default function LoginPage() {
  return (
    <div className="login-page">
      <h1>Login</h1>
      {/* TODO: Add login form */}
    </div>
  )
}
EOF

# ============================================
# Frontend: Components
# ============================================

cat > src/components/Header.jsx << 'EOF'
/**
 * Header Component
 */

export default function Header() {
  return (
    <header className="header">
      <h1>African Food Discovery</h1>
    </header>
  )
}
EOF

cat > src/components/BottomNav.jsx << 'EOF'
/**
 * Bottom Navigation
 * 5 tabs: Home, Map, Saved, Community, Account
 */

import { Link } from 'react-router-dom'

export default function BottomNav() {
  return (
    <nav className="bottom-nav">
      <Link to="/">Home</Link>
      <Link to="/map">Map</Link>
      <Link to="/saved">Saved</Link>
      <Link to="/community">Community</Link>
      <Link to="/account">Account</Link>
    </nav>
  )
}
EOF

# ============================================
# Frontend: App.jsx
# ============================================

cat > src/App.jsx << 'EOF'
/**
 * Root App Component
 * Main routing and layout
 */

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import HomePage from './pages/HomePage'
import ProductSearchPage from './pages/ProductSearchPage'
import ProductDetailPage from './pages/ProductDetailPage'
import PlaceDetailPage from './pages/PlaceDetailPage'
import MapPage from './pages/MapPage'
import LoginPage from './pages/LoginPage'
import Header from './components/Header'
import BottomNav from './components/BottomNav'
import './App.css'

function App() {
  return (
    <Router>
      <div className="app">
        <Header />
        <main className="main-content">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/search" element={<ProductSearchPage />} />
            <Route path="/products/:id" element={<ProductDetailPage />} />
            <Route path="/places/:id" element={<PlaceDetailPage />} />
            <Route path="/map" element={<MapPage />} />
            <Route path="/login" element={<LoginPage />} />
          </Routes>
        </main>
        <BottomNav />
      </div>
    </Router>
  )
}

export default App
EOF

# ============================================
# Frontend: App.css
# ============================================

cat > src/App.css << 'EOF'
:root {
  --color-primary: #B8472C;
  --color-secondary: #1B5E2D;
  --color-accent: #D4AF37;
  --color-light: #F5EFE0;
  
  --font-header: 'Montserrat', sans-serif;
  --font-body: 'Inter', sans-serif;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-body);
  background-color: #ffffff;
  color: #333;
}

.app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.header {
  background-color: var(--color-primary);
  color: white;
  padding: 1rem;
  text-align: center;
}

.header h1 {
  font-family: var(--font-header);
  font-size: 1.5rem;
}

.main-content {
  flex: 1;
  padding: 1rem;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}

.bottom-nav {
  display: flex;
  justify-content: space-around;
  background-color: var(--color-secondary);
  padding: 0.5rem 0;
  position: fixed;
  bottom: 0;
  width: 100%;
  left: 0;
  right: 0;
}

.bottom-nav a {
  color: white;
  text-decoration: none;
  padding: 0.75rem;
  flex: 1;
  text-align: center;
  font-weight: 500;
}

.bottom-nav a:hover {
  background-color: var(--color-primary);
}

/* Responsive Design */
@media (max-width: 768px) {
  .main-content {
    padding: 0.5rem;
    margin-bottom: 70px;
  }
  
  .header h1 {
    font-size: 1.25rem;
  }
}
EOF

# ============================================
# Frontend: README.md
# ============================================

cat > README.md << 'EOF'
# African Food Discovery Platform - Frontend

React + Vite frontend for the African Food Discovery Platform.

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Setup Environment
```bash
# Development
cp .env.development .env.development

# Production
cp .env.production .env.production
```

### 3. Run Development Server
```bash
npm run dev
```

Frontend will run at: **http://localhost:5173**

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Project Structure

```
frontend/
├── src/
│   ├── pages/              # Page components
│   │   ├── HomePage.jsx
│   │   ├── ProductSearchPage.jsx
│   │   ├── ProductDetailPage.jsx
│   │   ├── PlaceDetailPage.jsx
│   │   ├── MapPage.jsx
│   │   └── LoginPage.jsx
│   ├── components/         # Reusable components
│   │   ├── Header.jsx
│   │   └── BottomNav.jsx
│   ├── services/           # API calls
│   │   ├── api.js
│   │   ├── auth.js
│   │   ├── products.js
│   │   ├── places.js
│   │   ├── search.js
│   │   ├── reviews.js
│   │   └── qa.js
│   ├── hooks/              # React hooks
│   │   └── useAuth.js
│   ├── context/            # Context/state
│   ├── styles/             # CSS files
│   ├── utils/              # Utilities
│   ├── assets/             # Images, icons
│   ├── App.jsx
│   ├── App.css
│   └── main.jsx
├── .env.development        # Dev environment
├── .env.production         # Prod environment
├── vite.config.js
└── package.json
```

## Key Pages

- **Home Page** (`/`) - Search and featured content
- **Search Results** (`/search`) - Product search results
- **Product Detail** (`/products/:id`) - Single product
- **Place Detail** (`/places/:id`) - Store/restaurant details
- **Map** (`/map`) - Interactive map view
- **Login** (`/login`) - User authentication

## Services

### Authentication
- `signup()` - User registration
- `login()` - User login
- `getCurrentUser()` - Get current user
- `logout()` - Logout

### Products
- `searchProducts()` - Search for products
- `getProduct()` - Get product details
- `getProductPlaces()` - Get places with product

### Places
- `getPlaces()` - List places
- `getPlace()` - Get place details
- `getPlaceProducts()` - Get products at place

### Reviews
- `getPlaceReviews()` - Get place reviews
- `createReview()` - Create new review
- `markReviewHelpful()` - Mark helpful

### Q&A
- `getPlaceQA()` - Get Q&A for place
- `askQuestion()` - Ask new question
- `answerQuestion()` - Answer question

## Environment Variables

| Variable | Description |
|----------|-------------|
| VITE_API_URL | Backend API base URL |
| VITE_CLOUDINARY_CLOUD_NAME | Cloudinary cloud name |

## Building for Production

```bash
npm run build
```

This creates an optimized build in the `dist/` folder.

## Deployment

### Vercel (Recommended)
```bash
npm i -g vercel
vercel
```

### Manual
1. Run `npm run build`
2. Deploy `dist/` folder to any static hosting
3. Set environment variables in hosting platform

## Troubleshooting

### API Connection Error
- Check `VITE_API_URL` in `.env.development`
- Ensure backend is running on `http://localhost:8000`

### Build Error
- Delete `node_modules/` and `package-lock.json`
- Run `npm install` again
- Try `npm run build`

## Next Steps

1. Implement search functionality
2. Build product detail page
3. Build place detail page
4. Implement review system
5. Add authentication
6. Integrate map
7. Mobile optimization
8. Deploy to production

EOF

# Back to root
cd ..

echo "✅ Frontend setup complete!"
echo ""
echo "════════════════════════════════════════════════════════"
echo "��� PROJECT SETUP COMPLETE!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Project created: ./$PROJECT_NAME/"
echo ""
echo "��� NEXT STEPS:"
echo ""
echo "1️⃣  BACKEND SETUP"
echo "   cd $PROJECT_NAME/backend"
echo "   python3 -m venv venv"
echo "   source venv/bin/activate"
echo "   pip install -r requirements.txt"
echo "   cp .env.example .env"
echo "   # Edit .env with database URL"
echo "   createdb african_food_us"
echo "   python init_db.py"
echo "   python main.py"
echo ""
echo "2️⃣  FRONTEND SETUP (in new terminal)"
echo "   cd $PROJECT_NAME/frontend"
echo "   npm run dev"
echo ""
echo "3️⃣  OPEN IN BROWSER"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
echo ""
echo "════════════════════════════════════════════════════════"
