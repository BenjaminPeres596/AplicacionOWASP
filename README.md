# AplicacionOWASP

**1. Levantar solo app vulnerable:**

docker compose up -d juice-shop

Accedé a http://localhost:3000 para ver la app.

**2. Correr el escaneo de seguridad inicial con ZAP:**

docker compose run --rm zap zap-baseline.py -t http://juice-shop:3000 -r reporte-directo.html -x reporte-directo.xml -I

**3. Levantar Nginx con cabeceras seguras y re-escaneo:** 

docker compose up -d secure-proxy

Ahora accedés a la app en http://localhost:8080

**4. Correr el escaneo sobre la versión con cabeceras:**
  
docker compose run --rm zap zap-baseline.py -t http://secure-proxy:80 -r reporte-post-headers.html -x reporte-post-headers.xml -I
