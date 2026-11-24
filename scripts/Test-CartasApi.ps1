# Cartas - Deck API tests v2 (PowerShell)
# Updated for: PATCH /api/decks/{id} rename, 201 Location header, exception-based 404s.
# Run with the backend up:  .\mvnw.cmd spring-boot:run   (port 8081)
# Then in another PowerShell window:  .\cartas-deck-api-tests.ps1
# Works in Windows PowerShell 5.1 and PowerShell 7.

$base = "http://localhost:8081/api"
$script:pass = 0
$script:fail = 0

function Check($name, $condition) {
    if ($condition) {
        $script:pass++
        Write-Host "PASS  $name" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "FAIL  $name (HTTP $script:lastStatus)" -ForegroundColor Red
    }
}

# Calls the API and returns @{ Status; Body; Headers } - never throws on 4xx/5xx,
# so tests can assert on error status codes.
function Call($method, $url, $body) {
    try {
        $params = @{ Method = $method; Uri = $url; ContentType = "application/json" }
        if ($null -ne $body) { $params.Body = ($body | ConvertTo-Json) }
        $r = Invoke-WebRequest @params -UseBasicParsing
        $parsed = $null
        if ($r.Content) { $parsed = $r.Content | ConvertFrom-Json }
        $script:lastStatus = [int]$r.StatusCode
        return @{ Status = [int]$r.StatusCode; Body = $parsed; Headers = $r.Headers }
    } catch {
        if ($_.Exception.Response) {
            $script:lastStatus = [int]$_.Exception.Response.StatusCode
            return @{ Status = [int]$_.Exception.Response.StatusCode; Body = $null; Headers = $null }
        }
        throw
    }
}

# Pantlaza, Sun-Favored (LCC #124) - a real legendary creature. Create-deck
# validates the commander through Scryfall, so a made-up GUID gets a 400.
$commander = "150a35f8-bbdc-4f6e-98e3-3bd6a3b8154a"
$missingId = [guid]::NewGuid()

Write-Host "`n--- Health ---"
$r = Call GET "$base/health"
Check "GET /api/health returns 200" ($r.Status -eq 200)

Write-Host "`n--- Create deck ---"
$r = Call POST "$base/decks" @{ name = "API Test Deck"; format = "COMMANDER"; commanderScryfallId = $commander }
Check "POST /decks returns 201" ($r.Status -eq 201)
Check "Created deck echoes the name" ($r.Body.name -eq "API Test Deck")
Check "Created deck echoes format COMMANDER" ($r.Body.format -eq "COMMANDER")
Check "Created deck saved the commander" ($r.Body.commanderScryfallId -eq $commander)
$deckId = $r.Body.id
Check "Created deck has an id" ($null -ne $deckId)
$location = $r.Headers["Location"]
Check "POST returns a Location header for the new deck" ($location -like "*/api/decks/$deckId")
$r = Call GET $location
Check "Following the Location header returns the deck (200)" ($r.Status -eq 200 -and $r.Body.id -eq $deckId)

Write-Host "`n--- Create with defaults (name only) ---"
$r = Call POST "$base/decks" @{ name = "Defaults Deck" }
Check "POST name-only returns 201" ($r.Status -eq 201)
Check "Format defaults to COMMANDER" ($r.Body.format -eq "COMMANDER")
Check "Commander defaults to null" ($null -eq $r.Body.commanderScryfallId)
$defaultsId = $r.Body.id

Write-Host "`n--- Create validation ---"
$r = Call POST "$base/decks" @{ name = "" }
Check "POST blank name returns 400" ($r.Status -eq 400)

Write-Host "`n--- Get deck ---"
$r = Call GET "$base/decks/$deckId"
Check "GET /decks/{id} returns 200" ($r.Status -eq 200)
Check "GET returns the same deck" ($r.Body.id -eq $deckId -and $r.Body.name -eq "API Test Deck")
$r = Call GET "$base/decks/$missingId"
Check "GET missing deck returns 404" ($r.Status -eq 404)

Write-Host "`n--- Get all decks ---"
$r = Call GET "$base/decks"
Check "GET /decks returns 200" ($r.Status -eq 200)
Check "GET /decks contains the created deck" ((($r.Body | Where-Object { $_.id -eq $deckId }) | Measure-Object).Count -eq 1)

Write-Host "`n--- Rename deck (PATCH /{id}) ---"
$r = Call PATCH "$base/decks/$deckId" @{ name = "Renamed Test Deck" }
Check "PATCH rename returns 200" ($r.Status -eq 200)
Check "PATCH response shows the new name" ($r.Body.name -eq "Renamed Test Deck")
$r = Call GET "$base/decks/$deckId"
Check "Rename persisted (GET shows new name)" ($r.Body.name -eq "Renamed Test Deck")
Check "Rename kept format and commander" ($r.Body.format -eq "COMMANDER" -and $r.Body.commanderScryfallId -eq $commander)
$r = Call PATCH "$base/decks/$missingId" @{ name = "Ghost Deck" }
Check "PATCH missing deck returns 404" ($r.Status -eq 404)
$r = Call PATCH "$base/decks/$deckId" @{ name = "" }
Check "PATCH blank name returns 400" ($r.Status -eq 400)
$r = Call PATCH "$base/decks/$deckId/rename" @{ name = "Old Path Deck" }
Check "Old /rename path is gone (404 or 405)" ($r.Status -eq 404 -or $r.Status -eq 405)

Write-Host "`n--- Delete deck (DELETE) ---"
$r = Call POST "$base/decks" @{ name = "Throwaway Deck" }
$throwawayId = $r.Body.id
$r = Call DELETE "$base/decks/$throwawayId"
Check "DELETE returns 204" ($r.Status -eq 204)
$r = Call GET "$base/decks/$throwawayId"
Check "Deleted deck is gone (GET returns 404)" ($r.Status -eq 404)
$r = Call DELETE "$base/decks/$throwawayId"
Check "DELETE missing deck returns 404" ($r.Status -eq 404)

Write-Host "`n--- Cleanup (delete the test decks) ---"
Call DELETE "$base/decks/$deckId" | Out-Null
Call DELETE "$base/decks/$defaultsId" | Out-Null
Write-Host "Test decks deleted."

Write-Host "`n==============================="
Write-Host "RESULT: $script:pass passed, $script:fail failed"
Write-Host "==============================="
