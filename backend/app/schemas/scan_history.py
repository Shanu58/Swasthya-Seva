from datetime import datetime

from pydantic import BaseModel, ConfigDict


class ScanHistoryCreate(BaseModel):
    user_id: int | None = None
    medicine_id: int | None = None
    scanned_text: str


class ScanHistoryResponse(ScanHistoryCreate):
    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
