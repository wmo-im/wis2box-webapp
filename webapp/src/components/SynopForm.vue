<template>
  <v-card class="card">
    <v-card-title>Submit FM 12–XIV Ext. SYNOP Bulletin</v-card-title>
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
          <v-select label="Channel" v-model="hierarchy" :items="hierarchyList" v-if="hierarchyList.length"
            hint="Topic hierarchy for ingestion of data" persistent-hint></v-select>
        </v-card-item>

      </v-form>
      <v-card-item>
        <v-btn class="submit-button" :disabled="(datePossible === false) || !aaxxPresent || !equalsPresent || !hierarchy"
          @click="submit">Submit</v-btn>
      </v-card-item>
    </v-card-text>
  </v-card>

  <v-card v-if="result">
    <v-card-title>{{ getResultTitle() }}</v-card-title>

    <v-list>

      <!-- WARNINGS -->
      <!-- Warnings drop-down if there are any warnings -->
      <v-list-group v-if="result.warnings && result.warnings.length > 0" ref="warningList" value="Warnings"
        @click="scrollToRef('warningList')">
        <template v-slot:activator="{ props }">
          <v-list-item v-bind="props" prepend-icon="mdi-alert-circle">
            <template v-slot:prepend>
              <v-icon color="#FD9235"></v-icon>
            </template>
            <!-- If number of warnings > 0, set text to orange -->
            <v-list-item-content :style="{ color: '#FD9235' }">
              <span>Warnings: {{ result.warnings.length }}</span>
            </v-list-item-content>
          </v-list-item>
        </template>

        <v-list-item v-for="(warning, index) in result.warnings" :key="index" class="error-item"
          :style="{ backgroundColor: '#FEC89A' }">
          {{ warning }}
        </v-list-item>
      </v-list-group>

      <!-- Warnings drop-down if there are no warnings -->
      <v-list-item v-else prepend-icon="mdi-alert-circle">
        <span>Warnings: 0</span>
      </v-list-item>


      <!-- ERRORS -->
      <!-- Errors drop-down if there are any errors -->
      <v-list-group v-if="result.errors && result.errors.length > 0" ref="errorList" value="Errors"
        @click="scrollToRef('errorList')">
        <template v-slot:activator="{ props }">
          <v-list-item v-bind="props" prepend-icon="mdi-close-circle">
            <template v-slot:prepend>
              <v-icon color="#EA4848"></v-icon>
            </template>
            <!-- If number of errors > 0, set text to red -->
            <v-list-item-content :style="{ color: '#EA4848' }">
              <span>Errors: {{ result.errors.length }}</span>
            </v-list-item-content>
          </v-list-item>
        </template>

        <v-list-item v-for="(error, index) in result.errors" :key="index" class="error-item"
          :style="{ backgroundColor: '#F08080' }">
          {{ error }}
        </v-list-item>
      </v-list-group>

      <!-- Errors drop-down if there are no warnings -->
      <v-list-item v-else prepend-icon="mdi-close-circle">
        <span>Errors: 0</span>
      </v-list-item>


      <!-- OUTPUT BUFR -->
      <!-- BUFR files drop-down if there are any output files -->
      <v-list-group v-if="result.files && result.files.length > 0" ref="fileList" value="Files"
        @click="scrollToRef('fileList')">
        <template v-slot:activator="{ props }">
          <v-list-item v-bind="props" prepend-icon="mdi-check-circle">
            <template v-slot:prepend>
              <v-icon color="#00BD9D"></v-icon>
            </template>
            <!-- If number of BUFR files > 0, set text to green -->
            <v-list-item-content :style="{ color: '#00BD9D' }">
              <span>Output BUFR files: {{ result.files.length }}</span>
            </v-list-item-content>
          </v-list-item>

        </template>
        <v-list-item v-for="(file_url, index) in result.files" :key="index" class="file-item">
          <div class="file-info-wrapper" style="display: flex; align-items: center; justify-content: space-between;">
            <div class="file-info" style="margin-right: 15px">
              {{ getFileName(file_url) }}
            </div>
            <div class="file-actions" style="display: flex">
              <DownloadButton :fileUrl="file_url" />
              <InspectBufrButton :fileUrl="file_url" />
            </div>
          </div>
          <v-divider v-if="index < result.files.length - 1" class="divider-spacing"></v-divider>
        </v-list-item>
      </v-list-group>

      <!-- BUFR files drop-down if there are no warnings -->
      <v-list-item v-else prepend-icon="mdi-check-circle">
        <span>Output BUFR files: 0</span>
      </v-list-item>


    </v-list>

  </v-card>
