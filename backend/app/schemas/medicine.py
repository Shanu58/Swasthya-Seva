from decimal import Decimal

from pydantic import BaseModel, ConfigDict


class MedicineBase(BaseModel):
    name: str
    brand: str | None = None
    manufacturer: str | None = None
    form: str | None = None
    category: str | None = None
    price: Decimal | None = None


class MedicineCreate(MedicineBase):
    pass


class MedicineResponse(MedicineBase):
    id: int

    model_config = ConfigDict(from_attributes=True)


class MedicineIngredientDetail(BaseModel):
    id: int
    name: str
    standard_name: str | None = None
    strength: str | None = None


class MedicineDetailResponse(MedicineResponse):
    ingredients: list[MedicineIngredientDetail]
    active_ingredients: list[str] = []
    usage: str = "Not available"
    dosage: str = "Follow the directions on the label or advice from your doctor or pharmacist."
    food_guidance: str = "Follow label instructions and consult a healthcare professional if unsure."
    warnings: list[str] = []
    interaction_warnings: list[str] = []
    data_source: str = "local_dataset"
