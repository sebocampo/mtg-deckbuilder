package com.cartas.backend.decks.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

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
import com.cartas.backend.scryfall.dto.ScryfallLookupResult;
import com.cartas.backend.scryfall.service.ScryfallCardLookupService;

@Service
@Transactional(readOnly = true)
public class DeckService {

    private final DeckRepository deckRepository;

    private final ScryfallCardLookupService scryfallCardLookupService;

    private final DeckCardRepository deckCardRepository;

    private final CopyLimitPolicy copyLimitPolicy;

    public DeckService(DeckRepository deckRepository, ScryfallCardLookupService scryfallCardLookupService,
            DeckCardRepository deckCardRepository, CopyLimitPolicy copyLimitPolicy) {
        this.deckRepository = deckRepository;
        this.scryfallCardLookupService = scryfallCardLookupService;
        this.deckCardRepository = deckCardRepository;
        this.copyLimitPolicy = copyLimitPolicy;
    }

    // Deck Transactions

    @Transactional
    public DeckResponse createDeck(String name, UUID commanderScryfallId, DeckFormat format) {
        String trimmedName = name.trim();
        DeckEntity deck = new DeckEntity(trimmedName);
        if (deckRepository.existsByNameIgnoreCase(trimmedName)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A deck named '" + trimmedName + "' already exists.");
        }
        deck.setCommanderScryfallId(commanderScryfallId);
        if (commanderScryfallId != null) {
            ScryfallLookupResult cardInfo = scryfallCardLookupService.lookupCard(commanderScryfallId);
            isCardValidForCommanderSpot(cardInfo);
            deck.setCommanderOracleId(cardInfo.oracleId());
        }
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
        String trimmedName = newName.trim();
        if (deckRepository.existsByNameIgnoreCaseAndIdNot(trimmedName, deckId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A deck named '" + trimmedName + "' already exists.");
        }
        deck.setName(trimmedName);
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
        ScryfallLookupResult cardInfo = scryfallCardLookupService.lookupCard(request.getScryfallId());

        if (deck.getCommanderScryfallId() != null) {
            isAddCardCommander(deck.getCommanderOracleId(), cardInfo.oracleId());
        }
        Optional<DeckCardEntity> existing = deckCardRepository.findByDeck_IdAndOracleId(deck.getId(), cardInfo.oracleId());
        if (existing.isPresent()) {
            DeckCardEntity card = existing.get();
            int resultQuantity = card.getQuantity() + request.getQuantity();
            copyLimitPolicy.validateCopyLimit(deck.getFormat(), cardInfo.isBasicLand(), resultQuantity);
            card.setQuantity(resultQuantity);
        } else {
            copyLimitPolicy.validateCopyLimit(deck.getFormat(), cardInfo.isBasicLand(), request.getQuantity());
            deck.addCard(new DeckCardEntity(
                    request.getScryfallId(), cardInfo.oracleId(), request.getQuantity()));
        }
        return toResponse(deck);
    }

    @Transactional
    public DeckResponse updateCard(UUID deckId, AddCardRequest request) {
        if (request.getQuantity() <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Quantity must be greater than zero.");
        }
        DeckEntity deck = findDeckById(deckId);
        ScryfallLookupResult cardInfo = scryfallCardLookupService.lookupCard(request.getScryfallId());

        Optional<DeckCardEntity> existing = deckCardRepository.findByDeck_IdAndOracleId(deck.getId(), cardInfo.oracleId());
        if (existing.isPresent()) {
            DeckCardEntity card = existing.get();
            copyLimitPolicy.validateCopyLimit(deck.getFormat(), cardInfo.isBasicLand(), request.getQuantity());
            card.setScryfallId(request.getScryfallId());
            card.setQuantity(request.getQuantity());
        } else {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Card not found in the deck.");
        }
        return toResponse(deck);
    }

    @Transactional
    public DeckResponse removeCard(UUID deckId, UUID scryfallId) {
        DeckEntity deck = findDeckById(deckId);
        ScryfallLookupResult cardInfo = scryfallCardLookupService.lookupCard(scryfallId);

        Optional<DeckCardEntity> existing = deckCardRepository.findByDeck_IdAndOracleId(deck.getId(), cardInfo.oracleId());
        if (existing.isPresent()) {
            DeckCardEntity card = existing.get();
            deck.removeCard(card);
        } else {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Card not found in the deck.");
        }
        return toResponse(deck);
    }

    @Transactional
    public DeckResponse setCommander(UUID deckId, UUID commanderScryfallId) {
        DeckEntity deck = findDeckById(deckId);
        ScryfallLookupResult cardInfo = scryfallCardLookupService.lookupCard(commanderScryfallId);

        Optional<DeckCardEntity> existing = deckCardRepository.findByDeck_IdAndOracleId(deck.getId(), cardInfo.oracleId());
        if (existing.isPresent()) {
            // Possibly have logic to eventually move card from in the deck to the commander slot, but for now just throw an error.
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Commander cannot be a card already in the deck.");
        }

        isCardValidForCommanderSpot(cardInfo);

        deck.setCommanderScryfallId(commanderScryfallId);
        deck.setCommanderOracleId(cardInfo.oracleId());
        return toResponse(deck);
    }

    @Transactional
    public DeckResponse removeCommander(UUID deckId) {
        DeckEntity deck = findDeckById(deckId);

        if (deck.getCommanderScryfallId() != null) {
            deck.setCommanderScryfallId(null);
            deck.setCommanderOracleId(null);
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

    private static void isAddCardCommander(UUID currentCommanderOracleId, UUID oracleId) {
        if (currentCommanderOracleId.equals(oracleId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Card is already set as the commander of this deck.");
        }
    }

    private static void isCardValidForCommanderSpot(ScryfallLookupResult cardInfo) {
        if (!cardInfo.isLegendary() || !cardInfo.isCreature()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Commander must be a legendary creature.");
        }
    }
}
