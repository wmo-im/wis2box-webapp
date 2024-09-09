<template>
  <v-dialog v-model="dialog" width="auto">
    <template v-slot:activator="{ props }">
      <v-btn color="#49C6E5" :block="block" append-icon="mdi-feature-search" v-bind="props" @click="inspectFile">Inspect</v-btn>
    </template>
    <v-card class="inspect-content">
      <v-btn icon="mdi-close" class="close-button" variant="plain" @click="dialog = false"></v-btn>
      <v-card-title class="pad-filename">{{ fileName }}</v-card-title>
      <v-container class="scrollable-list">
        <!-- display error in result.error exists -->
        <v-row v-if="result.error">
          <v-col cols="12">
            <v-alert type="error" dismissible>
              <v-row>
                <v-col cols="12">
                  <div class="text-h6">Error</div>
                  <div>{{result.error}}</div>
                </v-col>
              </v-row>
            </v-alert>
          </v-col>
        </v-row>
        <!-- display result if it exists -->
        <v-row v-if="result.wsi">
          <!-- Left side of window -->
          <v-col cols="5">
            <v-list lines="zero">
              <v-list-item><b>Alert:</b> {{result.title}}</v-list-item>
              <v-list-item><b>Identifier:</b> {{result.identifier}}</v-list-item>
              <v-list-item><b>Sender:</b> {{result.sender}}</v-list-item>
              <v-list-item><b>Sent:</b> {{result.sent}}</v-list-item>
              <v-list-item><b>Status:</b> {{result.status}}</v-list-item>
              <v-list-item><b>Message Type:</b> {{result.msgType}} (m)</v-list-item>
              <v-list-item><b>Scope:</b> {{result.scope}}</v-list-item>
            </v-list>
            <v-card-item>
              <LocatorMap :longitude="result.longitude" :latitude="result.latitude"/>
            </v-card-item>
          </v-col>
          <v-divider vertical inset></v-divider>
          <!-- Right side of window -->
          <v-col cols="7">
            <v-card-item>
              <v-data-table :items="result.items" :headers="result.headers"
              items-per-page="25"
              items-per-page-text="Properties per page"/>
            </v-card-item>
          </v-col>
        </v-row>
      </v-container>
    </v-card>
  </v-dialog>
</template>

