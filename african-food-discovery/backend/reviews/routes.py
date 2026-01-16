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
