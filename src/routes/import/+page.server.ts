import { type Actions, fail } from "@sveltejs/kit";
import { createServerClient } from "@supabase/ssr";
import { createClient } from "@supabase/supabase-js";
import {
    PUBLIC_SUPABASE_ANON_KEY,
    PUBLIC_SUPABASE_URL,
} from "$env/static/public";
import { SUPABASE_SERVICE_ROLE_KEY } from "$env/static/private";

export const actions: Actions = {
    /**
     * Acțiune redenumită: gestionează upload-ul inițial al fișierului.
     */
    importFile: async ({ request, cookies }) => {
        console.log("--- Acțiune de import (importFile) începută ---");
        const supabase = createServerClient(
            PUBLIC_SUPABASE_URL,
            PUBLIC_SUPABASE_ANON_KEY,
            { cookies },
        );

        const formData = await request.formData();
        const file = formData.get("file") as File | null;

        if (!file || file.size === 0) {
            return fail(400, {
                message: "Te rog selectează un fișier JSON valid.",
            });
        }

        if (file.type !== "application/json") {
            return fail(400, {
                message: "Fișierul trebuie să fie de tip JSON.",
            });
        }

        try {
            const { data, error } = await supabase.functions.invoke(
                "import-products",
                {
                    body: formData,
                },
            );

            if (error) {
                throw error;
            }

            return { success: true, message: data.message };
        } catch (error: any) {
            console.error(
                "Eroare prinsă în acțiunea SvelteKit:",
                error.message,
            );

            if (error.context && typeof error.context.json === "function") {
                try {
                    const errorJson = await error.context.json();
                    if (errorJson.error === "new_category_found") {
                        console.log(
                            "Detectat răspuns de categorie nouă. Se trimit datele la UI.",
                        );
                        return fail(400, {
                            error: "new_category_found",
                            new_categories: errorJson.new_categories,
                        });
                    }
                } catch (e) {
                    // Ignorăm erorile de parsare JSON și trecem la eroarea generică
                }
            }

            return fail(500, {
                message:
                    "A apărut o eroare pe server la procesarea fișierului.",
            });
        }
    },

    /**
     * Acțiune nouă: adaugă categoriile confirmate de utilizator în baza de date.
     */
    addCategories: async ({ request }) => {
        console.log("--- Acțiune addCategories începută ---");

        const supabaseAdmin = createClient(
            PUBLIC_SUPABASE_URL,
            SUPABASE_SERVICE_ROLE_KEY,
        );

        const formData = await request.formData();
        const categoriesToInsert: { nume: string; prefix: string }[] = [];

        for (const [key, value] of formData.entries()) {
            if (key.startsWith("category_name_")) {
                const index = key.split("_").pop();
                const nume = value as string;
                const prefix = formData.get(
                    `category_prefix_${index}`,
                ) as string;

                if (nume && prefix) {
                    categoriesToInsert.push({ nume, prefix });
                }
            }
        }

        if (categoriesToInsert.length === 0) {
            return fail(400, {
                message: "Nu au fost furnizate date valide pentru categorii.",
            });
        }

        try {
            // **CORECTIE AICI: Folosim `upsert` pentru a ignora duplicatele**
            const { error } = await supabaseAdmin
                .from("categorii")
                .upsert(categoriesToInsert, {
                    onConflict: "nume",
                    ignoreDuplicates: true,
                });

            if (error) {
                console.error("Eroare la inserarea categoriilor:", error);
                return fail(500, {
                    message:
                        `Eroare la adăugarea categoriilor: ${error.message}`,
                });
            }

            return {
                success: true,
                message:
                    `Au fost adăugate categoriile noi. Vă rugăm reîncărcați fișierul de import.`,
            };
        } catch (error: any) {
            return fail(500, {
                message: `A apărut o eroare neașteptată: ${error.message}`,
            });
        }
    },
};
