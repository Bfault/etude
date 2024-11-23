<template>
  <div class="folder-container">
    <div class="nav-bar">
      <n-button 
        v-if="currentPdf !== null || navigationHistory.length > 0" 
        @click="goBack"
        class="back-button"
      >
        Retour
      </n-button>
    </div>

    <div class="main-content">
      <div v-if="currentPdf === null" class="folder-list">
        <div v-for="(item, index) in currentFolder" :key="index" class="folder-item">
          <n-button @click="navigate(item)">{{ item.name }}</n-button>
        </div>
      </div>

      <div v-else class="pdf-content">
        <PdfViewer :pdfUrl="wrappedCurrentPdfPath" :title="currentPdf.name" />
      </div>
    </div>
  </div>
</template>

<script>
  import { defineComponent } from 'vue'
  import { NButton } from 'naive-ui'
  import PdfViewer from './PdfViewer.vue';

  export default defineComponent({
    components: {
      NButton,
      PdfViewer
    },
    data() {
      return {
        currentFolder: [],
        currentPdf: null,
        navigationHistory: [],
        baseUrl: process.env.NODE_ENV === 'production'
          ? '/etude'
          : ''
      }
    },
    computed: {
      wrappedCurrentPdfPath() {
        return `${this.baseUrl}/${this.currentPdf.path}`
      }
    },
    methods: {
      async fetchStructure() {
        try {
          let structureUrl = `${this.baseUrl}/static/structure.json`;
          const response = await fetch(structureUrl);
          if (!response.ok) {
            throw new Error(`Erreur HTTP: ${response.status}`);
          }
          this.currentFolder = await response.json();
        } catch (err) {
          console.error('Erreur détaillée:', err);
          this.error = 'Erreur de chargement de la structure';
        }
      },
      navigate(folder) {
        if (folder.type === "directory") {
          this.navigationHistory.push(this.currentFolder);
          this.currentFolder = folder.children;
        } else if (folder.type === "pdf") {
          this.currentPdf = folder;
        }
      },
      goBack() {
        if (this.currentPdf !== null) {
          this.currentPdf = null;
        } else if (this.navigationHistory.length > 0) {
          this.currentFolder = this.navigationHistory.pop();
        }
      },
    },
    created() {
      this.fetchStructure();
    }
  })
</script>

<style scoped>
.folder-container {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100vh;
}

.nav-bar {
  padding: 1rem;
  background-color: #f5f5f5;
  border-bottom: 1px solid #e0e0e0;
}

.back-button {
  margin-right: 1rem;
}

.main-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.folder-list {
  padding: 1rem;
  width: 100%;
}

.folder-item {
  margin-bottom: 0.5rem;
}

.pdf-content {
  flex: 1;
  display: flex;
  width: 100%;
  height: 100%;
}
</style>