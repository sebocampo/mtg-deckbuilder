# Test-CommanderApi.ps1 — commander management proof (Sprint 2)
# Backend must be running on http://localhost:8081
# Endpoints under test:
#   PUT    /api/decks/{deckId}/commander   body: SetCommanderRequest { commanderScryfallId }
#   DELETE /api/decks/{deckId}/commander   no body — clears the commander (sets null)
# Rules under test (Sebastian, Nov 23, 2026; widened Nov 26, 2026):
# - Commander is a field on the deck (commander_scryfall_id), NOT a deck_cards row.
# - The commander must be a LEGENDARY CREATURE (isLegendary + isCreature on the
#   Scryfall type line) OR carry "can be your commander" in its oracle_text
#   (isCommander() on ScryfallLookupResult) — 400 otherwise. Backgrounds stay
#   rejected: they are only commanders next to a "choose a Background" partner,
#   and Partner support is deferred. Colour identity / banned lists stay deferred.
# - Commander and the 99 are mutually exclusive, by ORACLE identity:
#   setCommander rejects a card already in the deck; addCard rejects the commander.
# - Unknown printing -> 400 (via the same Scryfall lookup as add-card),
#   missing deck -> 404, DELETE with no commander -> 200 (idempotent).

$base = "http://localhost:8081/api/decks"
$pass = 0; $fail = 0
function Check($name, $condition) {
    if ($condition) { $script:pass++; Write-Host "PASS  $name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "FAIL  $name" -ForegroundColor Red }
}

# Cards (all IDs verified against the Scryfall API)
# Pantlaza, Sun-Favored (LCC #124) — Sebastian's working-example commander.
$pantlaza    = "150a35f8-bbdc-4f6e-98e3-3bd6a3b8154a"
# Zacama, Primal Calamity (LCC #296) — legendary creature; the swap target.
$zacama      = "05c5a9a8-badd-43ab-8408-a13e75407681"
# Zacama (RIX #174) — SAME oracle identity as $zacama, different printing.
$zacamaAlt   = "5aa75f2b-53c5-47c5-96d2-ab796358a96f"
# Sol Ring (LEA) — NOT legendary: the legendary-gate probe, and an ordinary card.
$solRing     = "c4300d24-1cae-4dd5-be7e-38cc677cf5bd"
# Tasha, the Witch Queen (CLB #364) — Legendary Planeswalker whose oracle text
# ends "Tasha, the Witch Queen can be your commander." Accepted under the new rule.
$tasha       = "b1c5f679-82d0-4434-9f13-d39ad57282b8"
# Jace, the Mind Sculptor — Legendary Planeswalker with NO "can be your commander"
# text. The control proving acceptance is the phrase, not "legendary planeswalker".
$jace        = "c8817585-0d32-4d56-9142-0d29512e86a9"
# Acolyte of Bahamut (CLB #212) — Legendary Enchantment — Background. Only a
# commander next to a "choose a Background" partner; Partner is deferred, so 400.
$acolyte     = "b0260e1f-ff6a-4ef3-bef7-8c77f8413500"
$unknown     = "00000000-0000-0000-0000-000000000000"
$missingDeck = "00000000-0000-0000-0000-000000000000"

function New-Deck($name) {
    $body = @{ name = $name; format = "COMMANDER" } | ConvertTo-Json
    $deck = Invoke-RestMethod -Method Post -Uri $base -ContentType "application/json" -Body $body
    return $deck.id
}

function Put-Commander($deckId, $scryfallId) {
    $body = @{ commanderScryfallId = $scryfallId } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Method Put -Uri "$base/$deckId/commander" -ContentType "application/json" -Body $body
        return @{ Code = 200; Body = $resp }
    } catch {
        return @{ Code = [int]$_.Exception.Response.StatusCode; Body = $null }
    }
}

function Delete-Commander($deckId) {
    try {
        $resp = Invoke-RestMethod -Method Delete -Uri "$base/$deckId/commander"
        return @{ Code = 200; Body = $resp }
    } catch {
        return @{ Code = [int]$_.Exception.Response.StatusCode; Body = $null }
    }
}

function Add-Card($deckId, $scryfallId) {
    $body = @{ scryfallId = $scryfallId; quantity = 1 } | ConvertTo-Json
    try {
        Invoke-RestMethod -Method Post -Uri "$base/$deckId/cards" -ContentType "application/json" -Body $body | Out-Null
        return 200
    } catch {
        return [int]$_.Exception.Response.StatusCode
    }
}

function Get-Deck($deckId) {
    return Invoke-RestMethod "$base/$deckId"
}

