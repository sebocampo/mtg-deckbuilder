package com.cartas.backend.decks.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.cartas.backend.entity.DeckEntity;

import java.util.UUID;

public interface DeckRepository
        extends JpaRepository<DeckEntity, UUID> {
}