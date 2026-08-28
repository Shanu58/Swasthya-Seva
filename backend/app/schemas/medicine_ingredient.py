from pydantic import BaseModel, ConfigDict


class MedicineIngredientCreate(BaseModel):
    medicine_id: int
    ingredient_id: int
    strength: str | None = None


class MedicineIngredientResponse(MedicineIngredientCreate):
    id: int

    model_config = ConfigDict(from_attributes=True)
