# Test-AddCardApi.ps1 — add-card endpoint proof (Sprint 2)
# Backend must be running on http://localhost:8081

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

function Post-Card($deckId, $scryfallId, $quantity) {
    $body = @{ scryfallId = $scryfallId; quantity = $quantity } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Method Post -Uri "$base/$deckId/cards" -ContentType "application/json" -Body $body
        return @{ Code = 200; Body = $resp }
    } catch {
        return @{ Code = [int]$_.Exception.Response.StatusCode; Body = $null }
    }
}

# 1. Fresh Commander deck
$deckBody = @{ name = "Add-Card Test Deck"; format = "COMMANDER" } | ConvertTo-Json
$deck = Invoke-RestMethod -Method Post -Uri $base -ContentType "application/json" -Body $deckBody
$deckId = $deck.id
Check "deck created" ($null -ne $deckId)

# 2. Add printing A, quantity 1
$r = Post-Card $deckId $printingA 1
Check "add printing A -> 200" ($r.Code -eq 200)
Check "one card row" ($r.Body.cards.Count -eq 1)
Check "quantity is 1" ($r.Body.cards[0].quantity -eq 1)
Check "oracleId matches Scryfall" ($r.Body.cards[0].oracleId -eq $oracleId)
Check "scryfallId is printing A" ($r.Body.cards[0].scryfallId -eq $printingA)

# 3. Add printing B - same oracle, different printing
$r = Post-Card $deckId $printingB 1
Check "add printing B -> 200" ($r.Code -eq 200)
Check "STILL one card row (merged by oracle)" ($r.Body.cards.Count -eq 1)
Check "quantity grew to 2" ($r.Body.cards[0].quantity -eq 2)
Check "stored printing is still A (first chosen)" ($r.Body.cards[0].scryfallId -eq $printingA)

# 4. Read path: GET the deck fresh
$deck = Invoke-RestMethod "$base/$deckId"
Check "GET deck shows one card" ($deck.cards.Count -eq 1)
Check "GET deck shows quantity 2" ($deck.cards[0].quantity -eq 2)

# 5. Error cases
$r = Post-Card $deckId ([guid]::NewGuid()) 1
Check "unknown printing -> 400" ($r.Code -eq 400)
$r = Post-Card ([guid]::NewGuid()) $printingA 1
Check "missing deck -> 404" ($r.Code -eq 404)
$r = Post-Card $deckId $printingA 0
Check "quantity 0 -> 400" ($r.Code -eq 400)

# 6. Cleanup
Invoke-RestMethod -Method Delete -Uri "$base/$deckId"
Write-Host "`n$pass passed, $fail failed"
