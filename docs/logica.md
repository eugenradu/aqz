# 🧠 Logica aplicației de gestionare a achizițiilor publice pentru laborator

## ✅ Scopul aplicației

Această aplicație gestionează întregul flux de achiziții publice pentru materiale de laborator, de la inițierea cererii (referat de necesitate) până la recepția livrărilor și integrarea în gestiunea de stocuri. Este destinată laboratoarelor mici-medii și respectă cadrul legal aplicabil în România.

---

## 📦 Module funcționale

1. Referate de necesitate
2. Ofertare
3. Proceduri de achiziție
4. Contractare
5. Comenzi
6. Livrări
7. Documente
8. (Opțional) Gestiune stocuri

---

## 🧱 Entități principale

### Referat
- Solicitare internă de achiziție.
- Include produse generice grupate în loturi interne (`LotReferat`), orientative pentru achiziții.
- Stări: `draft`, `trimis`, `aprobat`, `respins`, `anulat`.

### LotReferat
- Lot intern, propus în cadrul unui referat de necesitate.
- Grupare orientativă de produse generice (ex: "Reactivi PCR").
- Servește organizării cererii interne, dar nu este obligatoriu reflectat în procedura de achiziție.

### ProdusGeneric
- Produs cu specificații tehnice, fără denumire comercială.
- Clasificat pe categorii (ex: reactivi, consumabile).
- UM = unitate de lucru ireductibilă (ex: „reacție”, „test”, „litru”)
- Cantitățile exprimate în aceste unități servesc ca bază pentru cerințe, comparații și raportări
  
-### ProdusComercial
- Reprezintă un produs oferit de un furnizor.
- Conține o descriere text liber (ex: compoziție, aplicații, caracteristici comerciale)
- Are UM comercială (ex: kit, flacon, cutie), diferită de UM-ul produsului generic.
- Include un factor de conversie față de UM de referință:
  - `um_comerciala` – unitatea de ambalaj (ex: "kit")
  - `valoare_ambalaj` – număr de unități de referință conținute (ex: 48 reacții)
  - `um_referinta` – unitatea cerută în `ProdusGeneric` (ex: "reacție")
  - `factor_conversie` – echivalentul unui ambalaj în UM de referință
- Permite echivalarea și compararea între produse diferit ambalate care răspund aceleiași cerințe.
- Poate exista fără asociere cu un produs generic (ex: introducere manuală de produs nou).
- Poate fi asociat unuia sau mai multor produse generice printr-o relație de echivalare (`EchivalentaProdusGeneric`), cu justificare tehnică opțională.
- În cadrul ofertelor, un `ProdusComercial` este referit prin `OfertaItem`, care include furnizorul, prețul, cantitatea și termenul de livrare.
- Poate apărea în oferte multiple, fie pentru un referat informal, fie într-o procedură formală.
- Aceeași ofertă poate include produse comerciale de la mai mulți furnizori pentru același produs generic.
- La introducerea unei oferte, dacă `ProdusComercial` există deja (identificat prin `cod_catalog`, `producator` și, opțional, `ambalare`), acesta este reutilizat. În acest caz, `OfertaItem` va face referință la produsul existent și va conține detalii comerciale specifice ofertei curente (ex: preț, UM, termen livrare). Dacă produsul nu există, este creat automat. Se poate actualiza parțial metadatele produsului dacă sunt mai complete decât cele existente.

### Furnizor
- Entitate juridică care oferă produse comerciale.

### EchivalentaProdusGeneric
- Reprezintă legătura între un produs comercial și unul sau mai multe produse generice echivalente.
- Permite compararea și validarea conformității tehnice.
- Poate include justificare text (ex: fișă tehnică, descriere echivalență).

