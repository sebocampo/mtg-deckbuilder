package com.cartas.backend.decks.controller.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;

public class SetCommanderRequest {
    @NotNull
    private UUID commanderScryfallId;
    
    public UUID getCommanderScryfallId() {
        return commanderScryfallId;
    }

    public void setCommanderScryfallId(UUID commanderScryfallId) {
        this.commanderScryfallId = commanderScryfallId;
    }
}
