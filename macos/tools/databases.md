# Postgres + Redis on Mac

## What runs on the Windows PC

| | Postgres | Redis |
|---|---|---|
| Version | 16.3 (EDB installer) | 7.0.15 |
| How it runs | Windows service `postgresql-x64-16`, auto-start | WSL Debian, systemd `redis-server` enabled |
| Data dir | `C:\Program Files\PostgreSQL\16\data` | WSL `/var/lib/redis` |
| Port | 5432 | 6379, no password |
| Superuser | `postgres` (password auth, no pgpass) | n/a |

Roles and databases seen in project `.env` files (full list could not be read, `psql -l` needs a password):

| Project | Role | Database |
|---|---|---|
| TaxGPT_App/backend | `zafeer` | `taxgpt` (also `copy`, `test01` per env comment) |
| TaxGPT_ai_services | `test` | `djangoTest`, `ai` |
| TaxGPT_App/backend Celery | | Redis `redis://localhost:6379/0` |

Get the real list on Windows before moving (PowerShell, prompts for `postgres` password):

```powershell
psql -U postgres -h localhost -l
psql -U postgres -h localhost -c "\du"
```

## 1. Install and start services

```bash
brew install postgresql@16 redis
brew services start postgresql@16
brew services start redis
source ~/.zprofile   # install-tools.sh already added the postgresql@16 PATH line
psql postgres -c "select version();"
redis-cli ping   # PONG
```

Brew Postgres creates a superuser named after your Mac user, trust auth on localhost (no password needed locally).

## 2. Create roles and databases

Use the same passwords as in the copied `.env` files (do not commit them).

```bash
psql postgres <<'SQL'
CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'change-me';
CREATE ROLE zafeer WITH LOGIN CREATEDB PASSWORD 'from-TaxGPT_App-backend-env';
CREATE ROLE test WITH LOGIN CREATEDB PASSWORD 'from-TaxGPT_ai_services-env';
SQL

createdb -O zafeer taxgpt
createdb -O test djangoTest
createdb -O test ai
# optional: createdb -O zafeer copy; createdb -O zafeer test01
```

Then from each project run migrations instead of restoring, if a clean DB is fine:

```bash
cd ~/Desktop/Work/TaxGPT_App/backend && python manage.py migrate
cd ~/Desktop/Work/TaxGPT_ai_services && uv run python manage.py migrate   # if Django, else alembic upgrade head
```

## 3. Optional: copy data with pg_dump / pg_restore

On Windows (PowerShell), one file per database, custom format:

```powershell
$dumpDirectory = "$HOME\mac-export\pg"
New-Item -ItemType Directory -Force $dumpDirectory | Out-Null
foreach ($databaseName in 'taxgpt','djangoTest','ai') {
  pg_dump -U postgres -h localhost -Fc -f "$dumpDirectory\$databaseName.dump" $databaseName
}
pg_dumpall -U postgres -h localhost --roles-only -f "$dumpDirectory\roles.sql"
```

On Mac, after copying `mac-export/pg` over (skip step 2 role creation if you load `roles.sql`):

```bash
dump_directory="$HOME/mac-export/pg"
psql postgres -f "$dump_directory/roles.sql"   # errors for existing roles are fine
for database_name in taxgpt djangoTest ai; do
  createdb "$database_name" 2>/dev/null || true
  pg_restore -d "$database_name" --no-owner --role="$(whoami)" --clean --if-exists "$dump_directory/$database_name.dump"
done
```

Dumps contain real data. Keep them out of the dotfiles repo, delete after restore.

## Notes

- `enable_pgaudit` management command in TaxGPT_App needs the pgaudit extension, not shipped by brew postgresql@16.
  Only matters if you run that command locally.
- Redis needs no data migration (Celery broker/cache only).
- Stop/restart: `brew services restart postgresql@16`, `brew services list`.
