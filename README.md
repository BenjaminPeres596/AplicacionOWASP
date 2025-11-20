# AplicacionOWASP — Análisis Comparativo de Seguridad

Este proyecto demuestra cómo distintas configuraciones de nginx afectan la seguridad de una aplicación web, usando análisis automatizados con OWASP ZAP.

---

## 🚀 Inicio Rápido

Ejecuta todo el análisis con un solo comando:

```powershell
.\run-full-analysis.ps1
```

¿Qué hace?

- Levanta los contenedores
- Ejecuta 4 escaneos ZAP
- Genera reportes HTML y XML
- Abre los resultados automáticamente

⏱️ Tiempo estimado: ~5 minutos

---

## 🛡️ Niveles de Seguridad Analizados

| Nivel        | Puerto | Rate Limiting | Headers Seguridad | CSP         | Vulnerabilidades |
| ------------ | ------ | ------------- | ----------------- | ----------- | ---------------- |
| Ultra-Seguro | 8080   | Muy Estricto  | Completos         | Restrictiva | Mínimas          |
| Moderado     | 8081   | Moderado      | Básicos           | Permisiva   | Algunas          |
| Básico       | 8082   | Ninguno       | Mínimos           | Ninguna     | Muchas           |
| Juice-Shop   | 3000   | Ninguno       | Ninguno           | Ninguna     | Máximas          |

---

## 📊 Resultados y Reportes

Archivos generados:

- `reports/reporte-*.xml` — Reportes originales OWASP ZAP
- `reports/processed/reporte-simple-*.html` — Reportes HTML mejorados

¿Qué verás?

1. Ultra-Seguro → Pocas vulnerabilidades
2. Moderado → Vulnerabilidades intermedias
3. Básico → Muchas vulnerabilidades
4. Juice-Shop → Máximas vulnerabilidades (sin protección nginx)

---

## 🎯 Comandos Principales

### Análisis ZAP

```powershell
# Análisis rápido (baseline)
.\run-full-analysis.ps1

# Análisis detallado (2 min por servidor)
.\run-full-analysis.ps1 -ScanType full

# Análisis exhaustivo (5 min por servidor)
.\run-full-analysis.ps1 -ScanType full -ScanTime 5
```

### Análisis Adicionales

```powershell
# Headers de seguridad
.\security-headers-analysis.ps1

# Rate limiting
.\rate-limiting-test.ps1 -Url "http://localhost:8080" -NumRequests 200
```

---

## 🐳 Comandos Docker (Manual)

```bash
# Levantar todos los servicios
docker compose up -d

# Ver contenedores activos
docker ps

# Parar todo
docker compose down
```

---

## 🛠️ Troubleshooting

Si algo no funciona:

1. Verifica Docker:
   ```bash
   docker --version
   docker compose --version
   ```
2. Limpia y reinicia:
   ```bash
   docker compose down --remove-orphans
   docker compose up -d
   ```
3. Verifica puertos activos:
   ```bash
   docker ps
   ```
   Deberías ver: 3000, 8080, 8081, 8082

---

## 📁 Estructura del Proyecto

```
├── docker-compose.yml                # Configuración de contenedores
├── nginx/                            # Configuraciones nginx
│   ├── ultra-secure.conf             # Configuración máxima seguridad
│   ├── moderate-secure.conf          # Configuración intermedia
│   └── basic.conf                    # Configuración básica
├── run-full-analysis.ps1             # Script principal de análisis
├── zap-report-processor-simple.ps1   # Procesador de reportes
└── reports/                          # Directorio de reportes
    ├── *.xml                         # Reportes originales ZAP
    └── processed/                    # Reportes HTML mejorados
```

---

## 🎯 Objetivo del Proyecto

Demostrar cómo las configuraciones de nginx impactan la seguridad web mediante:

1. Configuraciones progresivas (básica → moderada → ultra-segura)
2. Escaneos automatizados con OWASP ZAP
3. Análisis comparativo de vulnerabilidades
4. Reportes visuales y profesionales

**Resultado:** Evidencia clara de cómo la seguridad configurada reduce el número y severidad de vulnerabilidades detectadas.

---

## 📋 Checklist de Uso

- [ ] Abrir PowerShell en la carpeta del proyecto
- [ ] Ejecutar `.\run-full-analysis.ps1`
- [ ] Esperar ~5 minutos
- [ ] Revisar reportes en `reports/processed/`
- [ ] Comparar diferencias entre los 4 niveles
- [ ] (Opcional) Ejecutar análisis de headers y rate limiting

---

## 🛠️ Scripts Adicionales

**Análisis de Headers de Seguridad:**

```powershell
.\security-headers-analysis.ps1
```
