package com.cartas.backend.decks.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.cartas.backend.decks.controller.dto.AddCardRequest;
import com.cartas.backend.decks.controller.dto.DeckCardResponse;
import com.cartas.backend.decks.controller.dto.DeckResponse;
import com.cartas.backend.decks.exception.DeckNotFoundException;
import com.cartas.backend.decks.model.DeckFormat;
import com.cartas.backend.decks.repository.DeckCardRepository;
import com.cartas.backend.decks.repository.DeckRepository;
import com.cartas.backend.entity.DeckCardEntity;
import com.cartas.backend.entity.DeckEntity;
import com.cartas.backend.scryfall.service.ScryfallCardLookupService;

@Service
@Transactional(readOnly = true)
public class DeckService {

    private final DeckRepository deckRepository;

    private final ScryfallCardLookupService scryfallCardLookupService;

    private final DeckCardRepository deckCardRepository;

    public DeckService(DeckRepository deckRepository, ScryfallCardLookupService scryfallCardLookupService,
            DeckCardRepository deckCardRepository) {
        this.deckRepository = deckRepository;
        this.scryfallCardLookupService = scryfallCardLookupService;
        this.deckCardRepository = deckCardRepository;
    }

    // Deck Transactions

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

    // DeckCard Transactions

    @Transactional
    public DeckResponse addCard(UUID deckId, AddCardRequest request) {
        DeckEntity deck = findDeckById(deckId);
        UUID oracleId = scryfallCardLookupService.resolveOracleId(request.getScryfallId());

        Optional<DeckCardEntity> existing = deckCardRepository.findByDeck_IdAndOracleId(deck.getId(), oracleId);
        if (existing.isPresent()) {
            DeckCardEntity card = existing.get();
            card.setQuantity(card.getQuantity() + request.getQuantity());
        } else {
            deck.addCard(new DeckCardEntity(
                    request.getScryfallId(), oracleId, request.getQuantity()));
        }
        return toResponse(deck);
    }

    // Private Helper Methods

    private DeckEntity findDeckById(UUID deckId) {
        return deckRepository.findById(deckId)
                .orElseThrow(() -> new DeckNotFoundException(deckId));
    }

    private static DeckResponse toResponse(DeckEntity deck) {
        List<DeckCardResponse> cards = deck.getCards().stream()
                .map(DeckService::toCardResponse)
                .toList();
        return new DeckResponse(
                deck.getId(),
                deck.getName(),
                deck.getFormat(),
                deck.getCommanderScryfallId(),
                deck.getCreatedAt(),
                deck.getUpdatedAt(),
                cards);
    }

    private static DeckCardResponse toCardResponse(DeckCardEntity card) {
        return new DeckCardResponse(
                card.getScryfallId(),
                card.getOracleId(),
                card.getQuantity(),
                card.getCreatedAt(),
                card.getUpdatedAt());
    }
}
