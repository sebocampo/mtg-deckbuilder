package com.cartas.backend.decks.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;
import java.util.UUID;

import com.cartas.backend.decks.controller.dto.CreateDeckRequest;
import com.cartas.backend.decks.controller.dto.DeckResponse;
import com.cartas.backend.decks.controller.dto.RenameDeckRequest;
import com.cartas.backend.decks.service.DeckService;
import com.cartas.backend.entity.DeckEntity;

import jakarta.validation.Valid;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
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
            @RequestBody @Valid CreateDeckRequest request) {
        DeckResponse response = deckService.createDeck(request.getName(),
                request.getCommanderScryfallId(), request.getFormat());
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}").buildAndExpand(response.id()).toUri();
        return ResponseEntity.created(location).body(response);
    }

    @GetMapping
    public ResponseEntity<List<DeckResponse>> getAllDecks() {
        return ResponseEntity.ok(deckService.getAllDecks());
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeckResponse> getDeck(@PathVariable UUID id) {
        return ResponseEntity.ok(deckService.getDeck(id));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<DeckResponse> renameDeck(
            @PathVariable UUID id,
            @RequestBody @Valid RenameDeckRequest request) {
        return ResponseEntity.ok(deckService.renameDeck(id, request.getName()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDeck(@PathVariable UUID id) {
        deckService.deleteDeck(id);
        return ResponseEntity.noContent().build();
    }
}
