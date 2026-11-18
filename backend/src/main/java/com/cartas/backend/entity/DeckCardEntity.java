
package com.cartas.backend.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
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

    @Column(name = "oracle_id", nullable = false)
    private UUID oracleId;

    @Column(name = "scryfall_id", nullable = false)
    private UUID scryfallId;

    @Column(name = "quantity", nullable = false)
    private int quantity = 1;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    protected DeckCardEntity() {
        // Required by JPA
    }

    public DeckCardEntity(UUID scryfallId, UUID oracleId, int quantity) {
        this.scryfallId = scryfallId;
        this.oracleId = oracleId;
        this.quantity = quantity;
    }

    public UUID getId() {
        return id;
    }

    public UUID getOracleId() {
        return oracleId;
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
