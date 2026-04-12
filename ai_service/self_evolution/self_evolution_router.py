from fastapi import APIRouter, Request, Depends
from self_evolution.schema import HealthDataInput, HealthEvaluationResponse
from self_evolution.self_evolution_service import SelfEvolutionService

router = APIRouter(prefix="/self", tags=["Self Evolution"])

def get_self_evolution_service(request: Request) -> SelfEvolutionService:
    model_bundle = getattr(request.app.state, "model_bundle", None)
    return SelfEvolutionService(model_bundle)

@router.post("/self_evolution", response_model=HealthEvaluationResponse)
def self_evolution(
    data: HealthDataInput, 
    service: SelfEvolutionService = Depends(get_self_evolution_service)
):
    return service.predict(data)
