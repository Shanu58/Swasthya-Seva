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


# Demo-ready medicine information for medicines likely to be scanned during
# the presentation. Unknown medicines still return database-backed metadata
# and a conservative safety fallback instead of blank cards.
MEDICINE_INFO = {
    "combiflam tablet": {
        "usage": "Combiflam is used for short-term relief of pain and fever, including headache, toothache, body pain, menstrual pain and pain associated with inflammation.",
        "dosage": "Use only as directed on the label or by a doctor. The exact dose depends on age, medical condition and the formulation. Do not exceed the recommended dose.",
        "food_guidance": "Taking it with food or milk may help reduce stomach irritation. Avoid alcohol while using this medicine unless a healthcare professional advises otherwise.",
        "warnings": [
            "Do not use if you are allergic to ibuprofen, paracetamol or similar pain medicines.",
            "Avoid exceeding the recommended dose because excess paracetamol can seriously damage the liver.",
            "Ibuprofen may irritate the stomach and may not be suitable for people with stomach ulcers, kidney disease or certain heart conditions.",
            "Do not combine with other medicines containing paracetamol or ibuprofen without checking with a doctor or pharmacist.",
        ],
        "data_source": "local_demo_reference",
    },
}


def _medicine_info(medicine: Medicine) -> dict:
    key = medicine.name.strip().lower()
    info = MEDICINE_INFO.get(key)
    if info:
        return info

    return {
        "usage": "Medicine information is not available in the local reference dataset for this product. Please consult a pharmacist or doctor before use.",
        "dosage": "Follow the directions on the medicine label or advice from your doctor or pharmacist.",
        "food_guidance": "Follow the instructions on the label. Ask a healthcare professional if you are unsure whether it should be taken with food.",
        "warnings": [
            "Do not self-medicate beyond the recommended directions.",
            "Check for allergies, duplicate ingredients and possible interactions before taking this medicine.",
        ],
        "data_source": "local_dataset_fallback",
    }


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
    return db.query(Medicine).all()


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
        .filter(MedicineIngredient.medicine_id == medicine_id)
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

    active_ingredients = [
        f"{item.name}{f' ({item.strength})' if item.strength else ''}"
        for item in ingredients
    ]

    info = _medicine_info(medicine)

    return MedicineDetailResponse(
        id=medicine.id,
        name=medicine.name,
        brand=medicine.brand,
        manufacturer=medicine.manufacturer,
        form=medicine.form,
        category=medicine.category,
        price=medicine.price,
        ingredients=ingredients,
        active_ingredients=active_ingredients,
        usage=info["usage"],
        dosage=info["dosage"],
        food_guidance=info["food_guidance"],
        warnings=info["warnings"],
        interaction_warnings=[],
        data_source=info["data_source"],
    )
