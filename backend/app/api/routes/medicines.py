from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Medicine, MedicineIngredient
from app.schemas.medicine import (
    MedicineCreate,
    MedicineDetailResponse,
    MedicineIngredientDetail,
    MedicineResponse,
)


router = APIRouter(
    prefix="/medicines",
    tags=["Medicines"],
)


@router.post(
    "/",
    response_model=MedicineResponse,
    status_code=201,
)
def create_medicine(
    medicine: MedicineCreate,
    db: Session = Depends(get_db),
):
    existing_medicine = (
        db.query(Medicine)
        .filter(Medicine.name == medicine.name)
        .first()
    )

    if existing_medicine:
        raise HTTPException(
            status_code=400,
            detail="Medicine already exists",
        )

    new_medicine = Medicine(
        **medicine.model_dump()
    )

    db.add(new_medicine)
    db.commit()
    db.refresh(new_medicine)

    return new_medicine


@router.get(
    "/",
    response_model=list[MedicineResponse],
)
def get_medicines(
    db: Session = Depends(get_db),
):
    medicines = db.query(Medicine).all()

    return medicines


@router.get(
    "/{medicine_id}",
    response_model=MedicineDetailResponse,
)
def get_medicine(
    medicine_id: int,
    db: Session = Depends(get_db),
):
    medicine = (
        db.query(Medicine)
        .filter(Medicine.id == medicine_id)
        .first()
    )

    if not medicine:
        raise HTTPException(
            status_code=404,
            detail="Medicine not found",
        )

    ingredient_links = (
        db.query(MedicineIngredient)
        .filter(
            MedicineIngredient.medicine_id == medicine_id
        )
        .all()
    )

    ingredients = [
        MedicineIngredientDetail(
            id=link.ingredient.id,
            name=link.ingredient.name,
            standard_name=link.ingredient.standard_name,
            strength=link.strength,
        )
        for link in ingredient_links
    ]

    return MedicineDetailResponse(
        id=medicine.id,
        name=medicine.name,
        brand=medicine.brand,
        manufacturer=medicine.manufacturer,
        form=medicine.form,
        category=medicine.category,
        price=medicine.price,
        ingredients=ingredients,
    )
