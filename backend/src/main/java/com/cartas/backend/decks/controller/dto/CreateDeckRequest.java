package com.cartas.backend.decks.controller.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CreateDeckRequest {
    @NotBlank
    @Size(max = 100)
    private String name;

    private UUID commanderScryfallId;

    public UUID getCommanderScryfallId() {
        return commanderScryfallId;
    }

    public void setCommanderScryfallId(UUID commanderScryfallId) {
        this.commanderScryfallId = commanderScryfallId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
