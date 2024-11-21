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
        <recursive-structure :item="item" />
      </div>
    </div>
  </div>
</template>

<script>
// Composant enfant pour la structure récursive
const RecursiveStructure = {
  name: 'RecursiveStructure',
  props: {
    item: {
      type: Object,
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
          />
        </div>
      </template>
      
      <template v-else-if="item.type === 'pdf'">
        <div class="border rounded-lg p-4 shadow hover:shadow-lg transition-shadow">
          <h4 class="text-lg font-semibold mb-2">{{ item.name }}</h4>
          <div class="h-[600px] w-full">
            <iframe
              :src="item.path"
              class="w-full h-full border-0"
              :title="item.name"
            />
          </div>
        </div>
      </template>
    </div>
  `
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
      basePath: process.env.NODE_ENV === 'production'
        ? '/etude'
        : ''
    };
  },
  async created() {
    try {
      const response = await fetch(`${this.basePath}/static/structure.json`);
      if (!response.ok) {
        throw new Error('Erreur de chargement de la structure');
      }
      this.pdfStructure = await response.json();
    } catch (err) {
      this.error = err.message;
    } finally {
      this.loading = false;
    }
  }
};
</script>

<style scoped>
</style>