package com.cartas.backend.decks.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

import com.cartas.backend.decks.controller.dto.DeckResponse;
import com.cartas.backend.decks.exception.DeckNotFoundException;
import com.cartas.backend.decks.model.DeckFormat;
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
    public DeckResponse createDeck(String name, UUID commanderScryfallId, DeckFormat format) {
        DeckEntity deck = new DeckEntity(name);
        deck.setCommanderScryfallId(commanderScryfallId);
        deck.setFormat(format);
        return toResponse(deckRepository.save(deck));
    }

    public List<DeckResponse> getAllDecks() {
        return deckRepository.findAll().stream()
                .map(DeckService::toResponse)
                .toList();
    }

    public DeckResponse getDeck(UUID deckId) {
        return toResponse(findDeckById(deckId));
    }

    @Transactional
    public DeckResponse renameDeck(UUID deckId, String newName) {
        DeckEntity deck = findDeckById(deckId);
        deck.setName(newName);
        return toResponse(deck);
    }

    @Transactional
    public void deleteDeck(UUID deckId) {
        deckRepository.delete(findDeckById(deckId));
    }

    private DeckEntity findDeckById(UUID deckId) {
        return deckRepository.findById(deckId)
                .orElseThrow(() -> new DeckNotFoundException(deckId));
    }

    private static DeckResponse toResponse(DeckEntity deck) {
        return new DeckResponse(
                deck.getId(),
                deck.getName(),
                deck.getFormat(),
                deck.getCommanderScryfallId(),
                deck.getCreatedAt(),
                deck.getUpdatedAt());
    }
}