<script>
  // imports
  import {defineComponent, onBeforeMount, onMounted, ref} from "vue";
  import {VCard, VCardTitle, VCardText, VCardItem, VBtn} from "vuetify/lib/components/index.mjs";
  import {VDialog, VContainer, VRow, VCol, VTextField} from "vuetify/lib/components/index.mjs";
  import { VDataTable } from 'vuetify/lib/components/index.mjs';
  import LocatorMap from '@/components/LocatorMap.vue';
  // now component to export
  export default defineComponent({
    name: "InspectBufrButton",
    props: {
      fileUrl: {
        type: String,
        required: false,
        default: ""
      },
      data: {
        type: String,
        required: false,
        default: ""
      },
      fileName:{
        type: String,
        required: true
      },
      block: {
        type: Boolean,
        required: false,
        default: false
      }
    },
    components: {
      VCard, VCardTitle, VCardText, VCardItem,
      VDialog,  VContainer, VRow, VCol, VTextField,
      LocatorMap, VBtn, VDataTable,
    },
    setup( props ){
      const result = ref(null);
      const dialog = ref(false);

      const loadData = async () =>{
        var payload;
        // result result object
        result.value = {
          result: null,
          wsi: null,
          name: null,
          coords: null,
          elevation: null,
          resultTime: null,
          items: [],
          headers: []
        }
        // determine whether we have data or need to load the data from a file
        if( props.fileUrl !== ""){
          payload = {
            inputs: {
              data_url: props.fileUrl
            }
          };
        }else if( props.data !== ""){
          payload = {
            inputs: {
              data: props.data
            }
          };
        }
        // now call to bufr to geojson to extract and transform
        const apiURL = `${import.meta.env.VITE_API_URL}/processes/bufr2geojson/execution`;
        const response = await fetch(apiURL,{
            method: "POST",
            headers: {
              "encode": "json",
              "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
          }
        );
        // check response status
        if( !response.ok){
          console.error("HTTP error", response.status);  // do we want to give user feedback?
        }else{
          const data = await response.json();
          // check for errors
          if( data.error ){
            console.info("bufr2geojon returned the error:", data.error);
            result.value.error = data.error;
          }
          // we should have a single subset per file but should add a check to make sure that is the case
          // assume one file for now, add to ToDo.
          // Get location, elevation, WSI and station name from first object
          if( data.items ){
            result.value.wsi = data.items[0].properties.wigos_station_identifier;
            result.value.name = data.items[0].properties.metadata.find( (item) => item.name === "station_or_site_name")?.description ?? "";
            result.value.elevation = parseFloat(data.items[0].geometry.coordinates[2]).toFixed(2);
            // if result.value.elevation is NaN, set to 'undefined'
            if (isNaN(result.value.elevation)) {
              result.value.elevation = 'undefined';
            }
            // Lon and lat are rounded to 5dp, but as toFixed returns
            // a string, parseFloat is used again to convert the
            // result back to a float
            result.value.longitude = parseFloat(parseFloat(data.items[0].geometry.coordinates[0]).toFixed(5));
            result.value.latitude = parseFloat(parseFloat(data.items[0].geometry.coordinates[1]).toFixed(5));
            result.value.resultTime = data.items[0].properties.resultTime;
            result.value.barometerHeight = parseFloat(data.items[0].properties.metadata.find( (item) => item.name === "height_of_barometer_above_mean_sea_level")?.value ?? "").toFixed(2);
            // if result.value.barometerHeight is NaN, set to undefined
            if (isNaN(result.value.barometerHeight)) {
              result.value.barometerHeight = 'undefined';
            }
            result.value.items = data.items.map( (item) => {
              var varName = item.properties.name.replace(/_/g," ").replace(/([0-9])([A-Za-z])/g,"$1 $2");
              var varValue = item.properties.value;
              var varUnits = item.properties.units;
              var varDescription = item.properties.description;
              var varPhenomenonTime = item.properties.phenomenonTime;

              // If the phenomenon time is a range (two times separated by /),
              // calculate the time period and append this to the variable name
              if (varPhenomenonTime.includes('/')) {
                var [startTimeStr, endTimeStr] = varPhenomenonTime.split('/');
                var startTime = new Date(startTimeStr);
                var endTime = new Date(endTimeStr);
                var timeDifferenceMs = endTime - startTime;
                // Get time difference in hours and minutes
                var timeDifferenceHours = timeDifferenceMs / (1000 * 60 * 60);
                var timeDifferenceMinutes = timeDifferenceMs / (1000 * 60);
                // If time difference in hours is >= 1, the period
                // is best expressed in hours. Otherwise, express in minutes
                if (timeDifferenceHours > 1) {
                  varName = `${varName} (${timeDifferenceHours} hours)`
                }
                else if (timeDifferenceHours == 1) {
                  varName = `${varName} (${timeDifferenceHours} hour)`
                }
                else {
                  varName = `${varName} (${timeDifferenceMinutes} minutes)`
                }
              }
              return {
                //phenomenonTime: varPhenomenonTime,
                observedProperty: varName,
                value: varValue,
                units: varUnits,
                description: varDescription
              };
            });
          }
        }

      };
      const inspectFile = async () => {
        await loadData();
        if( result.value.items && result.value.items.length > 0){
          result.value.headers = Object.keys( result.value.items[0] ).map( key => ({
            title: key,
            value: key,
            key: key,
            sortable: false
          }));
        };
        dialog.value = true;
      };
      onBeforeMount( async () => {
        result.value = {
          wsi: null,
          name: null,
          elevation: null,
          resultTime: null,
          items: [],
          headers: []
        }
      });
      return {result, dialog, inspectFile};
    }
  });
</script>
<style scoped>

.pad-filename {
  margin-top: 0.2rem;
}

.close-button {
  position: absolute;
  top: 0;
  right: 0;
  z-index: 1;
}

.inspect-content {
  align-self: center;
  align-items: center;
}

.scrollable-list {
  overflow-y: auto;
  max-height: 800px;
  max-width: 1600px;
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
