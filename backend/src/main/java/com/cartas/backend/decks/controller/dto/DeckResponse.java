package com.cartas.backend.decks.controller.dto;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import com.cartas.backend.decks.model.DeckFormat;

public record DeckResponse(
        UUID id,
        String name,
        DeckFormat format,
        UUID commanderScryfallId,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt,
        List<DeckCardResponse> cards) {
}
