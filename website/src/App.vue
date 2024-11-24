<template>
  <FolderNavigation />
</template>

<script>
import FolderNavigation from './components/FolderNavigation.vue';


export default {
  name: 'App',
  components: {
    FolderNavigation,
  }
}
</script>

<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100vh;
  overflow: hidden;
}

@media screen and (max-width: 768px) {
  html, body {
    overflow: visible;
  }
}

:root {
  background-color: #eeeeee;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  display: flex;
  height: 100vh;
  width: 100vw;
}
</style>