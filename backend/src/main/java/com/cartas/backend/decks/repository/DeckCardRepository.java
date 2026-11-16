package com.cartas.backend.decks.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.cartas.backend.entity.DeckCardEntity;

import java.util.Optional;
import java.util.UUID;

public interface DeckCardRepository
        extends JpaRepository<DeckCardEntity, UUID> {

    Optional<DeckCardEntity> findByDeck_IdAndScryfallId(
        UUID deckId,
        UUID scryfallId
    );
}