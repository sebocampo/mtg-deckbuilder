package com.cartas.backend.scryfall.dto;

import java.util.UUID;

public record ScryfallLookupResult(UUID oracleId, String typeLine) {

    public boolean isBasicLand() {
        return typeLine != null && typeLine.startsWith("Basic");
    }
}
