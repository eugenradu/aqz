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
- Include produse generice grupate în loturi (`LotReferat`).
- Stări: `draft`, `trimis`, `aprobat`, `respins`, `anulat`.

### ProdusGeneric
- Produs cu specificații tehnice, fără denumire comercială.
- Clasificat pe categorii (ex: reactivi, consumabile).
  
### ProdusComercial
- Variantă concretă a unui produs generic: include denumire, cod, producător, ambalaj.
- Poate acoperi mai multe produse generice.

### Furnizor
- Entitate juridică care oferă produse comerciale.

### Oferta
- Răspuns la un referat (informal) sau o procedură (oficial).
- Include produse comerciale și costuri (`OfertaItem`).
- Se leagă de un lot.

### ProceduraAchizitie
- Grup de loturi definite pentru achiziție.
- Poate agrega produse din mai multe referate.
- Tipuri: `directă`, `cerere ofertă`, `licitație`.
- Stări: `în pregătire`, `publicată`, `atribuită`, `finalizată`.

### LotProcedura
- Unități de atribuire.
- Atribuite unui ofertant câștigător.
- Pot conține produse din mai multe referate.

### Contract
- Leagă un ofertant de o procedură atribuită.
- Tipuri: `contract ferm`, `acord-cadru`.

### Comanda
- Fermă sau subsecventă.
- Conține produse comerciale și cantități.
- Poate fi livrată în una sau mai multe tranșe.

### Livrare
- Confirmare a onorării comenzii.
- Include cantități, factură, aviz.

### Document
- Poate fi atașat la orice entitate.
- Tipuri: PDF, Word, Excel, GDocs.
- Origine: generare automată, upload, link extern.

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

---

## 🔐 Autentificare și audit

- Rol unic cu acces complet.
- Autentificare JWT via FastAPI Users.
- Jurnalizare opțională a acțiunilor (`AuditLog`).

---

## 🔄 Note finale

- Documentul trebuie menținut sincronizat cu:
  - `erd.mmd` – când apar modificări în modele
  - `activitate.mmd` – când se schimbă fluxurile
  - `TODO.md` – când se redefinește strategia