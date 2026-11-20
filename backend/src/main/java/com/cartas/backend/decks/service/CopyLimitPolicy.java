package com.cartas.backend.decks.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import com.cartas.backend.decks.model.DeckFormat;

@Component
public class CopyLimitPolicy {
    public void validateCopyLimit(DeckFormat format, boolean isBasicLand, int resultingQuantity) {
        if (isBasicLand) {
            return; // Basic lands are exempt from copy limits
        }

        if (resultingQuantity > format.maxCopies()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Cannot have more than " + format.maxCopies() + " copies of a card in " + format.name()
                            + " format.");
        }
    }
}
