# Test-UpdateRemoveCardApi.ps1 — update-card (PATCH) + remove-card (DELETE) proof (Sprint 2)
# Backend must be running on http://localhost:8081
# Shapes under test:
#   PATCH  /api/decks/{deckId}/cards                 body: AddCardRequest { scryfallId, quantity }
#   DELETE /api/decks/{deckId}/cards/{scryfallId}    no body — scryfallId is a path variable

$base = "http://localhost:8081/api/decks"
$pass = 0; $fail = 0
function Check($name, $condition) {
    if ($condition) { $script:pass++; Write-Host "PASS  $name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "FAIL  $name" -ForegroundColor Red }
}

# Sol Ring: two printings, one oracle_id (verified against Scryfall)
$oracleId  = "6ad8011d-3471-4369-9d68-b264cc027487"
$printingA = "c4300d24-1cae-4dd5-be7e-38cc677cf5bd"  # LEA (Alpha, 1993)
$printingB = "fc817e07-c1f3-469f-9cf7-0945dea7400f"  # TRC (recent)

# Arcane Signet (TRC): a DIFFERENT oracle_id, never added to the deck.
# Used for the true "card not in deck" cases — a different printing of Sol Ring
# would NOT work here, because PATCH/DELETE resolve by oracle_id and Sol Ring IS in the deck.
$otherCard = "795df2ee-fbfc-4961-852c-e3ec50cc52da"

function Send-Card($method, $deckId, $scryfallId, $quantity) {
    $body = @{ scryfallId = $scryfallId; quantity = $quantity } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Method $method -Uri "$base/$deckId/cards" -ContentType "application/json" -Body $body
        return @{ Code = 200; Body = $resp }
    } catch {
        return @{ Code = [int]$_.Exception.Response.StatusCode; Body = $null }
    }
}

function Remove-Card($deckId, $scryfallId) {
    try {
        $resp = Invoke-RestMethod -Method Delete -Uri "$base/$deckId/cards/$scryfallId"
        return @{ Code = 200; Body = $resp }
    } catch {
        return @{ Code = [int]$_.Exception.Response.StatusCode; Body = $null }
    }
}

# 1. Setup: fresh Commander deck, add printing A with quantity 3
$deckBody = @{ name = "Update-Remove Test Deck"; format = "COMMANDER" } | ConvertTo-Json
$deck = Invoke-RestMethod -Method Post -Uri $base -ContentType "application/json" -Body $deckBody
$deckId = $deck.id
Check "deck created" ($null -ne $deckId)

$r = Send-Card Post $deckId $printingA 3
Check "setup: add printing A x3 -> 200" ($r.Code -eq 200)
Check "setup: quantity is 3" ($r.Body.cards[0].quantity -eq 3)

# 2. PATCH quantity down (same printing)
$r = Send-Card Patch $deckId $printingA 1
Check "PATCH quantity 3 -> 1 returns 200" ($r.Code -eq 200)
Check "still one card row" ($r.Body.cards.Count -eq 1)
Check "quantity is now 1" ($r.Body.cards[0].quantity -eq 1)
Check "scryfallId is still printing A" ($r.Body.cards[0].scryfallId -eq $printingA)
Check "oracleId unchanged" ($r.Body.cards[0].oracleId -eq $oracleId)

# 3. PATCH printing swap + quantity in one call (the printing-selector case)
$r = Send-Card Patch $deckId $printingB 2
Check "PATCH swap to printing B returns 200" ($r.Code -eq 200)
Check "still one card row after swap" ($r.Body.cards.Count -eq 1)
Check "scryfallId is now printing B" ($r.Body.cards[0].scryfallId -eq $printingB)
Check "oracleId STILL unchanged after swap" ($r.Body.cards[0].oracleId -eq $oracleId)
Check "quantity is now 2" ($r.Body.cards[0].quantity -eq 2)

# 4. PATCH error cases
$r = Send-Card Patch $deckId $printingB 0
Check "PATCH quantity 0 -> 400 (decision: DELETE is the only removal path)" ($r.Code -eq 400)
$r = Send-Card Patch ([guid]::NewGuid()) $printingA 1
Check "PATCH on missing deck -> 404" ($r.Code -eq 404)
$r = Send-Card Patch $deckId $otherCard 1
Check "PATCH card not in deck -> 404 (no silent add)" ($r.Code -eq 404)
$deck = Invoke-RestMethod "$base/$deckId"
Check "failed PATCH left the deck untouched" ($deck.cards.Count -eq 1 -and $deck.cards[0].quantity -eq 2 -and $deck.cards[0].scryfallId -eq $printingB)

# 5. DELETE removes all copies (path variable, no body)
$r = Remove-Card $deckId $printingB
Check "DELETE card -> 200" ($r.Code -eq 200)
Check "deck has no cards after DELETE" ($r.Body.cards.Count -eq 0)

$deck = Invoke-RestMethod "$base/$deckId"
Check "GET deck confirms card is gone" ($deck.cards.Count -eq 0)

$r = Remove-Card ([guid]::NewGuid()) $printingA
Check "DELETE on missing deck -> 404" ($r.Code -eq 404)

$r = Remove-Card $deckId $printingA
Check "DELETE card not in deck -> 404" ($r.Code -eq 404)

# 6. Known gap — FAILS until AddCardRequest gets its quantity default back:
#    POST add with no quantity should default to 1 (today it returns 400).
#    Fix: int quantity = 1; in AddCardRequest.
$bodyNoQty = @{ scryfallId = $printingA } | ConvertTo-Json
try {
    $resp = Invoke-RestMethod -Method Post -Uri "$base/$deckId/cards" -ContentType "application/json" -Body $bodyNoQty
    $code = 200; $qty = $resp.cards[0].quantity
} catch { $code = [int]$_.Exception.Response.StatusCode; $qty = -1 }
Check "GAP: POST add with no quantity -> 200" ($code -eq 200)
Check "GAP: defaulted quantity is 1" ($qty -eq 1)
if ($code -eq 200) { Remove-Card $deckId $printingA | Out-Null }

# 7. Cleanup
Invoke-RestMethod -Method Delete -Uri "$base/$deckId"
Write-Host "`n$pass passed, $fail failed"
