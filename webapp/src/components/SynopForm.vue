<template>
  <v-card>
    <v-card-title>Submit FM 12–XIV Ext. SYNOP bulletin</v-card-title>
    <v-card-text>
      <v-form>

        <!-- Date selection -->
        <v-card-item style="width:250px">
          <VueDatePicker v-model="date" :teleport="true" :state="datePossible" month-picker auto-apply required />
          <p v-if="datePossible === false" class="hint-text hint-invalid">Date in the future: please choose a valid month
            and year
          </p>
          <p v-else-if="datePossible === true" class="hint-text hint-valid">Date valid</p>
          <p v-else class="hint-text hint-default">Month and year of the data</p>
        </v-card-item>

        <!-- FM 12 data entry -->
        <v-card-item>
          <v-textarea label="FM 12" v-model.lazy="bulletin" @change="checkMessage"></v-textarea>
          <p v-if="aaxxPresent == false" class="hint-text hint-invalid">AAXX must be present for a valid SYNOP message</p>
          <p v-else-if="equalsPresent == false" class="hint-text hint-invalid">Delimiter (=) must be present for a valid
            SYNOP message</p>
          <p v-else class="hint-text hint-default">Raw FM 12 bulletin</p>
        </v-card-item>

        <!-- Topic hierarchy selection -->
        <v-card-item>
          <v-select label="Topic" v-model="hierarchy" :items="hierarchyList" v-if="hierarchyList.length" hint="Topic hierarchy for ingestion of data" persistent-hint></v-select>
        </v-card-item>

      </v-form>
      <v-btn :disabled="(datePossible === false) || !aaxxPresent || !equalsPresent || !hierarchy"
        @click="submit">Submit</v-btn>
    </v-card-text>
  </v-card>

<v-card v-if="result">
  <v-card-title>{{ getResultTitle() }}</v-card-title>
  <v-card-item v-for="(error, index) in result.errors" :key="index" class="error-item">
    {{ error }}
  </v-card-item>
  <v-card-item v-for="(warning, index) in result.warnings" :key="index" class="warning-item">
    {{ warning }}
  </v-card-item>
  <v-card-item v-for="(file_url, index) in result.files" :key="index" class="file-item">
    <div class="file-info">
      {{ getFileName(file_url) }}
    </div>
    <div class="file-actions">
      <DownloadButton :fileUrl="file_url"/>
      <InspectBufrButton :fileUrl="file_url"/>
    </div>
  </v-card-item>
</v-card>

</template>
  
<script>
import { defineComponent, ref, watch } from 'vue';
import { VCard, VCardTitle, VCardText, VCardItem, VForm, VTextarea, VBtn, VSelect } from 'vuetify/lib/components/index.mjs';
import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';
import InspectBufrButton from '@/components/InspectBufrButton.vue';
import DownloadButton from '@/components/DownloadButton.vue';

