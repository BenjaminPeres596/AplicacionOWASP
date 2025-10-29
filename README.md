# AplicacionOWASP - Comparación de Niveles de Seguridad

**1. Levantar solo app vulnerable (sin protección):**

docker compose up -d juice-shop

Accedé a http://localhost:3000 para ver la app.

**2. Correr el escaneo de seguridad inicial con ZAP:**

docker compose run --rm -w /zap/wrk zap zap-baseline.py -t http://juice-shop:3000 -r reporte-directo.html -x reporte-directo.xml -I

## 🛡️ Servidores con Diferentes Niveles de Seguridad

**3a. Servidor Ultra-Seguro (Máximo Endurecimiento):**

docker compose up -d ultra-secure-proxy

Accedé en http://localhost:8080

**3b. Servidor Moderadamente Seguro:**

docker compose up -d moderate-secure-proxy

Accedé en http://localhost:8081

**3c. Servidor Básico (Mínima Seguridad):**

docker compose up -d basic-proxy

Accedé en http://localhost:8082

## 🔍 Análisis de Seguridad (2 minutos)

**4a. Escaneo Servidor Ultra-Seguro:**

docker compose run --rm -w /zap/wrk zap zap-full-scan.py -t http://ultra-secure-proxy:80 -m 2 -r reporte-ultra-seguro.html -x reporte-ultra-seguro.xml -I

**4b. Escaneo Servidor Moderado:**

docker compose run --rm -w /zap/wrk zap zap-full-scan.py -t http://moderate-secure-proxy:80 -m 2 -r reporte-moderado.html -x reporte-moderado.xml -I

**4c. Escaneo Servidor Básico:**

docker compose run --rm -w /zap/wrk zap zap-full-scan.py -t http://basic-proxy:80 -m 2 -r reporte-basico.html -x reporte-basico.xml -I

## Análisis Super Intenso (OPCIONAL)

**5. Reporte Super Intenso (Sin Límite de Tiempo):**

docker compose run --rm -w /zap/wrk zap zap-full-scan.py -t http://ultra-secure-proxy:80 -a -r reporte-maxima-exigencia.html -x reporte-maxima-exigencia.xml -I

**ADVERTENCIA**: Este análisis es extremadamente exhaustivo y puede tardar.

**¿Por qué es super intenso?**

- **Sin límite de tiempo** (`sin -m`): Análisis completo hasta agotar todas las pruebas
- **Modo agresivo** (`-a`): Incluye ataques activos que pueden modificar datos
- **Spider profundo**: Explora cada endpoint, formulario y API descubierto
- **Fuzzing exhaustivo**: Prueba cientos de payloads de inyección SQL, XSS, etc.
- **Testing completo**: Autenticación, sesiones, CORS, CSP bypass, path traversal
- **Ataques de fuerza bruta**: En formularios de login y parámetros

## Comparación de Niveles de Seguridad

| Nivel            | Puerto | Rate Limiting | Headers Seguridad | CSP         | Vulnerabilidades Esperadas |
| ---------------- | ------ | ------------- | ----------------- | ----------- | -------------------------- |
| **Ultra-Seguro** | 8080   | Muy Estricto  | Completos         | Restrictiva | Mínimas                    |
| **Moderado**     | 8081   | Moderado      | Básicos           | Permisiva   | Algunas                    |
| **Básico**       | 8082   | Ninguno       | Mínimos           | Ninguna     | Muchas                     |
| **Sin Proxy**    | 3000   | Ninguno       | Ninguno           | Ninguna     | Máximas                    |
