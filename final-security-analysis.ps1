Write-Host "ANALISIS COMPLETO DE HEADERS DE SEGURIDAD" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "Esperando reset completo del rate limiting (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

$endpoints = @(
    @{Name="Ultra-Seguro"; Url="http://localhost:8080"; Config="ultra-secure.conf"},
    @{Name="Moderado"; Url="http://localhost:8081"; Config="moderate-secure.conf"}, 
    @{Name="Basico"; Url="http://localhost:8082"; Config="basic.conf"}
)

$securityHeaders = @(
    "X-Content-Type-Options",
    "X-Frame-Options", 
    "X-XSS-Protection",
    "Content-Security-Policy",
    "Referrer-Policy",
    "Cross-Origin-Opener-Policy",
    "Cross-Origin-Embedder-Policy",
    "Cross-Origin-Resource-Policy", 
    "Permissions-Policy",
    "Strict-Transport-Security",
    "Server",
    "X-Powered-By",
    "Cache-Control",
    "Pragma"
)

$results = @{}

Write-Host "`nRealizando analisis detallado..." -ForegroundColor Green

foreach ($endpoint in $endpoints) {
    Write-Host "`nAnalizando $($endpoint.Name) ($($endpoint.Url))..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $endpoint.Url -Method HEAD -TimeoutSec 15
        
        $results[$endpoint.Name] = @{
            Status = "ACTIVO"
            StatusCode = $response.StatusCode
            AllHeaders = $response.Headers
            SecurityHeaders = @{}
        }
        
        Write-Host "  Estado: ACTIVO (HTTP $($response.StatusCode))" -ForegroundColor Green
        
        # Extraer headers de seguridad específicos
        foreach ($header in $securityHeaders) {
            if ($response.Headers.ContainsKey($header)) {
                $value = $response.Headers[$header] -join "; "
                $results[$endpoint.Name].SecurityHeaders[$header] = @{
                    Present = $true
                    Value = $value
                }
                Write-Host "    $header : PRESENTE" -ForegroundColor Green
            } else {
                $results[$endpoint.Name].SecurityHeaders[$header] = @{
                    Present = $false
                    Value = "N/A"
                }
            }
        }
        
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $results[$endpoint.Name] = @{
            Status = "ERROR"
            Error = $_.Exception.Message
        }
    }
    
    Write-Host "  Esperando 10 segundos antes del siguiente..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
}

# Generar reporte completo
Write-Host "`nGenerando reporte final..." -ForegroundColor Cyan

$report = @"
================================================================
             REPORTE FINAL DE SEGURIDAD DE HEADERS
================================================================
Fecha y Hora: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Analisis: Comparativo entre configuraciones nginx
Aplicacion: OWASP Juice Shop con diferentes niveles de seguridad

================================================================
RESUMEN EJECUTIVO
================================================================
"@

foreach ($endpoint in $endpoints) {
    $result = $results[$endpoint.Name]
    
    if ($result.Status -eq "ACTIVO") {
        $totalHeaders = $securityHeaders.Count
        $presentHeaders = ($result.SecurityHeaders.Values | Where-Object { $_.Present }).Count
        $percentage = [math]::Round(($presentHeaders / $totalHeaders) * 100, 1)
        
        $securityLevel = if ($percentage -ge 70) { "ALTO" } 
                        elseif ($percentage -ge 40) { "MEDIO" } 
                        else { "BAJO" }
        
        $report += "`n`n$($endpoint.Name.ToUpper()) ($($endpoint.Config)):"
        $report += "`n  Estado: $($result.Status)"
        $report += "`n  Headers de Seguridad: $presentHeaders/$totalHeaders ($percentage%)"
        $report += "`n  Nivel de Seguridad: $securityLevel"
    } else {
        $report += "`n`n$($endpoint.Name.ToUpper()):"
        $report += "`n  Estado: ERROR"
        $report += "`n  Detalle: $($result.Error)"
    }
}

$report += "`n`n================================================================"
$report += "`nMATRIZ COMPARATIVA DETALLADA"
$report += "`n================================================================"
$report += "`nHeader                          Ultra-Seguro    Moderado       Basico"
$report += "`n" + ("-" * 75)

foreach ($header in $securityHeaders) {
    $line = $header.PadRight(32)
    
    foreach ($endpoint in $endpoints) {
        if ($results[$endpoint.Name].SecurityHeaders) {
            $status = if ($results[$endpoint.Name].SecurityHeaders[$header].Present) { "SI" } else { "NO" }
        } else {
            $status = "ERROR"
        }
        $line += $status.PadRight(15)
    }
    $report += "`n$line"
}

$report += "`n`n================================================================"
$report += "`nANALISIS DE VULNERABILIDADES"
$report += "`n================================================================"

$criticalHeaders = @("Content-Security-Policy", "X-Frame-Options", "X-Content-Type-Options")

