# Noble PropTech — Landing + Landlord Portal + Backend

Noble is an operating system for independent landlords: a focused public site,
a full landlord workspace (properties, tenants, repairs, compliance, finance,
documents, tasks, messages), and a real backend — Ruby WEBrick + SQLite with
multi-user accounts. The frontend works standalone in demo mode (localStorage)
and upgrades to server sync automatically when the backend is reachable.

The launch UI is built around one clear promise: run your rental portfolio
without an agency. The public experience leads with compliance, repair speed,
portfolio visibility and transparent pricing; the workspace opens on a
prioritised "Needs attention" queue with one-click actions and portfolio
metrics.

## Project layout

```
noble-proptech/
├── src/
│   ├── index.html     # App source (all markup + JS)
│   └── input.css      # Tailwind directives + custom Noble OS styles
├── assets/            # Vendored, never edited by hand
│   ├── fonts/         # Inter + JetBrains Mono (woff2) + generated fonts.css
│   └── js/            # lucide.min.js, jspdf.umd.min.js
├── backend/
│   ├── server.rb      # WEBrick server: serves dist/ + JSON REST API v1
│   ├── db.rb          # SQLite persistence (users, sessions, workspaces)
│   ├── password.rb    # PBKDF2 password hashing + legacy verification
│   ├── demo_workspace.rb  # Fresh demo portfolio generator (dynamic dates)
│   └── seed.rb        # Creates schema + demo landlord
├── data/              # SQLite database (created by seed/serve)
├── tailwind.config.js # Theme (colors/fonts/shadows) + safelist for dynamic classes
├── tools/
│   ├── tailwindcss    # Standalone Tailwind v3.4.17 CLI (no Node required)
│   ├── gen-fonts.pl   # Vendors Google Fonts subsets locally
│   ├── check-js.sh    # Syntax-checks inline JS via JavaScriptCore
│   ├── check-css.pl   # Verifies runtime classes exist in compiled CSS
│   └── smoke.rb       # Isolated backend/auth launch smoke test
├── build.sh           # Compiles CSS + assembles dist/
├── setup.sh           # One-time: downloads the toolchain + vendored assets
├── serve.sh           # Build + seed + run the backend server
└── dist/              # Built output (also served by the backend)
```

## Quick start (backend + accounts)

```bash
./setup.sh    # one-time: toolchain + vendored assets
./serve.sh    # builds dist/, seeds the DB, serves on http://127.0.0.1:8712
```

Demo login: `demo@noble.co.uk` / `noble-demo` — or create your own account
from the Log In modal (new accounts start with an editable sample portfolio).
Data lives in `data/noble.db`; delete it and re-run `serve.sh` for a fresh
start.

## API (v1)

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/health` | GET | Liveness |
| `/api/v1/auth/register` | POST | Create account → token + seeded workspace |
| `/api/v1/auth/login` | POST | Login → token + workspace |
| `/api/v1/auth/logout` | POST | Invalidate session |
| `/api/v1/me` | GET | Current user (Bearer token) |
| `/api/v1/me/profile` | POST | Update account name and company |
| `/api/v1/me/password` | POST | Rotate password and revoke other sessions |
| `/api/v1/workspace` | GET / PUT | Fetch / save the user's workspace document |
| `/api/v1/workspace/reset` | POST | Re-seed a fresh demo workspace |

Auth uses `Authorization: Bearer <token>` with PBKDF2-HMAC-SHA256 (210,000
iterations), expiring 30-day sessions, auth throttling, and transparent
migration of legacy SHA-256 demo accounts after a successful login. The
frontend stores the current workspace locally, syncs after changes, retries
when connectivity returns, and visibly reports Connected, Saving, Saved,
Saved locally, or Session expired states. If the API is unreachable the app
continues in local mode without losing the current workspace.

## Frontend build

```bash
./build.sh
ruby tools/smoke.rb
```

For a separately hosted frontend, build with `NOBLE_API_BASE=https://api.example.com/api/v1 ./build.sh` and set the backend's `NOBLE_CORS_ORIGIN` to the exact frontend origin. Same-origin deployments need no extra setting.

