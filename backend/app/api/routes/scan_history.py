from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Medicine
from app.models.scan_history import ScanHistory
from app.models.user import User
from app.schemas.scan_history import (
    ScanHistoryCreate,
    ScanHistoryResponse,
)


router = APIRouter(
    prefix="/scan-history",
    tags=["Scan History"],
)


@router.post(
    "/",
    response_model=ScanHistoryResponse,
    status_code=201,
)
def create_scan_history(
    scan: ScanHistoryCreate,
    db: Session = Depends(get_db),
):
    if scan.user_id is not None:
        user = (
            db.query(User)
            .filter(User.id == scan.user_id)
            .first()
        )

        if not user:
            raise HTTPException(
                status_code=404,
                detail="User not found",
            )

    if scan.medicine_id is not None:
        medicine = (
            db.query(Medicine)
            .filter(Medicine.id == scan.medicine_id)
            .first()
        )

        if not medicine:
            raise HTTPException(
                status_code=404,
                detail="Medicine not found",
            )

    new_scan = ScanHistory(
        **scan.model_dump()
    )

    db.add(new_scan)
    db.commit()
    db.refresh(new_scan)

    return new_scan


@router.get(
    "/",
    response_model=list[ScanHistoryResponse],
)
def get_scan_history(
    db: Session = Depends(get_db),
):
    scans = (
        db.query(ScanHistory)
        .order_by(ScanHistory.created_at.desc())
        .all()
    )

    return scans


@router.get(
    "/user/{user_id}",
    response_model=list[ScanHistoryResponse],
)
def get_user_scan_history(
    user_id: int,
    db: Session = Depends(get_db),
):
    user = (
        db.query(User)
        .filter(User.id == user_id)
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    scans = (
        db.query(ScanHistory)
        .filter(ScanHistory.user_id == user_id)
        .order_by(ScanHistory.created_at.desc())
        .all()
    )

    return scans
