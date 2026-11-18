package com.cartas.backend.scryfall.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
@EnableConfigurationProperties(ScryfallProperties.class)
public class ScryfallConfig {

    @Bean
    public RestClient scryfallRestClient(ScryfallProperties properties) {
        return RestClient.builder()
                .baseUrl(properties.baseUrl())
                .defaultHeader("Accept", "application/json")
                .defaultHeader("User-Agent", "Cartas/0.1")
                .build();
    }
}
