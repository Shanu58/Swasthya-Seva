from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.medicine_search import (
    MedicineSearchResponse,
    MedicineSearchResult,
)
from app.services.medicine_search import search_medicines


router = APIRouter(
    prefix="/medicine-search",
    tags=["Medicine Search"],
)


@router.get(
    "/",
    response_model=MedicineSearchResponse,
)
def search_medicine(
    query: str,
    limit: int = 5,
    db: Session = Depends(get_db),
):
    results = search_medicines(
        query=query,
        db=db,
        limit=limit,
    )

    return MedicineSearchResponse(
        query=query,
        results=[
            MedicineSearchResult(
                id=item["medicine"].id,
                name=item["medicine"].name,
                brand=item["medicine"].brand,
                manufacturer=item["medicine"].manufacturer,
                form=item["medicine"].form,
                category=item["medicine"].category,
                price=item["medicine"].price,
                confidence=item["score"],
            )
            for item in results
        ],
    )
