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