### OfertaItem
- Linie de ofertă pentru un `ProdusComercial`.
- Include cantitate, preț unitar, termen de livrare, UM comercială.
- Se referă la un `ProdusGeneric` și un `ProdusComercial`.
- Este parte dintr-o ofertă (`Oferta`), asociată cu un `LotReferat` sau `LotProcedura`.

### Oferta
- Răspuns la un referat (informal) sau o procedură (oficială).
- Include produse comerciale și costuri (`OfertaItem`).
- Se leagă de un lot (opțional în cazul ofertelor nesolicitate).
- Ofertele pot fi:
  - independente (ex: ofertă primită fără referat, doar pentru înregistrare internă)
  - asociate cu un referat de necesitate (răspuns informal)
  - asociate cu o procedură de achiziție (răspuns formal)
- În contextul unei proceduri, oferta trebuie să acopere complet cel puțin un `LotProcedura`.
- O ofertă poate include produse pentru mai multe loturi.
- Conține:
  - data primirii
  - furnizorul ofertant
  - valabilitate (opțional)
  - moneda (`RON`, `EUR`, etc.)
  - link la fișierul original (upload sau link GDrive)
- La introducerea unei oferte se permite:
  - verificarea existenței unui `ProdusComercial` (după cod_catalog + producător + ambalare opțional) și:
      - reutilizarea lui dacă există, cu adăugarea detaliilor comerciale în OfertaItem
      - crearea unui produs nou dacă nu există
  - asocierea unui `ProdusComercial` cu un `ProdusGeneric` prin echivalență
- Status ofertă (`status`): `inregistrata`, `in analiza`, `respinsa`, `selectata`, `castigatoare`
- Data transmiterii ofertei (`data_transmitere`), separată de data înregistrării.
- Câmp opțional de justificare (`motiv_selectare`) pentru alegerea unei oferte.
- Flag boolean `este_completa` definit pe `LotOferta`, care indică dacă toate produsele din `LotProcedura` au fost acoperite.
- Valoarea totală a ofertei și pe lot este calculată dinamic (nu stocată).
- Suport pentru atașamente multiple: entitate `OfertaDocument`, fiecare cu `nume`, `tip`, `link`.
- - Pentru gestionarea stărilor complexe ale ofertelor (`inregistrata`, `in analiza`, `respinsa`, `selectata`, `castigatoare`), se recomandă folosirea unui sistem de tip **Finite State Machine (FSM)**. Tranzițiile valide vor fi definite explicit într-un serviciu dedicat (`OfertaService`), pentru a evita logica dispersată în view-uri sau modele.

### ProceduraAchizitie
- Grup de loturi oficiale (`LotProcedura`) definite pentru achiziție.
- Poate agrega produse din mai multe referate.
- Tipuri: `achizitie_directa`, `negociere_SEAP`, `licitatie_deschisa`
- Stări: `în pregătire`, `publicată`, `atribuită`, `finalizată`.

### LotProcedura
- Unități de atribuire.
- Atribuite unui ofertant câștigător.
- Pot conține produse din mai multe referate și/sau loturi interne.
- Sunt unități oficiale de ofertare și atribuire.

-### Contract
- Reprezintă acordul juridic semnat cu furnizorul pentru furnizarea produselor atribuite.
- Este rezultatul atribuirii unuia sau mai multor loturi dintr-o procedură.
- Tipuri:
  - `contract_ferm`: pentru achiziție imediată (generează automat comenzi)
  - `acord_cadru`: pentru livrări succesive (necesită comenzi subsecvente)
- Conține:
  - `furnizor`
  - `tip_contract`
  - `numar_contract` (opțional)
  - `data_contract` (opțional)
  - `document_link` (link către fișier pdf, doc etc.)
  - `valabil_de_la` / `valabil_pana`
  - `status` (ex: `activ`, `expirat`, `reziliat`)
  - `tip_procedura`: `achizitie_directa`, `negociere_SEAP`, `licitatie_deschisa`
