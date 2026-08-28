from decimal import Decimal

from pydantic import BaseModel


class MedicineSearchResult(BaseModel):
    id: int
    name: str
    brand: str | None = None
    manufacturer: str | None = None
    form: str | None = None
    category: str | None = None
    price: Decimal | None = None
    confidence: float


class MedicineSearchResponse(BaseModel):
    query: str
    results: list[MedicineSearchResult]
