package com.cartas.backend.scryfall.dto;

import java.util.UUID;

public record ScryfallLookupResult(UUID oracleId, String typeLine, String oracleText ) {

    public boolean isBasicLand() {
        return typeLine != null && typeLine.startsWith("Basic");
    }

    public boolean isCommanderEligible() {
        return ((isLegendary() && isCreature()) || (oracleText != null && oracleText.contains("can be your commander")));
    }

    public boolean isLegendary() {
        return typeLine != null && typeLine.startsWith("Legendary");
    }

    public boolean isCreature() {
        return typeLine != null && typeLine.contains("Creature");
    }
}