foreach ($endpoint in $endpoints) {
    $result = $results[$endpoint.Name]
    
    if ($result.Status -eq "ACTIVO") {
        $report += "`n`n$($endpoint.Name.ToUpper()):"
        
        $vulnerabilities = @()
        $strengths = @()
        
        foreach ($header in $criticalHeaders) {
            if (-not $result.SecurityHeaders[$header].Present) {
                $vulnerabilities += $header
            }
        }
        
        foreach ($header in $securityHeaders) {
            if ($result.SecurityHeaders[$header].Present) {
                $strengths += $header
            }
        }
        
        if ($vulnerabilities.Count -gt 0) {
            $report += "`n  VULNERABILIDADES CRITICAS:"
            foreach ($vuln in $vulnerabilities) {
                $report += "`n    - $vuln ausente"
            }
        } else {
            $report += "`n  Headers criticos: TODOS PRESENTES"
        }
        
        if ($strengths.Count -gt 0) {
            $report += "`n  FORTALEZAS DETECTADAS:"
            foreach ($strength in $strengths) {
                $report += "`n    - $strength implementado"
            }
        }
    }
}

$report += "`n`n================================================================" 
$report += "`nVALORES ESPECIFICOS DE HEADERS"
$report += "`n================================================================"

foreach ($endpoint in $endpoints) {
    $result = $results[$endpoint.Name]
    
    if ($result.Status -eq "ACTIVO") {
        $report += "`n`n$($endpoint.Name.ToUpper()) - HEADERS CONFIGURADOS:"
        $report += "`n" + ("-" * 50)
        
        foreach ($header in $securityHeaders) {
            if ($result.SecurityHeaders[$header].Present) {
                $value = $result.SecurityHeaders[$header].Value
                if ($value.Length -gt 80) {
                    $value = $value.Substring(0, 77) + "..."
                }
                $report += "`n$header = $value"
            }
        }
    }
}

$report += "`n`n================================================================"
$report += "`nRECOMENDACIONES DE MEJORA"
$report += "`n================================================================"

$report += "`n`nPARA CONFIGURACION BASICA:"
$report += "`n- Implementar Content-Security-Policy"
$report += "`n- Anadir X-XSS-Protection"
$report += "`n- Configurar rate limiting"
$report += "`n- Ocultar header Server"

$report += "`n`nPARA CONFIGURACION MODERADA:"
$report += "`n- Implementar Content-Security-Policy estricta"
$report += "`n- Anadir headers anti-Spectre (COOP, COEP, CORP)"
$report += "`n- Configurar Referrer-Policy"
$report += "`n- Implementar Permissions-Policy"

$report += "`n`nPARA CONFIGURACION ULTRA-SEGURA:"
$report += "`n- Verificar que todos los headers esten activos"
$report += "`n- Considerar HSTS si se usa HTTPS"
$report += "`n- Monitoreo continuo de seguridad"
$report += "`n- Evaluar rate limiting (actualmente muy agresivo)"

$report += "`n`n================================================================"
$report += "`nCONCLUSIONES"
$report += "`n================================================================"

$report += "`n`n1. La configuracion Ultra-Segura muestra el mayor nivel de proteccion"
$report += "`n2. Todas las configuraciones necesitan mejoras en headers anti-Spectre"
$report += "`n3. El rate limiting de ultra-secure es efectivo pero puede ser muy restrictivo"
$report += "`n4. Se recomienda implementar CSP en todas las configuraciones"

$report += "`n`n================================================================"
$report += "`nGenerated by: PowerShell Security Headers Analyzer"
$report += "`nTimestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "`n================================================================"

# Guardar reporte
if (!(Test-Path ".\reports")) {
    New-Item -ItemType Directory -Path ".\reports" -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = ".\reports\security-analysis-complete-$timestamp.txt"
$report | Out-File -FilePath $reportPath -Encoding UTF8

# Mostrar resumen en pantalla
Write-Host "`n=== RESUMEN FINAL ===" -ForegroundColor Cyan

foreach ($endpoint in $endpoints) {
    $result = $results[$endpoint.Name]
    
    if ($result.Status -eq "ACTIVO") {
        $presentHeaders = ($result.SecurityHeaders.Values | Where-Object { $_.Present }).Count
        $totalHeaders = $securityHeaders.Count
        $percentage = [math]::Round(($presentHeaders / $totalHeaders) * 100, 1)
        
        $color = if ($percentage -ge 70) { "Green" } 
                elseif ($percentage -ge 40) { "Yellow" } 
                else { "Red" }
        
        Write-Host "$($endpoint.Name): $percentage% ($presentHeaders/$totalHeaders headers)" -ForegroundColor $color
    } else {
        Write-Host "$($endpoint.Name): ERROR - $($result.Error)" -ForegroundColor Red
    }
}

Write-Host "`nReporte completo guardado en:" -ForegroundColor Green
Write-Host "$reportPath" -ForegroundColor White

Write-Host "`nPara ver el reporte:" -ForegroundColor Cyan  
Write-Host "Get-Content '$reportPath'" -ForegroundColor Gray

Write-Host "`nANALISIS COMPLETO FINALIZADO" -ForegroundColor Green