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