# ---------- Set commander on a deck created without one ----------
$deckId = New-Deck "Commander Test Deck"
Check "deck created" ($null -ne $deckId)
$deck = Get-Deck $deckId
Check "new deck has no commander" ($null -eq $deck.commanderScryfallId)

$r = Put-Commander $deckId $pantlaza
Check "PUT Pantlaza -> 200" ($r.Code -eq 200)
$deck = Get-Deck $deckId
Check "GET shows Pantlaza as commander" ($deck.commanderScryfallId -eq $pantlaza)

# ---------- Unknown printing is rejected and changes nothing ----------
$r = Put-Commander $deckId $unknown
Check "PUT unknown printing -> 400" ($r.Code -eq 400)
$deck = Get-Deck $deckId
Check "rejected PUT changed nothing (still Pantlaza)" ($deck.commanderScryfallId -eq $pantlaza)

# ---------- A non-legendary card cannot be commander ----------
$r = Put-Commander $deckId $solRing
Check "PUT non-legendary (Sol Ring) -> 400" ($r.Code -eq 400)
$deck = Get-Deck $deckId
Check "legendary rejection changed nothing (still Pantlaza)" ($deck.commanderScryfallId -eq $pantlaza)

# ---------- "Can be your commander" cards are accepted; other planeswalkers and Backgrounds are not ----------
$r = Put-Commander $deckId $tasha
Check "PUT Tasha (can be your commander planeswalker) -> 200" ($r.Code -eq 200)
$deck = Get-Deck $deckId
Check "GET shows Tasha as commander" ($deck.commanderScryfallId -eq $tasha)

$r = Put-Commander $deckId $jace
Check "PUT ordinary planeswalker (Jace, the Mind Sculptor) -> 400" ($r.Code -eq 400)
$deck = Get-Deck $deckId
Check "planeswalker rejection changed nothing (still Tasha)" ($deck.commanderScryfallId -eq $tasha)

$r = Put-Commander $deckId $acolyte
Check "PUT Background (Acolyte of Bahamut) -> 400" ($r.Code -eq 400)
$deck = Get-Deck $deckId
Check "Background rejection changed nothing (still Tasha)" ($deck.commanderScryfallId -eq $tasha)

# ---------- PUT replaces the commander (no append, no second slot) ----------
$r = Put-Commander $deckId $zacama
Check "PUT Zacama (swap) -> 200" ($r.Code -eq 200)
$deck = Get-Deck $deckId
Check "GET shows Zacama as commander, Tasha gone" ($deck.commanderScryfallId -eq $zacama)

# ---------- Commander is separate from the cards list ----------
$code = Add-Card $deckId $solRing
Check "card added while commander set" ($code -eq 200)
$deck = Get-Deck $deckId
Check "deck has the one added card" ($deck.cards.Count -eq 1)

# ---------- The commander cannot also be added to the deck ----------
$code = Add-Card $deckId $zacama
Check "adding the commander (same printing) -> 400" ($code -eq 400)
$deck = Get-Deck $deckId
Check "rejected add changed nothing (cards still 1)" ($deck.cards.Count -eq 1)

$code = Add-Card $deckId $zacamaAlt
Check "adding the commander (different printing, same oracle) -> 400" ($code -eq 400)
$deck = Get-Deck $deckId
Check "oracle rejection changed nothing (cards still 1)" ($deck.cards.Count -eq 1)

$r = Delete-Commander $deckId
Check "DELETE commander -> 200" ($r.Code -eq 200)
$deck = Get-Deck $deckId
Check "GET shows commander cleared (null)" ($null -eq $deck.commanderScryfallId)
Check "DELETE commander left the cards untouched" ($deck.cards.Count -eq 1)

# ---------- DELETE is idempotent: clearing an empty slot is not an error ----------
$r = Delete-Commander $deckId
Check "DELETE commander again -> 200" ($r.Code -eq 200)
$deck = Get-Deck $deckId
Check "commander still null after second DELETE" ($null -eq $deck.commanderScryfallId)

# ---------- Missing deck -> 404 on both verbs ----------
$r = Put-Commander $missingDeck $pantlaza
Check "PUT commander on missing deck -> 404" ($r.Code -eq 404)
$r = Delete-Commander $missingDeck
Check "DELETE commander on missing deck -> 404" ($r.Code -eq 404)

# ---------- Adding a card to a deck with NO commander still works ----------
$deck2 = New-Deck "No Commander Deck"
$code = Add-Card $deck2 $solRing
Check "card added to a deck with no commander" ($code -eq 200)

# ---------- Cleanup ----------
Invoke-RestMethod -Method Delete -Uri "$base/$deckId" | Out-Null
Invoke-RestMethod -Method Delete -Uri "$base/$deck2" | Out-Null
Write-Host "`n$pass passed, $fail failed"
