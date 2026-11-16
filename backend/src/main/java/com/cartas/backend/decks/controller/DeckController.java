package com.cartas.backend.decks.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

import com.cartas.backend.decks.controller.dto.CreateDeckRequest;
import com.cartas.backend.decks.controller.dto.DeckResponse;
import com.cartas.backend.decks.service.DeckService;
import com.cartas.backend.entity.DeckEntity;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;


@RestController
@RequestMapping("/api/decks")
public class DeckController {

    private final DeckService deckService;

    public DeckController(DeckService deckService) {
        this.deckService = deckService;
    }

    @PostMapping
    public ResponseEntity<DeckResponse> createDeck(
            @Valid @RequestBody CreateDeckRequest request) {
        DeckEntity deck = deckService.createDeck(request.getName(), request.getCommanderScryfallId());
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(deck));
    }

    @GetMapping
    public ResponseEntity<List<DeckResponse>> getAllDecks() {
        List<DeckResponse> response = deckService.getAllDecks()
                .stream()
                .map(DeckController::toResponse)
                .toList();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeckResponse> getDeck(@PathVariable UUID id) {
        return ResponseEntity.of(
            deckService.getDeck(id).map(DeckController::toResponse)
        );
    }

    private static DeckResponse toResponse(DeckEntity deck) {
        return new DeckResponse(
                deck.getId(),
                deck.getName(),
                deck.getCommanderScryfallId(),
                deck.getCreatedAt(),
                deck.getUpdatedAt());
    }
}
