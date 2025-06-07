# Swift Challenge Fest Backend

This is the backend API for the Swift Challenge Fest project, built with FastAPI.

## Setup

1. Create a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the Server

To run the development server:
```bash
uvicorn main:app --reload
```

The server will start at `http://localhost:8000`

## API Documentation

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Available Endpoints

- `GET /`: Root endpoint that returns a welcome message
- `GET /hello/{name}`: Returns a personalized hello message 