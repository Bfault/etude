<template>
  <div class="max-w-4xl mx-auto p-4">
    <h2 class="text-2xl font-bold mb-6">Documents de cours</h2>
    
    <div v-if="loading" class="flex items-center justify-center h-64">
      <div class="text-lg">Chargement des documents...</div>
    </div>

    <div v-else-if="error" class="flex items-center justify-center h-64">
      <div class="text-red-500">Erreur: {{ error }}</div>
    </div>

    <div v-else>
      <div v-for="(item, index) in pdfStructure" :key="index">
        <recursive-structure :item="item" :base-url="baseUrl" />
      </div>
    </div>
  </div>
</template>

<script>
const RecursiveStructure = {
  name: 'RecursiveStructure',
  props: {
    item: {
      type: Object,
      required: true
    },
    baseUrl: {
      type: String,
      required: true
    }
  },
  template: `
    <div class="mb-4">
      <template v-if="item.type === 'directory'">
        <h3 class="text-xl font-bold mb-2">{{ item.name }}</h3>
        <div class="ml-4">
          <recursive-structure
            v-for="(child, index) in item.children"
            :key="index"
            :item="child"
            :base-url="baseUrl"
          />
        </div>
      </template>
      
      <template v-else-if="item.type === 'pdf'">
        <div class="border rounded-lg p-4 shadow hover:shadow-lg transition-shadow">
          <h4 class="text-lg font-semibold mb-2">{{ item.name }}</h4>
          <div class="h-[600px] w-full">
            <iframe
              :src="getFileUrl(item.path)"
              class="w-full h-full border-0"
              :title="item.name"
            />
          </div>
        </div>
      </template>
    </div>
  `,
  methods: {
    getFileUrl(path) {
      // Pour les fichiers PDF, on utilise toujours le chemin local en développement
      if (process.env.NODE_ENV === 'development') {
        return path;
      }
      return this.baseUrl + path;
    }
  }
};

export default {
  name: 'PdfViewer',
  components: {
    RecursiveStructure
  },
  data() {
    return {
      pdfStructure: [],
      loading: true,
      error: null,
      baseUrl: process.env.NODE_ENV === 'production' 
        ? '/<nom-de-votre-repo>' // Remplacez par le nom de votre repo
        : ''
    };
  },
  methods: {
    async fetchStructure() {
      try {
        let structureUrl;
        
        if (process.env.NODE_ENV === 'development') {
          // En développement, on utilise un chemin local statique
          structureUrl = '/static/structure.json';
        } else {
          // En production, on utilise le chemin GitHub Pages
          structureUrl = `${this.baseUrl}/static/structure.json`;
        }

        const response = await fetch(structureUrl);
        if (!response.ok) {
          throw new Error(`Erreur HTTP: ${response.status}`);
        }
        this.pdfStructure = await response.json();
      } catch (err) {
        console.error('Erreur détaillée:', err);
        this.error = 'Erreur de chargement de la structure';
      } finally {
        this.loading = false;
      }
    }
  },
  created() {
    this.fetchStructure();
  }
};
</script>