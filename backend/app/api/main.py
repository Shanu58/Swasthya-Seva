from fastapi import FastAPI

from app.api.routes.medicines import router as medicines_router
from app.api.routes.ingredients import router as ingredients_router
from app.api.routes.medicine_ingredients import (
    router as medicine_ingredients_router,
)
from app.api.routes.drug_interactions import (
    router as drug_interactions_router,
)
from app.api.routes.interaction_check import (
    router as interaction_check_router,
)
from app.api.routes.users import router as users_router
from app.api.routes.scan_history import router as scan_history_router


app = FastAPI(
    title="Swasthya Seva API",
    version="1.0.0",
)


app.include_router(medicines_router)
app.include_router(ingredients_router)
app.include_router(medicine_ingredients_router)
app.include_router(drug_interactions_router)
app.include_router(interaction_check_router)
app.include_router(users_router)
app.include_router(scan_history_router)


@app.get("/")
def root():
    return {
        "message": "Swasthya Seva API is running"
    }
