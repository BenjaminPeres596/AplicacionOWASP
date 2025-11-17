# Script Completo de Analisis de Seguridad OWASP ZAP
# Version simplificada sin caracteres especiales

param(
    [ValidateSet("baseline", "full")]
    [string]$ScanType = "baseline",
    [int]$ScanTime = 2
)

Write-Host "ANALISIS COMPLETO DE SEGURIDAD OWASP ZAP" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Configuracion de servidores
$servers = @(
    @{
        Name = "Ultra-Seguro"
        URL = "http://ultra-secure-proxy:80"
        Container = "ultra-secure-proxy"
        OutputPrefix = "ultra-seguro"
        Port = "8080"
    },
    @{
        Name = "Moderado"
        URL = "http://moderate-secure-proxy:80"
        Container = "moderate-secure-proxy"
        OutputPrefix = "moderado"
        Port = "8081"
    },
    @{
        Name = "Basico"
        URL = "http://basic-proxy:80"
        Container = "basic-proxy"
        OutputPrefix = "basico"
        Port = "8082"
    },
    @{
        Name = "Juice-Shop"
        URL = "http://juice-shop:3000"
        Container = "juice-shop"
        OutputPrefix = "juice-shop"
        Port = "3000"
    }
)

# Levantar todos los contenedores
Write-Host "`nLevantando todos los contenedores..." -ForegroundColor Blue
docker compose up -d | Out-Null
Start-Sleep 15

Write-Host "Contenedores activos:" -ForegroundColor Green
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Crear directorio de reportes
if (-not (Test-Path ".\reports")) {
    New-Item -ItemType Directory -Path ".\reports" -Force | Out-Null
}

Write-Host "`nINICIANDO ESCANEOS" -ForegroundColor Cyan
Write-Host "Tipo: $ScanType" -ForegroundColor Yellow

$successful = 0

foreach ($server in $servers) {
    Write-Host "`nEscaneando: $($server.Name)" -ForegroundColor Magenta
    
    $htmlFile = "reporte-$($server.OutputPrefix).html"
    $xmlFile = "reporte-$($server.OutputPrefix).xml"
    
    try {
        if ($ScanType -eq "baseline") {
            $cmd = "docker compose run --rm -v `"${PWD}/reports:/zap/reports`" zap sh -c `"cd /zap/reports && zap-baseline.py -t $($server.URL) -r $htmlFile -x $xmlFile -I`""
        } else {
            $cmd = "docker compose run --rm -v `"${PWD}/reports:/zap/reports`" zap sh -c `"cd /zap/reports && zap-full-scan.py -t $($server.URL) -m $ScanTime -r $htmlFile -x $xmlFile -I`""
        }
        
        Invoke-Expression $cmd | Out-Null
        
        if (Test-Path ".\reports\$xmlFile") {
            Write-Host "  COMPLETADO: $($server.Name)" -ForegroundColor Green
            $successful++
        } else {
            Write-Host "  ERROR: $($server.Name)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ERROR: $($server.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep 3
}

Write-Host "`nRESUMEN: $successful/$($servers.Count) escaneos completados" -ForegroundColor Blue

# Procesar reportes
Write-Host "`nProcesando reportes..." -ForegroundColor Cyan

if (Test-Path ".\zap-report-processor-simple.ps1") {
    .\zap-report-processor-simple.ps1 -InputPath ".\reports"
} else {
    Write-Host "Procesador no encontrado" -ForegroundColor Yellow
}

# Mostrar resultados
Write-Host "`nARCHIVOS GENERADOS:" -ForegroundColor Green
Write-Host "XML reports en: .\reports\" -ForegroundColor White
Get-ChildItem ".\reports" -Filter "reporte-*.xml" | ForEach-Object {
    Write-Host "  $($_.Name)" -ForegroundColor Gray
}

$processedDir = ".\reports\processed"
if (Test-Path $processedDir) {
    Write-Host "`nHTML reports en: $processedDir\" -ForegroundColor White
    Get-ChildItem $processedDir -Filter "*.html" | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Gray
    }
    
    Write-Host "`nAbriendo carpeta de reportes..." -ForegroundColor Green
    Start-Process $processedDir
}

Write-Host "`nANALISIS COMPLETADO!" -ForegroundColor Green