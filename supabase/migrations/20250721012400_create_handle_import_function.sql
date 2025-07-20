-- Această funcție gestionează întregul proces de import de produse dintr-un JSON.
-- Este tranzacțională și sigură, prevenind duplicatele.

CREATE OR REPLACE FUNCTION public.handle_product_import(
    products_json jsonb
)
RETURNS TABLE(status_code int, response_body jsonb)
LANGUAGE plpgsql
AS $$
DECLARE
    prod jsonb;
    categorie_nume TEXT;
    categorie_id_val BIGINT;
    new_code TEXT;
    new_categories TEXT[];
    existing_categories TEXT[];
BEGIN
    -- Pasul 1: Identifică categoriile din JSON
    SELECT array_agg(DISTINCT value->>'Categorie')
    INTO new_categories
    FROM jsonb_array_elements(products_json);

    -- Pasul 2: Verifică ce categorii există deja
    SELECT array_agg(nume)
    INTO existing_categories
    FROM public.categorii;

    -- Elimină categoriile care există deja din lista de categorii noi
    new_categories := ARRAY(
        SELECT unnest(new_categories)
        EXCEPT
        SELECT unnest(existing_categories)
    );

    -- Pasul 3: Dacă există categorii noi, oprește-te și returnează-le
    IF array_length(new_categories, 1) > 0 THEN
        RETURN QUERY SELECT 400, jsonb_build_object('error', 'new_category_found', 'new_categories', new_categories);
        RETURN;
    END IF;

    -- Pasul 4: Dacă toate categoriile sunt valide, procesează și inserează produsele
    FOR prod IN SELECT * FROM jsonb_array_elements(products_json)
    LOOP
        -- Găsește ID-ul categoriei
        categorie_nume := COALESCE(prod->>'Categorie', 'Fără categorie');
        SELECT id INTO categorie_id_val FROM public.categorii WHERE nume = categorie_nume;

        -- Generează un cod unic
        SELECT public.generate_product_code(categorie_id_val) INTO new_code;

        -- Inserează noul produs
        INSERT INTO public.produsgeneric (cod, nume_generic, specificatii_tehnice, um, categorie_id)
        VALUES (
            new_code,
            prod->>'Nume_Generic',
            prod->>'Specificatii_Tehnice',
            prod->>'Unitate_Masura',
            categorie_id_val
        );
    END LOOP;

    -- Pasul 5: Returnează un mesaj de succes
    RETURN QUERY SELECT 200, jsonb_build_object('message', 'Import realizat cu succes! Au fost importate ' || jsonb_array_length(products_json) || ' produse.');
    RETURN;

END;
$$;
