import enum

from sqlalchemy import (
    Column,
    Enum,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship

from app.db.database import Base


class InteractionSeverity(str, enum.Enum):
    Low = "Low"
    Moderate = "Moderate"
    Severe = "Severe"


class Medicine(Base):
    __tablename__ = "medicines"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, unique=True, index=True)
    brand = Column(String(255), nullable=True)
    manufacturer = Column(String(255), nullable=True)
    form = Column(String(100), nullable=True)
    category = Column(String(100), nullable=True)
    price = Column(Numeric(10, 2), nullable=True)

    ingredients = relationship(
        "MedicineIngredient",
        back_populates="medicine",
    )


class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, unique=True, index=True)
    standard_name = Column(String(255), nullable=True)

    medicines = relationship(
        "MedicineIngredient",
        back_populates="ingredient",
    )


class MedicineIngredient(Base):
    __tablename__ = "medicine_ingredients"

    id = Column(Integer, primary_key=True, index=True)
    medicine_id = Column(
        Integer,
        ForeignKey("medicines.id", ondelete="CASCADE"),
        nullable=False,
    )
    ingredient_id = Column(
        Integer,
        ForeignKey("ingredients.id", ondelete="CASCADE"),
        nullable=False,
    )
    strength = Column(String(100), nullable=True)

    medicine = relationship(
        "Medicine",
        back_populates="ingredients",
    )
    ingredient = relationship(
        "Ingredient",
        back_populates="medicines",
    )

    __table_args__ = (
        UniqueConstraint(
            "medicine_id",
            "ingredient_id",
            name="unique_medicine_ingredient",
        ),
    )


class DrugInteraction(Base):
    __tablename__ = "drug_interactions"

    id = Column(Integer, primary_key=True, index=True)

    ingredient_a_id = Column(
        Integer,
        ForeignKey("ingredients.id", ondelete="CASCADE"),
        nullable=False,
    )
    ingredient_b_id = Column(
        Integer,
        ForeignKey("ingredients.id", ondelete="CASCADE"),
        nullable=False,
    )

    severity = Column(
        Enum(
            InteractionSeverity,
            name="interaction_severity",
            create_type=False,
        ),
        nullable=False,
    )

    description = Column(Text, nullable=False)

    ingredient_a = relationship(
        "Ingredient",
        foreign_keys=[ingredient_a_id],
    )
    ingredient_b = relationship(
        "Ingredient",
        foreign_keys=[ingredient_b_id],
    )

    __table_args__ = (
        UniqueConstraint(
            "ingredient_a_id",
            "ingredient_b_id",
            name="unique_interaction_pair",
        ),
    )
