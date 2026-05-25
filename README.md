Maycol Estiben Gutierrez Vela _ 151012
Ana María Vargas Amaya _ 151013

# BogotApp


Aplicación móvil comunitaria enfocada en Bogotá. Combina un mapa colaborativo de lugares, crítica cultural de películas/series/música, y un mood picker con IA (Claude) que cruza ambos mundos para hacer recomendaciones personalizadas.

---

## Estructura del repositorio

```
MaitteSoft/
├── ARCHITECTURE.md          # Documento de arquitectura del proyecto
├── bogotapp_backend/        # API REST + WebSocket (Node.js + TypeScript)
└── bogotapp_flutter/        # App móvil/desktop (Flutter)
```

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Mobile / Desktop | Flutter 3 |
| Estado | Riverpod (AsyncNotifier) |
| Navegación | go_router |
| HTTP | dio (con interceptor JWT) |
| WebSockets | web_socket_channel |
| Backend | Node.js + Express + TypeScript |
| ORM | Drizzle ORM |
| Base de datos | PostgreSQL 16 (Docker) |
| Validación | Zod |
| Auth | JWT — access token 15 min + refresh 7 días (jose) |
| IA | Claude API (Anthropic) |
| Logs | pino + pino-pretty |
| Upload de fotos | multer (disco local) |

---

## Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x)
- [Node.js](https://nodejs.org/) 20+
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (para PostgreSQL)
- Una API key de [Anthropic](https://console.anthropic.com/) (para el mood picker)

---

## Configuración inicial

### 1. Levantar PostgreSQL con Docker

```bash
docker run --name bogotapp-db \
  -e POSTGRES_USER=bogotapp \
  -e POSTGRES_PASSWORD=bogotapp123 \
  -e POSTGRES_DB=bogotapp \
  -p 5432:5432 \
  -d postgres:16-alpine
```

Si el contenedor ya existe y está detenido:

```bash
docker start bogotapp-db
```

### 2. Configurar variables de entorno del backend

Copia el archivo de ejemplo y edítalo:

```bash
cp bogotapp_backend/.env.example bogotapp_backend/.env
```

Contenido de `.env`:

```env
PORT=3000
DATABASE_URL=postgresql://bogotapp:bogotapp123@localhost:5432/bogotapp
JWT_SECRET=bogotapp-super-secret-jwt-key-local-dev-2026
ANTHROPIC_API_KEY=sk-ant-...       # <-- tu key real aquí
CORS_ORIGIN=http://localhost:3001
NODE_ENV=development
```

### 3. Instalar dependencias e inicializar la base de datos

```bash
cd bogotapp_backend
npm install
npm run db:generate   # genera el SQL de migración
npm run db:migrate    # aplica las migraciones en PostgreSQL
```

### 4. Arrancar el backend

```bash
npm run dev
```

El servidor queda corriendo en `http://localhost:3000`.  
Verifica con: `curl http://localhost:3000/health`  
Respuesta esperada: `{"data":{"status":"ok"},"error":null,"meta":{}}`

### 5. Instalar dependencias de Flutter

```bash
cd bogotapp_flutter
flutter pub get
```

### 6. Correr la app Flutter

```bash
# En macOS (recomendado para desarrollo local)
flutter run -d macos

# En Chrome
flutter run -d chrome

# En un simulador iOS (requiere Xcode)
flutter run -d <device-id>
```

---

## Endpoints de la API

Todos los endpoints protegidos requieren el header:
```
Authorization: Bearer <access_token>
```

Todas las respuestas siguen el formato:
```json
{ "data": ..., "error": null, "meta": {} }
```

### Auth

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| POST | `/auth/register` | Crear cuenta | No |
| POST | `/auth/login` | Iniciar sesión | No |
| POST | `/auth/refresh` | Renovar access token | No |
| POST | `/auth/logout` | Cerrar sesión | No |

**Body register/login:**
```json
{ "name": "Ana", "email": "ana@email.com", "password": "minimo8chars" }
```

**Respuesta:** `{ user, accessToken, refreshToken }`

### Places (Mapa)

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| GET | `/places` | Listar todos los lugares | Sí |
| POST | `/places` | Crear un lugar (multipart/form-data) | Sí |
| GET | `/places/:id` | Obtener un lugar | Sí |
| DELETE | `/places/:id` | Eliminar un lugar (solo dueño) | Sí |
| POST | `/places/:id/likes` | Toggle like (da/quita like) | Sí |

**Campos para crear un lugar (form-data):**
```
name, description, category (cafe|park|food|secret|other), lat, lng, photo (archivo, opcional)
```

### Reviews (Cultura)

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| GET | `/reviews` | Listar reseñas (query: `?type=movie\|series\|music`) | Sí |
| POST | `/reviews` | Crear reseña | Sí |
| GET | `/reviews/:id` | Obtener una reseña | Sí |
| DELETE | `/reviews/:id` | Eliminar reseña (solo dueño) | Sí |

**Body crear reseña:**
```json
{ "type": "movie", "title": "Oppenheimer", "score": 5, "body": "Texto de la reseña..." }
```

### Mood IA

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| POST | `/mood` | Obtener recomendación personalizada de Claude | Sí |

**Body:**
```json
{ "mood": "Me siento creativo y con ganas de explorar algo diferente" }
```

**Respuesta:**
```json
{
  "data": {
    "type": "lugar",
    "name": "Café Cultor",
    "reason": "Un espacio tranquilo ideal para mentes creativas.",
    "lat": "4.6486",
    "lng": "-74.0582"
  }
}
```

---

## Estructura de la base de datos

```
users          id, name, email, password_hash, created_at
places         id, name, description, category, lat, lng, photo_url, likes_count, user_id, created_at
reviews        id, type, title, score, body, user_id, created_at
likes          user_id, place_id, created_at  (PK compuesta)
refresh_tokens id, token, user_id, expires_at, created_at
```

---

## Arquitectura interna

### Backend

```
Request → auth middleware → Controller (Zod) → Service → Repository → PostgreSQL
```

- **routes/** — mapean endpoints a controllers, sin lógica
- **controllers/** — validan body con Zod, delegan al service
- **services/** — lógica de negocio (auth, places, reviews, IA)
- **repositories/** — única capa que habla con Drizzle ORM
- **middlewares/** — auth (JWT), errorHandler global

### Flutter

Cada feature (`auth`, `mapa`, `cultura`, `mood`) es un módulo autónomo con:

```
features/<nombre>/
├── data/
│   ├── models/         modelos JSON con fromJson/toEntity
│   └── repositories/   implementaciones HTTP con dio
├── domain/
│   ├── entities/       clases puras de Dart
│   ├── repositories/   contratos abstractos
│   └── usecases/       casos de uso
└── presentation/
    ├── screens/        widgets de pantalla
    ├── providers/      AsyncNotifier de Riverpod
    └── widgets/        componentes reutilizables
```

**Core compartido:**
- `core/http/dio_client.dart` — interceptor JWT con refresco automático en 401
- `core/errors/failures.dart` — `ServerFailure`, `NetworkFailure`, `AuthFailure`
- `core/router/app_router.dart` — go_router con redirect guard por auth
- `core/theme/app_theme.dart` — Material 3 con colores de marca

---

## WebSocket

El backend emite eventos en tiempo real a todos los clientes conectados en `ws://localhost:3000/ws`.

| Evento | Cuándo se emite | Payload |
|---|---|---|
| `connected` | Al conectarse | `{ message: "Welcome to BogotApp" }` |
| `place:created` | Al crear un lugar nuevo | Objeto `Place` completo |

La app Flutter escucha `place:created` y actualiza el mapa automáticamente sin refrescar.

---

## Scripts del backend

```bash
npm run dev          # Desarrollo con hot reload (nodemon + ts-node)
npm run build        # Compila TypeScript a dist/
npm run start        # Corre la build compilada
npm run db:generate  # Genera archivos de migración SQL (drizzle-kit)
npm run db:migrate   # Aplica migraciones pendientes a la DB
npm run db:studio    # Abre Drizzle Studio (UI para explorar la DB)
```

---

## Fotos de lugares

Las fotos se guardan localmente en `bogotapp_backend/uploads/`. Se sirven como estáticos en `http://localhost:3000/uploads/<filename>`. El campo `photoUrl` en la DB guarda la ruta relativa (ej: `/uploads/1234567890-photo.jpg`).

Límites: máximo **5 MB** por foto. Formatos permitidos: `jpeg`, `jpg`, `png`, `webp`.

---

## Flujo de autenticación

```
1. POST /auth/register o /auth/login
   └─ Responde: { accessToken (15 min), refreshToken (7 días) }

2. Flutter guarda ambos en flutter_secure_storage

3. Cada request lleva: Authorization: Bearer <accessToken>

4. Si el servidor responde 401:
   └─ El interceptor de dio llama a POST /auth/refresh
   └─ Guarda los nuevos tokens
   └─ Reintenta la petición original automáticamente

5. Si el refresh también expiró → redirige al login
```
