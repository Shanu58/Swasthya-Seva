from pydantic import BaseModel


class InteractionCheckRequest(BaseModel):
    medicine_a_id: int
    medicine_b_id: int


class InteractionResult(BaseModel):
    ingredient_a: str
    ingredient_b: str
    severity: str
    description: str


class InteractionCheckResponse(BaseModel):
    medicine_a_id: int
    medicine_b_id: int
    interactions: list[InteractionResult]