`tools/smoke.rb` creates a temporary SQLite database and server process, then
checks static serving, registration, password migration, workspace persistence,
logout, session expiry, payload limits, and auth throttling. It does not touch
`data/noble.db`.

Compiles `src/input.css` through Tailwind (scanning `src/` for classes) into
`dist/css/tailwind.css`, copies the vendored assets, and emits `dist/index.html`
with paths rebased for the flat `dist/` layout.

## Deploy

**With backend**: run `ruby backend/server.rb [port]` on your host (needs
Ruby >= 2.6 with the `sqlite3` gem) and put `dist/` next to it - the server
serves both the site and the API. For local development, `./serve.sh` keeps
`HOST=127.0.0.1`; for deployment, configure `HOST`, `NOBLE_CORS_ORIGIN`, and
TLS or put the service behind a managed HTTPS reverse proxy. **Static-only**:
upload `dist/` to any static host (Netlify, Vercel, S3, nginx...) - the site
works in local demo mode; accounts and sync need the backend.

## Highlights

- **Repair workflow**: full lifecycle with audit timeline — Log → Request
  Quotes → Log Quote → Approve → Dispatch → Notify Tenant → Close & Log
  Expense. SLA clocks per priority (Emergency 24h / Urgent 3d / Routine 14d)
  with live countdown, breach detection, spend-vs-budget bars, over-budget
  flags, a repairs stats row, and a Details modal with the complete history.
- **Real backend**: multi-user accounts, token sessions, SQLite persistence,
  and automatic frontend↔server sync with offline fallback.
- **Launch-grade UI**: outcome-led landing page, responsive product preview,
  clear CTA paths, restrained graphite surfaces, accessible focus states,
  workspace context in the app header, account identity, synced-state feedback,
  responsive attention queue, and a dashboard built for scanning rather than
  decoration. Motion uses a pointer-reactive hero signal field, orbit choreography, staged product scanlines and scroll-linked depth, with a complete `prefers-reduced-motion` fallback.
- **Real search/filtering** on every portal tab, with focus retention.
- **UK compliance engine (England & Wales, Renters' Rights Act 2025 in force
  from 1 May 2026)**: derived register of required documents per property with
  automatic `valid / due soon / overdue / missing / n-a` status, per-property
  and portfolio scores, compliance ring, category filters, Add/Renew/View
  actions, and one-click **CSV export**.
- **Legal guardrails**: Section 21 disabled everywhere (abolished 1 May 2026);
  Section 13 validates 2-month notice + 12-month gap before generating a PDF;
  deposit 5-week cap checks on property/tenant cards; in-app legal guide with
  penalties and a persistent "not a law firm" disclaimer.

## Notes

- **Offline state**: `localStorage` key `noble_os_v7_guarded_data` caches the
  workspace; the **Reset demo data** button in Settings also re-seeds the
  server workspace when logged in.
- **Dynamic classes**: Tailwind cannot discover classes composed at runtime
  (e.g. `border-l-${cond ? 'red-500' : 'neon-500'}`); these are force-generated
  via the `safelist` in `tailwind.config.js`. If you add new dynamic class
  combinations, add them there.
- **PDFs**: generated legal documents are stored as data URLs in the vault so
  the Documents tab can re-download them; uploaded files over 800 KB are stored
  as metadata only.
- **Auth and transport**: PBKDF2-HMAC-SHA256 is built in and legacy demo
  hashes migrate on login. For a public deployment, set `NOBLE_TLS=1` with
  `NOBLE_TLS_CERT` and `NOBLE_TLS_KEY`, use a reverse proxy or managed TLS,
  set `HOST` deliberately, and set `NOBLE_CORS_ORIGIN` to the exact frontend
  origin rather than `*`. The server includes request limits, auth throttling,
  security headers, and 30-day session expiry, but still needs external
  monitoring, backups, and a production process supervisor.
