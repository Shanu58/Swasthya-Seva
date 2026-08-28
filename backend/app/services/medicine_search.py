import re
from functools import lru_cache

from rapidfuzz import fuzz, process
from sqlalchemy.orm import Session

from app.models.models import Medicine


def normalize_medicine_name(text: str) -> str:
    text = text.lower().strip()

    text = re.sub(
        r"[^a-z0-9\s]",
        " ",
        text,
    )

    text = re.sub(
        r"\s+",
        " ",
        text,
    )

    return text.strip()


@lru_cache(maxsize=1)
def get_medicine_name_map():
    from app.db.database import SessionLocal

    db = SessionLocal()

    try:
        medicines = (
            db.query(
                Medicine.id,
                Medicine.name,
            )
            .all()
        )

        return {
            normalize_medicine_name(medicine.name): medicine.id
            for medicine in medicines
        }

    finally:
        db.close()


def search_medicines(
    query: str,
    db: Session,
    limit: int = 5,
):
    query = query.strip()
    normalized_query = normalize_medicine_name(query)

    if not normalized_query:
        return []

    exact_matches = (
        db.query(Medicine)
        .filter(
            Medicine.name.ilike(
                f"%{query}%"
            )
        )
        .limit(limit)
        .all()
    )

    if exact_matches:
        return [
            {
                "medicine": medicine,
                "score": 100,
            }
            for medicine in exact_matches
        ]

    name_map = get_medicine_name_map()

    matches = process.extract(
        normalized_query,
        name_map.keys(),
        scorer=fuzz.WRatio,
        limit=limit,
    )

    medicine_ids = [
        name_map[normalized_name]
        for normalized_name, _, _ in matches
    ]

    medicines = (
        db.query(Medicine)
        .filter(Medicine.id.in_(medicine_ids))
        .all()
    )

    medicine_map = {
        medicine.id: medicine
        for medicine in medicines
    }

    results = []

    for normalized_name, score, _ in matches:
        medicine_id = name_map[normalized_name]
        medicine = medicine_map.get(medicine_id)

        if medicine:
            results.append(
                {
                    "medicine": medicine,
                    "score": round(score, 2),
                }
            )

    return results
