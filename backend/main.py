from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import google.generativeai as genai
import os
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Setup Gemini - Use environment variable for security
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable is required")

genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("models/gemini-2.0-flash")

# Predefined list of allowed foods
ALLOWED_FOODS = [
    "Arroz blanco cocido", "Arroz integral cocido", "Pan blanco", "Pan integral",
    "Pasta blanca cocida", "Papa cocida", "Camote cocido", "Tortilla de maiz",
    "Tortilla de harina", "Avena cocida", "Quinoa cocida", "Pollo pechuga sin piel",
    "Carne de res magra", "Cerdo lomo", "Salmon", "Atun", "Huevos enteros",
    "Frijoles negros cocidos", "Lentejas cocidas", "Garbanzos cocidos", "Tofu",
    "Brocoli", "Lechuga", "Tomate", "Pepino", "Zanahoria cruda", "Cebolla",
    "Pimiento", "Calabacín", "Apio", "Manzana", "Plátano", "Naranja", "Uvas",
    "Piña", "Mango", "Pera", "Kiwi", "Arándanos", "Leche entera", "Leche descremada",
    "Yogurt natural", "Yogurt griego", "Queso fresco", "Queso cheddar",
    "Queso mozzarella", "Mantequilla", "Aceite de oliva", "Aguacate", "Almendras",
    "Nueces", "Cacahuates", "Semillas de chía", "Aceite de coco", "Agua",
    "Té verde", "Café negro", "Jugo de naranja", "Refresco de cola", "Cerveza",
    "Vino tinto", "Chocolate negro 70%", "Galletas integrales", "Cereales integrales",
    "Granola", "Pizza margarita", "Hamburguesa simple", "Papas fritas",
    "Helado de vainilla", "Miel", "Azúcar blanca", "Mermelada", "Jamón", "Salchicha",
    "Sopa de verduras", "Mantequilla de maní", "Coliflor", "Col rizada (kale)",
    "Ejotes", "Chícharos", "Espárragos", "Berenjenas", "Rábanos", "Acelgas",
    "Champiñones", "Melón cantaloupe", "Sandía", "Papaya", "Durazno", "Ciruela"
]


app = FastAPI(
    title="Swift Challenge Fest API",
    description="Backend API for Swift Challenge Fest",
    version="1.0.0"
)

class HelloResponse(BaseModel):
    message: str
    name: Optional[str] = None

class ExtractFoodsRequest(BaseModel):
    text: str

class ExtractFoodsResponse(BaseModel):
    foods: List[str]

@app.get("/", response_model=HelloResponse)
async def root():
    return HelloResponse(message="Welcome to Swift Challenge Fest API!")

@app.get("/hello/{name}", response_model=HelloResponse)
async def hello_name(name: str):
    return HelloResponse(message=f"Hello, {name}!", name=name)

@app.post("/extract-foods", response_model=ExtractFoodsResponse)
async def extract_foods(request: ExtractFoodsRequest):
    allowed_foods_str = ", ".join(f'"{food}"' for food in ALLOWED_FOODS)
    print(allowed_foods_str)
    prompt = f"""
Tienes una lista de alimentos válidos:

[{allowed_foods_str}]

Del siguiente texto, extrae únicamente los nombres que aparezcan en esa lista. 
Devuélvelos como una lista JSON. No expliques nada.

IMPORTANTE: 
1. La respuesta debe ser SOLO una lista JSON válida
2. Los nombres DEBEN coincidir EXACTAMENTE con los de la lista
3. No agregues comillas extras ni caracteres adicionales
4. NO uses formato markdown ni bloques de código
5. Ejemplo de formato correcto: ["Arroz blanco cocido", "Pan integral"]

Texto: "{request.text}"
"""

    try:
        print("Sending prompt to Gemini:", prompt)  # Debug log
        response = model.generate_content(prompt)
        print("Raw response from Gemini:", response.text)  # Debug log
        
        # Clean the response text
        cleaned_text = response.text.strip()
        # Remove markdown code block formatting if present
        if cleaned_text.startswith("```"):
            cleaned_text = cleaned_text.split("\n", 1)[1]  # Remove first line
        if cleaned_text.endswith("```"):
            cleaned_text = cleaned_text.rsplit("\n", 1)[0]  # Remove last line
        if cleaned_text.startswith("json"):
            cleaned_text = cleaned_text.split("\n", 1)[1]  # Remove json language specifier
        cleaned_text = cleaned_text.strip()
        
        print("Cleaned response:", cleaned_text)  # Debug log
        
        # Parse the JSON response
        foods = json.loads(cleaned_text)
        print("Parsed foods:", foods)  # Debug log
        
        if isinstance(foods, list):
            # Validate that all returned foods are in the allowed list
            valid_foods = [food for food in foods if food in ALLOWED_FOODS]
            print("Valid foods:", valid_foods)  # Debug log
            return ExtractFoodsResponse(foods=valid_foods)
        else:
            print("Response was not a list:", type(foods))  # Debug log
            return ExtractFoodsResponse(foods=[])
            
    except json.JSONDecodeError as e:
        # Log the error in a real application
        print(f"JSON parsing error: {e}")
        print(f"Failed to parse response: {response.text}")  # Debug log
        return ExtractFoodsResponse(foods=[])
    except Exception as e:
        # Log the error in a real application
        error_msg = str(e)
        print(f"Gemini API error: {error_msg}")
        print(f"Error type: {type(e)}")  # Debug log
        
        # Handle specific API errors
        if "429" in error_msg:
            raise HTTPException(
                status_code=429,
                detail="API rate limit exceeded. Please try again later."
            )
        elif "401" in error_msg or "403" in error_msg:
            raise HTTPException(
                status_code=401,
                detail="Invalid API key or authentication error."
            )
        else:
            raise HTTPException(
                status_code=500,
                detail=f"Error processing request: {error_msg}"
            )

@app.get("/api/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)