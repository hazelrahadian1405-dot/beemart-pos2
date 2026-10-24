# BeeMart — Point of Sale (POS) Web App

A .NET 8 / C# POS system built for the Binus IT Bootcamp Test 2026/2027.
The solution uses **Separation of Concerns**: a backend **API** owns all business
logic and data, and a **WebClient** that consumes it exclusively over HTTP
(the WebClient never touches the database).

```
┌─────────────────┐     HTTP/JSON (JWT)     ┌──────────────────┐     EF Core      ┌────────────┐
│ BeeMart.WebClient│  ───────────────────▶   │   BeeMart.Api    │  ─────────────▶  │ SQL Server │
│  (Razor Pages)   │  ◀───────────────────   │ (ASP.NET Core)   │                  │  BeeMart   │
└─────────────────┘                          └──────────────────┘                  └────────────┘
```

## Projects

| Project            | Description                                                        |
|--------------------|--------------------------------------------------------------------|
| `BeeMart.Api`      | ASP.NET Core Web API (.NET 8), EF Core + SQL Server, JWT auth, v1  |
| `BeeMart.WebClient`| ASP.NET Core Razor Pages, pure HTML/CSS/JS (no Bootstrap)          |
| `database.sql`     | DDL + seed data (DML): 3 payment methods, 370 products, 2 users    |

## Features

- **Login** — validates Username + Password + Role against `MsUser`; PBKDF2 password
  hashing (no plain text); wrong combo → `Invalid login`. Role dropdown: Admin→`Admin`, Kasir→`Cashier`.
- **Register** — required fields, password hashing, unique username (`username has already exists`).
- **New Transaction** — live WIB clock, product search (max 10 results), "Pilih" → "Barang Terpilih"
  panel with stock check (`Jumlah barang yang dimasukkan melebihi sisa stok.`), cart,
  payment method fetched dynamically from the API, auto invoice number, reset on success.
- **Transaction History** — date-picker filter, pagination (max 20/page), ascending by date.
  Cashier sees only their own transactions; Admin sees all. Header shows `Role: <role> | Login: <username>`.
- **Invoice number** — `[5-digit userId][ddmmyy][3-digit running]`, generated server-side and shown
  read-only on the page. The running number is shared by all cashiers and restarts daily, as in the
  mockup (`66859030926001`, `55794030926002`, …).
- **Currency / time** — Rupiah (IDR) formatting and `Asia/Jakarta` (WIB) throughout.

## Prerequisites

- .NET 8 SDK
- SQL Server (LocalDB, Express, or full)

## Setup

### 1. Create the database

`database.sql` creates the five tables and seeds 3 payment methods, 370 products
and the two test accounts below. It runs against whichever database you are connected
to, so create `BeeMart` first:

```bash
sqlcmd -S localhost -Q "CREATE DATABASE BeeMart"
sqlcmd -S localhost -d BeeMart -i database.sql
```

Or skip this step: on first start the API creates the `BeeMart` database if needed and
runs `database.sql` when it finds no tables (turn off with `"SeedOnStartup": false`).
It never touches a database that already has tables.

### 2. Configure the connection string

Edit `BeeMart.Api/appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=BeeMart;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

### 3. Run

```bash
# Terminal 1 — API (https://localhost:7100, Swagger at /swagger)
dotnet run --project BeeMart.Api

# Terminal 2 — WebClient (https://localhost:7200)
dotnet run --project BeeMart.WebClient
```

Open <https://localhost:7200>.

## Seed logins

| Username | Password    | Role    |
|----------|-------------|---------|
| `admin`  | `Admin123!` | Admin   |
| `kasir`  | `Kasir123!` | Cashier |

## API (v1)

All endpoints are versioned under `/api/v1`. Protected endpoints require
`Authorization: Bearer <token>`.

| Method | Path                               | Auth           | Description                         |
|--------|------------------------------------|----------------|-------------------------------------|
| POST   | `/api/v1/auth/login`               | anonymous      | Login, returns JWT                  |
| POST   | `/api/v1/auth/register`            | anonymous      | Register a new user                 |
| GET    | `/api/v1/products/search?keyword=` | Admin/Cashier  | Product search (max 10)             |
| GET    | `/api/v1/products/{id}`            | Admin/Cashier  | Product detail                      |
| GET    | `/api/v1/paymentmethods`           | Admin/Cashier  | Payment methods (Cash/Debit/Credit) |
| GET    | `/api/v1/transactions/next-invoice`| Admin/Cashier  | Invoice no. for the next transaction|
| POST   | `/api/v1/transactions`             | Admin/Cashier  | Create a transaction                |
| GET    | `/api/v1/transactions/history`     | Admin/Cashier  | Paged history (role-scoped)         |

`transactions/history` query params: `date` (yyyy-MM-dd, required), `page` (default 1),
`pageSize` (default/max 20).

## Data model

Tables: `MsUser`, `MsProduct`, `LtPaymentMethod`, `TrTransaction`, `TrTransactionDetail`.
See `database.sql` and `docs/PROJECT_PLAN.md` for the full ERD and column types.

## Screenshots

| Login | Register |
|---|---|
| ![Login](docs/screenshots/01-login.png) | ![Register](docs/screenshots/07-register.png) |

| New Transaction — stock check | New Transaction — cart |
|---|---|
| ![Stock check](docs/screenshots/03-overstock.png) | ![Cart](docs/screenshots/04-cart.png) |

| History — Kasir | History — Admin (paginated) |
|---|---|
| ![Kasir history](docs/screenshots/06-history-kasir.png) | ![Admin history](docs/screenshots/08-history-admin.png) |

## Security notes

- Passwords are stored as PBKDF2-SHA256 hashes (`{iterations}.{salt}.{hash}`), never plain text.
- The WebClient has **no** database connection — it only calls the API.
- Role-based authorization is enforced server-side (history scoping is not trusted to the client).
- Change the JWT signing key (`Jwt:Key`) before any non-local use.
