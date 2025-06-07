from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional

app = FastAPI(
    title="Swift Challenge Fest API",
    description="Backend API for Swift Challenge Fest",
    version="1.0.0"
)

class HelloResponse(BaseModel):
    message: str
    name: Optional[str] = None

@app.get("/", response_model=HelloResponse)
async def root():
    """
    Root endpoint that returns a hello message.
    """
    return HelloResponse(message="Welcome to Swift Challenge Fest API!")

@app.get("/hello/{name}", response_model=HelloResponse)
async def hello_name(name: str):
    """
    Endpoint that returns a personalized hello message.
    """
    return HelloResponse(message=f"Hello, {name}!", name=name)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 