-- Inserare Categorii
INSERT INTO public.Categorii (nume, prefix) VALUES
('Biologie Moleculara', 'BMOL'),
('Consumabile', 'CONS'),
('Fără categorie', 'NOCAT');

-- Inserare Furnizori
INSERT INTO public.Furnizor (denumire, cif, email) VALUES
('Reactivi SRL', 'RO12345678', 'contact@reactivi.ro'),
('Lab Consumabile SA', 'RO87654321', 'vanzari@labconsumabile.ro');

-- Inserare Produse Generice (fără cod, deoarece va fi generat)
-- Notă: În mod normal, inserarea s-ar face prin funcția de import,
-- dar pentru seed putem adăuga coduri manual pentru consistență.
INSERT INTO public.ProdusGeneric (cod, nume_generic, um, categorie_id) VALUES
('BMOL-001', 'Kit extracție ADN/ARN viral', 'extracție', (SELECT id FROM public.Categorii WHERE nume = 'Biologie Moleculara')),
('CONS-001', 'Vârfuri de pipetă cu filtru 100ul', 'bucată', (SELECT id FROM public.Categorii WHERE nume = 'Consumabile'));