- Pentru gestionarea tranzițiilor de status (`activ`, `expirat`, `reziliat`) se va aplica același principiu FSM, cu reguli implementate în `ContractService`.
- Se poate referi la mai multe `LotProcedura` atribuite aceluiași furnizor.
- Fiecare legătură contract-lot permite calculul valorii pe lot.
- Număr și dată de înregistrare sunt comune cu celelalte documente și pot lipsi temporar.
- Contractele pot avea atașamente multiple salvate în entitatea `Document`, inclusiv fișiere scanate (PDF, DOCX).

### ComandaSubsecventa
- Contract subsecvent emis în baza unui `Contract` de tip `acord_cadru`.
- Reprezintă comanda efectivă de produse, conform unui calendar sau necesar punctual.
- Conține:
  - `contract_id`: referință la contractul de tip acord-cadru
  - `data_emitere`
  - `numar_comanda` (opțional)
  - `document_link` (pdf, doc, etc)
  - `status`: `emisa`, `livrata_partial`, `livrata_complet`, `anulata`
  - `observatii` (opțional)
- Fiecare comandă subsecventă conține una sau mai multe linii de comandă (`ComandaSubsecventaItem`):
  - produs comercial
  - cantitate
  - preț unitar
  - valoare totală
- Poate fi urmată de una sau mai multe livrări (`Livrare`) până la completarea cantităților comandate.
- Validări:
  - `Contract.tip_contract` trebuie să fie `acord_cadru`
  - `Contract.status` trebuie să fie `activ`
- Permite trasabilitate completă: `ComandaSubsecventa` → `Contract` → `LotProcedura` → `Oferta` → `ProdusGeneric`

### Comanda

- Instanță de comandă de produse, fie ca urmare a unui contract ferm, fie ca subsecventă în cadrul unui acord-cadru.
- Implementată unitar prin `ComandaSubsecventa`.
- Comenzile ferme sunt generate automat la semnarea unui `Contract` de tip `contract_ferm`.
- Comenzile subsecvente sunt create manual pentru `acord_cadru`.
- Fiecare comandă este asociată unui `Contract` și conține produse comerciale, cantități, prețuri și un document justificativ (link sau fișier).

### Livrare
- Confirmare a onorării unei comenzi (fermă sau subsecventă).
- O livrare poate fi completă sau parțială:
  - poate include doar o parte din produsele comandate
  - sau cantități mai mici decât cele comandate
- Fiecare livrare este asociată unei comenzi (`comanda_id`)
- Poate include unul sau mai multe produse (`LivrareItem[]`), fiecare cu:
  - `produs_comercial_id`, `cantitate_livrata`
  - opțional: `pret_unitar`, `data_expirare`, `lot_fabricatie`
  - opțional: `comanda_item_id` – referință la linia de comandă corespunzătoare, pentru trasabilitate completă.
- Poate avea atașamente (`LivrareDocument[]`) de tip:
  - `factura`, `aviz`, `altul`, cu nume și link
- Se pot vizualiza/filtra livrările:
  - pentru un contract, furnizor, produs, perioadă
- Integrare cu aplicația de gestiune stocuri:
  - livrările valide pot fi trimise automat sub formă de webhook
  - sau expuse prin API (`GET /livrari`) pentru sincronizare externă
- Se verifică dacă întreaga comandă a fost onorată
- Validări:
  - o livrare nu poate depăși cantitățile rămase neonorate din comandă
  - o comandă este considerată complet livrată dacă toate produsele comandate au fost livrate integral


### Document
- Poate fi atașat la orice entitate.
- Tipuri: PDF, Word, Excel, GDocs.
  Pot fi fișiere urcate direct în aplicație (upload local) sau linkuri către surse externe (ex: Google Drive). Sistemul va permite descărcarea și previzualizarea acestor fișiere, cu organizare pe entități.
