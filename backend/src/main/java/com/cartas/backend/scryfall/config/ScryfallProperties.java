package com.cartas.backend.scryfall.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "scryfall")
public record ScryfallProperties(String baseUrl) {
}