</template>
  
<script>
import { defineComponent, ref, watch } from 'vue';
import { VCard, VCardTitle, VCardText, VCardItem, VForm, VTextarea, VBtn, VSelect, VListGroup } from 'vuetify/lib/components/index.mjs';
import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';
import InspectBufrButton from '@/components/InspectBufrButton.vue';
import DownloadButton from '@/components/DownloadButton.vue';

export default defineComponent({
  name: 'RoleForm',
  props: {
    broker: {
      type: String,
      default: ''
    },
    channel: {
      type: String,
      default: ''
    },
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
      console.log(import.meta.env);
      // check if TEST_MODE is set in .env file or if VITE_API_URL is not set
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        console.log("TEST_MODE is enabled");
        this.hierachyList = ["test1", "test2", "test3"];
      }
      else {
        console.log("Fetching topic hierarchy from:", apiUrl);
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
              console.log(this.hierarchyList)
            }
            else {
              console.error("API response is not an object");
            }
          }
        }
        catch (error) {
          console.error("Error fetching topic hierarchy:", error)
        }
      }
    },
    // When the user clicks on one of the expandable lists such as
    // the output BUFR files, this method force scrolls the page down
    // so that the content is not accidentally missed by the user
    scrollToRef(refName) {
      setTimeout(() => {
        this.$refs[refName].$el.scrollIntoView({ behavior: 'smooth' });
      }, 200); // 200ms delay to allow the list to render before scrolling
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
    VListGroup,
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

    const hierarchyList = ref(["test1", "test2", "test3"]); // List of topic hierarchies for drop down
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
        "result": "Success",
        "messages transformed": 2,
        "messages published": 2,
        "files": [
          "http://3.73.37.35/data/2023-12-17/wis/synop/test/WIGOS_0-20000-0-15015_20231217T120000.bufr4",
          "http://3.73.37.35/data/2023-12-17/wis/synop/test/WIGOS_0-20000-0-15020_20231217T120000.bufr4"
        ],
        "warnings": [],
        "errors": []
      }
      // Update the result variable with the test data
      result.value = testData;
    };

    const testFailureResult = () => {
      // Simulated response data
      const testData = {
        "result": "Failure",
        "messages transformed": 0,
        "messages published": 0,
        "files": [],
        "warnings": [],
        "errors": [
          "Error converting to BUFR: local variable 'messages' referenced before assignment",
          "No SYNOP messages converted"
        ]
      };
      // Update the result variable with the test data
      result.value = testData;
    };

    const testPartialSuccessResult = () => {
      // Simulated response data
      const testData = {
        "result": "Partial Success",
        "messages transformed": 1,
        "messages published": 1,
        "files": [
          "http://3.73.37.35/data/2023-12-17/wis/synop/test/WIGOS_0-20000-0-15015_20231217T120000.bufr4"
        ],
        "warnings": [
          "Missing station height for station 15090",
          "Station 15108 not found in station metadata list",
        ],
        "errors": []
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

      // Build a new variable with result metadata
      const notificationData = {
        numFiles: (this.result).files.length,
        numWarnings: (this.result).warnings.length,
        numErrors: (this.result).errors.length,
        timestamp: new Date().toLocaleString()
      };

      // Emit result tp parent component so that information
      // can be used by the WIS2 Notfications component
      this.$emit('bufr-published', notificationData);

    };
    const callSynop2Bufr = async () => {
      var payload = {
        inputs: {
          data: bulletin.value,
          year: date.value.year,
          month: date.value.month + 1, // +1 as JS starts from 0 for months
          channel: hierarchy.value
        }
      };

      const synopUrl = `${import.meta.env.VITE_API_URL}/processes/wis2box-synop-process/execution`

      console.log(payload);
      console.log(synopUrl);
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
        console.log("Result:"); // TODO: Remove this line
        console.log(result.value); // TODO: Remove this line
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
.card {
  margin-bottom: -10px;
  /* ALlows the first and second card to blend together slightly */
}

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

.submit-button {
  margin-bottom: 10px;
}

.file-item,

.error-item {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px;
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

.divider-spacing {
  margin-top: 25px;
  /* adjust the value as needed */
}
</style>