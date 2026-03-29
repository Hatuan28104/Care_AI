from fastapi import FastAPI
from services.self_evolution_service import predict

app = FastAPI()

@app.post("/ai/self-evolution")
def self_evolution(data: dict):
    return predict(data)