export default defineComponent({
  name: 'RoleForm',
  props: {
    api: {
      type: String,
      default: 'api.opencdms.org'
    },
    path: {
      type: String,
      default: '/processes/wis2box-synop-process/execution'
    }
  },
  mounted() {
    this.fetchHierarchy();
  },
  methods: {
    // Check if AAXX and = delimiter present in the FM 12 data entered
    checkMessage() {
      this.aaxxPresent = this.bulletin.includes('AAXX ');
      this.equalsPresent = this.bulletin.includes('=');
    },  
    // Allows us to get the current topic hierarchies available
    async fetchHierarchy() {
      const apiUrl = `${import.meta.env.VITE_API_URL}/collections/discovery-metadata/items?f=json`;
      // check if TEST=True is set in .env file
      // check if TEST_MODE is set in .env file or if VITE_API_URL is not set
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        console.log("TEST_MODE is enabled");
        this.hierachyList = ["test1", "test2", "test3"];
      }
      else {
        try {
          const response = await fetch(apiUrl);
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }
          else {
            const data = await response.json();
            if (data.features) {
              // Use Array.map to create a new array of the topic hierarchies
              this.hierarchyList = data.features.map(feature => {
                if (feature.properties && feature.properties['wmo:topicHierarchy']) {
                  return feature.properties['wmo:topicHierarchy']
                }
              });
            }
            else {
              console.error("API response does not contain features:", data);
            }
          }
        }
        catch (error) {
          console.error("Error fetching topic hierarchy:", error)
        }
      }
    }
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
    VueDatePicker,
    InspectBufrButton,
    DownloadButton
  },
  setup(props) {
    const date = ref({
      month: new Date().getMonth(),
      year: new Date().getFullYear()
    }); // Default is current month and year
    const datePossible = ref(null) // Boolean for if date is possible

    const bulletin = ref(""); // SYNOP message string
    const aaxxPresent = ref(true); // Boolean for if AAXX present in data
    const equalsPresent = ref(true); // Boolean for if = delimiter present

    const hierarchyList = ref(["test1","test2","test3"]); // List of topic hierarchies for drop down
    const hierarchy = ref(""); // Topic hierarchy of transformed data

    const input = ref(null); // Concatenation of user inputs
    const result = ref(null); // Output from synop2bufr

    // Watch to verify that the selected month+year combination is possible
    watch(date, (newVal) => {
      const today = new Date();
      today.setHours(0, 0, 0, 0)

      if (newVal) {
        const selectedDate = new Date(newVal.year, newVal.month)
        datePossible.value = (selectedDate.getTime() <= today.getTime()); // If selected date is before now, then it is possible
      }
      else {
        datePossible.value = null;
      }
    });

    const testSuccessResult = () => {
      // Simulated response data
      const testData = {
        "result": "success",
        "messages transformed": 2,
        "messages published": 2,
        "files": [
          "http://3.73.37.35/data/2023-12-17/wis/synop/test/WIGOS_0-20000-0-15015_20231217T120000.bufr4",
          "http://3.73.37.35/data/2023-12-17/wis/synop/test/WIGOS_0-20000-0-15020_20231217T120000.bufr4"
        ],
        "errors": [],
        "warnings": []	
      }
      // Update the result variable with the test data
      result.value = testData;
    };

    const testFailureResult = () => {
      // Simulated response data
      const testData = {
        "result": "failure",
        "messages transformed": 0,
        "messages published": 0,
        "files": [],
        "errors": [
          "AAXX 17181 15015 01598 8270 10039 20026 39397 42633 58006 60022 70282 8657/ 333 10066 20029 31010 4/000 55300 0//// 20000 3//// 69917 91002 91104. __str__ returned non-string (type InvalidGroup)!"
        ],
        "warnings": [
          "Station 112345 not found in station file"
        ]	
      };
      // Update the result variable with the test data
      result.value = testData;
    };

    const testPartialSuccessResult = () => {
      // Simulated response data
      const testData = {
        "result": "partial success",
        "messages transformed": 1,
        "messages published": 1,
        "files": [
          "http://3.73.37.35/data/2023-12-17/wis/synop/test/WIGOS_0-20000-0-15015_20231217T120000.bufr4"
        ],
        "errors": [
          "AAXX 17181 15015 01598 8270 10039 20026 39397 42633 58006 60022 70282 8657/ 333 10066 20029 31010 4/000 55300 0//// 20000 3//// 69917 91002 91104. __str__ returned non-string (type InvalidGroup)!"
        ],
        "warnings": [
          "Station 112345 not found in station file"
        ]	
      };
      // Update the result variable with the test data
      result.value = testData;
    };

    // function to submit data and call synop2bufr process
    const submit = async () => {
      // set result back to null
      result.value = null;
      
      // check if bulletin contains the work success, failure or partial success
      if (bulletin.value.includes("partial")) {
        testPartialSuccessResult();
      } else if (bulletin.value.includes("failure")) {
        testFailureResult();
      } else if (bulletin.value.includes("success")) {
        testSuccessResult();
      } else {
        // if not, then call the synop2bufr process
        await callSynop2Bufr();
      }
    };
    const callSynop2Bufr = async () => {
      var payload = {
        inputs: {
          data: bulletin.value,
          year: date.value.year,
          month: date.value.month + 1, // +1 as JS starts from 0 for months
          channel: hierarchy.value,
          // topicHierarchy: hierarchy.value, // not sure how the synop2bufr process will handle topic hierarchy yet
        }
      };

      const synopUrl = `${import.meta.env.VITE_API_URL}/processes/wis2box-synop-process/execution`

      input.value = payload;

      const response = await fetch(synopUrl, {
        method: 'POST',
        headers: {
          'encode': 'json',
          'Content-Type': 'application/geo+json'
        },
        body: JSON.stringify(payload)
      });

      if (!response.ok) {
        console.error('HTTP error', response.status);
        result.value = {
          "result": "API error",
          "errors": [
            synopUrl + " returned " + response.status
          ]
        };
      } else {
        const data = await response.json();
        result.value = data;
      }

    };
    // Get the title text for the result card based on the "result" key value
    const getResultTitle = () => {
      if (result.value && result.value.result) {
        const resultKey = result.value.result;
        return "Result: " + resultKey;
      }
      return 'Unknown';
    };
    const getFileName = (url) => {
      const urlParts = url.split('/');
      return urlParts[urlParts.length - 1];
    };
    return {
      date,
      datePossible,
      bulletin,
      aaxxPresent,
      equalsPresent,
      hierarchyList,
      hierarchy,
      input,
      submit,
      result,
      getResultTitle,
      getFileName
    }
  }
});
</script>

<style scoped>
.hint-text {
  font-size: 0.75rem;
  margin-top: 0.25rem;
  padding-left: 1rem;
}

.hint-default {
  color: #888;
}

.hint-valid {
  color: green;
}

.hint-invalid {
  color: red;
}

.file-item,
.warning-item,
.error-item {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px;
}

.file-item {
  background-color: lightgreen;
}

.error-item {
  background-color: lightcoral
}

.warning-item {
  background-color: wheat;
}

.file-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-weight: bold;
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