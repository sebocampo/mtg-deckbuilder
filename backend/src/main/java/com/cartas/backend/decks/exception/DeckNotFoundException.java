package com.cartas.backend.decks.exception;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class DeckNotFoundException extends RuntimeException {
    public DeckNotFoundException(UUID deckId) {
        super("Deck not found: " + deckId);
    }
}