#!/usr/bin/env bash

echo "🔍 INICIANDO ANÁLISIS DE HEADERS DE SEGURIDAD"
echo "============================================="

# -------------------------
# Configuración de endpoints
# -------------------------

names=("Ultra-Seguro" "Moderado" "Basico" "Juice-Shop")
urls=("http://localhost:8080" "http://localhost:8081" "http://localhost:8082" "http://localhost:3000")
ports=("8080" "8081" "8082" "3000")
descs=(
  "Configuración con máximo endurecimiento"
  "Configuración con seguridad intermedia"
  "Configuración con seguridad mínima"
  "Instancia original de OWASP Juice Shop (sin Nginx delante)"
)

# Headers de seguridad a verificar
headers=(
  "X-Content-Type-Options"
  "X-Frame-Options"
  "X-XSS-Protection"
  "Content-Security-Policy"
  "Referrer-Policy"
  "Cross-Origin-Opener-Policy"
  "Cross-Origin-Embedder-Policy"
  "Cross-Origin-Resource-Policy"
  "Permissions-Policy"
  "Strict-Transport-Security"
  "Server"
  "X-Powered-By"
  "Cache-Control"
  "Pragma"
)

# Asociativos para resultados
declare -A STATUS        # STATUS["Ultra-Seguro"]="✅ ACTIVO" / "❌ ERROR"
declare -A STATUS_CODE   # STATUS_CODE["Ultra-Seguro"]="200"
declare -A HEADER_VALUE  # HEADER_VALUE["Ultra-Seguro|X-Frame-Options"]="SAMEORIGIN" o "AUSENTE"

display_name() {
  case "$1" in
    Basico)      echo "Básico" ;;
    Juice-Shop)  echo "Juice Shop (Original)" ;;
    *)           echo "$1" ;;
  esac
}

echo
echo "🚀 Iniciando pruebas de conectividad..."
echo

# -------------------------
#   Recolección de headers
# -------------------------

for i in "${!names[@]}"; do
  name="${names[$i]}"
  url="${urls[$i]}"
  echo "🔎 Analizando: $name ($url)"

  # -s silencioso, -D - cabeceras a stdout, -o /dev/null ignora body
  resp_headers="$(curl -s -D - -o /dev/null "$url" 2>/dev/null)"
  curl_exit=$?

  if [[ $curl_exit -ne 0 || -z "$resp_headers" ]]; then
    echo "❌ ERROR conectando a $url"
    STATUS["$name"]="❌ ERROR"
    STATUS_CODE["$name"]=""
    # Marcamos todos los headers como ausentes
    for h in "${headers[@]}"; do
      HEADER_VALUE["$name|$h"]="AUSENTE"
    done
    echo
    continue
  fi

  # Primera línea: HTTP/1.1 200 OK
  code="$(echo "$resp_headers" | head -n1 | awk '{print $2}')"
  STATUS["$name"]="✅ ACTIVO"
  STATUS_CODE["$name"]="$code"

  # Parsear headers
  for h in "${headers[@]}"; do
    # Buscar líneas que empiezan con ese header (case-insensitive)
    value="$(echo "$resp_headers" \
      | grep -i "^$h:" \
      | cut -d':' -f2- \
      | sed 's/^[[:space:]]*//; s/\r$//' \
      | paste -sd"; " -)"

    if [[ -n "$value" ]]; then
      HEADER_VALUE["$name|$h"]="$value"
    else
      HEADER_VALUE["$name|$h"]="AUSENTE"
    fi
  done

  echo "   → Código HTTP: $code"
  echo
done

# -------------------------
#    Generar reporte HTML
# -------------------------

timestamp_full="$(date +"%d/%m/%Y %H:%M:%S")"
timestamp_date="$(date +"%d/%m/%Y")"
timestamp_time="$(date +"%H:%M:%S")"

mkdir -p reports
report_path="reports/security-headers-report.html"

