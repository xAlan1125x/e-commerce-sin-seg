# Guía básica de exposición con Postman

## Objetivo

Explicar de forma sencilla cómo un cliente HTTP, en este caso Postman, se
comunica con una API REST. La demostración utiliza productos para mostrar un
CRUD: crear, consultar, actualizar y eliminar datos.

Duración sugerida: **7 a 10 minutos**.

## 1. Idea general

La comunicación ocurre de esta manera:

```text
Postman -> request HTTP -> API -> base de datos
Postman <- response HTTP <- API <- base de datos
```

- **Cliente HTTP:** programa que construye y envía peticiones. Postman es el
  cliente utilizado en esta demostración.
- **API REST:** aplicación que publica operaciones mediante URLs y métodos
  HTTP.
- **Endpoint:** combinación de un método y una URL. Por ejemplo,
  `GET /api/productos`.
- **Request:** petición enviada por el cliente. Puede contener método, URL,
  headers, parámetros y un body.
- **Response:** respuesta de la API. Contiene un código de estado, headers y,
  cuando corresponde, un body.
- **JSON:** formato de texto utilizado para intercambiar datos estructurados.

## 2. Relación entre CRUD y los métodos HTTP

CRUD significa **Create, Read, Update y Delete**.

| Operación CRUD | Método | Función | Ruta de este proyecto |
| --- | --- | --- | --- |
| Create | `POST` | Crear un producto | `POST /api/productos` |
| Read | `GET` | Consultar productos | `GET /api/productos` |
| Update | `PUT` | Reemplazar todos los datos | `PUT /api/productos/:id` |
| Update | `PATCH` | Modificar solamente algunos datos | `PATCH /api/productos/:id/stock` |
| Delete | `DELETE` | Eliminar un producto | `DELETE /api/productos/:id` |

> **Importante:** `PUT` y `PATCH` representan actualizaciones, pero tienen
> alcances diferentes. En este proyecto, `PUT` reemplaza nombre, precio, stock
> y categoría, mientras que `PATCH` modifica únicamente el stock.

## 3. Preparación antes de exponer

Desde la raíz del proyecto, ejecutar:

```powershell
npm install
npm run docker:up
```

Si el archivo `.env` todavía no existe, crearlo antes de levantar el proyecto:

```powershell
Copy-Item .env.example .env
```

Comprobar estas direcciones:

- Aplicación: `http://localhost:3000`
- Catálogo: `http://localhost:3000/api/productos`
- Swagger UI: `http://localhost:3000/api-docs`

El catálogo debe responder con el código `200 OK` y un arreglo JSON.

### Preparar Postman

1. Presionar **Import**.
2. Elegir `postman/E-Commerce-XP.postman_collection.json`.
3. Abrir la colección **E-Commerce XP - Exposición HTTP**.
4. Ejecutar las peticiones en el orden numerado.

La colección contiene variables que evitan escribir varias veces los mismos
datos:

- `baseUrl`: dirección principal de la API.
- `accessToken`: token JWT obtenido durante el login.
- `productId`: ID asignado al producto creado.
- `productName`: nombre único generado para evitar duplicados.

Si la extensión de Postman para VS Code no permite importar el archivo, se
puede usar Postman Desktop o Swagger UI sin modificar la API.

## 4. Pestañas principales de una request en Postman

### Params

**Params** contiene los parámetros que forman parte de la URL. No es el body de
la petición.

- **Query parameters:** aparecen después de `?` y normalmente se usan para
  filtrar, ordenar o paginar. Postman los presenta como pares `key/value`.
  Por ejemplo, `categoria=Periféricos` produce
  `/api/productos?categoria=Periféricos`.
- **Path parameters:** identifican un recurso dentro de la ruta. En
  `/api/productos/{{productId}}`, Postman reemplaza `{{productId}}` por el valor
  de la variable antes de enviar la request.

### Authorization

**Authorization** define cómo se acredita la identidad del cliente ante la API.
Algunos tipos habituales son:

- **No Auth:** no envía credenciales.
- **API Key:** envía una clave en un header o query parameter.
- **Bearer Token:** envía `Authorization: Bearer <token>`. Es el mecanismo JWT
  utilizado por este proyecto.
- **Basic Auth:** envía usuario y contraseña codificados; debe utilizarse sobre
  HTTPS.
- **OAuth 2.0:** obtiene y administra tokens mediante un flujo de autorización.
- **Inherit auth from parent:** reutiliza la autorización configurada en la
  carpeta o colección que contiene la request.

En esta colección se escribe `{{accessToken}}` como Bearer Token. Postman
construye automáticamente el header `Authorization`.

### Headers

Los **headers** son metadatos de la request. Se escriben como pares
`nombre/valor`. Los más importantes en esta demostración son:

```http
Content-Type: application/json
Authorization: Bearer {{accessToken}}
```

- `Content-Type` describe el formato del body enviado.
- `Authorization` contiene las credenciales.
- `Accept`, cuando se utiliza, indica el formato de respuesta esperado.

