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
    - `Referat`, `LotReferat`, `CerereProdusGeneric`
    - modelare unități de măsură + conversie ambalaj (UM + factor_conversie)
    - `EchivalentaProdusGeneric` (asociere M:N între produse comerciale și generice)
    - `FurnizorProdusComercial` (cod catalog și termen livrare pe furnizor)
    - mecanism import produse generice din fișier JSON (cu validări, completări manuale, cod automat)
4. [ ] Implementare flux „Redactare → Aprobare referat”
5. [ ] Formulare SvelteKit: creare referat + adăugare produse
6. [ ] Generare PDF referat de necesitate
7. [ ] Interfață listare + detaliu referat aprobat

---

## 📌 Obiective pe termen mediu

1. [ ] Implementare `ProceduraAchizitie`, `LotProcedura` (unități oficiale de achiziție)
2. [ ] Înregistrare oferte comerciale (cu validare echivalență UM comercială ↔ UM cerută, conversie UM)
2.1 [ ] Adăugare produs comercial direct, cu sau fără asociere la produs generic
2.2 [ ] Implementare completă `OfertaItem` (conține legătura produs generic ↔ produs comercial + detalii ofertă)
3. [ ] Legare oferte la produse comerciale și loturi
3.1 [ ] Interfață completă pentru import JSON: încărcare, afișare rezultate, completare câmpuri lipsă
3.2 [ ] Înregistrare ofertă independentă (fără legătură directă cu referat sau procedură)
3.3 [ ] Link fișier ofertă (Google Docs / PDF / alt URL)
3.4 [ ] Validare completitudine ofertă pentru loturi (în context procedură)
3.5 [ ] Câmp valabilitate ofertă și monedă (RON, EUR etc.)
4. [ ] Evaluare + marcare ofertă câștigătoare
5. [ ] Contractare: creare contract + emitere comandă fermă
5.1 [ ] Tipuri de proceduri: achiziție directă, negociere SEAP, licitație deschisă
5.2 [ ] Tipuri de contract: contract ferm, acord-cadru
5.3 [ ] Suport pentru atașamente contract (link fișier pdf/doc)
5.4 [ ] Număr și dată de înregistrare pentru contracte (nullable)
5.5 [ ] Calcul valoare contract per lot (din oferta asociată)
5.6 [ ] Contracte subsecvente (comenzi) pentru acorduri-cadru
5.7 [ ] Entitate `ComandaSubsecventa` cu produse și cantități
5.8 [ ] Validare contract activ și de tip acord-cadru
5.9 [ ] Link fișier PDF/Doc comandă subsecventă
5.10 [ ] Stare comandă: emisă, livrată parțial, livrată complet, anulată
6. [ ] Înregistrare livrare (factură, aviz, cantitate)
6.1 [ ] Adăugare entitate `Livrare`
6.2 [ ] Suport livrări parțiale (cantitate < comandă)
6.3 [ ] Entitate `LivrareItem` cu data expirare și lot (opțional)
6.4 [ ] Entitate `LivrareDocument` (tip, link, nume)
6.5 [ ] Filtrare livrări după furnizor, produs, contract
6.6 [ ] Integrare API webhook pentru aplicația de gestiune stocuri
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
  - `logica.md` – include regulile de import produse generice
  - `logica.md` – actualizat cu gestionarea ofertelor (tipuri, validări, fișiere, produse comerciale)
  - `TODO.md` – actualizat cu noi entități și obiective intermediare
  - `logica.md` – completat cu detalii despre contracte și proceduri
  - `erd.mmd` – actualizat cu entitatea CONTRACT, CONTRACT_LOT și câmpuri suplimentare
  - `logica.md` – actualizat cu `ComandaSubsecventa`
  - `erd.mmd` – adăugat modelul comenzilor subsecvente
  - `logica.md` – actualizat cu secțiunea extinsă pentru livrări
  - `erd.mmd` – adăugat model livrări cu atașamente și produse
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
