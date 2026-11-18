package com.cartas.backend.scryfall.client;

import com.cartas.backend.scryfall.dto.ScryfallResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import java.util.UUID;

@Component
public class ScryfallClient {

    private final RestClient restClient;

    public ScryfallClient(RestClient scryfallRestClient) {
        this.restClient = scryfallRestClient;
    }

    public ScryfallResponse getCard(UUID scryfallId) {
        return restClient.get()
                .uri("/cards/{id}", scryfallId)
                .retrieve()
                .body(ScryfallResponse.class);
    }
}
