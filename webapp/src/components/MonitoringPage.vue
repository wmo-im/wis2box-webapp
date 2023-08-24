<template>
  <v-card-title class="big-title">Monitoring Dashboard</v-card-title>

  <!-- Drop down selection for the dataset the user wants to monitor -->
  <v-select label="Choose dataset to monitor" v-model="selectedTitle" :items="titles" v-if="titles.length"></v-select>
  
  <!-- Dashboard visualising the notifications of the dataset selected -->
  <NotificationDashboard :topicHierarchy="datasets[selectedTitle]" v-if="selectedTitle"/>

</template>

<script>
import { defineComponent } from 'vue';
import { VCardTitle } from 'vuetify/lib/components/index.mjs';
import NotificationDashboard from '@/components/NotificationDashboard.vue';

export default defineComponent({
  name: 'MonitoringPage',
  components: {
    VCardTitle,
    NotificationDashboard
  },
  data() {
    return {
      // Options for user to filter the dashboard (surface, upper air, etc)
      datasets: {},
      // Title selected by the user, used to get the topic hierarchy
      // from the datasets dictionary
      selectedTitle: null
    }
  },
  computed: {
    // Get titles (the keys) from datasets dictionary by using Object.keys,
    // used for the selection at the top of the page
    titles() {
      return Object.keys(this.datasets);
    }
  },
  methods: {
    // Method to get topic hierarchies and corresponding titles from the 
    // discovery metadata, in order to allow the user to select the dataset
    // dsisplayed in the dashboard
    async getDatasets() {
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        console.log("Use test datasets");
        this.datasets = {
          "Synoptic weather observations from Romania": "rou/rnimh/data/core/weather/surface-based-observations/synop",
          "Surface weather observations from Malawi": "mwi/mwi_met_centre/data/core/weather/surface-based-observations/synop"
        };
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
            // If the features object is in the data
            if (data.features) {
              // Populate the datasets dictionary with the titles as keys
              // and corresponding topic hierarchies as items
              this.datasets = data.features.reduce((acc, feature) => {
                acc[feature.properties.title] = feature.properties["wmo:topicHierarchy"];
                // acc: accumulator object, used to iteratively build
                // this datasets dictionary
                return acc;
              }, {});
              console.log("Datasets:", this.datasets);
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
    }
  },
  mounted() {
    // Get topic hierarchies and titles for the user to select a dataset
    this.getDatasets();
  }
});  
</script>
<style scoped>
.big-title {
  font-size: 1.4rem;
  font-weight: 700;
}
</style>