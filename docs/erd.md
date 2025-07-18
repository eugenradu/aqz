# Diagrama ERD


```mermaid
erDiagram

  REFERAT ||--o{ CERERE_PRODUS_GENERIC : contine
  REFERAT ||--o{ LOT_REFERAT : grupeaza
  LOT_REFERAT ||--o{ CERERE_PRODUS_GENERIC : contine
  LOT_REFERAT }o--|| REFERAT : parte_din

  CERERE_PRODUS_GENERIC }o--|| PRODUS_GENERIC : specifica
  PRODUS_GENERIC }o--o{ PRODUS_COMERCIAL : este_acoperit_de

  REFERAT }o--|| UTILIZATOR : creat_de
  REFERAT ||--o{ DOCUMENT : atasament

  OFERTA ||--o{ OFERTA_ITEM : contine
  OFERTA_ITEM }o--|| PRODUS_COMERCIAL : propune
  OFERTA_ITEM }o--|| LOT_OFERTA : pentru_lot
  LOT_OFERTA }o--|| OFERTA : parte_din

  OFERTA ||--o{ OFERTA_DOCUMENT : are_documente

  OFERTA }o--|| FURNIZOR : transmisa_de

  PROCEDURA ||--o{ LOT_PROCEDURA : compusa_din
  LOT_PROCEDURA }o--o{ CERERE_PRODUS_GENERIC : include
  LOT_PROCEDURA }o--|| OFERTA : atribuita_la

  CONTRACT }o--|| FURNIZOR : semnat_cu
  CONTRACT }o--|| PROCEDURA : rezultat_din
  CONTRACT ||--o{ COMANDA : include
  CONTRACT ||--o{ DOCUMENT : are_documente

  COMANDA ||--o{ COMANDA_PRODUS : contine
  COMANDA_PRODUS }o--|| PRODUS_COMERCIAL : comanda_pentru

  LIVRARE ||--o{ LIVRARE_ITEM : contine
  LIVRARE_ITEM }o--|| COMANDA_PRODUS : raspunde_la
  LIVRARE }o--|| COMANDA : parte_din

  UTILIZATOR {
    string id PK
    string nume
    string email
  }

  REFERAT {
    string id PK
    string titlu
    string status
    datetime data_creare
    datetime data_aprobare
  }

  CERERE_PRODUS_GENERIC {
    string id PK
    float cant_minima
    float cant_maxima
  }

  PRODUS_GENERIC {
    string id PK
    string cod
    string nume
    string specificatii
    string categorie
    string um
  }
  IMPORT_PRODUS_GENERIC {
    string id PK
    string sursa
    string cale_fisier
    datetime data_import
    int numar_produse
    string stare
  }

  PRODUS_COMERCIAL {
    string id PK
    string nume
    string cod_catalog
    string producator
    string um_comerciala
    float valoare_ambalaj
    string um_referinta
    float factor_conversie
    string descriere
  }

  FURNIZOR {
    string id PK
    string denumire
    string cif
    string email
  }

  OFERTA {
    string id PK
    datetime data_inregistrare
    string tip
    string link_document
    string moneda
    date valabil_pana
    string status
    datetime data_transmitere
    string motiv_selectare
  }

  OFERTA_ITEM {
    string id PK
    float pret_unitar
    float cantitate
  }

  LOT_OFERTA {
    bool este_completa
  }

  PROCEDURA {
    string id PK
    string tip
    string status
    datetime data_publicare
  }

  LOT_PROCEDURA {
    string id PK
    string denumire
    string descriere
  }

  LOT_REFERAT {
    string id PK
    string nume
    string descriere
  }

  CONTRACT {
    string id PK
    string tip
    datetime data_semnare
    date data_expirare
    string numar_contract
    string tip_procedura
    string status
    string document_link
    date valabil_de_la
    date valabil_pana
  }
  CONTRACT_LOT {
    string id PK
    string contract_id FK
    string lot_procedura_id FK
    float valoare
  }

  COMANDA {
    string id PK
    datetime data_emiterii
    string status
  }

  COMANDA_PRODUS {
    string id PK
    float cantitate
  }

  LIVRARE {
    string comanda_id FK
    string observatii
    datetime data_livrare
  }

LIVRARE_DOCUMENT {
  string id PK
  string livrare_id FK
  string tip
  string nume
  string link
}

LIVRARE_ITEM {
  string id PK
  string livrare_id FK
  string produs_comercial_id FK
  float cantitate_livrata
  float pret_unitar
  date data_expirare
  string lot_fabricatie
  string observatii
}

  DOCUMENT {
    string id PK
    string tip
    string cale_fisier
    datetime data_upload
  }

  ECHIVALENTA_PRODUS_GENERIC {
    string id PK
    string produs_generic_id FK
    string produs_comercial_id FK
    string justificare
  }

  FURNIZOR_PRODUS_COMERCIAL {
    string id PK
    string produs_comercial_id FK
    string furnizor_id FK
    string cod_catalog_furnizor
    int termen_livrare_zile
  }

  OFERTA_DOCUMENT {
    string id PK
    string oferta_id FK
    string nume
    string tip
    string link_document
  }

  ECHIVALENTA_PRODUS_GENERIC }o--|| PRODUS_COMERCIAL : echivalat_cu
  ECHIVALENTA_PRODUS_GENERIC }o--|| PRODUS_GENERIC : echivaleaza

  FURNIZOR_PRODUS_COMERCIAL }o--|| PRODUS_COMERCIAL : instanta
  FURNIZOR_PRODUS_COMERCIAL }o--|| FURNIZOR : oferit_de
  IMPORT_PRODUS_GENERIC ||--o{ PRODUS_GENERIC : contine
  OFERTA }o--|| REFERAT : optional_pentru
  OFERTA }o--|| PROCEDURA : optional_pentru
  CONTRACT ||--o{ CONTRACT_LOT : acopera
CONTRACT_LOT }o--|| LOT_PROCEDURA : parte_din

  COMANDA_SUBSECVENTA {
    string id PK
    string contract_id FK
    date data_emitere
    string numar_comanda
    string document_link
    string status
    string observatii
  }

  COMANDA_SUBSECVENTA_ITEM {
    string id PK
    string comanda_subsecventa_id FK
    string produs_comercial_id FK
    float cantitate
    float pret_unitar
  }

  COMANDA_SUBSECVENTA }o--|| CONTRACT : apartine
  COMANDA_SUBSECVENTA ||--o{ COMANDA_SUBSECVENTA_ITEM : contine
  COMANDA_SUBSECVENTA_ITEM }o--|| PRODUS_COMERCIAL : pentru_produs

LIVRARE ||--o{ LIVRARE_DOCUMENT : atasamente
LIVRARE ||--o{ LIVRARE_ITEM : contine
LIVRARE_ITEM }o--|| PRODUS_COMERCIAL : produs_livrat

AUDIT_LOG {
  string id PK
  string utilizator_id FK
  string actiune
  string entitate
  string entitate_id
  datetime data_ora
  string detalii
}

AUDIT_LOG }o--|| UTILIZATOR : generat_de
```
