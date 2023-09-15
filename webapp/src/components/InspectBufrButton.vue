<template>
  <v-dialog v-model="dialog" width="auto">
    <template v-slot:activator="{ props }">
      <v-btn color="#49C6E5" append-icon="mdi-feature-search" v-bind="props" @click="inspectFile">Inspect</v-btn>
    </template>
      <v-card class="inspect-content">
        <v-card-title>{{ fileName }}</v-card-title>
        <v-card-text>
          <div v-if="itemsInBufr.length === 0">
            <!-- Display a message when itemsInBufr is empty -->
            <p>No items found in bufr</p>
          </div>
          <div v-for="(item, index) in itemsInBufr" :key="index" class="item-container">
            <div v-for="(value, key) in item" :key="key" class="key-value-pair">
              <span class="key">{{ key }}:</span> {{ value }}
            </div>
          </div>
        </v-card-text>
        <v-card-actions>
          <v-btn color="#1994b3" block @click="dialog = false">Close Dialog</v-btn>
        </v-card-actions>
      </v-card>
  </v-dialog>
</template>

<script>
import { defineComponent, ref } from 'vue';
import { VCard, VCardTitle, VCardText, VCardItem, VForm, VTextarea, VBtn, VSelect } from 'vuetify/lib/components/index.mjs';

export default defineComponent({
    name: 'InspectBufrButton',
    props: {
        fileName: {
            type: String,
            required: true,
        },
        fileUrl: {
            type: String,
            required: false,
            default: '',
        },
        data: {
            type: String,
            required: false,
            default: '',
        },
    },
    components: {
        VCard,
        VCardTitle,
        VCardText,
        VCardItem,
        VForm,
        VTextarea,
        VBtn,
        VSelect,
    },
    setup(props) {
        const itemsInBufr = ref([]);
        const dialog = ref(false);
        // function to create new object and to add to store
        const inspectFile = async () => {
            dialog.value = true;
            // check if TEST_MODE is set in .env file or if VITE_API_URL is not set
            if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
                console.log("TEST_MODE is enabled");
                itemsInBufr.value = [
                {
                    "wigos_station_identifier": "0-894-2-ZimbaSS",
                    "phenomenonTime": "2023-07-27T12:54:00Z",
                    "resultTime": "2023-07-27T12:54:00Z",
                    "name": "air_temperature",
                    "value": 25.75,
                    "units": "Celsius",
                    "description": null,
                    "fxxyyy": "012101"
                },
                {
                    "wigos_station_identifier": "0-894-2-ZimbaSS",
                    "phenomenonTime": "2023-07-27T12:54:00Z",
                    "resultTime": "2023-07-27T12:54:00Z",
                    "name": "characteristic_of_pressure_tendency",
                    "value": 7,
                    "units": "CODE TABLE",
                    "description": "DECREASING",
                    "fxxyyy": "010063"
                }]
            }
            else {
                await callInspect();
            }
            const desiredKeys = ['wigos_station_identifier','phenomenonTime','resultTime','name', 'value', 'units', 'description', 'fxxyyy'];
            // filter out the desired keys from the itemsInBufr array
            itemsInBufr.value = itemsInBufr.value.map(item => {
                return Object.keys(item)
                .filter(key => desiredKeys.includes(key))
                .reduce((obj, key) => {
                    obj[key] = item[key];
                    return obj;
                }, {});
            });
        };
        const callInspect = async () => {
            // set items_from_bufr back to empty array
            itemsInBufr.value = [];
            let payload;
            if (props.fileUrl !== '') {
              payload = {
                inputs: {
                  data_url: props.fileUrl
                }
              };
            } else if (props.data !== '') {
              payload = {
                inputs: {
                  data: props.data
                }
            };
            const inspectUrl = `${import.meta.env.VITE_API_URL}/processes/wis2box-bufr2geojson/execution`
            const response = await fetch(inspectUrl, {
                method: 'POST',
                headers: {
                'encode': 'json',
                'Content-Type': 'application/geo+json'
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                console.error('HTTP error', response.status);
            } else {
                const data = await response.json();
                //console.log(data);
                if (data.items) {
                // Use Array.map to create a new array of the items in the bufr file
                itemsInBufr.value = data.items.map(item => {
                if (item.properties) {
                    return item.properties;
                }
                });
                //console.log(itemsInBufr.value);
                }
            }
        };
        return {
            itemsInBufr,
            inspectFile,
            dialog,
            fileName: props.fileName
        };
    },
});
</script>

<style>
.inspect-content {
  align-self: center;
  align-items: center;
}
.item-container {
  margin-bottom: 10px;
  border: 1px solid #ccc;
  padding: 10px;
  border-radius: 4px;
}

.key-value-pair {
  margin-bottom: 5px;
}

.key {
  font-weight: bold;
  margin-right: 5px;
}
</style>
