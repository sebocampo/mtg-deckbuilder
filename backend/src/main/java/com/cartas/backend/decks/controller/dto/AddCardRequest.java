package com.cartas.backend.decks.controller.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public class AddCardRequest {
    @NotNull
    UUID scryfallId;

    @Positive
    int quantity;

    public UUID getScryfallId() {
        return scryfallId;
    }

    public void setScryfallId(UUID scryfallId) {
        this.scryfallId = scryfallId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
