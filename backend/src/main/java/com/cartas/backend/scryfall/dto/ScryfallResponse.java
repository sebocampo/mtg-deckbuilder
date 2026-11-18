package com.cartas.backend.scryfall.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@JsonIgnoreProperties(ignoreUnknown = true)
public record ScryfallResponse(
        UUID id,

        @JsonProperty("oracle_id") UUID oracleId,

        String name,

        @JsonProperty("set") String setCode,

        @JsonProperty("set_name") String setName,

        @JsonProperty("collector_number") String collectorNumber,

        @JsonProperty("type_line") String typeLine,

        @JsonProperty("mana_cost") String manaCost,

        BigDecimal cmc,

        String layout,

        @JsonProperty("image_uris") Map<String, String> imageUris,

        @JsonProperty("card_faces") List<CardFaceResponse> cardFaces

) {

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record CardFaceResponse(

            String name,

            @JsonProperty("mana_cost") String manaCost,

            @JsonProperty("type_line") String typeLine,

            @JsonProperty("image_uris") Map<String, String> imageUris

    ) {
    }
}