Postman puede generar algunos headers automáticamente. No conviene duplicar
manualmente un header que ya aparece en la sección de headers temporales.

### Body

**Body** contiene los datos principales enviados a la API. Postman permite
elegir un solo modo por request:

- **none:** no envía body. Es lo habitual en `GET` y `DELETE` de esta API.
- **form-data:** envía campos y archivos como `multipart/form-data`. Cada campo
  puede ser texto o archivo. Postman calcula automáticamente el `boundary`.
- **x-www-form-urlencoded:** envía pares `key=value` codificados como un
  formulario tradicional. No permite adjuntar archivos.
- **raw:** envía texto sin estructura de formulario. Puede ser JSON, XML, HTML
  o texto plano. Los endpoints de productos utilizan **raw + JSON**.
- **binary:** envía el contenido de un único archivo como cuerpo completo, sin
  campos adicionales.
- **GraphQL:** permite escribir una query o mutation y un objeto JSON de
  variables para servidores GraphQL.

Ejemplo utilizado por `POST` y `PUT` en modo **raw / JSON**:

```json
{
  "nombre": "Teclado mecánico",
  "precio": 45000,
  "stock": 10,
  "categoria": "Periféricos"
}
```

Elegir `form-data` o `x-www-form-urlencoded` para este endpoint no es
equivalente: Express está configurado para interpretar JSON mediante
`express.json()`.

### Scripts

Los **scripts** son programas JavaScript que automatizan una request:

- **Pre-request:** se ejecuta antes del envío. Sirve para generar datos,
  calcular firmas o preparar variables.
- **Post-response:** se ejecuta después de recibir la respuesta. Sirve para
  comprobar códigos y datos o guardar valores para peticiones posteriores.

La colección genera un nombre único antes de crear el producto:

```javascript
pm.collectionVariables.set('productName', 'Producto Demo ' + Date.now());
```

Después del `POST`, comprueba el estado y guarda el ID recibido:

```javascript
pm.test('Responde 201 Created', () => pm.response.to.have.status(201));
const producto = pm.response.json();
pm.collectionVariables.set('productId', String(producto.id));
```

### Settings

**Settings** modifica el comportamiento de esa request sin cambiar sus datos.
Según la versión de Postman, permite controlar opciones como el seguimiento de
redirecciones, la codificación automática de la URL, el uso del almacén de
cookies, la validación de certificados SSL y límites de red.

Para esta demostración se pueden conservar los valores predeterminados. Si una
request solo funciona al desactivar la validación SSL, se debe revisar el
certificado del servidor en lugar de asumir que la conexión es segura.

## 5. JSON de ejemplo para el CRUD

Este es el producto que se utilizará como ejemplo:

```json
{
  "nombre": "Teclado mecánico",
  "precio": 45000,
  "stock": 10,
  "categoria": "Periféricos"
}
```

Los nombres de las propiedades deben escribirse entre comillas dobles. Los
textos también llevan comillas, mientras que los números no.

### POST: crear

```http
POST {{baseUrl}}/api/productos
Content-Type: application/json
Authorization: Bearer {{accessToken}}
```

Body JSON:

```json
{
  "nombre": "Teclado mecánico",
  "precio": 45000,
  "stock": 10,
  "categoria": "Periféricos"
}
```

Respuesta esperada: `201 Created`. La respuesta agrega el `id` generado por la
base de datos:

```json
{
  "id": 7,
  "nombre": "Teclado mecánico",
  "precio": 45000,
  "stock": 10,
  "categoria": "Periféricos"
}
```

### GET: consultar

```http
GET {{baseUrl}}/api/productos?categoria=Periféricos
```

`GET` no necesita body JSON porque los filtros se envían como parámetros de
consulta en la URL. Respuesta esperada: `200 OK` y un arreglo:

```json
[
  {
    "id": 7,
    "nombre": "Teclado mecánico",
    "precio": 45000,
    "stock": 10,
    "categoria": "Periféricos"
  }
]
```

### PUT: reemplazar el recurso completo

Un `PUT` normalmente recibe todos los campos editables del recurso:

```http
PUT {{baseUrl}}/api/productos/{{productId}}
Content-Type: application/json
Authorization: Bearer {{accessToken}}
```

Body JSON:

```json
{
  "nombre": "Teclado mecánico RGB",
  "precio": 52000,
  "stock": 15,
  "categoria": "Periféricos"
}
```

Respuesta esperada: `200 OK`. La API reemplaza los cuatro campos editables y
devuelve el producto actualizado. Si falta uno de esos campos o su valor es
inválido, responde `422 Unprocessable Content`.

### PATCH: actualizar parcialmente

```http
PATCH {{baseUrl}}/api/productos/{{productId}}/stock
Content-Type: application/json
Authorization: Bearer {{accessToken}}
```

Body JSON:

```json
{
  "stock": 25
}
```

Respuesta esperada: `200 OK`. Solo cambia el stock; el nombre, el precio y la
categoría conservan sus valores anteriores.

