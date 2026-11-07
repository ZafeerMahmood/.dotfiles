# Work projects on macOS

All repos live in `~/Desktop/Work` (keeps the `includeIf gitdir:~/Desktop/Work/` work identity from `macos/git-editors`).
No Docker. Postgres 16 + Redis via brew services (see `macos/tools/databases.md`).

## 0. Before leaving Windows (push or save this work)

| Repo | What is only on Windows |
| --- | --- |
| TaxGPT_App | `dev` dirty: `frontend/lib/rollbar/RollbarClientProvider.tsx`; 1 stash (`mcp-to-mcp stash`) |
| TaxGPT_App | ahead of upstream: EN-5152 (12), EN-7019 (33), EN-7396-v2 (1), EN-8926 (1), main (3), |
| | chore/microsoft-more-connectors (30), chore/microsoft-more-connectors-calender (10), |
| | feat-ci-connector-mcp (16), feat-ci-connector-tenant (17) |
| TaxGPT_App | 32 local-only branches, biggest: hotfix/prompt-req (60), demo-mvp (29), copilot-app-landing-page (24), |
| | backup/cal-old-119902dbf (18), EN-4944 (15) |
| TaxGPT_App | worktree `.claude/worktrees/files-views-to-services-usage` (upstream gone); Cursor/Temp worktrees: prune |
| TaxGPT_App | ignored local files: `backend/script.py`, `backend/taxbiz_script.py`, `frontend/src/app/(app)/test/` |
| TaxGPT_ai_services | `dev` dirty: `app/core/config/loader_aa_review.py`, `loader_research.py`; untracked `runbook-v1.md` |
| TaxGPT_ai_services | local-only branch `data-agent-v2` (2); ignored dirs `app/api/document_selection`, `app/api/imports`, `app/exp` |
| TaxGPT_cowork | 6 stashes; ahead: EN-9044-shared-connector-tools (5), EN-9044-vault-default-on (12), |
| | fix/connector-vendor-names (2), kyle/EN-6525-button-refactor (2) |
| TaxGPT_cowork | local-only: 6 `backup/*` branches, `fix-npm-audit` |
| TaxGPT_cowork-formatting | worktree, branch `chore-prettier-setup` not on origin at all: `git push -u origin chore-prettier-setup` |
| TaxGPT_ui_library | 1 stash (`gitattributes`) |
| chrome-extension | `package.json` dirty: Windows-only removal of `INLINE_RUNTIME_CHUNK=false`. Discard, Mac needs original |
| taxgpt_mobile | 22 deleted `android/app/src/main/res/*` files (Windows breakage). Discard, fresh clone is correct |
| test-worktree | stale TaxGPT_App worktree, branch `test-worktree` 1 local-only commit, 2719 deletions. Likely junk |

Quick push for every branch with a remote: `git push origin <branch>`. For local-only: `git push -u origin <branch>`.
Stashes: `git stash show -p stash@{N} > ~/stash-N.patch` and add to the export bundle, or commit to a WIP branch.

## 1. Clone

```bash
bash ~/.dotfiles/macos/projects/clone.sh
```

Then restore env files / private dirs from the export bundle (paths listed in the export manifest).

## 2. Shared prerequisites

Node 24 (`node@24`), uv, go, Postgres, Redis, watchman, cocoapods, `mupdf-tools`, android-studio, zulu@17 come from
`macos/tools/Brewfile`. Node 24 covers every repo (frontend needs 20+, ui_library 24+), so no nvm. Extras:

```bash
brew bundle --file="$HOME/.dotfiles/macos/tools/Brewfile"
brew install python@3.11 aws-sam-cli
xcode-select --install          # needed for node-gyp (better-sqlite3, robotjs) and iOS
brew services start postgresql@16 && brew services start redis
```

`GH_PACKAGES_TOKEN` (classic PAT, `read:packages`) must be in each repo `.env`; `.npmrc` reads `${GH_PACKAGES_TOKEN}`.
Always `npm run install:env`, never bare `npm install`, in TaxGPT_App/frontend and TaxGPT_cowork.

## 3. TaxGPT_App

Remote `git@github.com:TaxGPT/TaxGPT_App.git`, branch `dev`. Python 3.11.6, Node 20+ (24 works), Django 5.2, Celery 5.4.

Database (Windows `.env` uses `DATABASE_NAME=taxgpt`, `DATABASE_USER=zafeer`, host localhost:5432):

Create role `zafeer` + db `taxgpt` (or restore the Windows dump) per `macos/tools/databases.md` section 2.

Backend (`backend/`, venv must be `backend/env`, CLAUDE.md commands use `./env/bin/python`):

