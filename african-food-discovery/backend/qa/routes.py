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