{
  echo '<!DOCTYPE html>'
  echo '<html>'
  echo '<head>'
  echo '    <meta charset="utf-8">'
  echo '    <title>Reporte de Headers de Seguridad - AplicacionOWASP</title>'
  echo '    <style>'
  echo "        body { font-family: 'Segoe UI', Tahoma, sans-serif; margin: 20px; background-color: #f5f5f5; }"
  echo '        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }'
  echo '        h1 { color: #2c3e50; text-align: center; border-bottom: 3px solid #3498db; padding-bottom: 10px; }'
  echo '        h2 { color: #34495e; margin-top: 30px; padding: 10px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 5px; }'
  echo '        .summary { background: #ecf0f1; padding: 20px; border-radius: 8px; margin-bottom: 30px; }'
  echo '        table { width: 100%; border-collapse: collapse; margin-top: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }'
  echo '        th { background: #34495e; color: white; padding: 15px; text-align: left; font-weight: bold; }'
  echo '        td { padding: 12px; border-bottom: 1px solid #ddd; vertical-align: top; }'
  echo '        tr:nth-child(even) { background-color: #f9f9f9; }'
  echo '        tr:hover { background-color: #e8f4f8; }'
  echo '        .present { color: #27ae60; font-weight: bold; }'
  echo '        .absent { color: #e74c3c; font-weight: bold; }'
  echo '        .status-active { color: #27ae60; font-weight: bold; }'
  echo '        .status-error { color: #e74c3c; font-weight: bold; }'
  echo '        .comparison-table { overflow-x: auto; }'
  echo '        .header-name { background: #f8f9fa; font-weight: bold; min-width: 200px; }'
  echo '        .timestamp { text-align: center; color: #7f8c8d; margin-top: 20px; font-style: italic; }'
  echo '        .security-level { display: inline-block; padding: 5px 10px; border-radius: 20px; color: white; font-weight: bold; margin-left: 10px; }'
  echo '        .level-ultra { background: #27ae60; }'
  echo '        .level-moderate { background: #f39c12; }'
  echo '        .level-basic { background: #e74c3c; }'
  echo '        .level-juice { background: #8e44ad; }'
  echo '    </style>'
  echo '</head>'
  echo '<body>'
  echo '  <div class="container">'
  echo '    <h1>🔒 Reporte de Headers de Seguridad - AplicacionOWASP</h1>'
  echo '    <div class="summary">'
  echo "      <h3>📋 Resumen Ejecutivo</h3>"
  echo "      <p><strong>Fecha:</strong> $timestamp_full</p>"
  echo '      <p><strong>Objetivo:</strong> Comparar headers de seguridad entre diferentes configuraciones de nginx y el backend original.</p>'
  echo '      <p><strong>Configuraciones analizadas:</strong> 3 niveles de Nginx (Básico, Moderado, Ultra-Seguro) + backend original (Juice Shop)</p>'
  echo '    </div>'

  # Estado de los servicios
  echo '    <h2>🌐 Estado de los Servicios</h2>'
  echo '    <table>'
  echo '      <tr><th>Configuración</th><th>Puerto</th><th>Estado</th><th>Descripción</th></tr>'

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    label="$(display_name "$name")"
    port="${ports[$i]}"
    desc="${descs[$i]}"
    state="${STATUS[$name]}"
    [[ "$state" == "✅ ACTIVO" ]] && status_class="status-active" || status_class="status-error"
    case "$name" in
      Ultra-Seguro) level_class="level-ultra" ;;
      Moderado)     level_class="level-moderate" ;;
      Basico)       level_class="level-basic" ;;
      Juice-Shop)   level_class="level-juice" ;;
    esac
    echo "      <tr>"
    echo "        <td><strong>$label</strong><span class=\"security-level $level_class\">$label</span></td>"
    echo "        <td>$port</td>"
    echo "        <td class=\"$status_class\">$state</td>"
    echo "        <td>$desc</td>"
    echo "      </tr>"
  done

  echo '    </table>'

  # Comparación de headers
  echo '    <h2>🔍 Comparación Detallada de Headers de Seguridad</h2>'
  echo '    <div class="comparison-table">'
  echo '      <table>'
  echo '        <tr>'
  echo '          <th>Header de Seguridad</th>'
  echo '          <th>Ultra-Seguro (8080)</th>'
  echo '          <th>Moderado (8081)</th>'
  echo '          <th>Básico (8082)</th>'
  echo '          <th>Juice Shop (3000)</th>'
  echo '        </tr>'

  for h in "${headers[@]}"; do
    echo '        <tr>'
    echo "          <td class='header-name'>$h</td>"
    for cfg in "Ultra-Seguro" "Moderado" "Basico" "Juice-Shop"; do
      val="${HEADER_VALUE["$cfg|$h"]}"
      if [[ "$val" == "AUSENTE" ]]; then
        cls="absent"
        disp="❌ AUSENTE"
      else
        cls="present"
        disp="$val"
      fi
      echo "          <td class=\"$cls\">$disp</td>"
    done
    echo '        </tr>'
  done

  echo '      </table>'
  echo '    </div>'

  # Análisis de vulnerabilidades
  echo '    <h2>📊 Análisis de Vulnerabilidades</h2>'
  echo '    <div class="summary">'
  echo '      <h4>🔴 Headers Críticos Ausentes:</h4>'
  echo '      <ul>'

  critical=("Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options")
  for h in "${critical[@]}"; do
    for cfg in "Basico" "Moderado" "Ultra-Seguro" "Juice-Shop"; do
      val="${HEADER_VALUE["$cfg|$h"]}"
      if [[ "$val" == "AUSENTE" ]]; then
        label_cfg="$(display_name "$cfg")"
        echo "        <li><strong>$label_cfg:</strong> $h ausente - Vulnerable a ataques</li>"
      fi
    done
  done

  echo '      </ul>'
  echo '      <h4>🟢 Fortalezas Identificadas:</h4>'
  echo '      <ul>'

  # Solo destacamos fortalezas de las capas Nginx, no del backend original
  for cfg in "Ultra-Seguro" "Moderado" "Basico"; do
    total=${#headers[@]}
    present=0
    for h in "${headers[@]}"; do
      val="${HEADER_VALUE["$cfg|$h"]}"
      [[ "$val" != "AUSENTE" ]] && ((present++))
    done
    perc=$(awk "BEGIN { printf \"%.1f\", ($present/$total)*100 }")
    label_cfg="$(display_name "$cfg")"
    echo "        <li><strong>$label_cfg:</strong> $perc% de headers de seguridad implementados</li>"
  done

  echo '      </ul>'
  echo '    </div>'

  # Recomendaciones
  echo '    <h2>🎯 Recomendaciones</h2>'
  echo '    <div class="summary">'
  echo '      <h4>Para Configuración Básica:</h4>'
  echo '      <ul>'
  echo '        <li>Implementar Content Security Policy (CSP)</li>'
  echo '        <li>Agregar X-Frame-Options para prevenir clickjacking</li>'
  echo '        <li>Configurar rate limiting</li>'
  echo '        <li>Ocultar información del servidor</li>'
  echo '      </ul>'
  echo '      <h4>Para Configuración Moderada:</h4>'
  echo '      <ul>'
  echo "        <li>Endurecer la CSP removiendo 'unsafe-inline' y 'unsafe-eval'</li>"
  echo '        <li>Implementar headers anti-Spectre</li>'
  echo '        <li>Configurar timeouts más estrictos</li>'
  echo '      </ul>'
  echo '      <h4>Para Configuración Ultra-Segura:</h4>'
  echo '      <ul>'
  echo '        <li>Considerar implementar HSTS si se usa HTTPS</li>'
  echo '        <li>Evaluar rate limiting más agresivo</li>'
  echo '        <li>Monitoreo continuo de seguridad</li>'
  echo '      </ul>'
  echo '    </div>'

  echo '    <div class="timestamp">'
  echo "      <p>Reporte generado el $timestamp_date a las $timestamp_time | AplicacionOWASP Security Testing</p>"
  echo '    </div>'

  echo '  </div>'
  echo '</body>'
  echo '</html>'
} > "$report_path"

echo
echo "✅ ANÁLISIS COMPLETADO"
echo "============================================="
echo "📁 Reporte generado en: $report_path"
echo "🌐 Podés abrirlo con tu navegador (doble click o):"
echo "   firefox \"$report_path\"  # o chrome/edge"

echo
echo "📊 RESUMEN RÁPIDO:"
for name in "${names[@]}"; do
  total=${#headers[@]}
  present=0
  for h in "${headers[@]}"; do
    val="${HEADER_VALUE["$name|$h"]}"
    [[ "$val" != "AUSENTE" ]] && ((present++))
  done
  perc=$(awk "BEGIN { printf \"%.1f\", ($present/$total)*100 }")
  echo "• $(display_name "$name") : ${STATUS[$name]} - $perc% headers implementados"
done
