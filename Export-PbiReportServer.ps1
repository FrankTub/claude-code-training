<#
.SYNOPSIS
    Exporteert alle Power BI-rapporten van een Power BI Report Server naar een lokale mappenstructuur,
    met datamodel maar zonder data.

.DESCRIPTION
    Gebruikt de Report Server REST API v2.0 met de huidige Windows-gebruiker (domain authenticatie).
    De server bewaart rapporten als .pbix, inclusief data. Elke .pbix wordt naar een tijdelijke map
    buiten de exportmap gedownload en met pbi-tools uitgepakt. pbi-tools schrijft het model (tabellen,
    kolommen, measures, relaties), Power Query en de rapportopmaak als tekstbestanden, zonder data.
    Daarna wordt de .pbix verwijderd, ook als het uitpakken mislukt.

    Vereist pbi-tools (Desktop-editie) en Power BI Desktop op deze machine.

.EXAMPLE
    .\Export-PbiReportServer.ps1 -ServerUrl http://pbirs/reports -OutputPath D:\pbi-export

.EXAMPLE
    .\Export-PbiReportServer.ps1 -ServerUrl http://pbirs/reports -OutputPath D:\pbi-export -PbiToolsPath C:\Tools\pbi-tools\pbi-tools.exe
#>
[CmdletBinding()]
param(
    # Basis-URL van het webportaal, bijvoorbeeld http://pbirs/reports
    [Parameter(Mandatory)]
    [string]$ServerUrl,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    # Pad naar pbi-tools.exe; standaard wordt pbi-tools op het PATH gebruikt
    [string]$PbiToolsPath = 'pbi-tools'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest is anders erg traag in PS 5.1

if (-not (Get-Command $PbiToolsPath -ErrorAction SilentlyContinue)) {
    throw "pbi-tools niet gevonden ('$PbiToolsPath'). Installeer pbi-tools of geef -PbiToolsPath op."
}

$apiBase = $ServerUrl.TrimEnd('/') + '/api/v2.0'

function Get-SafeName([string]$Name) {
    $invalid = [IO.Path]::GetInvalidFileNameChars() -join ''
    return ($Name -replace "[$([regex]::Escape($invalid))]", '_')
}

# Alle rapporten ophalen, inclusief eventuele paginering
$reports = @()
$uri = "$apiBase/PowerBIReports"
while ($uri) {
    $page = Invoke-RestMethod -Uri $uri -UseDefaultCredentials
    $reports += $page.value
    $uri = $page.'@odata.nextLink'
}
Write-Host "$($reports.Count) rapporten gevonden."

$failed = @()
foreach ($report in $reports) {
    # De .pbix bevat data en komt daarom nooit in de exportmap
    $file = Join-Path ([IO.Path]::GetTempPath()) "$([guid]::NewGuid()).pbix"
    try {
        # Path = /Map/Submap/Rapportnaam -> lokale submappen
        $segments = $report.Path.Trim('/') -split '/' | ForEach-Object { Get-SafeName $_ }
        $name = $segments[-1]
        $folderParts = @($segments | Select-Object -SkipLast 1)
        $targetDir = [IO.Path]::Combine([string[]](@($OutputPath) + $folderParts))
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

        Invoke-WebRequest -Uri "$apiBase/PowerBIReports($($report.Id))/Content/`$value" `
            -UseDefaultCredentials -OutFile $file

        $extractDir = Join-Path $targetDir $name
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
        # Continue: in PS 5.1 breekt 'Stop' anders af op elke regel die pbi-tools naar stderr schrijft
        $ErrorActionPreference = 'Continue'
        $log = & $PbiToolsPath extract $file -extractFolder $extractDir 2>&1
        $ErrorActionPreference = 'Stop'
        if ($LASTEXITCODE -ne 0) {
            throw "pbi-tools extract gaf exitcode $LASTEXITCODE`n$(($log | Select-Object -Last 5) -join "`n")"
        }

        # Vangnet: een binair DataModel bevat data en mag niet in de export staan
        if (Get-ChildItem $extractDir -Recurse -File -Filter DataModel) {
            Remove-Item $extractDir -Recurse -Force
            throw "uitgepakte map bevatte een binair DataModel; map verwijderd"
        }
        Write-Host "OK   $($report.Path)"
    }
    catch {
        Write-Warning "FOUT $($report.Path): $($_.Exception.Message)"
        $failed += $report.Path
    }
    finally {
        if (Test-Path $file) { Remove-Item $file -Force }
    }
}

Write-Host "Klaar. $($reports.Count - $failed.Count) gelukt, $($failed.Count) mislukt."
if ($failed) { $failed | ForEach-Object { Write-Host "  mislukt: $_" } }
