package com.cartas.backend.decks.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cartas.backend.decks.controller.dto.CreateDeckRequest;
import com.cartas.backend.decks.controller.dto.DeckResponse;
import com.cartas.backend.decks.service.DeckService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class DeckController {

    private final DeckService deckService;

    public DeckController(DeckService deckService) {
        this.deckService = deckService;
    }

    @PostMapping("/decks")
    public ResponseEntity<DeckResponse> createDeck(
            @Valid @RequestBody CreateDeckRequest request) {
        var deck = deckService.createDeck(request.getName());
        var response = new DeckResponse(
                deck.getId(),
                deck.getName(),
                deck.getCreatedAt(),
                deck.getUpdatedAt());

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
