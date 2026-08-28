from pydantic import BaseModel, ConfigDict


class IngredientBase(BaseModel):
    name: str
    standard_name: str | None = None


class IngredientCreate(IngredientBase):
    pass


class IngredientResponse(IngredientBase):
    id: int

    model_config = ConfigDict(from_attributes=True)
