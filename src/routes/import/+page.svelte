<script lang="ts">
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';

	export let form: ActionData;
</script>

<div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
	<div class="sm:mx-auto sm:w-full sm:max-w-md">
		<h1 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
			Import Produse Generice
		</h1>
		<p class="mt-2 text-center text-sm text-gray-600">
			Încărcați un fișier JSON pentru a adăuga produse în sistem.
		</p>
	</div>

	<div class="mt-8 sm:mx-auto sm:w-full sm:max-w-2xl">
		<div class="bg-white py-8 px-4 shadow-lg sm:rounded-lg sm:px-10">
			
            <!-- Afișare Mesaje de Succes/Eroare Generale -->
			{#if form?.success}
				<div class="rounded-md bg-green-50 p-4 mb-6">
					<div class="flex">
						<div class="flex-shrink-0">
							<svg class="h-5 w-5 text-green-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
								<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
							</svg>
						</div>
						<div class="ml-3">
							<p class="text-sm font-medium text-green-800">{form.message}</p>
						</div>
					</div>
				</div>
			{/if}

            {#if form?.message && !form.success && form?.error !== 'new_category_found'}
                 <div class="rounded-md bg-red-50 p-4 mb-6">
                    <p class="text-sm font-medium text-red-800">{form.message}</p>
                 </div>
            {/if}

			<!-- Formularul Principal de Upload -->
			<form method="POST" action="?/importFile" use:enhance class="space-y-6" enctype="multipart/form-data">
				<div>
					<label for="file-upload" class="block text-sm font-medium text-gray-700">
						Selectează fișier JSON
					</label>
					<div class="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md">
						<div class="space-y-1 text-center">
							<div class="flex text-sm text-gray-600 justify-center">
								<label for="file-upload" class="relative cursor-pointer bg-white rounded-md font-medium text-indigo-600 hover:text-indigo-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500">
									<span>Încarcă un fișier</span>
									<input id="file-upload" name="file" type="file" class="sr-only" accept=".json" />
								</label>
								<p class="pl-1">sau trage-l aici</p>
							</div>
							<p class="text-xs text-gray-500">Doar fișiere JSON</p>
						</div>
					</div>
				</div>

				<div>
					<button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
						Încarcă și Procesează
					</button>
				</div>
			</form>

            <!-- Dialogul de Confirmare pentru Categorii Noi -->
            {#if form?.error === 'new_category_found'}
                <div class="mt-8 border-t-4 border-yellow-400 bg-yellow-50 p-4 rounded-b-lg shadow-md">
                    <h3 class="text-lg font-bold text-yellow-900">Confirmare Categorii Noi</h3>
                    <p class="mt-2 text-sm text-yellow-800">
                        Următoarele categorii nu există în sistem. Vă rugăm să le alocați un prefix unic (3-5 litere) pentru a continua.
                    </p>

                    <form method="POST" action="?/addCategories" use:enhance class="mt-4 space-y-4">
                        {#each form.new_categories as category, i}
                            <div class="flex items-center space-x-4">
                                <span class="flex-1 text-sm font-medium text-gray-700 bg-gray-200 px-3 py-2 rounded-md">{category}</span>
                                <input 
                                    type="text" 
                                    name="category_prefix_{i}" 
                                    required
                                    minlength="3"
                                    maxlength="5"
                                    placeholder="Prefix (ex: EXTQ)"
                                    class="w-32 block px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                                />
                                <input type="hidden" name="category_name_{i}" value={category} />
                            </div>
                        {/each}

                        <div class="flex justify-end pt-4">
                             <button type="submit" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500">
                                Confirmă și Adaugă Categoriile
                            </button>
                        </div>
                    </form>
                </div>
            {/if}
		</div>
	</div>
</div>
