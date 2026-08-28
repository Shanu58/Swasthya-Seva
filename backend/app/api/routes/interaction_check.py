from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_, and_
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import (
    DrugInteraction,
    Ingredient,
    Medicine,
    MedicineIngredient,
)
from app.schemas.interaction_check import (
    InteractionCheckRequest,
    InteractionCheckResponse,
    InteractionResult,
)


router = APIRouter(
    prefix="/interaction-check",
    tags=["Interaction Check"],
)


@router.post(
    "/",
    response_model=InteractionCheckResponse,
)
def check_interaction(
    request: InteractionCheckRequest,
    db: Session = Depends(get_db),
):
    medicine_a = (
        db.query(Medicine)
        .filter(Medicine.id == request.medicine_a_id)
        .first()
    )

    if not medicine_a:
        raise HTTPException(
            status_code=404,
            detail="Medicine A not found",
        )

    medicine_b = (
        db.query(Medicine)
        .filter(Medicine.id == request.medicine_b_id)
        .first()
    )

    if not medicine_b:
        raise HTTPException(
            status_code=404,
            detail="Medicine B not found",
        )

    ingredients_a = (
        db.query(Ingredient)
        .join(MedicineIngredient)
        .filter(
            MedicineIngredient.medicine_id
            == request.medicine_a_id
        )
        .all()
    )

    ingredients_b = (
        db.query(Ingredient)
        .join(MedicineIngredient)
        .filter(
            MedicineIngredient.medicine_id
            == request.medicine_b_id
        )
        .all()
    )

    interactions_found = []

    for ingredient_a in ingredients_a:
        for ingredient_b in ingredients_b:

            interaction = (
                db.query(DrugInteraction)
                .filter(
                    or_(
                        and_(
                            DrugInteraction.ingredient_a_id
                            == ingredient_a.id,
                            DrugInteraction.ingredient_b_id
                            == ingredient_b.id,
                        ),
                        and_(
                            DrugInteraction.ingredient_a_id
                            == ingredient_b.id,
                            DrugInteraction.ingredient_b_id
                            == ingredient_a.id,
                        ),
                    )
                )
                .first()
            )

            if interaction:
                interactions_found.append(
                    InteractionResult(
                        ingredient_a=ingredient_a.name,
                        ingredient_b=ingredient_b.name,
                        severity=interaction.severity.value,
                        description=interaction.description,
                    )
                )

    return InteractionCheckResponse(
        medicine_a_id=request.medicine_a_id,
        medicine_b_id=request.medicine_b_id,
        interactions=interactions_found,
    )
