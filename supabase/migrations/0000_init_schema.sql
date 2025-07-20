-- #################################################################
-- ### Fișier de Migrație Inițial și Consolidat pentru Proiectul aqz ###
-- #################################################################

-- PASUL 1: CONFIGURAREA PROFILURILOR DE UTILIZATOR
CREATE TABLE public.profiles (
  id UUID NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nume_complet TEXT,
  rol TEXT DEFAULT 'achizitor'
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nume_complet)
  VALUES (new.id, new.raw_user_meta_data->>'full_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- PASUL 2: CREAREA TABELELOR DE BUSINESS (ÎN ORDINEA DEPENDENȚELOR)
CREATE TABLE public.Categorii (
    id BIGSERIAL PRIMARY KEY,
    nume TEXT UNIQUE NOT NULL,
    prefix TEXT UNIQUE NOT NULL CHECK (char_length(prefix) >= 3 AND char_length(prefix) <= 5),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.ProdusGeneric (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cod TEXT UNIQUE NOT NULL,
    nume_generic TEXT NOT NULL,
    specificatii_tehnice TEXT,
    categorie_id BIGINT REFERENCES public.Categorii(id) ON DELETE SET NULL,
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

CREATE TABLE public.Referat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    titlu TEXT NOT NULL,
    status TEXT DEFAULT 'draft',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.CerereProdusGeneric (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    produs_generic_id UUID NOT NULL REFERENCES public.ProdusGeneric(id) ON DELETE RESTRICT,
    referat_id UUID NOT NULL REFERENCES public.Referat(id) ON DELETE CASCADE,
    cant_minima NUMERIC NOT NULL,
    cant_maxima NUMERIC NOT NULL
);

-- ... și restul tabelelor, dacă le-am fi definit. Le putem adăuga ulterior.

-- PASUL 3: CREAREA FUNCȚIILOR SQL (DUPĂ CE TABELELE EXISTĂ)
CREATE OR REPLACE FUNCTION public.get_all_categories()
RETURNS TABLE(categorie text)
LANGUAGE sql
STABLE
AS $$
  SELECT nume
  FROM public.categorii
  WHERE nume IS NOT NULL
  ORDER BY nume;
$$;

CREATE OR REPLACE FUNCTION public.generate_product_code(p_categorie_id BIGINT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_prefix TEXT;
    v_next_seq BIGINT;
BEGIN
    -- Obține prefixul pentru categoria dată
    SELECT prefix INTO v_prefix FROM public.categorii WHERE id = p_categorie_id;

    -- Calculează următoarea valoare secvențială
    SELECT COALESCE(MAX(SUBSTRING(cod FROM '[0-9]+$')::BIGINT), 0) + 1
    INTO v_next_seq
    FROM public.produsgeneric
    WHERE cod LIKE v_prefix || '-%';

    -- Returnează codul formatat
    RETURN v_prefix || '-' || LPAD(v_next_seq::TEXT, 3, '0');
END;
$$;

-- PASUL 4: ACTIVAREA RLS PENTRU TABELE
ALTER TABLE public.categorii ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produsgeneric ENABLE ROW LEVEL SECURITY;
-- ... și pentru restul tabelelor

-- PASUL 5: DEFINIREA POLITICILOR RLS
CREATE POLICY "Allow authenticated read access on categories" ON public.categorii FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read access on products" ON public.produsgeneric FOR SELECT TO authenticated USING (true);
-- ... și restul politicilor

-- Adaugă o politică de securitate (RLS policy) care permite utilizatorilor
-- autentificați să insereze rânduri noi în tabela 'categorii'.
CREATE POLICY "Allow authenticated users to insert categories"
ON public.categorii
FOR INSERT
TO authenticated
WITH CHECK (true);