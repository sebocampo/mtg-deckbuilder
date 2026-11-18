package com.cartas.backend.scryfall.service;

import com.cartas.backend.scryfall.client.ScryfallClient;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.server.ResponseStatusException;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ScryfallCardLookupService {

    private final ScryfallClient scryfallClient;
    private final Map<UUID, UUID> oracleIdCache = new ConcurrentHashMap<>();

    public ScryfallCardLookupService(ScryfallClient scryfallClient) {
        this.scryfallClient = scryfallClient;
    }

    public UUID resolveOracleId(UUID scryfallId) {
        return oracleIdCache.computeIfAbsent(scryfallId, id -> {
            try {
                return scryfallClient.getCard(id).oracleId();
            } catch (HttpClientErrorException.NotFound e) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown Scryfall card id: " + id);
            } catch (RestClientException e) {
                throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Scryfall is unavailable", e);
            }
        });
    }
}
