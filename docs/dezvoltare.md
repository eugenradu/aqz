### Ciclul de Dezvoltare și Deploy (Supabase + SvelteKit)

Acest flux de lucru este conceput pentru a oferi o experiență de dezvoltare modernă, rapidă și sigură. El separă clar mediul local de cel de producție și automatizează cât mai mult posibil procesul de actualizare a aplicației live.

---

### **Faza 1: Ciclul de Dezvoltare Locală (Bucla Zilnică pe macOS)**

Aici petreci 99% din timp. Totul rulează în containere Docker, deci sistemul tău de operare rămâne curat.

1.  **Pornirea Mediului:**
    * Deschizi terminalul în folderul proiectului.
    * Rulezi comanda `supabase start`.
    * **Ce se întâmplă?** Supabase CLI folosește Docker Desktop pentru a porni întregul backend Supabase (baza de date PostgreSQL, autentificare, stocare fișiere etc.) într-o serie de containere. Ai un backend complet funcțional, dar izolat, la tine pe Mac.

2.  **Dezvoltarea Frontend:**
    * Într-un al doilea terminal, rulezi `npm run dev`.
    * **Ce se întâmplă?** Pornește serverul de dezvoltare SvelteKit. Acesta este configurat să comunice cu instanța Supabase locală (cea din Docker). Când modifici un fișier `.svelte`, browserul se actualizează automat (Hot Reloading).

3.  **Modificarea Aplicației (Exemple):**
    * **Schimbare de UI:** Editezi un fișier `.svelte` în VS Code. Schimbarea apare instant în browser.
    * **Schimbare de Logică Backend (Schema Bazei de Date):**
        * Vrei să adaugi o coloană nouă în tabela `Contract`.
        * Creezi un nou fișier de migrație în folderul `supabase/migrations/` (ex: `0004_add_status_to_contract.sql`).
        * Scrii comanda `ALTER TABLE "Contract" ADD COLUMN ...` în acest fișier.
        * Rulezi `supabase db reset`. Această comandă șterge și reface baza de date locală, aplicând toate migrațiile în ordine. Astfel, te asiguri că structura locală este mereu consistentă cu istoricul migrațiilor.
    * **Schimbare de Logică Backend (Edge Function):**
        * Editezi un fișier TypeScript în folderul `supabase/functions/numele-functiei/`.
        * Serverul local Supabase detectează schimbarea și actualizează funcția automat.

4.  **Oprirea Mediului:**
    * Când ai terminat, rulezi `supabase stop`. Toate containerele sunt oprite.

---

### **Faza 2: Controlul Versiunilor (Sincronizarea cu GitHub)**

Acesta este pasul care permite colaborarea și pregătește terenul pentru deploy.

1.  **Ce se salvează?** Adaugi în Git întregul folder al proiectului, inclusiv:
    * Codul sursă SvelteKit (`src/`, `package.json`, etc.).
    * **Tot folderul `supabase/`**. Acesta este esențial, deoarece conține toate migrațiile bazei de date, codul pentru Edge Functions și configurația locală.

2.  **Fluxul de lucru:** Folosești comenzi standard Git:
    ```bash
    git add .
    git commit -m "feat: Adăugat status la contracte și funcția de notificare"
    git push origin main
    ```
    Acum, repository-ul tău GitHub conține definiția completă și istorică a întregii aplicații (frontend și backend).

---

### **Faza 3: Ciclul de Deploy (Self-Hosting pe VPS)**

Acest proces descrie cum să instalezi și să actualizezi atât backend-ul Supabase, cât și frontend-ul SvelteKit pe același server VPS (Hetzner), folosind containere Docker.

#### **Pasul 1: Pregătirea Inițială a Serverului (O singură dată)**

1.  **Instalează Docker și Docker Compose** pe VPS-ul tău.
2.  **Configurează un Reverse Proxy** (ex: Nginx Proxy Manager, Caddy sau Traefik). Acesta este esențial pentru a gestiona subdomeniile (ex: `api.domeniultau.ro` pentru Supabase, `app.domeniultau.ro` pentru SvelteKit) și pentru a genera automat certificate SSL/TLS.
3.  **Clonează Proiectul:** Conectează-te prin SSH la server și clonează repository-ul tău de pe GitHub: `git clone <URL-ul-repo-ului-tau>`.

#### **Pasul 2: Deploy-ul și Gestiunea Backend-ului Supabase (Self-Hosted)**

1.  **Configurarea pentru Producție:**
    * În folderul `supabase/` de pe server, copiază fișierul `docker-compose.yml` generat de Supabase într-un nou fișier, de exemplu `docker-compose.prod.yml`.
    * Creează un fișier `.env` în același director. Aici vei stoca **secretele de producție**: `POSTGRES_PASSWORD`, `JWT_SECRET`, `ANON_KEY`, `SERVICE_ROLE_KEY`. **Este crucial să generezi valori noi, puternice și sigure pentru acestea, nu să le folosești pe cele din dezvoltare.**
2.  **Pornirea Inițială:** Rulează `docker-compose -f docker-compose.prod.yml up -d`. Aceasta va porni toate containerele Supabase în fundal.
3.  **Configurarea Reverse Proxy:** Configurează reverse proxy-ul să direcționeze traficul de la subdomeniul tău (ex: `api.domeniultau.ro`) către containerul `kong` din rețeaua Docker, pe portul corespunzător (de obicei 8000).
4.  **Aplicarea Migrațiilor:** Spre deosebire de dezvoltarea locală, **nu vei folosi `supabase db reset`**. Pentru a aplica migrațiile pe baza de date de producție, te vei conecta la containerul PostgreSQL și vei rula manual fișierele SQL din folderul `migrations`.
    ```bash
    # Exemplu de aplicare manuală a unei migrații
    cat supabase/migrations/0004_add_status_to_contract.sql | docker-compose -f docker-compose.prod.yml exec -T db psql -U postgres -d postgres
    ```

#### **Pasul 3: Deploy-ul Frontend-ului SvelteKit (Automatizat)**

Această parte rămâne similară, dar se va conecta la instanța ta self-hosted.

1.  **Pregătirea (o singură dată):**
    * Creezi un `Dockerfile` în rădăcina proiectului pentru a construi imaginea de producție a aplicației SvelteKit.
    * În Coolify/Dokku, conectezi repository-ul tău de GitHub.
    * Configurezi variabilele de mediu pentru producție:
        * `PUBLIC_SUPABASE_URL`: URL-ul instanței tale Supabase self-hosted (ex: `https://api.domeniultau.ro`).
        * `PUBLIC_SUPABASE_ANON_KEY`: Cheia `ANON_KEY` pe care ai setat-o în fișierul `.env` de pe server.
2.  **Procesul Automat (la `git push`):**
    * La fiecare `git push` pe ramura `main`, Coolify/Dokku va prelua codul, va construi o nouă imagine Docker a frontend-ului și o va porni, conectându-se la backend-ul Supabase care rulează deja pe același VPS.
