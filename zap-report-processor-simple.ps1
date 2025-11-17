# Procesador de Reportes OWASP ZAP - Version Simplificada
# Convierte los reportes XML de ZAP en documentos mas legibles

param(
    [string]$InputPath = ".",
    [string]$OutputDir = "./reports/processed",
    [switch]$GenerateComparative
)

# Crear directorio de salida si no existe
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Funcion para extraer datos de XML de ZAP
function Parse-ZapXmlReport {
    param([string]$XmlPath)
    
    if (-not (Test-Path $XmlPath)) {
        return $null
    }
    
    try {
        [xml]$xml = Get-Content $XmlPath
        
        $report = @{
            GeneratedTime = $xml.OWASPZAPReport.generated
            Version = $xml.OWASPZAPReport.version
            Site = ""
            Alerts = @()
            Summary = @{
                High = 0
                Medium = 0
                Low = 0
                Informational = 0
                Total = 0
            }
        }
        
        # Extraer informacion del sitio
        if ($xml.OWASPZAPReport.site) {
            $report.Site = $xml.OWASPZAPReport.site.name
        }
        
        # Procesar alertas
        if ($xml.OWASPZAPReport.site.alerts.alertitem) {
            foreach ($alert in $xml.OWASPZAPReport.site.alerts.alertitem) {
                $alertObj = @{
                    Name = $alert.name
                    RiskDesc = $alert.riskdesc
                    Risk = $alert.riskdesc.Split(' ')[0]
                    Confidence = $alert.confidence
                    Description = $alert.desc
                    Solution = $alert.solution
                    Reference = $alert.reference
                    Instances = @()
                }
                
                # Contar por nivel de riesgo
                switch ($alertObj.Risk) {
                    "High" { $report.Summary.High++ }
                    "Medium" { $report.Summary.Medium++ }
                    "Low" { $report.Summary.Low++ }
                    "Informational" { $report.Summary.Informational++ }
                }
                $report.Summary.Total++
                
                $report.Alerts += $alertObj
            }
        }
        
        return $report
    }
    catch {
        Write-Warning "Error procesando $XmlPath : $($_.Exception.Message)"
        return $null
    }
}

# Script principal
Write-Host "PROCESADOR DE REPORTES OWASP ZAP" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Buscar archivos XML de ZAP
$xmlFiles = Get-ChildItem -Path $InputPath -Filter "reporte-*.xml" -ErrorAction SilentlyContinue

if ($xmlFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos XML de ZAP en $InputPath" -ForegroundColor Red
    Write-Host "Busca archivos con patron: reporte-*.xml" -ForegroundColor Yellow
    exit 1
}

$processedReports = @()

foreach ($xmlFile in $xmlFiles) {
    Write-Host "Procesando: $($xmlFile.Name)" -ForegroundColor Green
    
    $reportData = Parse-ZapXmlReport -XmlPath $xmlFile.FullName
    
    if ($reportData) {
        # Determinar tipo de servidor
        $serverType = switch -Regex ($xmlFile.BaseName) {
            "ultra" { "Ultra-Seguro" }
            "moderate|moderado" { "Moderado" }
            "basic|basico" { "Basico" }
            "directo|juice-shop" { "Juice-Shop (Sin Proteccion)" }
            default { "Desconocido" }
        }
        
        # Generar reporte HTML simple
        $outputFile = Join-Path $OutputDir "reporte-simple-$($xmlFile.BaseName).html"
        
        $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Reporte de Seguridad - $serverType</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 30px; }
        .summary { display: flex; gap: 20px; margin-bottom: 30px; }
        .card { background: white; border: 1px solid #dee2e6; padding: 20px; border-radius: 5px; text-align: center; flex: 1; }
        .high { border-left: 5px solid #dc3545; }
        .medium { border-left: 5px solid #fd7e14; }
        .low { border-left: 5px solid #ffc107; }
        .info { border-left: 5px solid #17a2b8; }
        .alert { margin-bottom: 20px; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; }
        .alert h3 { margin-top: 0; }
        .risk-high { background-color: #f8d7da; }
        .risk-medium { background-color: #fff3cd; }
        .risk-low { background-color: #d4edda; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Reporte de Seguridad - $serverType</h1>
        <p>Generado: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    </div>
    
    <div class="summary">
        <div class="card high">
            <h2>$($reportData.Summary.High)</h2>
            <p>Alto Riesgo</p>
        </div>
        <div class="card medium">
            <h2>$($reportData.Summary.Medium)</h2>
            <p>Riesgo Medio</p>
        </div>
        <div class="card low">
            <h2>$($reportData.Summary.Low)</h2>
            <p>Riesgo Bajo</p>
        </div>
        <div class="card info">
            <h2>$($reportData.Summary.Informational)</h2>
            <p>Informativo</p>
        </div>
    </div>
    
    <h2>Vulnerabilidades Encontradas</h2>
"@

        # Agregar alertas
        $sortedAlerts = $reportData.Alerts | Sort-Object { 
            switch ($_.Risk) {
                "High" { 1 }
                "Medium" { 2 }
                "Low" { 3 }
                "Informational" { 4 }
                default { 5 }
            }
        }

        foreach ($alert in $sortedAlerts) {
            $riskClass = "risk-" + $alert.Risk.ToLower()
            $htmlContent += @"
    <div class="alert $riskClass">
        <h3>$($alert.Name)</h3>
        <p><strong>Riesgo:</strong> $($alert.RiskDesc)</p>
        <p><strong>Descripcion:</strong> $($alert.Description)</p>
        $(if($alert.Solution) { "<p><strong>Solucion:</strong> $($alert.Solution)</p>" })
    </div>
"@
        }

        $htmlContent += @"
</body>
</html>
"@

        $htmlContent | Out-File -FilePath $outputFile -Encoding UTF8
        Write-Host "Generado: $outputFile" -ForegroundColor Green
        
        $processedReports += @{
            Type = $serverType.ToLower() -replace " .*",""
            File = $outputFile
            Data = $reportData
        }
    }
}

Write-Host "`nProcesamiento completado!" -ForegroundColor Green
Write-Host "Archivos generados en: $OutputDir" -ForegroundColor Yellow