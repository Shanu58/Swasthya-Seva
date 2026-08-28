from pydantic import BaseModel, ConfigDict

from app.models.models import InteractionSeverity


class DrugInteractionCreate(BaseModel):
    ingredient_a_id: int
    ingredient_b_id: int
    severity: InteractionSeverity
    description: str


class DrugInteractionResponse(DrugInteractionCreate):
    id: int

    model_config = ConfigDict(from_attributes=True)
