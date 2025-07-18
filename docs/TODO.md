# ✅ TODO – Plan de dezvoltare aplicație achiziții publice laborator

> Obiectiv general: dezvoltarea modulară și documentată a unei aplicații complete pentru gestionarea achizițiilor publice în laborator, cu capacitate de a relua dezvoltarea din orice punct.

---

## 📌 Obiective pe termen scurt (MVP)

1. [ ] Inițializare proiect: FastAPI + SvelteKit + Docker
2. [ ] Autentificare:
    2.1 [ ] Integrare completă FastAPI Users (cu SQLite în MVP)
    2.2 [ ] Model `Utilizator` și configurare UserDB
    2.3 [ ] Endpointuri de autentificare și înregistrare
    2.4 [ ] Asigurare că toate endpointurile aplicației sunt protejate (auth_required)
    2.5 [ ] Izolare cod autentificare în `auth/` (routere, models, config)
    2.6 [ ] (Opțional) Mecanism de creare conturi numai din backend (fără self-register)
3. [ ] Implementare model date:
    - `Utilizator`
    - `ProdusGeneric`
    - `ProdusComercial`
    - `Referat`, `LotReferat`, `CerereProdusGeneric`
    - modelare unități de măsură + conversie ambalaj (UM + factor_conversie)
    - `EchivalentaProdusGeneric` (asociere M:N între produse comerciale și generice)
    - `FurnizorProdusComercial` (cod catalog și termen livrare pe furnizor)
    - mecanism import produse generice din fișier JSON (cu validări, completări manuale, cod automat)
3.5 [ ] MVP simplificat: flux complet de bază
     - creare Referat cu produse generice
     - adăugare ofertă informală (fără procedură)
     - validare conversie UM și echivalență produse comerciale ↔ produse generice
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
2.3 [ ] La introducerea unei oferte noi, dacă produsul comercial există deja în baza de date (pe baza codului și producătorului), atunci va fi reutilizat. Se vor actualiza doar detaliile comerciale relevante (preț, UM, ambalare, valabilitate). În caz contrar, produsul comercial va fi creat.
3. [ ] Legare oferte la produse comerciale și loturi
3.1 [ ] Script de import JSON în backend pentru produse generice (raportează erorile într-un fișier log) – UI avansat amânat după MVP
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
5.6.1 [ ] Legătură 1:1 între COMANDA și COMANDA_SUBSECVENTA (comandă generală vs. subsecventă)
5.6.2 [ ] Păstrarea entității COMANDA pentru comenzi de orice tip
5.7 [ ] Entitate `ComandaSubsecventa` cu produse și cantități
5.8 [ ] Validare contract activ și de tip acord-cadru
5.9 [ ] Link fișier PDF/Doc pentru orice tip de comandă (fermă sau subsecventă)
5.10 [ ] Înregistrare StatusLog pentru tranziții de status la entitățile cu FSM
5.11 [ ] Implementare serviciu centralizat `DocumentService` pentru:
     - upload fișiere (local, S3 sau link extern)
     - asociere fișier la entități (ex: Oferta, Contract, Livrare)
     - generare link securizat (temporar) pentru descărcare
     - validare denumire și tip fișier

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
5.6.1 [ ] Legătură 1:1 între COMANDA și COMANDA_SUBSECVENTA (comandă generală vs. subsecventă)
5.6.2 [ ] Păstrarea entității COMANDA pentru comenzi de orice tip
5.7 [ ] Entitate `ComandaSubsecventa` cu produse și cantități
5.8 [ ] Validare contract activ și de tip acord-cadru
5.9 [ ] Link fișier PDF/Doc pentru orice tip de comandă (fermă sau subsecventă)
5.10 [ ] Înregistrare StatusLog pentru tranziții de status la entitățile cu FSM
5.11 [ ] Implementare serviciu centralizat `DocumentService` pentru:
     - upload fișiere (local, S3 sau link extern)
     - asociere fișier la entități (ex: Oferta, Contract, Livrare)
     - generare link securizat (temporar) pentru descărcare
     - validare denumire și tip fișier

