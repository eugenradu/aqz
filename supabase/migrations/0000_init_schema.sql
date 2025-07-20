-- #################################################################
-- ### PASUL 1: CONFIGURAREA PROFILURILOR DE UTILIZATOR (MODEL SUPABASE) ###
-- #################################################################

-- Crearea tabelei 'profiles' pentru a stoca date publice despre utilizatori.
CREATE TABLE public.profiles (
  id UUID NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nume_complet TEXT,
  rol TEXT DEFAULT 'achizitor'
);

-- Activează Row Level Security pentru tabela 'profiles'.
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Politică RLS: Permite utilizatorilor să-și vadă propriul profil.
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles
  FOR SELECT USING (true);

-- Politică RLS: Permite utilizatorilor să-și actualizeze propriul profil.
CREATE POLICY "Users can insert their own profile." ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile." ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Funcție trigger care se execută la crearea unui nou utilizator în 'auth.users'.
-- Aceasta va crea automat o intrare corespunzătoare în tabela 'profiles'.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nume_complet)
  VALUES (new.id, new.raw_user_meta_data->>'full_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crearea trigger-ului care apelează funcția de mai sus.
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- #################################################################
-- ### PASUL 2: CREAREA TABELELOR DE BUSINESS CONFORM ERD ###
-- #################################################################

-- Entități de bază: Produse și Furnizori
CREATE TABLE public.ProdusGeneric (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cod TEXT UNIQUE NOT NULL,
    nume_generic TEXT NOT NULL,
    specificatii_tehnice TEXT,
    categorie TEXT,
    um TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.ProdusComercial (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nume_comercial TEXT NOT NULL,
    producator TEXT,
    cod_catalog TEXT,
    um_comerciala TEXT,
    factor_conversie NUMERIC,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.EchivalentaProdusGeneric (
    produs_generic_id UUID NOT NULL REFERENCES public.ProdusGeneric(id) ON DELETE CASCADE,
    produs_comercial_id UUID NOT NULL REFERENCES public.ProdusComercial(id) ON DELETE CASCADE,
    justificare TEXT,
    PRIMARY KEY (produs_generic_id, produs_comercial_id)
);

CREATE TABLE public.Furnizor (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    denumire TEXT NOT NULL,
    cif TEXT UNIQUE,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Fluxul de Referate
CREATE TABLE public.Referat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    titlu TEXT NOT NULL,
    status TEXT DEFAULT 'draft',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.LotReferat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referat_id UUID NOT NULL REFERENCES public.Referat(id) ON DELETE CASCADE,
    nume TEXT,
    descriere TEXT
);

CREATE TABLE public.CerereProdusGeneric (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    produs_generic_id UUID NOT NULL REFERENCES public.ProdusGeneric(id) ON DELETE RESTRICT,
    referat_id UUID NOT NULL REFERENCES public.Referat(id) ON DELETE CASCADE,
    lot_referat_id UUID REFERENCES public.LotReferat(id) ON DELETE SET NULL,
    cantitate NUMERIC NOT NULL
);

-- Fluxul de Proceduri și Ofertare
CREATE TABLE public.Procedura (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tip TEXT,
    status TEXT DEFAULT 'în pregătire',
    data_publicare TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.LotProcedura (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    procedura_id UUID NOT NULL REFERENCES public.Procedura(id) ON DELETE CASCADE,
    denumire TEXT NOT NULL
);

-- Tabela de joncțiune pentru a lega produsele de loturile de procedură
CREATE TABLE public.LotProcedura_CerereProdusGeneric (
    lot_procedura_id UUID NOT NULL REFERENCES public.LotProcedura(id) ON DELETE CASCADE,
    cerere_produs_generic_id UUID NOT NULL REFERENCES public.CerereProdusGeneric(id) ON DELETE CASCADE,
    PRIMARY KEY (lot_procedura_id, cerere_produs_generic_id)
);

CREATE TABLE public.Oferta (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    procedura_id UUID NOT NULL REFERENCES public.Procedura(id) ON DELETE CASCADE,
    furnizor_id UUID NOT NULL REFERENCES public.Furnizor(id) ON DELETE RESTRICT,
    status TEXT DEFAULT 'inregistrata',
    moneda TEXT DEFAULT 'RON',
    valabil_pana DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.OfertaItem (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    oferta_id UUID NOT NULL REFERENCES public.Oferta(id) ON DELETE CASCADE,
    produs_comercial_id UUID NOT NULL REFERENCES public.ProdusComercial(id) ON DELETE RESTRICT,
    lot_procedura_id UUID NOT NULL REFERENCES public.LotProcedura(id) ON DELETE CASCADE,
    cantitate NUMERIC NOT NULL,
    pret_unitar NUMERIC NOT NULL
);

-- Fluxul de Contractare, Comenzi și Livrări
CREATE TABLE public.Contract (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    procedura_id UUID NOT NULL REFERENCES public.Procedura(id) ON DELETE RESTRICT,
    furnizor_id UUID NOT NULL REFERENCES public.Furnizor(id) ON DELETE RESTRICT,
    tip TEXT NOT NULL, -- 'ferm' sau 'acord-cadru'
    numar_contract TEXT,
    data_semnare DATE,
    status TEXT DEFAULT 'activ',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.ContractLot (
    contract_id UUID NOT NULL REFERENCES public.Contract(id) ON DELETE CASCADE,
    lot_procedura_id UUID NOT NULL REFERENCES public.LotProcedura(id) ON DELETE RESTRICT,
    valoare NUMERIC,
    PRIMARY KEY (contract_id, lot_procedura_id)
);

CREATE TABLE public.Comanda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES public.Contract(id) ON DELETE RESTRICT,
    numar_comanda TEXT,
    data_emitere DATE,
    status TEXT DEFAULT 'emisa',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.ComandaItem (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comanda_id UUID NOT NULL REFERENCES public.Comanda(id) ON DELETE CASCADE,
    produs_comercial_id UUID NOT NULL REFERENCES public.ProdusComercial(id) ON DELETE RESTRICT,
    cantitate NUMERIC NOT NULL,
    pret_unitar NUMERIC NOT NULL
);

CREATE TABLE public.Livrare (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comanda_id UUID NOT NULL REFERENCES public.Comanda(id) ON DELETE RESTRICT,
    data_livrare DATE NOT NULL,
    observatii TEXT,
    created_at TIMESTAMptz DEFAULT now()
);

CREATE TABLE public.LivrareItem (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    livrare_id UUID NOT NULL REFERENCES public.Livrare(id) ON DELETE CASCADE,
    comanda_item_id UUID NOT NULL REFERENCES public.ComandaItem(id) ON DELETE RESTRICT,
    cantitate_livrata NUMERIC NOT NULL,
    data_expirare DATE,
    lot_fabricatie TEXT
);

-- Entități de sistem: Documente și Audit
CREATE TABLE public.Documente (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id UUID NOT NULL,
    entity_type TEXT NOT NULL, -- 'Referat', 'Oferta', 'Contract', 'Livrare'
    nume_fisier TEXT NOT NULL,
    cale_storage TEXT NOT NULL,
    tip_mime TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.AuditLog (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    actiune TEXT NOT NULL,
    entitate TEXT,
    entitate_id UUID,
    detalii JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- #################################################################
-- ### PASUL 3: ACTIVAREA ROW LEVEL SECURITY PENTRU TABELELE DE BUSINESS ###
-- #################################################################

-- Exemplu: Activează RLS pentru tabelele principale.
-- Politicile specifice vor fi adăugate în migrații viitoare.
ALTER TABLE public.ProdusGeneric ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ProdusComercial ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Furnizor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Referat ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Procedura ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Oferta ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Contract ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Comanda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Livrare ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Documente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.AuditLog ENABLE ROW LEVEL SECURITY;

-- Politică de bază: Permite accesul la date doar utilizatorilor autentificați.
-- Aceasta este o măsură de siguranță; politici mai granulare vor suprascrie acest comportament.
CREATE POLICY "Allow authenticated read access" ON public.ProdusGeneric FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read access" ON public.Furnizor FOR SELECT TO authenticated USING (true);

-- Politică specifică: Utilizatorii își pot vedea propriile referate.
CREATE POLICY "Users can see their own referate." ON public.Referat
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create referate." ON public.Referat
  FOR INSERT WITH CHECK (auth.uid() = user_id);

