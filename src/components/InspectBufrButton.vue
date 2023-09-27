<template>
  <v-dialog v-model="dialog" width="auto">
    <template v-slot:activator="{ props }">
      <v-btn color="#49C6E5" :block="block" append-icon="mdi-feature-search" v-bind="props" @click="inspectFile">Inspect</v-btn>
    </template>
    <v-card class="inspect-content">
      <v-btn icon="mdi-close" class="close-button" variant="plain" @click="dialog = false"></v-btn>
      <v-card-title class="pad-filename">{{ fileName }}</v-card-title>
      <v-row>
        <!-- Left side of window -->
        <v-col cols="6">
          <v-card-item>
            <v-card-text>WIGOS Identifier: {{result.wsi}}</v-card-text>
            <v-card-text>Station name: {{result.name}}</v-card-text>
            <v-card-text>Station elevation: {{result.elevation}} (m)</v-card-text>
            <v-card-text>Barometer height above mean sea level: {{result.barometerHeight}} (m)</v-card-text>
            <v-card-text>Nominal report time: {{result.resultTime}}</v-card-text>
          </v-card-item>
          <v-card-item min-width="600px">
            <LocatorMap :longitude="result.longitude" :latitude="result.latitude"/>
          </v-card-item>
        </v-col>
        <v-divider vertical inset></v-divider>
        <!-- Right side of window -->
        <v-col cols="6">
          <v-card-item>
            <v-data-table :items="result.items" :headers="result.headers"
            items-per-page="25"
            items-per-page-text="Properties per page"/>
          </v-card-item>
        </v-col>
      </v-row>
    </v-card>
  </v-dialog>
</template>

<script>
  // imports
  import {defineComponent, onBeforeMount, onMounted, ref} from "vue";
  import {VCard, VCardTitle, VCardText, VCardItem, VBtn} from "vuetify/lib/components/index.mjs";
  import {VDialog, VContainer, VRow, VCol, VTextField} from "vuetify/lib/components/index.mjs";
  import { VDataTable } from 'vuetify/lib/labs/VDataTable/index.mjs';
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
          wsi: null,
          name: null,
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
          // we should have a single subset per file but should add a check to make sure that is the case
          // assume one file for now, add to ToDo.
          // Get location, elevation, WSI and station name from first object
          if( data.items ){
            result.value.wsi = data.items[0].properties.wigos_station_identifier;
            result.value.name = data.items[0].properties.metadata.find( (item) => item.name === "station_or_site_name")?.description ?? "";
            result.value.elevation = data.items[0].geometry.coordinates[2];
            result.value.longitude = data.items[0].geometry.coordinates[0];
            result.value.latitude = data.items[0].geometry.coordinates[1];
            result.value.resultTime = data.items[0].properties.resultTime;
            result.value.barometerHeight = data.items[0].properties.metadata.find( (item) => item.name === "height_of_barometer_above_mean_sea_level")?.value ?? "";
            result.value.items = data.items.map( (item) => {
              var varName = item.properties.name.replace(/_/g," ").replace(/([0-9])([A-Za-z])/g,"$1 $2");
              var varValue = item.properties.value;
              var varUnits = item.properties.units;
              //var varPhenomenonTime = item.properties.phenomenonTime;
              return {
                //phenomenonTime: varPhenomenonTime,
                observedProperty: varName,
                value: varValue,
                units: varUnits
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
