<template>
  <div class="viewer-container">
    <embed
    :src="pdfUrl"
    type="application/pdf"
    class="pdf-viewer"
    />
  </div>
</template>
  
<script>
import { defineComponent } from 'vue'
  
export default defineComponent({
  props: {
    pdfUrl: {
      type: String,
      required: true
    },
    title: {
      type: String,
      default: 'Document PDF'
    }
  },
})
</script>
  
<style scoped>
.viewer-container {
  flex: 1;
  display: flex;
  width: 100%;
  height: 100%;
}

.pdf-viewer {
  flex: 1;
  width: 100%;
  height: 100%;
  border: none;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>