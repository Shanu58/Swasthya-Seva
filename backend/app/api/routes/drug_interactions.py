from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import DrugInteraction, Ingredient
from app.schemas.drug_interaction import (
    DrugInteractionCreate,
    DrugInteractionResponse,
)


router = APIRouter(
    prefix="/drug-interactions",
    tags=["Drug Interactions"],
)


@router.post(
    "/",
    response_model=DrugInteractionResponse,
    status_code=201,
)
def create_drug_interaction(
    interaction: DrugInteractionCreate,
    db: Session = Depends(get_db),
):
    if interaction.ingredient_a_id == interaction.ingredient_b_id:
        raise HTTPException(
            status_code=400,
            detail="An ingredient cannot interact with itself",
        )

    ingredient_a = (
        db.query(Ingredient)
        .filter(Ingredient.id == interaction.ingredient_a_id)
        .first()
    )

    if not ingredient_a:
        raise HTTPException(
            status_code=404,
            detail="Ingredient A not found",
        )

    ingredient_b = (
        db.query(Ingredient)
        .filter(Ingredient.id == interaction.ingredient_b_id)
        .first()
    )

    if not ingredient_b:
        raise HTTPException(
            status_code=404,
            detail="Ingredient B not found",
        )

    existing_interaction = (
        db.query(DrugInteraction)
        .filter(
            DrugInteraction.ingredient_a_id
            == interaction.ingredient_a_id,
            DrugInteraction.ingredient_b_id
            == interaction.ingredient_b_id,
        )
        .first()
    )

    if existing_interaction:
        raise HTTPException(
            status_code=400,
            detail="Interaction already exists",
        )

    new_interaction = DrugInteraction(
        **interaction.model_dump()
    )

    db.add(new_interaction)
    db.commit()
    db.refresh(new_interaction)

    return new_interaction
