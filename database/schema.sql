-- PostgreSQL Database Initialization for Swasthya Seva

CREATE TYPE interaction_severity AS ENUM ('Low', 'Moderate', 'Severe');

CREATE TABLE IF NOT EXISTS medicines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    brand VARCHAR(255),
    manufacturer VARCHAR(255),
    form VARCHAR(100),
    category VARCHAR(100),
    price NUMERIC(10, 2)
);

CREATE TABLE IF NOT EXISTS ingredients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    standard_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS medicine_ingredients (
    id SERIAL PRIMARY KEY,
    medicine_id INTEGER REFERENCES medicines(id) ON DELETE CASCADE,
    ingredient_id INTEGER REFERENCES ingredients(id) ON DELETE CASCADE,
    strength VARCHAR(100),
    CONSTRAINT unique_medicine_ingredient
        UNIQUE(medicine_id, ingredient_id)
);

CREATE TABLE IF NOT EXISTS drug_interactions (
    id SERIAL PRIMARY KEY,
    ingredient_a_id INTEGER REFERENCES ingredients(id) ON DELETE CASCADE,
    ingredient_b_id INTEGER REFERENCES ingredients(id) ON DELETE CASCADE,
    severity interaction_severity NOT NULL,
    description TEXT NOT NULL,
    CONSTRAINT unique_interaction_pair
        UNIQUE(ingredient_a_id, ingredient_b_id)
);

CREATE INDEX IF NOT EXISTS idx_medicines_name
    ON medicines(name);

CREATE INDEX IF NOT EXISTS idx_ingredients_name
    ON ingredients(name);
