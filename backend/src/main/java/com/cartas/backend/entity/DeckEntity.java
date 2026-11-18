
package com.cartas.backend.entity;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.cartas.backend.decks.model.DeckFormat;

@Entity
@Table(name = "decks")
public class DeckEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "format", nullable = false, length = 30)
    private DeckFormat format = DeckFormat.COMMANDER;

    @Column(name = "commander_scryfall_id")
    private UUID commanderScryfallId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @OneToMany(
        mappedBy = "deck",
        cascade = CascadeType.ALL,
        orphanRemoval = true
    )

    @OrderBy ("createdAt ASC")
    private List<DeckCardEntity> cards = new ArrayList<>();

    protected DeckEntity() {
        // Required by JPA
    }

    public DeckEntity(String name) {
        this.name = name;
    }

    @PrePersist
    protected void onCreate() {
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = OffsetDateTime.now(ZoneOffset.UTC);
    }

    public void addCard(DeckCardEntity card) {
        cards.add(card);
        card.setDeck(this);
    }

    public void removeCard(DeckCardEntity card) {
        cards.remove(card);
        card.setDeck(null);
    }

    public UUID getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public DeckFormat getFormat() {
        return format;
    }
    
    public void setFormat(DeckFormat format) {
        this.format = format;
    }

    public UUID getCommanderScryfallId() {
        return commanderScryfallId;
    }

    public void setCommanderScryfallId(UUID commanderScryfallId) {
        this.commanderScryfallId = commanderScryfallId;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public List<DeckCardEntity> getCards() {
        return cards;
    }
}