-- Remove the old uniqueness constraint based on printing identity
ALTER TABLE deck_cards
DROP CONSTRAINT uq_deck_cards_deck_scryfall;

-- Add the canonical card identity
ALTER TABLE deck_cards
ADD COLUMN oracle_id UUID NOT NULL;

-- Prevent the same card identity from being added twice to a deck
ALTER TABLE deck_cards
ADD CONSTRAINT uq_deck_cards_deck_oracle
UNIQUE (deck_id, oracle_id);