---

## 📄 Documente atașate
1. [ ] Atașamente pentru `CONTRACT` (PDF/Doc link via DOCUMENT)
2. [ ] Atașamente pentru `LIVRARE` (factură, aviz)
3. [ ] Atașamente pentru `OFERTA` (fișier ofertă)
4. [ ] Documente identificabile prin: tip, nume, link
5. [ ] Entitatea `DOCUMENT` folosită pentru toate tipurile

---

## 🧠 Strategie de implementare

0. **Autentificare completă**
   0.1 Se implementează în întregime la început, pentru a permite testarea în condiții reale de securitate
   0.2 Se izolează codul legat de autentificare în `auth/`
   0.3 Se marchează toate endpointurile care necesită login (inclusiv /docs)
   0.4 Se creează conturi doar din backend în MVP (fără interfață de self-register)

1. **Structurare modele + ORM**
2. **Separare logică în servicii (`services/`)**
2.1 Pentru entități centrale (ex: Oferta, Contract), se vor crea servicii dedicate (ex: `OfertaService`, `ContractService`) care vor implementa toată logica de business și tranzițiile de status.
2.2 Modelele SQLAlchemy și Pydantic vor rămâne simple, fără logică aplicativă directă.
2.3 Pentru entitățile cu statusuri și fluxuri complexe (ex: Referat, Oferta, Procedura, Contract), se va implementa o Finite State Machine (FSM) simplă care definește tranzițiile valide de stare.
2.4 FSM-urile vor fi centralizate (ex: în `services/fsm/`) și invocate exclusiv din servicii (ex: `OfertaService.set_status(...)`).
2.5 Se vor scrie teste unitare pentru FSM-uri pentru a asigura stabilitatea logicii de tranziție.
2.6 Se va introduce entitatea `StatusLog` pentru înregistrarea tuturor tranzițiilor de status (entitate, id, status vechi/nou, utilizator, dată). Va fi creată automat de fiecare serviciu care implementează FSM.
2.7 Se va crea serviciul `DocumentService` care gestionează încărcarea, salvarea, legarea și securizarea documentelor (Google Docs link, PDF local etc.). Acesta va fi apelat de entitățile relevante (Oferta, Contract, Livrare).
3. **Testare cu FastAPI TestClient (unit + integration)**
4. **UI modular în SvelteKit (pagină per modul major)**
5. **Documente generate automat în backend**
6. **Deploy cu `docker-compose` pe VPS Hetzner via Coolify**
7. Jurnalizare acțiuni în AUDIT_LOG (opțional, extensibil)

0. Se prioritizează fluxul MVP simplificat: Referat → Ofertă informală → Echivalare produs comercial/generic. Complexitatea (proceduri, contracte) se adaugă ulterior.

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
  - `logica.md` – actualizat cu modelul de audit și relațiile contract-document
  - `erd.mmd` – adăugat AUDIT_LOG și relație CONTRACT → DOCUMENT
  - `logica.md` – completat cu principii de arhitectură și separare responsabilități (servicii vs. modele)
  - `logica.md` – adăugat StatusLog pentru urmărirea tranzițiilor de status
  - `erd.mmd` – adăugată entitate STATUS_LOG
  - `TODO.md` – adăugat obiectiv privind jurnalizarea tranzițiilor de status
  - `logica.md` – completat cu detalii despre gestionarea documentelor prin serviciu dedicat
  - `logica.md` – completat cu detalii privind reutilizarea produselor comerciale la introducerea unei oferte
  - `erd.mmd` – actualizat cu relațiile și logica de reutilizare produse comerciale în ofertare
  - `TODO.md` – obiectiv intermediar privind logica de reutilizare produs comercial
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
