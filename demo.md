A07 – Identification and Authentication Failures

Por qué:
El login permite intentos ilimitados.
No hay controles de fuerza bruta, lockout, captcha, ni rate limiting.
En la versión secure, se agrega un control de tasa (limit_req) que mitiga ese riesgo.

A05 – Security Misconfiguration
Porque la aplicación por defecto no configura ningún límite.

Juice-shop default
for i in {1..30}; do echo "Intento $i"; curl -s -o /dev/null -w "Codigo: %{http_code}\n" -X POST http://localhost:3000/rest/user/login -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"incorrecta"}'; done

Ultra-secure
for i in {1..30}; do echo "Intento $i"; curl -s -o /dev/null -w "Codigo: %{http_code}\n" -X POST http://localhost:8080/rest/user/login -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"incorrecta"}'; done

A03 – Injection (XSS)

Por qué:
El input del usuario (q= en la búsqueda) se inserta directamente en el DOM sin escapado.
Se ejecuta JavaScript arbitrario vía onerror.

A05 – Security Misconfiguration

Por la falta de Content-Security-Policy en Juice-Shop default.
En la versión secure, la CSP mitiga el ataque:

Ingresar en search:
<img src=x onerror=alert('XSS')>
