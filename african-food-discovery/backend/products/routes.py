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