- Origine: generare automată, upload, link extern.
- Pentru ofertele încărcate, se recomandă fie upload direct, fie integrare cu Google Drive.
- Fișierele pot fi stocate local (upload direct în aplicație, compatibil S3) sau atașate ca linkuri externe.
- Setarea de stocare se poate configura global în aplicație.
- Structura recomandată pentru GDrive: `/Aqz/Ofertare/[nume_furnizor]/[data_oferta].pdf`
- Documentele asociate cu `Oferta` vor fi evidențiate în interfață și disponibile pentru descărcare/verificare.
- Pentru suportul de atașamente multiple, fiecare entitate care acceptă atașamente va avea o entitate dedicată de tip `[Entitate]Document` (ex: `OfertaDocument`, `ContractDocument`, `LivrareDocument`), cu nume, tip și link.
- Aceasta permite asocierea mai multor fișiere (PDF, Excel etc.) cu o ofertă.
- Documentele pot fi asociate și cu livrări (`LivrareDocument`), comenzi (`ComandaDocument`), contracte (`ContractDocument`), și referate (`ReferatDocument`), pe lângă oferte.

Pentru a asigura o gestiune unitară a documentelor în aplicație, logica de încărcare (upload local/S3 sau atașare prin link extern), asociere cu alte entități și generare de linkuri securizate va fi implementată într-un serviciu dedicat `DocumentService`. Acest serviciu centralizat evită duplicarea codului și permite aplicarea unor politici uniforme de validare, denumire fișiere, permisiuni și generare de URL-uri securizate.

### Înregistrare documente
- Toate entitățile de tip document (`Referat`, `Oferta`, `Contract`, `Comanda`, etc.) au câmpuri:
  - `numar_inregistrare` (nullable)
  - `data_inregistrare` (nullable)
- Acestea pot fi completate ulterior, după trimiterea la registratură.

### FurnizorProdusComercial
- Reprezintă o instanță contextuală a unui produs comercial oferit de un anumit furnizor.
- Include codul de catalog al furnizorului, eventualele variații de ambalaj și termenul de livrare tipic.

### Import produse generice din fișiere JSON

Pentru a facilita introducerea rapidă a produselor generice în sistem, aplicația suportă importul acestora din fișiere JSON. Acest mecanism este util pentru preluarea datelor existente din surse istorice (ex: Google Docs).

#### Format JSON acceptat

```json
[
  {
    "categorie": "PCR tumori",
    "unitate_masura": "kit",
    "nume_generic": "Kit pentru analiza variantelor EGFR în țesut tumoral",
    "specificatii_tehnice": "...",
    "ambalare": "kit 52 reacții"  // opțional
  }
]
```

#### Reguli și validări la import

- Câmpurile lipsă (ex: ambalare) pot fi completate ulterior manual; acestea sunt evidențiate discret în interfață.
- Dacă o `categorie` nu există în sistem, utilizatorul este întrebat dacă dorește să o adauge — evitând dubluri sau greșeli de redactare.
- Dacă `unitate_masura` nu există, utilizatorul poate alege între:
  - adăugarea acesteia în sistem, sau
  - omiterea produsului respectiv din import.
- Produsele deja existente în sistem (după `nume_generic` + `categorie`) nu sunt importate automat — utilizatorul este informat și decide asupra acțiunii.
- Pentru fiecare produs importat cu succes, sistemul generează automat un cod unic (`cod`) pe baza categoriei (ex: `PT001` pentru „PCR tumori”).

### (Extensibil) Import produse comerciale

- Aplicația poate fi extinsă pentru a importa și produse comerciale din fișiere JSON structurate.
- Importul ar trebui să conțină:
  - `nume_comercial`, `producator`, `cod_catalog`, `ambalare`, `um_comerciala`, `valoare_ambalaj`, `um_referinta`
- Opțional se poate asocia automat cu produse generice existente (pe baza codificării sau descrierii).

#### Interfață utilizator

