# ✅ TODO – Plan de dezvoltare aplicație achiziții publice laborator

> Obiectiv general: dezvoltarea modulară și documentată a unei aplicații complete pentru gestionarea achizițiilor publice în laborator, cu capacitate de a relua dezvoltarea din orice punct.

---

## 📌 Obiective pe termen scurt (MVP)

1. [ ] Inițializare proiect: FastAPI + SvelteKit + Docker
2. [ ] Configurare autentificare cu FastAPI Users (rol unic)
3. [ ] Implementare model date:
    - `Utilizator`
    - `ProdusGeneric`
    - `ProdusComercial`
    - `Referat`, `CerereProdusGeneric`, `LotReferat`
4. [ ] Implementare flux „Redactare → Aprobare referat”
5. [ ] Formulare SvelteKit: creare referat + adăugare produse
6. [ ] Generare PDF referat de necesitate
7. [ ] Interfață listare + detaliu referat aprobat

---

## 📌 Obiective pe termen mediu

1. [ ] Implementare `ProceduraAchizitie` + `LotProcedura`
2. [ ] Înregistrare oferte comerciale
3. [ ] Legare oferte la produse comerciale și loturi
4. [ ] Evaluare + marcare ofertă câștigătoare
5. [ ] Contractare: creare contract + emitere comandă fermă
6. [ ] Înregistrare livrare (factură, aviz, cantitate)
7. [ ] Generare comenzi + documente asociate (PDF/Docs)
8. [ ] Export status complet achiziții (CSV/PDF)

---

## 🧠 Strategie de implementare

### Etape principale:
1. **Structurare modele + ORM**
2. **Separare logică în servicii (`services/`)**
3. **Testare cu FastAPI TestClient (unit + integration)**
4. **UI modular în SvelteKit (pagină per modul major)**
5. **Documente generate automat în backend**
6. **Deploy cu `docker-compose` pe VPS Hetzner via Coolify**

---

## 🔄 Actualizare documentație

Documentația va fi **actualizată la fiecare commit semnificativ**.  
Orice modificare de logică, flux sau model va impune:

- [ ] 🔁 Sincronizare:
  - `erd.mmd` – actualizat la modificări în structură de date
  - `activitate.mmd` – actualizat la schimbări de flux
  - `logica.md` – completat cu noi entități, reguli sau validări
- [ ] 🔖 Marcare commit cu `checkpoint: nume_modificare`
- [ ] 🗂 Commit în GitHub cu mesaj explicit: `update logică + ERD`

---

## 🧯 Mecanism de reluare după întrerupere

Dacă dezvoltarea este întreruptă:
- Se consultă fișierele:
  - `logica.md` pentru înțelegerea fluxului
  - `erd.mmd` pentru bază de date
  - `activitate.mmd` pentru pașii procesuali
  - `TODO.md` pentru progres și priorități
- Se poate recrea rapid contextul local:
  - rulare `docker-compose up`
  - restaurare `.env` + dump SQLite/Postgres

---

## 🗂 Structura repo (propunere)

```bash
repo/
├── app/                # backend FastAPI
├── sveltekit/          # frontend SvelteKit
├── docs/               # documentație permanentă
│   ├── erd.mmd
│   ├── activitate.mmd
│   ├── logica.md
│   └── TODO.md
├── docker-compose.yml
├── .env.template
└── README.md
```

