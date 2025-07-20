-- #################################################################
-- ### Fișier seed.sql - Date Inițiale pentru Dezvoltare ###
-- #################################################################
-- Acest script populează tabelele de bază cu date demo pentru a facilita
-- dezvoltarea și testarea interfeței.

-- Inserare Furnizori
INSERT INTO public.Furnizor (denumire, cif, email) VALUES
('Reactivi SRL', 'RO12345678', 'contact@reactivi.ro'),
('Lab Consumabile SA', 'RO87654321', 'vanzari@labconsumabile.ro'),
('BioTech Solutions', 'RO11223344', 'office@biotech.ro');

-- Inserare Produse Generice
-- Folosim o clauză WITH pentru a captura ID-urile generate și a le folosi mai târziu
WITH pg_inserts AS (
    INSERT INTO public.ProdusGeneric (cod, nume_generic, specificatii_tehnice, categorie, um) VALUES
    ('PG-PCR-001', 'Kit extracție ADN/ARN viral', 'Extracție de pe tampoane nazofaringiene, bazată pe particule magnetice.', 'Biologie Moleculara', 'extracție'),
    ('PG-PCR-002', 'Master Mix pentru Real-Time PCR', 'Compatibil cu sonde tip TaqMan, low-ROX.', 'Biologie Moleculara', 'reacție'),
    ('PG-CONS-001', 'Vârfuri de pipetă cu filtru 100ul', 'Sterile, compatibile cu pipete Gilson/Eppendorf.', 'Consumabile', 'bucată'),
    ('PG-CONS-002', 'Plăci PCR 96 godeuri', 'Low-profile, albe, compatibile cu majoritatea termociclerelor.', 'Consumabile', 'bucată')
    RETURNING id, nume_generic
),
-- Inserare Produse Comerciale
pc_inserts AS (
    INSERT INTO public.ProdusComercial (nume_comercial, producator, cod_catalog, um_comerciala, factor_conversie) VALUES
    ('PurePath Viral DNA/RNA Kit', 'ThermoFisher', 'A42352', 'kit', 96),
    ('TaqPath 1-Step RT-qPCR Master Mix', 'ThermoFisher', 'A15300', 'flacon 1ml', 200),
    ('Filter Tips 100µL, Sterile, Box of 960', 'Eppendorf', '0030077518', 'cutie', 960),
    ('MicroAmp Optical 96-Well Reaction Plate', 'Applied Biosystems', 'N8010560', 'cutie 10 buc', 10)
    RETURNING id, nume_comercial
)
-- Inserare Echivalențe între Produse Generice și Comerciale
-- Aici legăm produsele create mai sus
INSERT INTO public.EchivalentaProdusGeneric (produs_generic_id, produs_comercial_id, justificare) VALUES
(
    (SELECT id FROM pg_inserts WHERE nume_generic = 'Kit extracție ADN/ARN viral'),
    (SELECT id FROM pc_inserts WHERE nume_comercial = 'PurePath Viral DNA/RNA Kit'),
    'Produs standard de industrie, validat intern.'
),
(
    (SELECT id FROM pg_inserts WHERE nume_generic = 'Master Mix pentru Real-Time PCR'),
    (SELECT id FROM pc_inserts WHERE nume_comercial = 'TaqPath 1-Step RT-qPCR Master Mix'),
    'Compatibil cu echipamentele existente.'
),
(
    (SELECT id FROM pg_inserts WHERE nume_generic = 'Vârfuri de pipetă cu filtru 100ul'),
    (SELECT id FROM pc_inserts WHERE nume_comercial = 'Filter Tips 100µL, Sterile, Box of 960'),
    'Echivalență directă.'
),
(
    (SELECT id FROM pg_inserts WHERE nume_generic = 'Plăci PCR 96 godeuri'),
    (SELECT id FROM pc_inserts WHERE nume_comercial = 'MicroAmp Optical 96-Well Reaction Plate'),
    'Echivalență directă.'
);

-- Poți adăuga aici și alte date demo, de exemplu pentru un utilizator de test,
-- dar acest lucru se face de obicei prin interfața de autentificare Supabase.

