import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    // Creăm un client admin pentru a avea permisiunile necesare
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Extragem fișierul din cerere
    const formData = await req.formData();
    const file = formData.get("file") as File | null;

    if (!file) {
      throw new Error("Fișierul nu a fost găsit în cerere.");
    }

    const content = await file.text();
    const productsJson = JSON.parse(content);

    console.log(
      "--- Funcția Edge a primit JSON-ul. Se pasează către funcția SQL handle_product_import... ---",
    );

    // Apelăm noua funcție SQL care conține toată logica
    const { data, error } = await supabaseAdmin.rpc("handle_product_import", {
      products_json: productsJson,
    });

    if (error) {
      throw error;
    }

    // Funcția SQL returnează un singur rând cu status_code și response_body
    const result = data[0];

    console.log("--- Răspuns primit de la funcția SQL:", result, "---");

    // Returnăm direct răspunsul primit de la funcția SQL
    return new Response(
      JSON.stringify(result.response_body),
      {
        status: result.status_code,
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("!!! EROARE FATALĂ ÎN FUNCȚIA EDGE:", error);
    return new Response(
      JSON.stringify({ message: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