- Formular pentru încărcarea fișierului JSON
- Afișare tabelară a rezultatului importului:
  - ✅ Produse importate
  - ⚠️ Produse respinse (cu motiv)
  - ✏️ Posibilitate de completare manuală a câmpurilor lipsă
- Confirmare explicită pentru adăugarea de categorii sau unități de măsură noi

---

## 🔄 Fluxuri principale

### 1. Inițiere referat
- Redactare `Referat` cu produse (`CerereProdusGeneric`)
- Aprobare formală
- Devine eligibil pentru proceduri

### 2. Ofertare
- Se definesc `LotProcedura` din unul sau mai multe referate
- Se primesc `Oferte` (cu produse comerciale și prețuri)
- Se selectează oferta câștigătoare pentru fiecare lot

### 3. Contractare
- Fiecare lot atribuit generează un `Contract`
- Dacă este contract ferm → se generează automat o `Comanda`
- Dacă este acord-cadru → comenzile se emit ulterior

### 4. Comenzi
- `Comanda` conține produse comerciale
- Se trimite furnizorului
- Poate fi livrată parțial sau integral

### 5. Livrare
- Furnizorul trimite aviz și factură
- Se înregistrează livrarea
- Se verifică dacă întreaga comandă a fost onorată
- Validări:
  - o livrare nu poate depăși cantitățile rămase neonorate din comandă
  - o comandă este considerată complet livrată dacă toate produsele comandate au fost livrate integral

### 6. Integrare stocuri (modul viitor)
- După livrare, se creează automat o `IntrareStoc`

---

## 📤 Documente generate

| Document              | Format    | Legat de         | Generare         |
|-----------------------|-----------|------------------|------------------|
| Referat necesitate    | PDF, GDocs| Referat          | Jinja2, Docs API |
| Centralizator ofertă  | PDF       | Procedură        | WeasyPrint       |
| Contract achiziție    | DOCX, PDF | Contract         | python-docx      |
| Comandă furnizor      | PDF       | Comanda          | Jinja2, PDF      |
| Recepție livrare      | PDF       | Livrare          | Jinja2, CSV      |

---

## 🧪 Validări importante

- Referatul nu poate fi trimis fără produse.
- Ofertele trebuie să corespundă produselor din loturi.
- Comenzile nu pot depăși cantitățile contractate.
- Livrările nu pot depăși cantitatea comandată.
- Nu se poate modifica un referat aprobat.
- Nu se acceptă oferte pentru proceduri finalizate.
- În contextul unei proceduri, o ofertă trebuie să acopere integral cel puțin un `LotProcedura`.
- Ofertele fără asociere la referat sau procedură sunt permise, dar marcate ca "informale".
- O ofertă de procedură trebuie să acopere complet cel puțin un `LotProcedura` (`este_completa` = true).
- Nu este permisă marcarea manuală a unei oferte ca "câștigătoare" fără completitudinea pe lot.
- Tranzițiile de stare pentru entități precum `Oferta`, `Contract`, `Referat` vor fi validate folosind FSM (Finite State Machine). Acest mecanism clarifică ce stări sunt permise și ce acțiuni le pot declanșa. De exemplu, o ofertă nu poate fi marcată „câștigătoare” dacă nu a fost mai întâi „selectată” și completă pe lot.

---

## 🔐 Autentificare și audit

- Rol unic cu acces complet.
- Autentificare JWT via FastAPI Users.
- Jurnalizare opțională a acțiunilor (`AuditLog`):
  - modificări asupra referatelor, ofertelor, contractelor
  - selecții de oferte, ștergeri, adăugiri, actualizări de status
  - emitere comenzi, înregistrare livrări
  - autentificare utilizator, modificări de fișiere/documente
  - Fiecare acțiune jurnalizată include: utilizatorul, tipul acțiunii, entitatea afectată, ID-ul acesteia, data/ora și opțional detalii text.

### 🧾 Jurnalizare a tranzițiilor de status

