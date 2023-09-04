<template>
  <v-card-title class="big-title">Monitoring Dashboard</v-card-title>

  <v-card-item>
    <!-- Drop down selection for the topic the user wants to monitor -->
    <v-select label="Choose a topic to monitor" v-model="selectedTopic" :items="topics" v-if="topics.length"></v-select>
    
  </v-card-item>


  <!-- Dashboard visualising the notifications of the topic selected -->
  <NotificationDashboard :topicHierarchy="selectedTopic" v-if="selectedTopic" />
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
      topics: [],
      // Title selected by the user, used to get the topic hierarchy
      // from the topics array
      selectedTopic: null
    }
  },
  methods: {
    // Method to get topic hierarchies and corresponding titles from the 
    // discovery metadata, in order to allow the user to select the topic
    // dsisplayed in the dashboard
    async getTopics() {
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        console.log("Use test topics");
        this.topics = [
          "rou/rnimh/data/core/weather/surface-based-observations/synop", 
          "mwi/mwi_met_centre/data/core/weather/surface-based-observations/synop",
          "tst/topic/with/zero/notifications"
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
            // If the features object is in the data
            if (data.features) {
              // Use Array.map to create a new array of the topic hierarchies
              this.topics = data.features.map(feature => {
                if (feature.properties && feature.properties['wmo:topicHierarchy']) {
                  return feature.properties['wmo:topicHierarchy']
                }
              });
              console.log("Topics:", this.topics);
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
    // Get topic hierarchies and titles for the user to select a topic
    this.getTopics();
  }
});  
</script>
<style scoped>
.big-title {
  font-size: 1.4rem;
  font-weight: 700;
}
</style>