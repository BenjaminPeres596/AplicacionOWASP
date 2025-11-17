1. X-Content-Type-Options: nosniff

Evita que el navegador adivine el tipo de contenido. Fuerza a que respete el MIME real del archivo, reduciendo riesgos donde un archivo podría ejecutarse como otro tipo.

2. X-Frame-Options: DENY

Impide que el sitio sea cargado dentro de un iframe. Esto bloquea intentos de engañar al usuario haciendo clic sobre contenido invisible superpuesto (clickjacking).

3. Referrer-Policy: no-referrer

Evita que el navegador envíe la URL de origen al realizar peticiones. Protege de filtrar parámetros sensibles o rutas internas hacia otros sitios.

4. X-XSS-Protection: 1; mode=block

Activa el filtro de XSS nativo del navegador (en los que todavía lo soportan) y bloquea la página si detecta un script inyectado.

5. Strict-Transport-Security (HSTS)

Indica al navegador que debe acceder siempre mediante HTTPS. Reduce riesgos de ataques de intermediario y previene el downgrade a HTTP.

6. Content-Security-Policy (CSP)

Define de dónde pueden cargarse scripts, estilos, imágenes y otros recursos.
En tu configuración:

Solo permite scripts propios y desde CDNs específicos.

Bloquea JavaScript inline, incluidos handlers como onerror=.

Permite estilos inline pero restringe el resto de orígenes.

Limita imágenes y fuentes solo a lo necesario.

Evita que el sitio sea embeído en frames.

Restringe conexiones de red solo al propio servidor y WebSockets específicos.

Es la defensa más fuerte que incorporaste porque evita la ejecución de código malicioso incluso si la aplicación lo inyecta.

7. Permissions-Policy

Desactiva APIs del navegador que no son necesarias (ubicación, micrófono, cámara, sensores, pago, etc.). Reduce la superficie de ataque del navegador.

8. Cross-Origin-Opener-Policy / Cross-Origin-Embedder-Policy / Cross-Origin-Resource-Policy

Aíslan completamente el origen.
Evitan que recursos externos puedan interactuar con tu página y reducen riesgos relacionados con Spectre, fuga de datos entre procesos o manipulación entre ventanas.

9. X-Permitted-Cross-Domain-Policies: none

Impide que navegadores antiguos o plugins (como Flash) carguen políticas externas que podrían habilitar accesos indebidos.

10. X-Download-Options: noopen

Evita que ciertos archivos descargados se abran automáticamente. Reduce riesgos de ejecución accidental al descargar contenido.

11. Expect-CT

Ayuda a detectar certificados mal emitidos o inválidos al visitar tu sitio mediante mecanismos de Certificate Transparency.

12. Cache-Control / Pragma

Evitan que las respuestas HTML o de API queden en caché.
Previene filtración de datos personales o de sesión si el navegador es compartido.

13. X-Powered-By: secure-stack

Agrega un valor controlado y genérico, evitando que se filtre información real sobre el backend. Dificulta el fingerprinting de tecnologías.

14. proxy_hide_header Server / X-Powered-By

Ocultan cabeceras enviadas por el backend real (Juice Shop).
Evitan exponer versiones del framework o del servidor original.

15. limit_conn / limit_req (Rate Limiting y Control de Conexiones)

Controlan:

Cantidad máxima de conexiones simultáneas por IP.

Cantidad de solicitudes por segundo/minuto por IP.

Límites específicos para rutas críticas como /login.

Previenen abuso de peticiones, automatización excesiva y ataques de fuerza bruta.
