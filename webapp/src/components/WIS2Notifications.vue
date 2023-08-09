<template>
  <v-card>
    <v-card-title>WIS2 notifications</v-card-title>
    <v-card-item v-for="dataset in datasets" :key="dataset.id">
      <NotificationsButton :dataset="dataset.properties['wmo:topicHierarchy']" :title="dataset.properties.title" />
    </v-card-item>
  </v-card>
</template>

<script>
import { defineComponent, ref } from 'vue';
import { VCard, VCardTitle, VCardText, VCardItem, VForm, VTextarea, VBtn, VSelect } from 'vuetify/lib/components/index.mjs';
import InspectBufrButton from '@/components/InspectBufrButton.vue';
import DownloadButton from '@/components/DownloadButton.vue';
import NotificationsButton from '@/components/NotificationsButton.vue';

export default defineComponent({
    name: 'WIS2Notifications',
    components: {
        VCard,
        VCardTitle,
        VCardText,
        VCardItem,
        VForm,
        VTextarea,
        VBtn,
        VSelect,
        InspectBufrButton,
        DownloadButton,
        NotificationsButton
    },
    setup(props) {
        const datasets = ref([]); // array of datasets extracted from discovery-metadata
        // function to get datasets from discovery-metadata
        const getDatasets = async () => {    
          if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
            console.log("Use test datasets");
            datasets.value = [
              {
                "id": "urn:x-wmo:md:rou:rnimh:synoptic-weather-observations",
                "properties": {
                  "title": "Synoptic weather observations from Romania",
                  "description": "Synoptic weather observations from Romania",
                  "wmo:topicHierarchy": "rou/rnimh/data/core/weather/surface-based-observations/synop",
                }
              },
              {
                "id": "urn:x-wmo:md:mwi:mwi_met_centre:surface-weather-observations",
                "properties": {
                  "title": "Surface weather observations from Malawi",
                  "description": "Surface weather observations from Malawi",
                  "wmo:topicHierarchy": "mwi/mwi_met_centre/data/core/weather/surface-based-observations/synop",
                }
              }
            ];
          }
          else {
            const apiUrl = `${import.meta.env.VITE_API_URL}/collections/discovery-metadata/items?f=json`;
            console.log("Fetching topic hierarchy from:", apiUrl);
            try {
              const response = await fetch(apiUrl);
              if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
              }
              else {
                const data = await response.json();
                if (data.features) {
                  datasets.value = data.features;
                }
                else {
                  console.error("API response does not have features property");
                } 
              }
            }
            catch (error) {
              console.error("Error fetching topic hierarchy:", error)
            }
          }
        };
        getDatasets();
        return {
            datasets,
            getDatasets
        };
    },
});  
</script>