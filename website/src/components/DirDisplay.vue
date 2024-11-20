<template>
  <div class="grid grid-cols-[300px,1fr] h-screen">
    <!-- Sidebar avec la structure -->
    <div class="overflow-y-auto border-r p-4 bg-gray-50">
      <h2 class="text-xl font-bold mb-4">Structure des cours</h2>
      <div v-if="structure" class="space-y-2">
        <template v-for="item in structure" :key="item.path">
          <div 
            :class="[
              'cursor-pointer p-2 rounded hover:bg-gray-200 flex items-center',
              selectedFile?.path === item.path ? 'bg-blue-100' : ''
            ]"
            @click="selectItem(item)"
          >
            <!-- Icône dossier ou fichier -->
            <span class="mr-2">
              {{ item.type === 'directory' ? '📁' : '📄' }}
            </span>
            
            <!-- Nom du fichier/dossier -->
            <span class="flex-1">{{ item.name }}</span>
          </div>
          
          <!-- Si c'est un dossier, indenter son contenu -->
          <div v-if="item.type === 'directory'" class="ml-4">
            <!-- Contenu récursif ici si nécessaire -->
          </div>
        </template>
      </div>
      <div v-else class="text-gray-600">
        Chargement...
      </div>
    </div>

    <!-- Zone d'affichage PDF -->
    <div class="h-full bg-gray-100 p-4">
      <div v-if="selectedFile" class="h-full">
        <!-- Options d'affichage -->
        <div class="mb-4 flex space-x-4">
          <button 
            class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            @click="viewerType = viewerType === 'iframe' ? 'object' : 'iframe'"
          >
            Changer le mode d'affichage
          </button>
          <a 
            :href="getFilePath(selectedFile)"
            target="_blank"
            class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
          >
            Ouvrir dans un nouvel onglet
          </a>
        </div>

        <!-- Visionneuse PDF -->
        <div class="h-[calc(100%-4rem)]">
          <iframe
            v-if="viewerType === 'iframe'"
            :src="getFilePath(selectedFile)"
            class="w-full h-full border-0 rounded shadow"
          ></iframe>
          <object
            v-else
            :data="getFilePath(selectedFile)"
            type="application/pdf"
            class="w-full h-full"
          >
            <div class="text-center p-4">
              <p>Votre navigateur ne peut pas afficher le PDF directement.</p>
              <a 
                :href="getFilePath(selectedFile)"
                class="text-blue-500 hover:underline"
                target="_blank"
              >
                Cliquez ici pour le télécharger
              </a>
            </div>
          </object>
        </div>
      </div>
      <div v-else class="flex items-center justify-center h-full text-gray-500">
        Sélectionnez un fichier PDF à afficher
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const structure = ref(null);
const selectedFile = ref(null);
const viewerType = ref('iframe'); // ou 'object'

onMounted(async () => {
  try {
    const response = await fetch('/website/structure.json');
    structure.value = await response.json();
  } catch (error) {
    console.error('Erreur lors du chargement de la structure:', error);
  }
});

function selectItem(item) {
  if (item.type === 'file') {
    selectedFile.value = item;
  }
}

function getFilePath(file) {
  return `/${file.path}`;
}
</script>