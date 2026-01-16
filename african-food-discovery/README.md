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

