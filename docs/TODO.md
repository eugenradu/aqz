# ✅ TODO – Plan de dezvoltare aplicație achiziții (Supabase + SvelteKit)

> Obiectiv general: dezvoltarea rapidă a unui MVP funcțional, urmată de extinderea modulară a funcționalităților, folosind arhitectura Supabase + SvelteKit.

---

## 🚀 Strategie de Implementare (Principii)

1.  **Dezvoltare bazată pe Migrații:** Orice modificare a schemei bazei de date (tabele, funcții, RLS) se face exclusiv prin fișiere de migrație SQL, gestionate cu Supabase CLI.
2.  **Logică Izolată:** Logica de business complexă se implementează în **Supabase Edge Functions**. Frontend-ul rămâne responsabil doar pentru UI și interacțiune.
3.  **Securitate la Nivel de Bază de Date:** Accesul la date este controlat prin **Row Level Security (RLS)**, asigurând că un utilizator nu poate accesa niciodată date neautorizate.
4.  **Componente Modulare:** Interfața SvelteKit va fi construită din componente reutilizabile și pagini dedicate fiecărui modul principal (Referate, Oferte, etc.).

---

## 📌 Obiective pe termen scurt (MVP)

Scopul MVP este să avem un flux funcțional de creare și vizualizare a unui referat, cu autentificare și structura de bază a proiectului.

1.  **[ ] Inițializare Proiect și Mediu de Lucru**
    1.1. [ ] Inițializare proiect SvelteKit (`npm create svelte@latest`).
    1.2. [ ] Inițializare proiect Supabase local (`supabase init`).
    1.3. [ ] Pornire servicii locale Supabase (`supabase start`) și salvare chei API.

2.  **[ ] Structura Bazei de Date (Schema Inițială)**
    2.1. [ ] Creare migrație SQL pentru tabelele de bază: `profiles`, `ProdusGeneric`, `Referat`, `CerereProdusGeneric`.
    2.2. [ ] Aplicare migrație în mediul local (`supabase db reset`).

3.  **[ ] Autentificare și Profil Utilizator**
    3.1. [ ] Configurare **Supabase Auth** în SvelteKit (login/logout).
    3.2. [ ] Creare pagini de autentificare (Login, Register).
    3.3. [ ] Implementare trigger PostgreSQL pentru a crea automat un `profile` la înregistrarea unui nou utilizator în `auth.users`.
    3.4. [ ] Configurare RLS de bază: utilizatorii autentificați își pot vedea și crea propriile referate.

4.  **[ ] Modulul "Produse Generice"**
    4.1. [ ] Creare pagină SvelteKit pentru listarea produselor generice.
    4.2. [ ] Creare formular pentru adăugarea/editarea unui `ProdusGeneric`.

5.  **[ ] Modulul "Referate" (Flux de bază)**
    5.1. [ ] Creare pagină SvelteKit pentru listarea referatelor create de utilizatorul curent.
    5.2. [ ] Creare formular complex în SvelteKit pentru crearea unui `Referat` nou, care permite adăugarea dinamică a mai multor `CerereProdusGeneric`.
    5.3. [ ] Implementare logică de salvare a referatului și a produselor asociate în baza de date.

---

## 📌 Obiective pe termen mediu

După finalizarea MVP, extindem aplicația pentru a acoperi întregul flux de achiziții.

1.  **[ ] Structură Completă Bază de Date**
    1.1. [ ] Creare migrații SQL pentru restul tabelelor: `Procedura`, `LotProcedura`, `Oferta`, `OfertaItem`, `Contract`, `Comanda`, `Livrare`, etc.
    1.2. [ ] Definire relații și constrângeri între tabele.

2.  **[ ] Stocare Fișiere (Documente)**
    2.1. [ ] Implementare upload de fișiere în **Supabase Storage** pentru entitatea `Documente`.
    2.2. [ ] Creare componentă SvelteKit reutilizabilă pentru upload și atașare documente la entități (Oferte, Contracte).

3.  **[ ] Implementare Flux "Ofertare"**
    3.1. [ ] Creare interfețe pentru managementul Procedurilor și Loturilor.
    3.2. [ ] Creare formular de înregistrare a unei `Oferte`, cu posibilitatea de a adăuga `OfertaItem` pentru fiecare lot și de a atașa documente.

4.  **[ ] Implementare Logică de Business în Edge Functions**
    4.1. [ ] Creare **Edge Function** pentru generarea automată a unei `Comanda` la crearea unui `Contract` de tip `contract_ferm`.
    4.2. [ ] Creare **Edge Function** pentru generarea unui PDF simplu (ex: Referat de necesitate).
    4.3. [ ] Creare **Edge Function** pentru importul de produse dintr-un fișier JSON.

5.  **[ ] Implementare Flux "Contractare și Comenzi"**
    5.1. [ ] Interfață pentru vizualizarea contractelor.
    5.2. [ ] Interfață pentru crearea manuală a comenzilor subsecvente pentru un `acord-cadru`.

6.  **[ ] Implementare Flux "Livrări"**
    6.1. [ ] Formular pentru înregistrarea unei `Livrari` aferente unei comenzi.
    6.2. [ ] Implementare validări (prin trigger PostgreSQL) pentru a preveni livrarea unei cantități mai mari decât cea comandată.

7.  **[ ] Audit și Raportare**
    7.1. [ ] Implementare trigger PostgreSQL pentru popularea automată a tabelei `AuditLog`.
    7.2. [ ] Creare pagină de vizualizare a jurnalului de audit.

---

## 🧯 Mecanism de reluare după întrerupere

Dacă dezvoltarea este întreruptă, contextul poate fi recreat rapid:
1.  **Consultă documentația:** `logica.md` (fluxul), `erd.md` (structura datelor), `TODO.md` (progresul).
2.  **Clonează repo-ul GitHub.**
3.  **Rulează `npm install`** pentru a instala dependențele SvelteKit.
4.  **Rulează `supabase start`** pentru a porni mediul local. Baza de date se va recrea automat pe baza fișierelor de migrație.