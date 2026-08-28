import re

from rapidfuzz import fuzz, process
from sqlalchemy.orm import Session

from app.models.models import Medicine

from app.services.ocr_service import (
    extract_text_from_image,
)

from app.services.medicine_search import (
    normalize_medicine_name,
    search_medicines,
)


def is_possible_medicine_name(
    text: str,
) -> bool:
    text = text.strip()

    if len(text) < 6:
        return False

    text_lower = text.lower()

    if not any(
        character.isalpha()
        for character in text
    ):
        return False

    if re.search(
        r"\d+\s*(mg|ml|mcg|g|iu)",
        text_lower,
    ):
        return False

    excluded_phrases = [
        "keep out",
        "reach of children",
        "mental health",
        "side effects",
        "schedule",
        "drug caution",
        "not to be sold",
        "prescription",
        "practitioner",
        "manufactured",
        "technical guidance",
        "contains",
        "dosage",
        "store",
        "temperature",
        "children",
        "physician",
        "colours",
        "colour",
        "village",
        "dist",
        "district",
        "khasra",
        "unit",
        "ltd",
        "pvt",
        "india",
        "roorkee",
        "haridwar",
        "uttarkhand",
        "lake quinoline",
        "tablet",
        "tablets",
        "capsule",
        "capsules",
        "syrup",
    ]

    if any(
        phrase in text_lower
        for phrase in excluded_phrases
    ):
        return False

    if text_lower.startswith("m.l."):
        return False

    if len(text.split()) > 4:
        return False

    words = text.split()

    if max(
        len(word)
        for word in words
    ) < 5:
        return False

    return True


def candidate_priority(
    text: str,
) -> int:
    score = 0

    if "-" in text:
        score += 30

    if len(text.split()) <= 2:
        score += 20

    score += min(
        len(text),
        20,
    )

    return score


def get_manufacturer_names(
    db: Session,
) -> list[str]:
    manufacturers = (
        db.query(
            Medicine.manufacturer
        )
        .filter(
            Medicine.manufacturer.isnot(None)
        )
        .distinct()
        .all()
    )

    return [
        normalize_medicine_name(
            manufacturer[0]
        )
        for manufacturer in manufacturers
        if manufacturer[0]
    ]


def is_manufacturer_name(
    text: str,
    manufacturer_names: list[str],
) -> bool:
    normalized_text = normalize_medicine_name(
        text
    )

    if not normalized_text:
        return False

    # Exact manufacturer match.
    if normalized_text in manufacturer_names:
        return True

    # Fuzzy manufacturer match.
    match = process.extractOne(
        normalized_text,
        manufacturer_names,
        scorer=fuzz.WRatio,
    )

    if not match:
        return False

    _, score, _ = match

    return score >= 95


def find_medicine_from_image(
    image_path: str,
    db: Session,
    limit: int = 5,
):
    texts = extract_text_from_image(
        image_path,
    )

    manufacturer_names = (
        get_manufacturer_names(db)
    )

    candidates = []

    seen = set()

    for text in texts:
        if not is_possible_medicine_name(
            text,
        ):
            continue

        # Reject known manufacturer names.
        if is_manufacturer_name(
            text,
            manufacturer_names,
        ):
            continue

        normalized = normalize_medicine_name(
            text
        )

        if normalized in seen:
            continue

        seen.add(normalized)

        candidates.append(text)

    candidates = sorted(
        candidates,
        key=candidate_priority,
        reverse=True,
    )

    all_results = {}

    for candidate in candidates:
        results = search_medicines(
            query=candidate,
            db=db,
            limit=limit,
        )

        for result in results:
            medicine = result["medicine"]
            score = result["score"]

            if score < 70:
                continue

            existing = all_results.get(
                medicine.id,
            )

            if (
                existing is None
                or score > existing["score"]
            ):
                all_results[
                    medicine.id
                ] = {
                    "medicine": medicine,
                    "score": score,
                    "matched_text": candidate,
                }

    sorted_results = sorted(
        all_results.values(),
        key=lambda item: item["score"],
        reverse=True,
    )

    return {
        "ocr_text": texts,
        "candidates": candidates,
        "matches": sorted_results[:limit],
    }
