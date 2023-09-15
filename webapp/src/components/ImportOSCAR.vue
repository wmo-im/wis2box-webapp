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
        <v-card-text>{{redirectWarning}}</v-card-text>
        <v-card-actions>
          <v-btn color="primary" @click='router.push("/station")'>Cancel</v-btn>
          <v-btn color="warning" @click='router.push("/station/")'>Create new station</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-card>
      <v-card-title>Import station from OSCAR/Surface</v-card-title>
      <v-card-item>
        <v-form>
          <v-text-field :rules="[rules.validWSI]" v-model="wsi" label="WIGOS Station Identifier" hint="Enter WIGOS Station Identifier" persistent-hint/>
          <v-text-field v-model="token" type="password" clearable label="Auth token"/>
          <v-card-actions>
            <v-btn @click="submit">Submit</v-btn>
          </v-card-actions>
        </v-form>
      </v-card-item>
    </v-card>
  </v-sheet>
</template>
<script>
  import {defineComponent, ref} from "vue";
  import {VSheet, VCard, VCardTitle, VCardItem, VForm, VTextField, VBtn, VCardActions} from 'vuetify/lib/components/index.mjs';
  import {useRoute, useRouter} from 'vue-router';

  export default defineComponent({
    name: "ImportOSCAR",
    components: {
      VSheet, VCard, VCardTitle, VCardItem, VForm, VTextField, VBtn, VCardActions
    },
    setup(){
      const wsi = ref(null);
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
            errorMessage.value = "Error fetching form OSCAR/Surface: " + response.status;
            showDialog.value = true;
          }else{
            data.value = await response.json();
          };
        } catch( error ) {
          errorMessage.value = "Error fetching from OSCAR/Surface: " + error;
          console.log("Error fetching from OSCAR/Surface: " + error);
          showDialog.value = true;
        };



        if( data.value ){
          if( data.value.feature ){
            station.value = JSON.parse(JSON.stringify(data.value.feature))
            console.log(station.value);
            var apiURL = `${import.meta.env.VITE_API_URL}/collections/stations/items`;
            var leaf = "";
            apiURL = apiURL + leaf;
            try{
              const response2 = await fetch(apiURL, {
                  method: 'POST',
                  headers: {
                      'encode': 'json',
                      'Content-Type': 'application/geo+json',
                      'authorization': 'Bearer '+ token.value
                  },
                  body: JSON.stringify(station.value)
                });
              if (!response2.ok) {
                console.log(record);
                console.error('HTTP error', response2.status);
                errorMessage.value = "Error submitting record: "+response2.status;
                showDialog.value = true;
              } else {
                errorMessage.value = "Station successfully submitted, redirecting to station editor.";
                showDialog.value = true;
                setTimeout( () => {router.push("/station/"+wsi.value+"?action=edit")}, 3000);
              }
            }catch{
              throw new Error(`HTTP error posting to API: ${response2.status}`);
              errorMessage.value = JSON.stringify(response2);
              showDialog.value = true;
            }
          }else if(data.value.error){
            redirectMessage.value = "Station not found in OSCAR, unable to import," +
                                    "please register station in OSCAR/Surface and try again." ;
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
      return {wsi, errorMessage, showDialog, rules, router,
          redirectMessage, redirectWarning, showRedirect, submit, token};
    }
  });
</script>
