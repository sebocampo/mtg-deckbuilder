# Test-CopyLimitsApi.ps1 — format copy-limit proof (Sprint 2)
# Backend must be running on http://localhost:8081
# Rules under test: Commander max 1 copy per card, Standard + Pauper max 4,
# basic lands exempt. Enforced on BOTH add (POST) and quantity update (PATCH).
# A rejected request must leave the deck unchanged.

$base = "http://localhost:8081/api/decks"
$pass = 0; $fail = 0
function Check($name, $condition) {
    if ($condition) { $script:pass++; Write-Host "PASS  $name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "FAIL  $name" -ForegroundColor Red }
}

# Cards (all verified against Scryfall)
$solRingOracle = "6ad8011d-3471-4369-9d68-b264cc027487"
$printingA     = "c4300d24-1cae-4dd5-be7e-38cc677cf5bd"  # Sol Ring, LEA
$printingB     = "fc817e07-c1f3-469f-9cf7-0945dea7400f"  # Sol Ring, TRC (same oracle)
$arcaneSignet  = "795df2ee-fbfc-4961-852c-e3ec50cc52da"  # Arcane Signet, TRC
$plains        = "09ac862f-0a51-44dd-b86f-9412b8218b13"  # Plains — type_line "Basic Land"

function New-Deck($name, $format) {
    $body = @{ name = $name; format = $format } | ConvertTo-Json
    $deck = Invoke-RestMethod -Method Post -Uri $base -ContentType "application/json" -Body $body
    return $deck.id
}

function Send-Card($method, $deckId, $scryfallId, $quantity) {
    $body = @{ scryfallId = $scryfallId; quantity = $quantity } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Method $method -Uri "$base/$deckId/cards" -ContentType "application/json" -Body $body
        return @{ Code = 200; Body = $resp }
    } catch {
        return @{ Code = [int]$_.Exception.Response.StatusCode; Body = $null }
    }
}

function Get-CardRow($deckId, $oracleId) {
    $deck = Invoke-RestMethod "$base/$deckId"
    return $deck.cards | Where-Object { $_.oracleId -eq $oracleId } | Select-Object -First 1
}

# ---------- Commander: limit 1 ----------
$cmdId = New-Deck "Copy-Limit Commander" "COMMANDER"
Check "commander deck created" ($null -ne $cmdId)

$r = Send-Card Post $cmdId $printingA 1
Check "CMD: add Sol Ring x1 -> 200" ($r.Code -eq 200)
Check "CMD: quantity is 1" ($r.Body.cards[0].quantity -eq 1)

$r = Send-Card Post $cmdId $printingB 1
Check "CMD: add 2nd copy (other printing, same oracle) -> 400" ($r.Code -eq 400)

$row = Get-CardRow $cmdId $solRingOracle
Check "CMD: rejected add changed nothing (still qty 1)" ($null -ne $row -and $row.quantity -eq 1)

$r = Send-Card Patch $cmdId $printingA 2
Check "CMD: PATCH quantity to 2 -> 400" ($r.Code -eq 400)

$r = Send-Card Patch $cmdId $printingA 1
Check "CMD: PATCH quantity to 1 (at limit) -> 200" ($r.Code -eq 200)

# ---------- Commander: basic lands are exempt ----------
$r = Send-Card Post $cmdId $plains 10
Check "CMD: add Plains x10 -> 200 (basic land exempt)" ($r.Code -eq 200)
$row = $r.Body.cards | Where-Object { $_.scryfallId -eq $plains } | Select-Object -First 1
Check "CMD: Plains quantity is 10" ($row.quantity -eq 10)

$r = Send-Card Post $cmdId $plains 5
Check "CMD: add 5 more Plains -> 200" ($r.Code -eq 200)
$row = $r.Body.cards | Where-Object { $_.scryfallId -eq $plains } | Select-Object -First 1
Check "CMD: Plains quantity is 15" ($row.quantity -eq 15)

$r = Send-Card Patch $cmdId $plains 20
Check "CMD: PATCH Plains to 20 -> 200" ($r.Code -eq 200)

# ---------- Commander: single request over the limit ----------
$cmd2Id = New-Deck "Copy-Limit Commander 2" "COMMANDER"
$r = Send-Card Post $cmd2Id $printingA 2
Check "CMD: add Sol Ring x2 in one request -> 400" ($r.Code -eq 400)
$deck = Invoke-RestMethod "$base/$cmd2Id"
Check "CMD: deck is still empty after rejection" ($deck.cards.Count -eq 0)

# ---------- Standard: limit 4 ----------
$stdId = New-Deck "Copy-Limit Standard" "STANDARD"
$r = Send-Card Post $stdId $arcaneSignet 4
Check "STD: add Arcane Signet x4 -> 200" ($r.Code -eq 200)
Check "STD: quantity is 4" ($r.Body.cards[0].quantity -eq 4)

$r = Send-Card Post $stdId $arcaneSignet 1
Check "STD: add a 5th copy -> 400" ($r.Code -eq 400)

$r = Send-Card Patch $stdId $arcaneSignet 5
Check "STD: PATCH quantity to 5 -> 400" ($r.Code -eq 400)

$r = Send-Card Patch $stdId $arcaneSignet 4
Check "STD: PATCH quantity to 4 (at limit) -> 200" ($r.Code -eq 200)

$r = Send-Card Post $stdId $printingA 5
Check "STD: add Sol Ring x5 in one request -> 400" ($r.Code -eq 400)

# ---------- Pauper: limit 4 ----------
$pauId = New-Deck "Copy-Limit Pauper" "PAUPER"
$r = Send-Card Post $pauId $printingA 4
Check "PAU: add Sol Ring x4 -> 200" ($r.Code -eq 200)
$r = Send-Card Post $pauId $printingA 1
Check "PAU: add a 5th copy -> 400" ($r.Code -eq 400)

# ---------- Cleanup ----------
foreach ($id in @($cmdId, $cmd2Id, $stdId, $pauId)) {
    Invoke-RestMethod -Method Delete -Uri "$base/$id" | Out-Null
}
Write-Host "`n$pass passed, $fail failed"
