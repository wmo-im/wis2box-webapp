<template>
    <v-dialog v-model="dialog" width="auto">
      <template v-slot:activator="{ props }">
        <v-btn v-bind="props" @click="getNotifications" class="dataset-button">
            {{ title }}
        </v-btn>
      </template>
        <v-card class="messages">
          <v-card-title>{{ title }}</v-card-title>
          <v-card-subtitle>Messages seen in the last 24 hours </v-card-subtitle>
          <v-card-actions>
            <v-btn @click="getNotifications" block>Update</v-btn>
          </v-card-actions>
          <v-card-text>
            <v-card-title>Number of messages by WIGOS station identifier</v-card-title>
            <v-card-item v-for="(item, index) in groupedMessages" :key="index">
                {{ index }}: {{ item.count }}
            </v-card-item>
        </v-card-text>
          <v-card-text>
            <v-card-title>Messages</v-card-title>
            <!-- Check if messages array is empty -->
            <div v-if="messages.length === 0" class="no-notifications-message">
                No notifications found for dataset
            </div>
            <!-- If messages array is not empty, render notifications -->
            <div v-else>
                <div v-for="(item, index) in messages" :key="index" class="item-container">
                    <v-card-item>Published at: {{ item.properties.pubtime }}</v-card-item>
                    <v-card-item>WIGOS station identifier: {{ item.properties.wigos_station_identifier }}</v-card-item>
                    <v-card-item>
                        <div class="file-info">
                            Data: {{ getFileName( item.canonical_url ) }}
                        </div>
                        <div class="file-actions">
                            <DownloadButton :fileUrl="item.canonical_url"/>
                            <InspectBufrButton :fileUrl="item.canonical_url"/>
                    </div>
                    </v-card-item>
                </div>
            </div>
          </v-card-text>
          <v-card-actions>
            <v-btn color="primary" block @click="dialog = false">Close Dialog</v-btn>
          </v-card-actions>
        </v-card>
    </v-dialog>
  </template>

<script>
import { defineComponent, ref } from 'vue';
import { VCard, VCardTitle, VCardText, VCardItem, VForm, VTextarea, VBtn, VSelect } from 'vuetify/lib/components/index.mjs';
import InspectBufrButton from '@/components/InspectBufrButton.vue';
import DownloadButton from '@/components/DownloadButton.vue';

export default defineComponent({
    name: 'NotificationsButton',
    props: {
        dataset: {
            type: String,
            required: true,
        },
        title: {
            type: String,
            required: true,
        },
    },
    components: {
        VCard,
        VCardTitle,
        VCardText,
        VCardItem,
        VTextarea,
        VForm,
        VBtn,
        VSelect,
        InspectBufrButton,
        DownloadButton
    },
    setup(props) {
        const messages = ref([]);
        const groupedMessages = ref({});
        const dialog = ref(false);
        const wigos_id = ref("")

        const getNotifications = async () => {
            dialog.value = true;
            // check if TEST_MODE is set in .env file or if VITE_API_URL is not set
            if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
                console.log("TEST_MODE is enabled");
                // prepare dummy data
                messages.value = [
                    {
                    "id": "af14d8c4-5f63-45af-8171-7730ec9932ba",
                    "properties": {
                        "data_id": "wis2/rou/rnimh/data/core/weather/surface-based-observations/synop/WIGOS_0-20000-0-15015_20220331T000000",
                        "datetime": "2022-03-31T00:00:00Z",
                        "pubtime": "2023-07-25T14:31:49Z",
                        "wigos_station_identifier": "0-20000-0-15015",
                        "id": "af14d8c4-5f63-45af-8171-7730ec9932ba"
                    },
                    "links": [
                        {
                            "rel": "canonical",
                            "type": "application/x-bufr",
                            "href": "http://3.73.37.35/data/2022-03-31/wis/rou/rnimh/data/core/weather/surface-based-observations/synop/WIGOS_0-20000-0-15015_20220331T000000.bufr4",
                        },
                        {
                            "rel": "via",
                            "type": "text/html",
                            "href": "https://oscar.wmo.int/surface/#/search/station/stationReportDetails/0-20000-0-15015"
                        }]
                    },
                    {
                    "id": "8855221f-2112-43fa-b2da-1552e8aa9a2d",
                    "properties": {
                        "data_id": "wis2/rou/rnimh/data/core/weather/surface-based-observations/synop/WIGOS_0-20000-0-15020_20220331T000000",
                        "datetime": "2022-03-31T00:00:00Z",
                        "pubtime": "2023-07-25T14:32:43Z",
                        "wigos_station_identifier": "0-20000-0-15020",
                        "id": "8855221f-2112-43fa-b2da-1552e8aa9a2d"
                    },
                    "links": [
                        {
                            "rel": "canonical",
                            "type": "application/x-bufr",
                            "href": "http://3.73.37.35/data/2022-03-31/wis/rou/rnimh/data/core/weather/surface-based-observations/synop/WIGOS_0-20000-0-15020_20220331T000000.bufr4",
                        },
                        {
                            "rel": "via",
                            "type": "text/html",
                            "href": "https://oscar.wmo.int/surface/#/search/station/stationReportDetails/0-20000-0-15015"
                        }]
                    }
                ];
            }
            else {
                await apiCall();
            }
            // Group the messages based on 'wigos_station_identifier' add canonical_url property to each item
            const grouped = {};
            messages.value.forEach((item) => {
                const canonicalLink = item.links.find(link => link.rel === "canonical");
                if (canonicalLink) {
                    item.canonical_url = canonicalLink.href;
                }
                const identifier = item.properties.wigos_station_identifier;
                if (!grouped[identifier]) {
                    grouped[identifier] = {};
                    grouped[identifier].count = 0;
                }
                grouped[identifier].count++;
            });
            groupedMessages.value = grouped;
        };
        const apiCall = async () => {
          // set messages back to empty array
          messages.value = [];
          const apiUrl = `${import.meta.env.VITE_API_URL}/collections/messages/items`;
          try {
            // get current time in UTC minus 24 hours
            const now = new Date();
            const now_minus_24hours = new Date(now.getTime() - (24 * 60 * 60 * 1000));
            const params = new URLSearchParams({
                f: 'json', // Specify the response format as JSON
                data_id: `${props.dataset}%`, // Filter by data_id that starts with the provided value
                sortby: '-pubtime', // Sort by time in descending order
                limit: 9999, // Limit the results to 9999
                datetime: `${now_minus_24hours.toISOString()}/${now.toISOString()}`, // Filter by datetime range
            });
            // Make the HTTP GET request
            console.log("API request:", `${apiUrl}?${params}`)
            const response = await fetch(`${apiUrl}?${params}`);
            if (!response.ok) {
              throw new Error(`HTTP error! Status: ${response.status}`);
            }
            else {
              const data = await response.json();
              if (data.features) {
                messages.value = data.features;
              }
              else {
                console.error("API response does not contain features:", data);
              }
            }
          }
          catch (error) {
            console.error("Error fetching notifications:", error)
          }
        };
        const getFileName = (url) => {
            if(!url) return;
            const urlParts = url.split('/');
            return urlParts[urlParts.length - 1];
        };
        return {
            getNotifications,
            getFileName,
            dialog,
            messages,
            groupedMessages
        };
    },
});  
</script>

<style>
.dataset-button {
  padding: 2px;
  width: 90%;
  max-width: 800px;
  margin: 10px;
}

.file-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px;
}

.file-actions v-btn {
  align-self: center;
}
</style>