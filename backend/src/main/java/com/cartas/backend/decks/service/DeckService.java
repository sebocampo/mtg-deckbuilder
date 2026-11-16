package com.cartas.backend.decks.service;

import org.springframework.stereotype.Service;

import com.cartas.backend.decks.repository.DeckRepository;
import com.cartas.backend.entity.DeckEntity;

@Service
public class DeckService {

    private final DeckRepository deckRepository;

    public DeckService(DeckRepository deckRepository) {
        this.deckRepository = deckRepository;
    }

    public DeckEntity createDeck(String name) {
        return deckRepository.save(new DeckEntity(name));
    }
}
