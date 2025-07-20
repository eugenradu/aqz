# ✅ TODO – Plan de dezvoltare aplicație aqz (Supabase + SvelteKit)

> **Stadiu actual:** Fundația tehnică este solidă. Fluxul urgent de import al produselor din JSON este complet funcțional.

### ✅ **Sarcini Finalizate (Flux Urgent)**

1. **[✓] Configurare Mediu de Dezvoltare:** Proiect SvelteKit și Supabase inițializat și funcțional local în containere Docker.

2. **[✓] Definire Schemă Bază de Date:** Structura completă a bazei de date (tabele, relații, funcții) a fost creată printr-o migrație consolidată.

3. **[✓] Creare Date Inițiale:** Fișierul `seed.sql` populează corect baza de date cu date de test.

4. **[✓] Implementare Flux de Import Produse:**

   * **[✓] Interfață de Upload (SvelteKit):** Pagina `/import` este funcțională.

   * **[✓] Logică de Backend (Supabase):** Funcția `handle_product_import` gestionează validarea, generarea de coduri unice și inserarea produselor.

   * **[✓] Gestionare Categorii Noi:** Interfața permite utilizatorului să adauge categorii noi cu prefixe unice, în mod interactiv și sigur.

### 🎯 **Următorii Pași: Faza 2 - Construirea Generatorului de Referate**

*Scop: Crearea unei interfețe care permite selectarea produselor importate și gruparea lor în loturi pentru a genera un referat de necesitate.*

1. **[ ] Crearea Paginii "Referat Nou" (SvelteKit)**

   * **1.1.** Creare rută nouă `/referate/new`.

   * **1.2.** Implementare formular de bază cu un câmp pentru `titlul` referatului.

   * **1.3.** Adăugare secțiune dinamică în UI care permite utilizatorului să adauge, să redenumească (`Nume lot`) și să șteargă loturi.

2. **[ ] Implementare Interfață de Adăugare Produse în Loturi**

   * **2.1.** În fiecare lot, adăugare componentă de căutare care interoghează și afișează produse din tabela `ProdusGeneric`.

   * **2.2.** La selectarea unui produs, acesta se adaugă vizual în lot.

   * **2.3.** Pentru fiecare produs adăugat, se afișează două câmpuri: `Cantitate minimă` și `Cantitate maximă`.

3. **[ ] Crearea Logicii de Salvare a Referatului**

   * **3.1.** Creare funcție PostgreSQL (RPC) `creare_referat_complet` care primește datele referatului, lista de loturi și lista de produse per lot.

   * **3.2.** Implementare acțiune SvelteKit (`+page.server.ts`) care colectează toate datele din formular și apelează funcția RPC.

   * **3.3.** Afișare mesaj de succes și redirecționare către pagina de vizualizare a referatului nou creat.

4. **[ ] Pagina de Vizualizare Referat**

   * **4.1.** Creare rută dinamică `/referate/[id]`.

   * **4.2.** Preluare date din baza de date și afișarea structurată a referatului, cu loturi și produse.

   * **4.3.** Implementare formatare corectă pentru câmpul `specificatii_tehnice` (cu `white-space: pre-wrap;`).