### DELETE: eliminar

```http
DELETE {{baseUrl}}/api/productos/{{productId}}
Authorization: Bearer {{accessToken}}
```

`DELETE` no necesita body JSON porque el ID identifica el producto en la URL.
Respuesta esperada: `204 No Content`. Ese código confirma la eliminación y no
incluye body.

## 6. Guion sencillo para la exposición

### Introducción

> Postman es un cliente HTTP. Lo voy a usar para enviar peticiones a nuestra
> API REST. Cada petición tiene un método, una URL y, cuando es necesario,
> headers y un body JSON. La API procesa la petición y devuelve una respuesta
> con un código de estado.

### Paso 1: iniciar sesión

Abrir **1 - Autenticación -> POST - Iniciar sesión como ADMIN**.

Señalar:

- Método `POST`.
- URL `/api/auth/login`.
- Header `Content-Type: application/json`.
- Body con email, contraseña y nombre del dispositivo.

Después de presionar **Send**:

> La API respondió `200 OK` y entregó un access token JWT. La colección guarda
> automáticamente el token en `accessToken`. Las siguientes operaciones de
> escritura lo envían como `Bearer Token` para demostrar que el usuario está
> autenticado y tiene el rol `ADMIN`.

### Paso 2: crear un producto

Abrir **2 - CRUD de productos -> POST - Crear producto**.

> `POST` crea un recurso nuevo. Enviamos los datos en formato JSON. La API
> valida los campos, guarda el producto y responde `201 Created` con el ID
> generado. La colección guarda ese ID en `productId`.

### Paso 3: consultar productos

Abrir **GET - Consultar catálogo filtrado**.

> `GET` obtiene información sin modificarla. El parámetro `categoria` aparece
> después del signo `?` y permite filtrar el catálogo. La API responde `200 OK`
> con un arreglo JSON. Esta ruta es pública y no necesita JWT.

### Paso 4: ejecutar PUT y PATCH

Primero explicar brevemente:

> `PUT` reemplaza todos los datos editables del producto. Por eso enviamos
> nombre, precio, stock y categoría en el mismo JSON. La API responde `200 OK`
> con la representación actualizada.

Abrir **PUT - Reemplazar datos del producto** y presionar **Send**.

Abrir **PATCH - Actualizar stock** y señalar `{{productId}}` en la URL.

> Enviamos únicamente `{ "stock": 25 }`. La API actualiza ese campo y responde
> `200 OK` con el producto actualizado.

### Paso 5: eliminar el producto

Abrir **DELETE - Eliminar producto**.

> `DELETE` elimina el producto identificado por el ID de la URL. La respuesta
> `204 No Content` significa que la operación fue correcta y que no hay un body
> de respuesta.

## 7. Headers y autenticación

Los dos headers principales de la demostración son:

```http
Content-Type: application/json
Authorization: Bearer {{accessToken}}
```

- `Content-Type` informa que el body está escrito como JSON.
- `Authorization` envía el JWT para acreditar la identidad y los permisos.

`401 Unauthorized` significa que falta una autenticación válida. `403
Forbidden` significa que el usuario está autenticado, pero no tiene el rol o
permiso necesario.

## 8. Códigos de estado que pueden aparecer

| Código | Significado en esta demostración |
| --- | --- |
| `200 OK` | Consulta o actualización realizada correctamente |
| `201 Created` | Producto creado correctamente |
| `204 No Content` | Producto eliminado; no existe body de respuesta |
| `401 Unauthorized` | Falta un JWT válido |
| `403 Forbidden` | El usuario no tiene permiso suficiente |
| `404 Not Found` | La ruta o el producto no existe |
| `409 Conflict` | El producto no puede eliminarse porque pertenece a un pedido |
| `422 Unprocessable Content` | El JSON es válido, pero sus datos no cumplen las reglas |

## 9. Conceptos para recordar

- `POST` crea.
- `GET` consulta.
- `PUT` reemplaza completamente.
- `PATCH` modifica parcialmente.
- `DELETE` elimina.
- `GET` y `DELETE` normalmente no necesitan body.
- El ID se envía como parámetro de ruta: `/api/productos/7`.
- Un filtro se envía como query parameter: `?categoria=Periféricos`.
- JSON es el formato de intercambio; HTTP es el protocolo de comunicación.
- El código de estado resume el resultado de la petición.

## 10. Plan de contingencia

- Levantar el entorno al menos diez minutos antes y no cerrar Docker Desktop.
- Ejecutar toda la secuencia una vez antes de la exposición.
- Tener abierta `http://localhost:3000/api/productos` como comprobación.
- Tener abierta `http://localhost:3000/api-docs` como alternativa a Postman.
- Si el login devuelve `401`, ejecutar `npm run db:seed` y comprobar que las
  credenciales de `.env` coincidan con las variables de la colección.
- Si una actualización responde `422`, revisar que `PUT` incluya nombre,
  precio, stock y categoría con valores válidos.
- No mostrar ni reutilizar las credenciales fuera del entorno local.
