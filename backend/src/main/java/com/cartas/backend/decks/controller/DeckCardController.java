package com.cartas.backend.decks.controller;

import java.util.UUID;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cartas.backend.decks.controller.dto.AddCardRequest;
import com.cartas.backend.decks.controller.dto.DeckResponse;
import com.cartas.backend.decks.service.DeckService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/decks/{deckId}/cards")
public class DeckCardController {
    private final DeckService deckService;

    public DeckCardController(DeckService deckService) {
        this.deckService = deckService;
    }

    @PostMapping
    public DeckResponse addCard(@PathVariable UUID deckId, @Valid @RequestBody AddCardRequest request) {
        return deckService.addCard(deckId, request);
    }

    // This covers both updating quantity of card and updating the scryfallId(the printing) of the card in the deck
    @PatchMapping
    public DeckResponse updateCard(@PathVariable UUID deckId, @Valid @RequestBody AddCardRequest request) {
        return deckService.updateCard(deckId, request);
    }

    // This is remove all copies, irrespective of the quantity, of a card from the deck. If you want to remove a specific quantity, use the updateCard endpoint with a lower quantity.
    @DeleteMapping("/{scryfallId}")
    public DeckResponse removeCard(@PathVariable UUID deckId, @PathVariable UUID scryfallId) {
        return deckService.removeCard(deckId, scryfallId);
    }
}
