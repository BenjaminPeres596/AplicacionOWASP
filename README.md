# AplicacionOWASP - Análisis Comparativo de Seguridad

Proyecto que demuestra cómo diferentes configuraciones nginx afectan la seguridad de una aplicación web mediante análisis automatizados con OWASP ZAP.

## ⚡ INICIO RÁPIDO

**Un solo comando ejecuta todo el análisis:**

```powershell
.\run-full-analysis.ps1
```

**¿Qué hace?** Levanta contenedores → Ejecuta 4 escaneos ZAP → Genera reportes HTML → Abre resultados  
**Tiempo:** ~5 minutos

---

## 🎯 COMANDOS DISPONIBLES

### Análisis Principal

```powershell
# Análisis rápido (baseline - 1 min por servidor)
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

## 🛡️ NIVELES DE SEGURIDAD ANALIZADOS

| Nivel            | Puerto | Rate Limiting | Headers Seguridad | CSP         | Vulnerabilidades |
| ---------------- | ------ | ------------- | ----------------- | ----------- | ---------------- |
| **Ultra-Seguro** | 8080   | Muy Estricto  | Completos         | Restrictiva | Mínimas          |
| **Moderado**     | 8081   | Moderado      | Básicos           | Permisiva   | Algunas          |
| **Básico**       | 8082   | Ninguno       | Mínimos           | Ninguna     | Muchas           |
| **Juice-Shop**   | 3000   | Ninguno       | Ninguno           | Ninguna     | Máximas          |

---

## 📊 RESULTADOS

**Archivos generados:**

- `./reports/reporte-*.xml` - Reportes originales OWASP ZAP
- `./reports/processed/reporte-simple-*.html` - Reportes HTML mejorados

**Lo que verás:**

1. **Ultra-Seguro** → Pocas vulnerabilidades detectadas
2. **Moderado** → Vulnerabilidades intermedias
3. **Básico** → Muchas vulnerabilidades
4. **Juice-Shop** → Máximas vulnerabilidades (sin protección nginx)

---

## 🐳 COMANDOS DOCKER (Opcional - Manual)

```bash
# Levantar todos los servicios
docker compose up -d

# Ver contenedores activos
docker ps

# Parar todo
docker compose down
```

---

## 🔧 TROUBLESHOOTING

**Si algo no funciona:**

1. **Verificar Docker:**

   ```bash
   docker --version
   docker compose --version
   ```

2. **Limpiar y reiniciar:**

   ```bash
   docker compose down --remove-orphans
   docker compose up -d
   ```

3. **Verificar puertos activos:**
   ```bash
   docker ps
   ```
   Deberías ver: 3000, 8080, 8081, 8082

## 📁 Estructura del Proyecto

```
├── docker-compose.yml              # Configuración de contenedores
├── nginx/                          # Configuraciones nginx
│   ├── ultra-secure.conf          # Configuración máxima seguridad
│   ├── moderate-secure.conf       # Configuración intermedia
│   └── basic.conf                 # Configuración básica
├── run-full-analysis.ps1          # Script principal de análisis
├── zap-report-processor-simple.ps1 # Procesador de reportes
└── reports/                        # Directorio de reportes
    ├── *.xml                      # Reportes originales ZAP
    └── processed/                 # Reportes HTML mejorados
```

## 🎯 OBJETIVO DEL PROYECTO

Demostrar cómo diferentes configuraciones nginx afectan la seguridad mediante:

1. **Configuraciones nginx progresivas** (básica → moderada → ultra-segura)
2. **Escaneos automatizados con OWASP ZAP**
3. **Análisis comparativo de vulnerabilidades**
4. **Reportes visuales y profesionales**

**Resultado:** Evidencia clara de cómo las configuraciones de seguridad impactan en el número y severidad de vulnerabilidades detectadas.

---

## 📋 CHECKLIST DE USO

- [ ] Abrir PowerShell en la carpeta del proyecto
- [ ] Ejecutar `.\run-full-analysis.ps1`
- [ ] Esperar ~5 minutos
- [ ] Revisar reportes en `reports/processed/`
- [ ] Comparar diferencias entre los 4 niveles
- [ ] (Opcional) Ejecutar análisis adicionales de headers y rate limiting

¡Eso es todo! 🎉
| **Básico** | 8082 | Ninguno | Mínimos | Ninguna | Muchas |
| **Sin Proxy** | 3000 | Ninguno | Ninguno | Ninguna | Máximas |

## 🛠️ Scripts Adicionales

**Pruebas de Rate Limiting:**

```powershell
.\rate-limiting-test.ps1 -Url "http://localhost:8080" -NumRequests 100
```

**Análisis de Headers de Seguridad:**

```powershell
.\security-headers-analysis.ps1
```
