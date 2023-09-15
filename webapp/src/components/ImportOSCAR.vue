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
    <v-dialog v-model="showRedirect" width="auto">
      <v-card align="center">
        <v-card-text>{{redirectMessage}}</v-card-text>
        <v-card-text color-text="warning">{{redirectWarning}}</v-card-text>
        <v-card-actions align="center">
          <v-btn color="primary" @click='router.push("/station")' elevation=2>Cancel</v-btn>
          <v-btn color="warning" @click='router.push("/station/")'  elevation=2>Create new station</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-card max-width="1200px">
      <v-card-title>Import station from OSCAR/Surface</v-card-title>
      <v-card-item>
        <v-form>
          <v-text-field :rules="[rules.validWSI]" v-model="wsi" label="WIGOS Station Identifier" hint="Enter WIGOS Station Identifier" persistent-hint/>
          <!-- <v-text-field v-model="token" type="password" clearable label="Auth token"/> -->
          <v-card-actions align="center">
            <v-btn @click="submit">Search</v-btn>
          </v-card-actions>
        </v-form>
      </v-card-item>
    </v-card>
    <v-card v-if="station" max-width="1200px">
      <v-form v-model="formValid" align="left">
        <v-card-item>
          <v-text-field
            label="Station name"
            v-model="station.properties.name"
            :rules="[rules.validName]"
            readonly
            hint="Enter name of station" persistent-hint>
          </v-text-field>
        </v-card-item>
        <v-card-item>
          <v-text-field
            label="WIGOS station identifier"
            v-model="station.properties.wigos_station_identifier"
            :rules="[rules.validWSI]"
            readonly
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
            readonly
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
                  readonly
                  type="number"
                  hint="Enter the station longitude (degrees E)" persistent-hint/>
                </v-row>
                <v-row>
                  <v-text-field
                  label="Latitude (decimal degrees N), -90 to 90"
                  v-model="station.geometry.latitude"
                  :rules="[rules.validLatitude]"
                  readonly
                  type="number"
                  hint="Enter the station latitude (degrees N)" persistent-hint/>
              </v-row>
              <v-row>
                <v-text-field
                  label="Station elevation above sea level (metres)"
                  v-model="station.geometry.elevation"
                  :rules="[rules.validElevation]"
                  readonly
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
          <v-text-field v-model="station.properties.facility_type" readonly/>
        </v-card-item>
        <v-card-item>
          <v-text-field
            label="Barometer height above sea level"
            v-model="station.properties.barometer_height"
            :rules="[rules.validBarometerHeight]"
            readonly
            hint="Enter barometer height (metres)" persistent-hint type="number">
          </v-text-field>
        </v-card-item>
        <v-card-item><v-text-field  v-model="station.properties.wmo_region" readonly/></v-card-item>
        <v-card-item><v-text-field  v-model="station.properties.territory_name" readonly/></v-card-item>
        <v-card-item><v-text-field  v-model="station.properties.status" readonly/></v-card-item>
        <v-card-item>
          <v-text-field type="password" clearable v-model="token" label="Auth token"></v-text-field>
        </v-card-item>
        <v-card-actions>
          <v-btn @click="confirm()" elevation=2>Ingest and edit station</v-btn>
          <v-btn @click="router.push('/station')" elevation=2>Cancel</v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
  </v-sheet>
</template>
<script>
  import {defineComponent, ref} from "vue";
  import {VSheet, VCard, VCardTitle, VCardItem, VForm, VTextField, VBtn, VCardActions} from 'vuetify/lib/components/index.mjs';
  import {useRoute, useRouter} from 'vue-router';
  import LocatorMap from '@/components/LocatorMap.vue';

  export default defineComponent({
    name: "ImportOSCAR",
    components: {
      VSheet, VCard, VCardTitle, VCardItem, VForm, VTextField, VBtn, VCardActions, LocatorMap
    },
    setup(){
      const wsi = ref("");
      const station = ref(null);
      const errorMessage = ref(null);
      const showDialog = ref(false);
      const redirectMessage = ref(null);
      const redirectWarning = ref(null);
      const showRedirect = ref(false)
      const token = ref(null);
      const rules = ref({
        validWSI: value => /^0-[0-9]{1,5}-[0-9]{0,5}-[0-9a-zA-Z]{1,16}$/.test(value) || 'Invalid WSI'
      });
      const data = ref(null);
      const router = useRouter();
      const formValid = ref(null);

      const confirm = async () => {
        var apiURL = `${import.meta.env.VITE_API_URL}/collections/stations/items`;
        var leaf = "";
        apiURL = apiURL + leaf;
        try{
          const response = await fetch(apiURL, {
              method: 'POST',
              headers: {
                  'encode': 'json',
                  'Content-Type': 'application/geo+json',
                  'authorization': 'Bearer '+ token.value
              },
              body: JSON.stringify(station.value)
            });
          if (!response.ok) {
            console.log(record);
            console.error('HTTP error', response.status);
            errorMessage.value = "Error submitting record: "+response.status;
            showDialog.value = true;
          } else {
            errorMessage.value = "Station successfully submitted, redirecting to station viewer.";
            showDialog.value = true;
            setTimeout( () => {router.push("/station/"+wsi.value+"?action=view")}, 3000);
          }
        }catch{
          throw new Error(`HTTP error posting to API: ${response.status}`);
          errorMessage.value = JSON.stringify(response);
          showDialog.value = true;
        }
      };

      const submit = async () => {
        var apiURL = `${import.meta.env.VITE_API_URL}/processes/oscar2feature/execution`;
        var payload = {
              "inputs": {
                "wigos_station_identifier": wsi.value
              }
            };
        // get data
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
            console.log(response);
            errorMessage.value = "Error fetching form OSCAR/Surface via WIS2box API, please check status of the API and OSCAR/Surface. See console for more details.";
            console.error(response.status);
            showDialog.value = true;
          }else{
            data.value = await response.json();
          };
        } catch( error ) {
          errorMessage.value = "Error fetching form OSCAR/Surface via WIS2box API, please check status of the API and OSCAR/Surface. See console for more details.";
          console.log(error);
          showDialog.value = true;
        };
        if( data.value ){
          if( data.value.feature ){
            station.value = JSON.parse(JSON.stringify(data.value.feature));
            station.value.geometry.longitude = station.value.geometry.coordinates[0];
            station.value.geometry.latitude = station.value.geometry.coordinates[1];
            station.value.geometry.elevation = station.value.geometry.coordinates.length === 3 ?
                  station.value.geometry.coordinates[2] : null;
            console.log(station.value);

          }else if(data.value.error){
            redirectMessage.value = "Station not found in OSCAR, unable to import." +
                                    " Please register station in OSCAR/Surface and try again." ;
            redirectWarning.value = "For development and testing purposes stations can be created directly." +
                                    "To add a new station to the WIS2box please click the 'create new station' button";
            showRedirect.value = true;
          }else{
            errorMessage.value = "Unexpected response, see logs for further details.";
            console.error("Error fetching station details:", data.value);
            showDialog.value = true;
          }
        };
      };
      return {wsi, errorMessage, showDialog, rules, router, station, formValid, confirm,
          redirectMessage, redirectWarning, showRedirect, submit, token};
    }
  });
</script>
