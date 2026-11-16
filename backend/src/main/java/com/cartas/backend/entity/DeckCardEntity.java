
package com.cartas.backend.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "deck_cards")
public class DeckCardEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "deck_id", nullable = false)
    private DeckEntity deck;

    @Column(name = "scryfall_id", nullable = false)
    private UUID scryfallId;

    @Column(name = "quantity", nullable = false)
    private int quantity = 1;

    protected DeckCardEntity() {
        // Required by JPA
    }

    public DeckCardEntity(UUID scryfallId, int quantity) {
        this.scryfallId = scryfallId;
        this.quantity = quantity;
    }

    public UUID getId() {
        return id;
    }

    public DeckEntity getDeck() {
        return deck;
    }

    public void setDeck(DeckEntity deck) {
        this.deck = deck;
    }

    public UUID getScryfallId() {
        return scryfallId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
