<template>
  <v-app>
    <v-main>
      <SynopForm  api="processes/" path="x-wmo:synop2bufr/execution"/>
    </v-main>
  </v-app>
</template>
<script setup>
  import SynopForm from '@/components/SynopForm.vue'
</script>