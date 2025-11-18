# Analizador de Headers de Seguridad - Version Simple
# Compara headers entre los diferentes niveles de seguridad

Write-Host "ANALISIS DE HEADERS DE SEGURIDAD" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Crear directorio para reportes si no existe
if (-not (Test-Path "reports")) { 
    New-Item -ItemType Directory -Path "reports" | Out-Null 
}

# Inicializar reporte HTML
$htmlContent = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analisis de Headers de Seguridad - OWASP</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            text-align: center;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .server-section {
            margin: 30px 0;
            border: 1px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
        }
        .server-header {
            padding: 15px;
            font-weight: bold;
            font-size: 18px;
        }
        .ultra-secure { background-color: #27ae60; color: white; }
        .moderado { background-color: #f39c12; color: white; }
        .basico { background-color: #e74c3c; color: white; }
        .juice-shop { background-color: #9b59b6; color: white; }
        .error { background-color: #95a5a6; color: white; }
        .headers-table {
            width: 100%;
            border-collapse: collapse;
        }
        .headers-table th, .headers-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
            vertical-align: top;
        }
        .headers-table th {
            background-color: #f8f9fa;
            font-weight: bold;
            width: 25%;
        }
        .headers-table td:nth-child(2) {
            width: 20%;
        }
        .headers-table td:nth-child(3) {
            width: 55%;
            word-wrap: break-word;
        }
        .present { color: #27ae60; font-weight: bold; }
        .absent { color: #e74c3c; font-weight: bold; }
        .summary {
            background-color: #ecf0f1;
            padding: 20px;
            margin: 20px 0;
            border-radius: 5px;
        }
        .progress-bar {
            background-color: #ddd;
            border-radius: 10px;
            overflow: hidden;
            height: 20px;
            margin: 10px 0;
        }
        .progress-fill {
            height: 100%;
            text-align: center;
            line-height: 20px;
            color: white;
            font-weight: bold;
            font-size: 12px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #7f8c8d;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Analisis de Headers de Seguridad</h1>
        <p style="text-align: center; color: #7f8c8d;">Fecha: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
"@

$serverResults = @()

$servers = @(
    @{ Name = "Ultra-Seguro"; URL = "http://localhost:8080"; Port = "8080" },
    @{ Name = "Moderado"; URL = "http://localhost:8081"; Port = "8081" },
    @{ Name = "Basico"; URL = "http://localhost:8082"; Port = "8082" },
    @{ Name = "Juice-Shop"; URL = "http://localhost:3000"; Port = "3000" }
)

$securityHeaders = @(
    "X-Content-Type-Options",
    "X-Frame-Options", 
    "X-XSS-Protection",
    "Strict-Transport-Security",
    "Content-Security-Policy",
    "Referrer-Policy",
    "Permissions-Policy",
    "Cross-Origin-Opener-Policy",
    "Cross-Origin-Embedder-Policy",
    "Cross-Origin-Resource-Policy",
    "Cache-Control",
    "Pragma",
    "X-Permitted-Cross-Domain-Policies",
    "X-Download-Options",
    "Expect-CT",
    "X-Powered-By",
    "Server",
    "Set-Cookie",
    "Access-Control-Allow-Origin"
)

foreach ($server in $servers) {
    Write-Host "`nAnalizando: $($server.Name) ($($server.URL))" -ForegroundColor Yellow
    Write-Host "=" * 50 -ForegroundColor Gray
    
    $serverResult = @{
        Name = $server.Name
        URL = $server.URL
        Port = $server.Port
        Headers = @{}
        FoundCount = 0
        Error = $null
    }
    
    try {
        $response = Invoke-WebRequest -Uri $server.URL -Method HEAD -UseBasicParsing -TimeoutSec 10
        
        foreach ($header in $securityHeaders) {
            if ($response.Headers[$header]) {
                Write-Host "[+] $header : $($response.Headers[$header])" -ForegroundColor Green
                $serverResult.Headers[$header] = $response.Headers[$header]
                $serverResult.FoundCount++
            } else {
                Write-Host "[-] $header : AUSENTE" -ForegroundColor Red
                $serverResult.Headers[$header] = $null
            }
        }
        
        $percentage = [math]::Round(($serverResult.FoundCount / $securityHeaders.Count) * 100, 1)
        
        Write-Host "`nResumen: $($serverResult.FoundCount)/$($securityHeaders.Count) headers ($percentage%)" -ForegroundColor Blue
        
    } catch {
        Write-Host "[!] Error conectando a $($server.Name): $($_.Exception.Message)" -ForegroundColor Red
        $serverResult.Error = $_.Exception.Message
    }
    
    $serverResults += $serverResult
}

Write-Host "`nAnalisis completado!" -ForegroundColor Green

# Generar contenido HTML para cada servidor
foreach ($result in $serverResults) {
    $percentage = if ($result.Error) { 0 } else { [math]::Round(($result.FoundCount / $securityHeaders.Count) * 100, 1) }
    
    # Determinar clase CSS según el servidor
    $cssClass = switch ($result.Name) {
        "Ultra-Seguro" { "ultra-secure" }
        "Moderado" { "moderado" }
        "Basico" { "basico" }
        "Juice-Shop" { "juice-shop" }
        default { if ($result.Error) { "error" } else { "basico" } }
    }
    
    # Color de barra de progreso
    $progressColor = if ($percentage -ge 80) { "#27ae60" } 
                    elseif ($percentage -ge 50) { "#f39c12" } 
                    else { "#e74c3c" }
    
    $htmlContent += @"
        <div class="server-section">
            <div class="server-header $cssClass">
                $($result.Name) ($($result.URL))
            </div>
"@
    
    if ($result.Error) {
        $htmlContent += @"
            <div style="padding: 20px;">
                <p style="color: #e74c3c; font-weight: bold;">[!] Error de conexion: $($result.Error)</p>
            </div>
"@
    } else {
        $htmlContent += @"
            <table class="headers-table">
                <thead>
                    <tr>
                        <th>Header de Seguridad</th>
                        <th>Estado</th>
                        <th>Valor</th>
                    </tr>
                </thead>
                <tbody>
"@
        
        foreach ($header in $securityHeaders) {
            $status = if ($result.Headers[$header]) { "[+] PRESENTE" } else { "[-] AUSENTE" }
            $statusClass = if ($result.Headers[$header]) { "present" } else { "absent" }
            $value = if ($result.Headers[$header]) { 
                $headerValue = $result.Headers[$header]
                # Truncar valores muy largos para mejor visualización
                if ($headerValue.Length -gt 80) {
                    $headerValue.Substring(0, 77) + "..."
                } else {
                    $headerValue
                }
            } else { 
                "-" 
            }
            
            $htmlContent += @"
                    <tr>
                        <td><strong>$header</strong></td>
                        <td class="$statusClass">$status</td>
                        <td style="font-family: monospace; font-size: 11px; word-break: break-all; max-width: 300px;">$value</td>
                    </tr>
"@
        }
        
        $htmlContent += @"
                </tbody>
            </table>
            <div style="padding: 20px;">
                <strong>Resumen: $($result.FoundCount)/$($securityHeaders.Count) headers ($percentage%)</strong>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: $percentage%; background-color: $progressColor;">
                        $percentage%
                    </div>
                </div>
            </div>
"@
    }
    
    $htmlContent += "        </div>`n"
}

# Resumen general
$totalServers = $serverResults.Count
$serversWithErrors = ($serverResults | Where-Object { $_.Error }).Count
$averageProtection = if ($totalServers -gt $serversWithErrors) {
    $validResults = $serverResults | Where-Object { -not $_.Error }
    $totalHeaders = ($validResults | ForEach-Object { $_.FoundCount } | Measure-Object -Sum).Sum
    [math]::Round($totalHeaders / ($validResults.Count * $securityHeaders.Count) * 100, 1)
} else { 0 }

$htmlContent += @"
        <div class="summary">
            <h2>Resumen General</h2>
            <table style="width: 100%;">
                <tr>
                    <td><strong>Servidores analizados:</strong></td>
                    <td>$totalServers</td>
                </tr>
                <tr>
                    <td><strong>Servidores con errores:</strong></td>
                    <td>$serversWithErrors</td>
                </tr>
                <tr>
                    <td><strong>Proteccion promedio:</strong></td>
                    <td>$averageProtection%</td>
                </tr>
            </table>
        </div>

        <div class="footer">
            <p>Generado por security-headers-analysis.ps1 | $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')</p>
            <p>Analisis de Headers de Seguridad OWASP</p>
        </div>
    </div>
</body>
</html>
"@

# Guardar reporte HTML
$reportPath = "reports\security-headers-report.html"
$htmlContent | Out-File -FilePath $reportPath -Encoding UTF8 -NoNewline

Write-Host "`nReporte HTML generado: $reportPath" -ForegroundColor Cyan
Write-Host "Abre el archivo en tu navegador para ver el reporte completo." -ForegroundColor Green