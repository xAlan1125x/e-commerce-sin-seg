# Guía de exposición con Postman

## Objetivo

Mostrar cómo un cliente HTTP consume la API REST del proyecto mediante los
métodos `POST`, `GET`, `PATCH` y `DELETE`. La demostración también enseña
autenticación con JWT, variables de Postman, códigos de estado y validaciones.

Duración sugerida: **7 a 10 minutos**.

## Preparación antes de exponer

Desde la raíz del proyecto:

```powershell
Copy-Item .env.example .env
npm run docker:up
```

Si `.env` ya existe, no hace falta copiarlo. Comprobar en el navegador que
`http://localhost:3000/api/productos` responde antes de comenzar.

En Postman:

1. Presionar **Import**.
2. Elegir `postman/E-Commerce-XP.postman_collection.json`.
3. Abrir la colección **E-Commerce XP - Exposición HTTP**.
4. Ejecutar las requests en el orden numerado.

La colección ya contiene `baseUrl`, el usuario administrador local y scripts
que guardan automáticamente el JWT, el nombre único y el ID del producto.

### Alternativa: probar desde Swagger UI

La documentación interactiva está disponible en
`http://localhost:3000/api-docs`. Allí se encuentran todas las rutas de la API,
agrupadas en **Autenticación**, **Sesiones**, **Productos** y **Pedidos**.

Para probar una operación protegida:

1. Ejecutar `POST /api/auth/login`.
2. Copiar únicamente el valor de `accessToken` de la respuesta.
3. Presionar **Authorize** y pegar el token.
4. Ejecutar la operación protegida; Swagger agregará el header
   `Authorization: Bearer <token>`.

## Guion para decir en vivo

### Introducción (30 segundos)

> Postman es un cliente HTTP. Me permite construir una request, elegir el
> método, la URL, los headers y el body, enviarla a la API y analizar la
> respuesta. Voy a mostrar un CRUD de productos: crear, leer, actualizar y
> eliminar.

### 1. POST - Iniciar sesión

Abrir **1 - Autenticación → POST - Iniciar sesión como ADMIN**.

Antes de presionar **Send**, mostrar:

- URL: `/api/auth/login`.
- Header: `Content-Type: application/json`.
- Body: credenciales y nombre del dispositivo.

Después de enviarla:

> Recibimos `200 OK`. Como el login no es idempotente, cada ejecución crea una
> sesión. La respuesta incluye un access token JWT. Un script de Postman lo
> guarda en la variable `accessToken`, evitando copiarlo manualmente.

### 2. POST - Crear un producto

Abrir **2 - CRUD de productos → POST - Crear producto**.

Mostrar la pestaña **Authorization** y luego el body. Presionar **Send**.

> `POST` se usa para crear un recurso. Enviamos sus datos como JSON y el token
> como `Bearer Token`. La API responde `201 Created` y asigna el ID; el cliente
> no inventa ese identificador. El script guarda el ID para las próximas URLs.

### 3. GET - Consultar el catálogo

Abrir **GET - Consultar catálogo filtrado** y presionar **Send**.

> `GET` recupera información y no modifica el servidor. Es una operación segura
> e idempotente. Aquí usamos el query parameter `categoria` para filtrar. La
> API devuelve `200 OK` y un arreglo JSON. Esta lectura es pública y no necesita
> JWT.

### 4. PATCH - Actualizar el stock

Abrir **PATCH - Actualizar stock**. Señalar `{{productId}}` en la URL y el body.
Presionar **Send**.

> `PATCH` realiza una actualización parcial. No reemplazamos todo el producto:
> enviamos solamente el campo `stock`. La variable se resuelve con el ID creado
> antes. La respuesta `200 OK` confirma que el stock ahora vale 25.

### 5. DELETE - Eliminar el producto

Abrir **DELETE - Eliminar producto** y presionar **Send**.

> `DELETE` elimina el recurso indicado por su ID. La API responde `204 No
> Content`: la operación salió bien y, por definición, no hay body para mostrar.

## Cierre opcional: errores controlados

Si queda tiempo, usar la carpeta **3 - Errores opcionales**.

- **POST - Sin token (401):** demuestra autenticación. La identidad no fue
  acreditada, por eso la API responde `401 Unauthorized`.
- **PATCH - Stock negativo (422):** demuestra validación y reglas de negocio.
  El JSON es sintácticamente correcto, pero su contenido no se puede procesar.

> Los códigos HTTP no son decorativos: permiten que cualquier cliente entienda
> el resultado sin depender de la interfaz visual de esta aplicación.

## Resumen para una diapositiva

| Método | Acción mostrada | Respuesta exitosa |
| --- | --- | --- |
| `POST` | Iniciar sesión / crear producto | `200` / `201` |
| `GET` | Consultar catálogo | `200` |
| `PATCH` | Actualizar stock parcialmente | `200` |
| `DELETE` | Eliminar producto | `204` |

Conceptos clave: endpoint, request, response, header, body JSON, parámetro de
consulta, parámetro de ruta, JWT, idempotencia y códigos de estado.

## Plan de contingencia

- Levantar el entorno al menos diez minutos antes y no cerrar Docker Desktop.
- Ejecutar toda la secuencia una vez antes de la exposición. El nombre del
  producto lleva una marca de tiempo, por lo que repetirla no genera duplicados.
- Tener abierta la URL `http://localhost:3000/api/productos` como comprobación.
- Si el login devuelve `401`, volver a ejecutar `npm run db:seed` y verificar
  que las variables `SEED_ADMIN_EMAIL` y `SEED_ADMIN_PASSWORD` de `.env`
  coincidan con las variables de la colección.
- No mostrar ni reutilizar estas credenciales fuera del entorno local.
