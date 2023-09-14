<template>
  <v-sheet align="center">
    <v-dialog v-model="showDialog" width="auto">
      <v-card>
        <v-card-text>{{errorMessage}}</v-card-text>
        <v-card-actions>
          <v-btn color="primary" block @click="showDialog = false">Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-card-title v-if="!readonly">{{ route.params.id ? 'Edit' : 'Create new' }} station</v-card-title>
    <v-card-title v-else>View station</v-card-title>
    <v-card v-if="station" max-width="1200px">
      <v-form v-model="formValid" align="left">
        <v-card-item>
          <v-text-field
            label="Station name"
            v-model="station.properties.name"
            :rules="[rules.validName]"
            :readonly="readonly"
            hint="Enter name of station" persistent-hint>
          </v-text-field>
        </v-card-item>
        <v-card-item>
          <v-text-field
            label="WIGOS station identifier"
            v-model="station.properties.wigos_station_identifier"
            :rules="[rules.validWSI]"
            :readonly="readonly"
            hint="Enter the WIGOS station identifier" persistent-hint>
          </v-text-field>
        </v-card-item>
        <!--<v-card-item v-if="(!readonly) && (!route.params.id)">
          <v-btn elevation=2 @click="importOSCAR">Import from OSCAR/Surface</v-btn>
        </v-card-item>
        -->
        <v-card-item>
          <v-text-field
            label="Traditional station identifier"
            v-model="station.properties.traditional_station_identifier"
            :readonly="readonly"
            hint="Enter the traditional (5 or 7 digit) station identifier" persistent-hint>
          </v-text-field>
        </v-card-item>
        <v-card-item>
          <v-container>
            <v-row>
              <v-col cols="4">
                <v-row>
                <v-text-field
                  label="Longitude (decimal degrees E), -180 to 180"
                  v-model="station.geometry.longitude"
                  :rules="[rules.validLongitude]"
                  :readonly="readonly"
                  type="number"
                  hint="Enter the station longitude (degrees E)" persistent-hint/>
                </v-row>
                <v-row>
                  <v-text-field
                  label="Latitude (decimal degrees N), -90 to 90"
                  v-model="station.geometry.latitude"
                  :rules="[rules.validLatitude]"
                  :readonly="readonly"
                  type="number"
                  hint="Enter the station latitude (degrees N)" persistent-hint/>
              </v-row>
              <v-row>
                <v-text-field
                  label="Station elevation above sea level (metres)"
                  v-model="station.geometry.elevation"
                  :rules="[rules.validElevation]"
                  :readonly="readonly"
                  type="number"
                  hint="Station elevation above sea level (metres)" persistent-hint/>
              </v-row>
              <!--
              <v-row v-if="!readonly">
                <v-btn @click=getElevation()>Get elevation</v-btn>
              </v-row>
              -->
              </v-col>
              <v-col cols="8">
                <LocatorMap
                    :longitude="parseFloat(station.geometry.longitude)"
                    :latitude="parseFloat(station.geometry.latitude)"/>
              </v-col>
            </v-row>
          </v-container>
        </v-card-item>
        <v-card-item>
          <FacilityTypeSelector v-model="station.properties.facility_type" :readonly="readonly"/>
        </v-card-item>
        <v-card-item>
          <v-text-field
            label="Barometer height above sea level"
            v-model="station.properties.barometer_height"
            :rules="[rules.validBarometerHeight]"
            :readonly="readonly"
            hint="Enter barometer height (metres)" persistent-hint type="number">
          </v-text-field>
        </v-card-item>
        <v-card-item><WMORegionSelector v-model="station.properties.wmo_region" :readonly="readonly"/></v-card-item>
        <v-card-item><TerritorySelector v-model="station.properties.territory_name" :readonly="readonly"/></v-card-item>
        <v-card-item><OperatingStatusSelector v-model="station.properties.status" :readonly="readonly"/></v-card-item>
        <v-card-item>
          <TopicHierarchySelector v-model="station.properties.topics" multiple :readonly="readonly"/>
        </v-card-item>
        <v-card-item>
          <v-text-field type="password" clearable v-model="token" label="Auth token"></v-text-field>
        </v-card-item>
        <v-card-actions v-if="!readonly">
          <v-btn @click="registerStation()" elevation=2 :disabled="!formValid">Register/Update</v-btn>
          <v-btn @click="cancelEdit()" elevation=2>Cancel</v-btn>
        </v-card-actions>
        <v-card-actions v-else>
          <v-btn @click="router.push('/station/'+route.params.id+'?action=edit')" elevation=2>Edit</v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
    </v-sheet>
  </template>
  <script>
    import {defineComponent, ref, watch, onBeforeMount, onMounted} from 'vue';
    import {VSheet, VCard, VCardItem, VTextField, VContainer, VRow, VCol, VBtn, VCardActions} from 'vuetify/lib/components/index.mjs';
    import {VForm} from 'vuetify/lib/components/index.mjs';
    import TopicHierarchySelector from '@/components/TopicHierarchySelector.vue';
    import FacilityTypeSelector from '@/components/FacilityTypeSelector.vue';
    import WMORegionSelector from '@/components/WMORegionSelector.vue';
    import TerritorySelector from '@/components/TerritorySelector.vue';
    import OperatingStatusSelector from '@/components/OperatingStatusSelector.vue';
    import LocatorMap from '@/components/LocatorMap.vue';
    import {useRoute, useRouter} from 'vue-router';



    export default defineComponent({
      name: 'StationEditor',
      components: {
        VContainer, VRow, VContainer, VCard, VCardItem, VTextField, OperatingStatusSelector,
        TopicHierarchySelector, FacilityTypeSelector, WMORegionSelector, TerritorySelector,
        VBtn, VCardActions, LocatorMap, VForm
      },
      setup(){
        const route = useRoute();
        const router = useRouter();
        const station = ref(null);
        const topics = ref([null]);
        const showDialog = ref(false);
        const errorMessage = ref(null);
        const operatingStatusOptions = ref(null);
        const territoryOptions = ref(null);
        const WMORegionOptions = ref(null);
        const facilityTypeOptions = ref(null);
        const readonly = ref(false);
        const msg = ref('');
        const token = ref(null);
        const formValid = ref(null);

        const selectedFacilityType = ref(null);



        // define validation rules
        const rules = ref({
          validWSI: value => /^0-[0-9]{1,5}-[0-9]{0,5}-[0-9a-zA-Z]{1,16}$/.test(value) || 'Invalid WSI',
          validLongitude: value => ! (Math.abs(value) > 180 || isNaN(value)) ? true : 'Invalid longitude',
          validLatitude: value => ! (Math.abs(value) > 90 || isNaN(value)) ? true : 'Invalid latitude',
          validElevation: value => ! isNaN(value) ? true : 'Invalid elevation',
          validBarometerHeight: value => ! isNaN(value) ? true : 'Invalid barometer height',
          validName: value => value && value.length > 3 ? true : 'Name must be more than 3 characters'
        });

        const cancelEdit = async () => {
          readonly.value = true;
          if( route.params.id ){
            loadStation(route.params.id);
            router.push('/station/'+route.params.id);
          }else{
            router.push('/station');
          };
        };

        const registerStation = async () => {
          if( ! formValid.value ){
            errorMessage.value = "Please correct validation errors before submitting"
            showDialog = true;
            return;
          }
          var record = {
            id: station.value.properties.wigos_station_identifier,  // WSI
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: [parseFloat(station.value.geometry.longitude),
                            parseFloat(station.value.geometry.latitude),
                            parseFloat(station.value.geometry.elevation)]
            },
            properties: {
              name: station.value.properties.name,
              wigos_station_identifier: station.value.properties.wigos_station_identifier,  // WSI
              traditional_station_identifier: station.value.properties.traditional_station_identifier,
              facility_type: station.value.properties.facility_type.id ? station.value.properties.facility_type.id : null,
              territory_name: station.value.properties.territory_name.id ? station.value.properties.territory_name.id : null,
              barometer_height: parseFloat(station.value.properties.barometer_height),
              wmo_region: station.value.properties.wmo_region.id ? station.value.properties.wmo_region.id : null,
              url: "https://oscar.wmo.int/surface/#/search/station/stationReportDetails/" +
                      station.value.properties.wigos_station_identifier,
              topics: station.value.properties.topics.map( (topic) => (topic.id)),
              status: station.value.properties.status.id ? station.value.properties.status.id : null,
              id: station.value.properties.wigos_station_identifier  // WSI
            }
          }
          var apiURL = `${import.meta.env.VITE_API_URL}/collections/stations/items`;
          var leaf = route.params.id ? "/" + route.params.id : "";
          apiURL = apiURL + leaf;
          const response = await fetch(apiURL, {
              method: route.params.id ? 'PUT' : 'POST',
              headers: {
                  'encode': 'json',
                  'Content-Type': 'application/geo+json',
                  'authorization': 'Bearer '+ token.value
              },
              body: JSON.stringify(record)
            });
          if (!response.ok) {
              console.log(record);
              console.error('HTTP error', response.status);
              errorMessage.value = "Error submitting record: "+response.status;
              showDialog.value = true;
          } else {
            errorMessage.value = "Station successfully submitted, redirecting to station list.";
            showDialog.value = true;
            setTimeout( () => {router.push("/station")}, 3000); // short pause to give backend time to catch up.
          }
        };

        const getElevation = async () => {
          var isValid = true;
          if ( isNaN( station.value.geometry.latitude ) || Math.abs(station.value.geometry.latitude) > 90 ){
            isValid = false;
          }
          if ( isNaN( station.value.geometry.longitude ) || Math.abs(station.value.geometry.longitude) > 180 ){
            isValid = false;
          }
          if( isValid ){
            var query = "https://api.opentopodata.org/v1/aster30m?locations=" +
                          station.value.geometry.latitude + "," +
                          station.value.geometry.longitude;
            const response = await fetch(query);
            if( !response.ok ){
              throw new Error(`HTTP error fetching elevation, Status: ${response.status}`);
            }else{
              const data = await response.json();
              station.value.geometry.elevation = data.results[0].elevation;
            }
          }else{
            msg.value = "Please enter a valid location before getting the elevation.";
            showDialog.value = true;
          }
        };

        onBeforeMount( async () => {
          if(route.query.action==="edit"){
            readonly.value = false;
          }else{
            readonly.value = true;
          }
          // fetch code lists
          var data = null;
          var response;
          await fetch("/code_lists/territory.json").then( (response) => response.json()).then( (data) => territoryOptions.value = data);
          await fetch("/code_lists/facilityType.json").then( (response) => response.json()).then( (data) => facilityTypeOptions.value = data);
          await fetch("/code_lists/operatingStatus.json").then( (response) => response.json()).then( (data) => operatingStatusOptions.value = data);
          await fetch("/code_lists/WMORegion.json").then( (response) => response.json()).then( (data) => WMORegionOptions.value = data);
        });

        onMounted( async () => {
          // load codes lists
          if (route.params.id){
            await loadStation( route.params.id );
          };
          if( ! station.value ){
            readonly.value = false;
            station.value = {
              id: null,  // WSI
              type: 'Feature',
              geometry: {
                type: 'Point',
                coordinates: [null,null,null]
              },
              properties: {
                name: null,
                wigos_station_identifier: null,  // WSI
                traditional_station_identifier: null,
                facility_type: {},
                territory_name: {},
                barometer_height: null,
                wmo_region: {},
                url: null,
                topics: [],
                status: {},
                id: null  // WSI
              }
            };
          }
        })

        // load station
        const loadStation = async (wsi) => {
          const apiURL = `${import.meta.env.VITE_API_URL}/collections/stations/items/${wsi}`;
          try {
            const response  = await fetch(apiURL);
            if (!response.ok && response.status !== 404){
              throw new Error(`HTTP error! Status: ${response.status}`);
            }else if(response.status === 404){
              errorMessage.value = "Station not found, please check the ID or register a new station."
              showDialog.value = true;
              router.push('/station/');
            } else{
              var data = await response.json();
              station.value = {
                id: data.id,  // WSI
                type: data.type,
                geometry: {
                  type: data.geometry.type,
                  coordinates: data.geometry.coordinates,
                  longitude: data.geometry.coordinates[0],
                  latitude: data.geometry.coordinates[1],
                  elevation: data.geometry.coordinates[2]
                },
                properties: {
                  name: data.properties.name,
                  wigos_station_identifier: data.properties.wigos_station_identifier,  // WSI
                  traditional_station_identifier: data.properties.traditional_station_identifier,
                  facility_type: data.properties.facility_type,
                  territory_name: data.properties.territory_name,
                  barometer_height: data.properties.barometer_height,
                  wmo_region: data.properties.wmo_region,
                  url: data.properties.url,
                  topics: JSON.parse(JSON.stringify(data.properties.topics)),
                  status: data.properties.status,
                  id: data.properties.id  // WSI
                }
              };
            }
          }
          catch (error) {
            errorMessage.value = "Error fetching station details, please check the API end point." +
                                  " See logs for more information.";
            console.error("Error fetching station details:", error)
          }
        }

        watch( (route), () => {
          if(route.query.action === "edit"){
            readonly.value = false;
          }else{
            readonly.value = true;
          }
        })

        const importOSCAR = async () => {
          if( station.value.properties.wigos_station_identifier ){
            const apiURL = `${import.meta.env.VITE_API_URL}/processes/wis2box-oscar2feature/execution`;
            // fetch via process
            const payload = {
              "inputs": {
                "wigos_station_identifier": station.value.properties.wigos_station_identifier
              }
            }
            try {
              const response = await fetch(
                apiURL, {
                  method: 'POST',
                  headers: {
                      'encode': 'json',
                      'Content-Type': 'application/json',
                      'authorization': 'Bearer '+ token.value
                  },
                  body: JSON.stringify(payload)
                }
              );
              if( ! response.ok ){
                console.log( response );
                errorMessage.value = "Error fetching form OSCAR/Surface: " + response.status;
                showDialog.value = true;
              }else{
                console.log( response );
                const data = await response.json();
                console.log(data)
                // this is currently broken, the drop down selectors are not updated when data are loaded via this route
                // we may want to import from oscar directly from the station table
                if( data.feature ){
                  station.value = {
                    id: data.feature.id,  // WSI
                    type: data.feature.type,
                    geometry: {
                      type: data.feature.geometry.type,
                      coordinates: data.feature.geometry.coordinates,
                      longitude: data.feature.geometry.coordinates[0],
                      latitude: data.feature.geometry.coordinates[1],
                      elevation: data.feature.geometry.coordinates[2]
                    },
                    properties: {
                      name: data.feature.properties.name,
                      wigos_station_identifier: data.feature.properties.wigos_station_identifier,  // WSI
                      traditional_station_identifier: data.feature.properties.traditional_station_identifier,
                      territory_name: territoryOptions.value.find( (item) => item.id === data.feature.properties.territory_name ),
                      barometer_height: data.feature.properties.barometer_height,
                      wmo_region: WMORegionOptions.value.find( (item) => item.id === data.feature.properties.wmo_region ),
                      url: data.feature.properties.url,
                      topics: JSON.parse(JSON.stringify(data.feature.properties.topics)),
                      status: operatingStatusOptions.value.find( (item) => item.id === data.feature.properties.status ),
                      id: data.feature.properties.id  // WSI
                    }
                  };
                  // update code list elements separately
                  selectedFacilityType.value = facilityTypeOptions.value.find( (item) => item.id === data.feature.properties.facility_type );
                  console.log(station.value);
                }else if (data.error){
                  errorMessage.value = JSON.stringify(data.error);
                  showDialog.value = true;
                }else{
                  errorMessage.value = "Unexpected response: " + JSON.stringify(data);
                  showDialog.value = true;
                }
              }
            } catch( error ) {
              errorMessage.value = "Error fetching from OSCAR/Surface: " + error;
              showDialog.value = true;
            }

          }
        };

        return {station, topics, registerStation, getElevation, showDialog, msg, rules, route, router,
          operatingStatusOptions, WMORegionOptions, territoryOptions, readonly, errorMessage, token, formValid,
          cancelEdit, importOSCAR, selectedFacilityType
        };
      }
    });
  </script>

