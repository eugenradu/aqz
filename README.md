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
    ├── activitate.mmd
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
- `activitate.mmd`: flux de activitate achiziție
- `logica.md`: descriere logică completă a aplicației
- `TODO.md`: strategia și obiectivele de dezvoltare

---

## 🛰️ Deploy în producție

- Recomandat: [Coolify](https://coolify.io) pe VPS (Hetzner etc.)
- Metodă: push GitHub → Coolify auto-deploy (Docker Compose)

---