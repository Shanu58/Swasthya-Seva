from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Medicine, Ingredient, MedicineIngredient
from app.schemas.medicine_ingredient import (
    MedicineIngredientCreate,
    MedicineIngredientResponse,
)


router = APIRouter(
    prefix="/medicine-ingredients",
    tags=["Medicine Ingredients"],
)


@router.post(
    "/",
    response_model=MedicineIngredientResponse,
    status_code=201,
)
def add_ingredient_to_medicine(
    medicine_ingredient: MedicineIngredientCreate,
    db: Session = Depends(get_db),
):
    medicine = (
        db.query(Medicine)
        .filter(Medicine.id == medicine_ingredient.medicine_id)
        .first()
    )

    if not medicine:
        raise HTTPException(
            status_code=404,
            detail="Medicine not found",
        )

    ingredient = (
        db.query(Ingredient)
        .filter(Ingredient.id == medicine_ingredient.ingredient_id)
        .first()
    )

    if not ingredient:
        raise HTTPException(
            status_code=404,
            detail="Ingredient not found",
        )

    existing_link = (
        db.query(MedicineIngredient)
        .filter(
            MedicineIngredient.medicine_id
            == medicine_ingredient.medicine_id,
            MedicineIngredient.ingredient_id
            == medicine_ingredient.ingredient_id,
        )
        .first()
    )

    if existing_link:
        raise HTTPException(
            status_code=400,
            detail="Ingredient already linked to this medicine",
        )

    new_link = MedicineIngredient(
        **medicine_ingredient.model_dump()
    )

    db.add(new_link)
    db.commit()
    db.refresh(new_link)

    return new_link
