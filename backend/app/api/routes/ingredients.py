from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Ingredient
from app.schemas.ingredient import (
    IngredientCreate,
    IngredientResponse,
)


router = APIRouter(
    prefix="/ingredients",
    tags=["Ingredients"],
)


@router.post(
    "/",
    response_model=IngredientResponse,
    status_code=201,
)
def create_ingredient(
    ingredient: IngredientCreate,
    db: Session = Depends(get_db),
):
    existing_ingredient = (
        db.query(Ingredient)
        .filter(Ingredient.name == ingredient.name)
        .first()
    )

    if existing_ingredient:
        raise HTTPException(
            status_code=400,
            detail="Ingredient already exists",
        )

    new_ingredient = Ingredient(
        **ingredient.model_dump()
    )

    db.add(new_ingredient)
    db.commit()
    db.refresh(new_ingredient)

    return new_ingredient


@router.get(
    "/",
    response_model=list[IngredientResponse],
)
def get_ingredients(
    db: Session = Depends(get_db),
):
    return db.query(Ingredient).all()


@router.get(
    "/{ingredient_id}",
    response_model=IngredientResponse,
)
def get_ingredient(
    ingredient_id: int,
    db: Session = Depends(get_db),
):
    ingredient = (
        db.query(Ingredient)
        .filter(Ingredient.id == ingredient_id)
        .first()
    )

    if not ingredient:
        raise HTTPException(
            status_code=404,
            detail="Ingredient not found",
        )

    return ingredient
