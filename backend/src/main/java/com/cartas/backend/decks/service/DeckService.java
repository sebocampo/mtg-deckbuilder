package com.cartas.backend.decks.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.cartas.backend.decks.repository.DeckRepository;
import com.cartas.backend.entity.DeckEntity;

@Service
@Transactional(readOnly = true)
public class DeckService {

    private final DeckRepository deckRepository;

    public DeckService(DeckRepository deckRepository) {
        this.deckRepository = deckRepository;
    }

    @Transactional
    public DeckEntity createDeck(String name, UUID commanderScryfallId) {
        DeckEntity deck = new DeckEntity(name);
        deck.setCommanderScryfallId(commanderScryfallId);
        return deckRepository.save(deck);
    }

    public List<DeckEntity> getAllDecks() {
        return deckRepository.findAll();
    }

    public Optional<DeckEntity> getDeck(UUID deckId) {
        return deckRepository.findById(deckId);
    }
}
