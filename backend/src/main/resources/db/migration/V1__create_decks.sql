-- ==========================================
-- V1: Create the initial Cartas deck schema
-- ==========================================

-- 1. Main deck table
CREATE TABLE decks (
    id UUID PRIMARY KEY,

    name VARCHAR(100) NOT NULL,

    commander_scryfall_id UUID,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_decks_name_not_blank
        CHECK (btrim(name) <> '')
);


-- 2. Cards belonging to each deck
CREATE TABLE deck_cards (
    id UUID PRIMARY KEY,

    deck_id UUID NOT NULL,

    scryfall_id UUID NOT NULL,

    quantity INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT fk_deck_cards_deck
        FOREIGN KEY (deck_id)
        REFERENCES decks(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_deck_cards_deck_scryfall
        UNIQUE (deck_id, scryfall_id),

    CONSTRAINT chk_deck_cards_quantity_positive
        CHECK (quantity > 0)
);
