# AQZ – Aplicație pentru gestionarea achizițiilor publice

Aplicație web pentru gestionarea completă a achizițiilor publice în laboratoare de biologie moleculară. Construită modular, containerizată, ușor de publicat cu Docker și Coolify.

## 🚀 Rulare locală cu Docker

```bash
docker-compose up --build

Accesează aplicația la: [http://localhost:8000](http://localhost:8000)

---

## 📁 Structura proiectului

```bash
aqz/
├── app/                  # Backend FastAPI
│   ├── main.py
│   ├── Dockerfile
│   └── pyproject.toml
├── docker-compose.yml    # Orchestrare backend (și frontend în viitor)
├── .env.template         # Variabile de mediu (exemplu)
├── .gitignore
├── README.md
└── docs/                 # Documentație sistem
    ├── erd.mmd
    ├── activitate_old.mmd      # diagramă veche de activitate (arhivată)
    ├── logica.md
    └── TODO.md
```

---

## 🧪 Dezvoltare locală alternativă (fără Docker)

```bash
cd app
uv venv
source .venv/bin/activate
uv pip install --all
uvicorn main:app --reload
```

---

## 🔐 Gestiune versiuni (Git + GitHub)

- Repo: https://github.com/USERNAME/aqz
- Branch principal: `main`
- Commituri importante conțin prefix `checkpoint: descriere`
- Documentația (`docs/`) se actualizează la fiecare etapă

---

## ✅ Documentație cheie

- `erd.mmd`: diagrama logică (entități, relații)
- `activitate_old.mmd`: diagramă de activitate arhivată – nu se mai actualizează
- `logica.md`: descriere logică completă a aplicației
- `TODO.md`: strategia și obiectivele de dezvoltare

---

## 🛰️ Deploy în producție

- Recomandat: [Coolify](https://coolify.io) pe VPS (Hetzner etc.)
- Metodă: push GitHub → Coolify auto-deploy (Docker Compose)

---

## 🗃️ Notă despre documentația activităților

Fișierul `activitate.mmd` a fost arhivat ca `activitate_old.mmd` pentru a simplifica întreținerea documentației. Documentația activă este acum formată din:

- `logica.md` – descriere completă a entităților și proceselor
- `erd.mmd` – diagrama logică a bazei de date
- `TODO.md` – obiective și stadiul dezvoltării