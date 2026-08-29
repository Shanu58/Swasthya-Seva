from pathlib import Path
from tempfile import NamedTemporaryFile

from fastapi import (
    APIRouter,
    Depends,
    File,
    HTTPException,
    UploadFile,
)
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.services.ocr_medicine_search import (
    find_medicine_from_image,
)


router = APIRouter(
    prefix="/medicine-image-search",
    tags=["Medicine Image Search"],
)


@router.post("/")
async def search_medicine_from_image(
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    allowed_types = {
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/webp",
    }
    allowed_suffixes = {
        ".jpg",
        ".jpeg",
        ".png",
        ".webp",
    }

    suffix = Path(image.filename or "").suffix.lower()

    # Some desktop/mobile image pickers send application/octet-stream
    # even when the selected file is a valid image. Accept known image
    # extensions in that case instead of rejecting a valid scan.
    if image.content_type not in allowed_types and suffix not in allowed_suffixes:
        raise HTTPException(
            status_code=400,
            detail=(
                "Only JPG, JPEG, PNG, and WEBP images are allowed. "
                f"Received content type: {image.content_type!r}."
            ),
        )

    if not suffix:
        suffix = ".jpg"

    temp_file = None

    try:
        temp_file = NamedTemporaryFile(
            delete=False,
            suffix=suffix,
        )

        contents = await image.read()

        if not contents:
            raise HTTPException(
                status_code=400,
                detail="The uploaded image is empty.",
            )

        temp_file.write(contents)
        temp_file.close()

        result = find_medicine_from_image(
            image_path=temp_file.name,
            db=db,
        )

        matches = []

        for match in result["matches"]:
            medicine = match["medicine"]

            matches.append(
                {
                    "id": medicine.id,
                    "name": medicine.name,
                    "score": match["score"],
                    "matched_text": match["matched_text"],
                }
            )

        return {
            "success": True,
            "ocr_candidates": result["candidates"],
            "matches": matches,
        }

    finally:
        if (
            temp_file is not None
            and Path(temp_file.name).exists()
        ):
            Path(temp_file.name).unlink()
