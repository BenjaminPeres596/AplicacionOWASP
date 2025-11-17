# Analizador de Headers de Seguridad - Version Simple
# Compara headers entre los diferentes niveles de seguridad

Write-Host "ANALISIS DE HEADERS DE SEGURIDAD" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

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
    "Cross-Origin-Resource-Policy"
)

foreach ($server in $servers) {
    Write-Host "`nAnalizando: $($server.Name) ($($server.URL))" -ForegroundColor Yellow
    Write-Host "=" * 50 -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $server.URL -Method HEAD -UseBasicParsing -TimeoutSec 10
        
        $foundHeaders = 0
        
        foreach ($header in $securityHeaders) {
            if ($response.Headers[$header]) {
                Write-Host "✅ $header : $($response.Headers[$header])" -ForegroundColor Green
                $foundHeaders++
            } else {
                Write-Host "❌ $header : AUSENTE" -ForegroundColor Red
            }
        }
        
        $percentage = [math]::Round(($foundHeaders / $securityHeaders.Count) * 100, 1)
        
        Write-Host "`nResumen: $foundHeaders/$($securityHeaders.Count) headers ($percentage%)" -ForegroundColor Blue
        
    } catch {
        Write-Host "❌ Error conectando a $($server.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nAnalisis completado!" -ForegroundColor Green