Pentru a asigura trasabilitatea completă a ciclului de viață al documentelor (referate, oferte, proceduri, contracte etc.), se introduce o entitate suplimentară dedicată:

StatusLog
• Înregistrează exclusiv tranzițiile de status ale entităților relevante.
• Complementară față de AuditLog, care înregistrează toate tipurile de acțiuni.
• Câmpuri:
• entitate: numele entității afectate (ex: Oferta, Contract, Referat)
• entitate_id: identificatorul instanței respective
• status_vechi: valoarea statusului anterior (ex: in analiza)
• status_nou: valoarea statusului nou (ex: castigatoare)
• utilizator_id: cine a inițiat tranziția
• data_ora: momentul exact al tranziției

Beneficii:
• Permite auditarea clară a momentelor și utilizatorilor implicați în modificarea statusurilor.
• Suport pentru generare de rapoarte (ex: durata medie între in analiza și castigatoare)
• Util în contextul respectării legislației privind trasabilitatea deciziilor în achiziții publice.

În OfertaService, ContractService etc., la fiecare modificare de status validă prin FSM, se va crea automat un StatusLog corespunzător.

---

## 🔄 Note finale

- Documentul trebuie menținut sincronizat cu:
  - `erd.mmd` – când apar modificări în modele
  - `activitate.mmd` – când se schimbă fluxurile
  - `TODO.md` – când se redefinește strategia
- Acest fișier conține toate detaliile logice necesare pentru a relua dezvoltarea aplicației în caz de pierdere de context. Sincronizarea sa cu restul documentației este esențială.
### AuditLog
- Înregistrează acțiunile utilizatorilor asupra entităților aplicației.
- Câmpuri:
  - `utilizator_id`
  - `actiune` (ex: `modificare_referat`, `adaugare_oferta`, `actualizare_status`)
  - `entitate` (ex: `Referat`, `Oferta`)
  - `entitate_id`
  - `data_ora`
  - `detalii` (opțional)

- Este utilizat pentru trasabilitate, debugging și eventual audit extern.

---

## 🧭 Principii arhitecturale (Design Guidelines)

- **Separarea logicii de business de modelele de date:**
  - Modelele ORM (SQLAlchemy) și cele Pydantic (schema de input/output) vor fi păstrate **cât mai simple**, fără logică de validare complexă sau tranziții de status în ele.
  - Toată logica de validare, modificare a statusurilor, generare de documente, reguli de tranzacție etc. va fi implementată în **servicii dedicate**, cum ar fi:
    - `OfertaService`
    - `ContractService`
    - `ReferatService`
    - `LivrareService`
    - etc.

- **Responsabilități clar definite:**
  - Serviciile de tip `Service` vor expune metode cu semnătură clară (ex: `selecteaza_oferta`, `genereaza_contract`, `inregistreaza_livrare`)
  - Acestea vor funcționa ca o interfață logică între controller (FastAPI route handler) și stratul de date (repository / ORM).
  - Codul din `routes/` va fi redus la apeluri către aceste servicii și returnarea răspunsurilor către client (UI/API).

- **Validările importante (business logic) vor fi centralizate:**
  - Exemplu: regula conform căreia o ofertă nu poate fi marcată drept „câștigătoare” dacă nu este completă pe lot (`este_completa == False`) va fi implementată **strict în `OfertaService`**, niciodată în controller sau direct în ORM.
  - - Pentru entitățile cu stări multiple și tranziții bine definite, se va implementa un **sistem FSM simplificat**, bazat pe un dicționar central cu stările posibile și tranzițiile permise. Acesta va fi utilizat exclusiv în serviciile logice (`OfertaService`, `ContractService`, etc.), nu în modelele ORM sau în rutele FastAPI.

- **Documentele generate vor fi declanșate doar din servicii**, nu din view-uri, nu automat la schimbarea statusului unui model.
