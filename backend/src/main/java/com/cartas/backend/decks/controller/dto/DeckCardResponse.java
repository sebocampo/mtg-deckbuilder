package com.cartas.backend.decks.controller.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record DeckCardResponse(
        UUID scryfallId,
        UUID oracleId,
        int quantity,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt) {
}
