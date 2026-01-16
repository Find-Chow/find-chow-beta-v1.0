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
