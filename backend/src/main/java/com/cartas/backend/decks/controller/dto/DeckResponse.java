package com.cartas.backend.decks.controller.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record DeckResponse(
        UUID id,
        String name,
        UUID commanderScryfallId,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt) {
}
