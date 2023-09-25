<template>
  <v-dialog v-model="apiDown" width="auto">
    <v-card>
      <v-card-text>Unable to connect to API, please check status.<br/>
        API: <a :href="apiUrl">{{apiUrl}}</a></v-card-text>
      <v-card-actions>
        <v-btn color="primary" block @click="apiDown=false" elevation=2>Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
  import { defineComponent, ref, onBeforeMount } from 'vue';
  import { VDialog, VCard, VCardText, VCardActions, VBtn } from 'vuetify/lib/components/index.mjs';

  export default defineComponent({
    name: 'APIStatus',
    components: {
      VDialog, VCard, VCardText, VCardActions, VBtn
    },
    setup() {
      const apiDown = ref(false);
      const apiUrl = `${import.meta.env.VITE_API_URL}/`;
      onBeforeMount(async () => {
        try {
          const response = await fetch(apiUrl); // Add await here
          if (!response.ok) {
            apiDown.value = true;
            console.error(response)
          }
        } catch (err) {
          apiDown.value = true;
          console.error(err)
        }
      });
      return { apiDown, apiUrl };
    }
  });
</script>