```bash
cd ~/Desktop/Work/TaxGPT_App/backend
python3.11 -m venv env && source env/bin/activate
python scripts/install.py                         # reads GH_PACKAGES_TOKEN from .env for private tax engine
python scripts/install.py -r requirements.dev.txt # type stubs for pyright
python manage.py migrate
python manage.py createsuperuser --email admin@taxgpt.com
python manage.py runserver                        # http://127.0.0.1:8000
celery -A taxGPTbackend worker -l info --pool threads   # 2nd terminal, needs redis
celery -A taxGPTbackend beat -l info                    # optional, CELERY_BEAT_SCHEDULE exists
./env/bin/python manage.py test apps.crm.tests -v 2 --noinput
ruff check . && ruff format .
./env/bin/python manage.py makemigrations --check
```

Frontend (`frontend/`, Next.js):

```bash
cd ~/Desktop/Work/TaxGPT_App/frontend
npm run install:env
npm run dev              # http://localhost:3000
npm test && npm run type-check && npm run eslint:all
npm run storybook        # :6006, storybook:rac on :6007
```

Pre-commit (repo root): `bash scripts/setup-precommit.sh` (Windows had the hook installed).

Microservices (no Docker, run directly):

| Service | Commands |
| --- | --- |
| `microservices/anthropic_proxy` | Node >=20: `npm install && npm run dev`, `npm test` |
| `microservices/document_upload` | Go 1.25 + `mupdf-tools` (`mutool`): `cp .env.templete .env`, `go run main.go` (:8080) |
| `microservices/tax_engine` | Go 1.25: `cp .env.template .env`, `go run ./cmd/server`, `go test ./...` |
| `microservices/litellm` | uv, py 3.11: `uv sync`, `uv run pytest tests/test_weights.py -q` (proxy itself is Docker-only) |

## 4. TaxGPT_ai_services

Remote `git@github.com:TaxGPT/TaxGPT_ai_services.git`, branch `dev`. Python 3.11 (`.python-version`), uv, FastAPI.

```bash
cd ~/Desktop/Work/TaxGPT_ai_services
uv sync
uv run pre-commit install
uv run uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
uv run pytest
uv run pytest --cov=app --cov-report=term-missing
```

Uses Postgres (DATABASE_* in `.env`) and remote Neo4j/Aura.

## 5. TaxGPT_cowork (Electron)

Remote `git@github.com:TaxGPT/TaxGPT_cowork.git`, branch `EN-9044-harness-connect-card`. Node 24, npm.
Native modules `better-sqlite3`, `@jitsi/robotjs` rebuild on every `dev` (needs Xcode CLT).

```bash
cd ~/Desktop/Work/TaxGPT_cowork
npm run install:env
npm run dev                 # electron-rebuild + vite + electron
npm run dev:harness         # CLI harness, reads .env.harness if present
npm test && npm run type-check && npm run lint
npm run build:mac:local     # unsigned arm64 build
```

`TaxGPT_cowork-formatting` = worktree of this repo on `chore-prettier-setup` (clone.sh recreates it once pushed).

## 6. TaxGPT_ui_library

Remote `git@github.com:TaxGPT/TaxGPT_ui_library.git`, branch `main`. Node >=24, npm 10.8, turbo monorepo.

```bash
cd ~/Desktop/Work/TaxGPT_ui_library
set -a && source .env && set +a   # GH_PACKAGES_TOKEN (create .env from .env.example)
npm install
npm run build && npm run test && npm run typecheck && npm run lint
npm run storybook
```

## 7. chrome-extension

Remote `git@github.com:TaxGPT/chrome-extension.git`, branch `dev`. CRA + webpack.

```bash
cd ~/Desktop/Work/chrome-extension
npm install
npm start            # dev server
npm run build        # then chrome://extensions > Load unpacked > build/
npm test
```

## 8. taxgpt_mobile (React Native 0.75.2)

Remote `git@github.com:TaxGPT/taxgpt_mobile.git`, branch `main`. Node >=18, yarn 3.6.4 (corepack), Ruby + CocoaPods, JDK 17.

```bash
cd ~/Desktop/Work/taxgpt_mobile
corepack enable && yarn install
bundle install && (cd ios && bundle exec pod install)
yarn start           # metro
yarn ios             # needs Xcode app + simulator
yarn android         # needs Android Studio SDK, ANDROID_HOME=$HOME/Library/Android/sdk
yarn test && yarn lint
```

Install full Xcode from the App Store first (`sudo xcode-select -s /Applications/Xcode.app`).

## 9. Small repos

| Repo | Branch | Notes |
| --- | --- | --- |
| taxgpt_prompts | main | prompt text only, nothing to install |
| document-upload | main | AWS SAM: `cd backend && sam build && sam deploy --guided`, needs AWS creds |
| review-assignments/taxgpt-assignment | master | external repo (Usamaraoo), Next.js: `npm install && npm run dev` |
| claude-code-leaked | n/a | not git, copy folder from export bundle if wanted |
