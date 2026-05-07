[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true)]
    [Parameter(ParametersetName="Endpoint")]
    [Parameter(ParametersetName="Infographics")]
    [ValidateSet("HealthCheck", "Infographics")]
    [string]$Endpoint,
    [Parameter(Mandatory=$true)]
    [Parameter(ParametersetName="Infographics")]
    [ValidateSet("ErzeugungErneuerbarerEnergien", "Lastfluesse", "EigenerzeugungVonEnergie", "WoechentlicherEnergieverbrauch", "VerfuegbareEnergie", "GaskraftwerkeErzeugungsgrad", "ImportEuropaeischerReglerwerte")]
    [string]$InfographicsSlug
)
$InfoGraphicsHost = "https://app.23degrees.io/api/v2/content"
$InfoGraphicsEndpoint = "/{0}/data"
$PeakHourHost = "https://awareness.cloud.apg.at/api"
$PeakHourHealthEndpoint = "/healthz"
$PeakHourStatusEndpoint = "/v1/PeakHourStatus"
$AuthHeader = @{"Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NDUwZGMwMjEzNjhkM2YwZDkzZWMxMGQiLCJlbWFpbCI6ImFwZy1hcGlAMjNkZWdyZWVzLmlvIiwic2x1ZyI6ImFwZy1hcGktdXNlciIsInJvbGVzIjpbXSwiaWF0IjoxNjgzMDIwODAyfQ.SuwZlsWe_GopDUhTg3RTaRhOGA0roqeD5UyoTbMyHsQ"}

# Slugs for infographics
$Slugs = @{
    "ErzeugungErneuerbarerEnergien" = "onFQVwdMNSZ62rCN-line-erzeugung-erneuerbarer-energien"
    "Lastfluesse" = "n3vfefqpLyjsQ5s2-line-lastfluesse"
    "EigenerzeugungVonEnergie" = "dpcgsZKysiXZmwtf-bar-vertical-eigenerzeugung-von-energie-in"
    "WoechentlicherEnergieverbrauch" = "K7tley8BjdU1ng8j-bar-vertical-woechentlicher-energieverbrauch"
    "VerfuegbareEnergie" = "btohciVvwEG8jAGr-donut-verfuegbare"
    "GaskraftwerkeErzeugungsgrad" = "N8hJwwM6SllaR3bZ-donut-gaskraftwerke-erzeugungsgrad"
    "ImportEuropaeischerReglerwerte" = "VUGApLOeJOMFkc13-bar-vertical-import-europaeischer-reglerwerte"
}

function Get-InfographicData
{
    param
    (
        [string]$Slug
    )

    $url = "$InfoGraphicsHost$InfoGraphicsEndpoint" -f $Slug

    try
    {
        $response = Invoke-RestMethod -Uri $url -Headers $authHeader
        return $response.payload
    }

    catch
    {
        Write-Error "Fehler beim Abrufen der Infografik-Daten: $_"
        return $null
    }
}

function Get-PeakHourStatus
{
    $healthUrl = "$PeakHourHost$PeakHourHealthEndpoint"
    $statusUrl = "$PeakHourHost$PeakHourStatusEndpoint"

    try
    {
        # Überprüfen Sie die Gesundheit der API
        $healthResponse = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing
        if ($healthResponse.StatusCode -ne 200) {
            Write-Error "Die Peak Hour API konnte nicht abgefragt werden. Statuscode: $($healthResponse.StatusCode)"
            return $null
        }

        # Abrufen des Peak Hour Status
        $statusResponse = Invoke-WebRequest -Uri $statusUrl -UseBasicParsing
        return $statusResponse.Content | ConvertFrom-Json
    }

    catch
    {
        Write-Error "Fehler beim Abrufen des Peak Hour Status: $_"
        return $null
    }
}

if ($Endpoint -eq "Infographics")
{
    $slug = $Slugs[$InfographicsSlug]
    Get-InfographicData -Slug $slug
}

Elseif ($Endpoint -eq "HealthCheck")
{
    Get-PeakHourStatus
}