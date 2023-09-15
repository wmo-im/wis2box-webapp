<template>
    <v-card>
        <v-card-title class="big-title">
            Welcome to WIS2 in a box!
        </v-card-title>
        <v-card-item>
            At this page you can submit FM 12 SYNOP bulletin and monitor notifications from topics found in your wis2box.
        </v-card-item>
        <v-card-item v-html="homeContent"></v-card-item>
    </v-card>
</template>

<script setup>

import { ref, onMounted } from 'vue';

const homeContent = ref('If you encounter any issues, please contact: <a href = "mailto: abc@example.com">abc@example.com</a>')

if (import.meta.env.VITE_HOME_CONTENT_PATH != undefined) {
    onMounted(async () => {
        const response = await fetch(import.meta.env.VITE_HOME_CONTENT_PATH);
        if (response.ok) {
            homeContent.value = await response.text();
        }
    });
}
</script>

<style scoped>

.big-title {
  font-size: 1.4rem;
  font-weight: 700;
}

</style>
