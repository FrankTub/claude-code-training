# Claude Code workshop voor ASZ-collega's

Lesmateriaal voor een workshop van ongeveer een uur over veilig werken met Claude Code in het ASZ. Zie [MISSION.md](MISSION.md) voor doel en scope.

## Inhoud

| Map / bestand | Wat |
|---|---|
| `index.html`, `lessons/` | Lessen (hand-out en oefenmateriaal) |
| `reference/` | Naslag: begrippen, draaiboek, MCP en skills, veilig werken |
| `example-queries/` | Voorbeeldqueries (T-SQL) waar de skill `adhoc-query` op bouwt |
| `.claude/skills/adhoc-query/` | Skill die een datavraag omzet in een query |
| `Export-PbiReportServer.ps1` | Script dat Power BI-rapporten exporteert en uitpakt, zonder data |

## Skill: `adhoc-query`

Zet de datavraag van een eindgebruiker om in een T-SQL-query. De skill gebruikt alleen tabellen, joins, filters en kolommen die al in een voorbeeldquery in `example-queries/` staan.

Aanroepen in Claude Code (alleen handmatig; Claude start deze skill niet zelf):

```
/adhoc-query Aantal SEH-bezoeken per maand in 2025, per specialisme
```

Wat de skill doet:

1. Leest alle `.sql`-bestanden in `example-queries/`.
2. Splitst de vraag in meetwaarden, granulariteit, filters en periode. Bij twijfel stelt de skill genummerde vragen.
3. Zoekt voor elk onderdeel de bron: een voorbeeldbestand en regel.
4. Ontbreekt een bron, dan krijg je alleen een dekkingsrapport. Voeg een voorbeeldquery toe en roep de skill opnieuw aan.
5. Anders krijg je de query, een tabel met de bron van elk onderdeel en de gekozen betekenissen.

De skill voert de query niet uit. Claude heeft geen databaseverbinding (ASZ-afspraak). Voer de query zelf uit en deel alleen geaggregeerde resultaten die niet naar een patiënt te herleiden zijn.

## Script: `Export-PbiReportServer.ps1`

Exporteert alle Power BI-rapporten van een Power BI Report Server via de REST API v2.0, met je eigen Windows-account. Per rapport:

1. Download de `.pbix` naar een tijdelijke map buiten de exportmap.
2. Pak de `.pbix` uit met `pbi-tools extract`, in een map met de naam van het rapport. De mappen volgen de mappenstructuur op de server.
3. Verwijder de `.pbix`, ook als het uitpakken mislukt.

`pbi-tools` schrijft het datamodel (tabellen, kolommen, measures, relaties), de Power Query-stappen en de rapportopmaak als tekstbestanden. De data zelf neemt het niet mee. Na afloop staan er alleen uitgepakte mappen, zonder data en zonder `.pbix`-bestanden.

### Vereisten

- [pbi-tools](https://pbi.tools), Desktop-editie, op het `PATH` of via `-PbiToolsPath`.
- Power BI Desktop op dezelfde machine. `pbi-tools` gebruikt die om het model te lezen.
- Leesrechten op de Report Server met je Windows-account.

### pbi-tools installeren

`pbi-tools` is een ZIP-bestand zonder installer. Gebruik de Desktop-editie (`pbi-tools.exe`), niet de Core-editie (`pbi-tools.core`). Vraag bij twijfel eerst akkoord van IT of security: het is een tool van GitHub.

Handmatig:

1. Open de [laatste release](https://github.com/pbi-tools/pbi-tools/releases/latest).
2. Download onder *Assets* de ZIP zonder `core` in de naam.
3. Deblokkeer de ZIP: rechtermuisklik, *Properties*, vink *Unblock* aan. Of gebruik `Unblock-File`.
4. Pak de ZIP uit, bijvoorbeeld naar `C:\Tools\pbi-tools`.
5. Controleer de installatie met `C:\Tools\pbi-tools\pbi-tools.exe info`. De uitvoer toont welke Power BI Desktop-installaties `pbi-tools` vindt.

Of in PowerShell. Controleer eerst de naam van de gekozen asset; het filter is niet getest tegen de actuele release.

```powershell
$rel = Invoke-RestMethod https://api.github.com/repos/pbi-tools/pbi-tools/releases/latest
$asset = $rel.assets | Where-Object { $_.name -like '*.zip' -and $_.name -notlike '*core*' } | Select-Object -First 1
$asset.name
$zip = Join-Path $env:TEMP $asset.name
Invoke-WebRequest $asset.browser_download_url -OutFile $zip
Unblock-File $zip
Expand-Archive $zip -DestinationPath C:\Tools\pbi-tools -Force
C:\Tools\pbi-tools\pbi-tools.exe info
```

Daarna:

- Zet `C:\Tools\pbi-tools` in je gebruikers-`PATH`, of geef het script `-PbiToolsPath C:\Tools\pbi-tools\pbi-tools.exe` mee.
- Heb je alleen Power BI Desktop voor Report Server, en vindt `info` die niet? Zet dan de omgevingsvariabele `PBITOOLS_PbiInstallDir` op de installatiemap van die versie. Waarschijnlijk is dat `C:\Program Files\Microsoft Power BI Desktop RS`; controleer dat op je eigen machine.

Bron: [pbi.tools/cli](https://pbi.tools/cli/)

### Parameters

| Parameter | Verplicht | Betekenis |
|---|---|---|
| `-ServerUrl` | ja | Basis-URL van het webportaal, bijvoorbeeld `http://pbirs/reports` |
| `-OutputPath` | ja | Map waarin de export komt |
| `-PbiToolsPath` | nee | Pad naar `pbi-tools.exe`. Standaard: `pbi-tools` op het `PATH`. |

### Voorbeelden

Standaard, met `pbi-tools` op het `PATH`:

```powershell
.\Export-PbiReportServer.ps1 -ServerUrl http://pbirs/reports -OutputPath D:\pbi-export
```

Met een eigen pad naar `pbi-tools`:

```powershell
.\Export-PbiReportServer.ps1 -ServerUrl http://pbirs/reports -OutputPath D:\pbi-export -PbiToolsPath C:\Tools\pbi-tools\pbi-tools.exe
```

Blokkeert Windows het script (execution policy), start het dan zo:

```powershell
powershell -ExecutionPolicy Bypass -File .\Export-PbiReportServer.ps1 -ServerUrl http://pbirs/reports -OutputPath D:\pbi-export
```

### Goed om te weten

- Test eerst met één rapport. Controleer dat het model compleet is en dat er geen data in de map staat.
- Vangnet: staat er na het uitpakken toch een binair `DataModel`-bestand in de map, dan verwijdert het script die map en meldt het rapport als mislukt.
- Mislukt een rapport, dan meldt het script dat aan het eind, met de laatste regels van de `pbi-tools`-uitvoer.
- Rapporten van de Report Server horen bij een eigen versie van Power BI Desktop (Report Server-editie). Werkt `pbi-tools` daar niet mee, dan meldt het script die rapporten als mislukt.
