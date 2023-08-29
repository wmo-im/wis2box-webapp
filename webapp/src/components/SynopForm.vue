<template>
  <v-row>
    <v-col cols="12">
      <!-- Form entry --><v-fade-transition appear>
        <v-card>
          <!-- Font size of title for tablets and desktops -->
          <div class="hidden-xs">
            <v-card-title class="big-title">Submit FM 12–XIV Ext. SYNOP Bulletin</v-card-title>
          </div>
          <!-- Font size of title for phones -->
          <div class="hidden-sm-and-up">
            <v-card-title class="small-title">Submit FM 12–XIV Ext. SYNOP Bulletin</v-card-title>
          </div>
          <v-card-text>
            <v-form>
              <v-card-item class="calendar-box">
                <VueDatePicker v-model="date" :teleport="true" :state="datePossible" month-picker auto-apply required />
                <p v-if="datePossible === false" class="hint-text hint-invalid">Date in the future: please choose a valid
                  month
                  and year
                </p>
                <p v-else-if="datePossible === true" class="hint-text hint-valid">Date valid</p>
                <p v-else class="hint-text hint-default">Month and year of the data</p>
              </v-card-item>
              <!-- Date selection -->

              <!-- FM 12 data entry -->
              <v-card-item>
                <v-textarea label="FM 12" v-model.lazy="bulletin" @change="checkMessage"></v-textarea>
                <p v-if="aaxxPresent == false" class="hint-text hint-invalid">AAXX must be present for a valid SYNOP
                  message
                </p>
                <p v-else-if="equalsPresent == false" class="hint-text hint-invalid">Delimiter (=) must be present for a
                  valid
                  SYNOP message</p>
                <p v-else class="hint-text hint-default">Raw FM 12 bulletin</p>
              </v-card-item>

              <!-- Topic hierarchy selection -->
              <v-card-item>
                <v-select label="Topic" v-model="topic" :items="topicList" v-if="topicList.length"
                  hint="Topic hierarchy for ingestion of data" persistent-hint></v-select>
              </v-card-item>

            </v-form>
            <v-card-item>
              <!-- Show switch above the submit button on mobile -->
              <v-switch class="hidden-sm-and-up"
                :disabled="(datePossible === false) || !aaxxPresent || !equalsPresent || !topic"
                v-model="notificationsOnPending" label="Publish on WIS2" color="primary" hide-details></v-switch>
              <div class="button-align">
                <v-btn :disabled="(datePossible === false) || !aaxxPresent || !equalsPresent || !topic"
                  append-icon="mdi-cloud-upload" :loading="loading" @click="submit">Submit
                  <template v-slot:loader>
                    <v-progress-linear indeterminate></v-progress-linear>
                  </template>
                </v-btn>
                <!-- Show switch on the right of submit button on tablet and desktop -->
                <v-switch class="hidden-xs"
                  :disabled="(datePossible === false) || !aaxxPresent || !equalsPresent || !topic"
                  v-model="notificationsOnPending" label="Publish on WIS2" color="primary" hide-details></v-switch>
              </div>
            </v-card-item>
          </v-card-text>
        </v-card>
      </v-fade-transition>
    </v-col>
  </v-row>

  <v-row>
    <v-col cols="12">
      <!-- Output data -->
      <v-card v-if="result">
        <v-card-title>{{ resultTitle }}</v-card-title>

        <v-list>

          <v-list-item class="hint-default">
            {{ numberNotifications }}</v-list-item>

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
                <span class="warning-color">Warnings: {{ result.warnings.length }}</span>
              </v-list-item>
            </template>

            <v-list-item v-for="(warning, index) in result.warnings" :key="index" class="warning-item">
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
                <span class="error-color">Errors: {{ result.errors.length }}</span>
              </v-list-item>
            </template>

            <v-list-item v-for="(error, index) in result.errors" :key="index" class="error-item">
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
                <span :style="{ color: '#00BD9D' }">Output BUFR files: {{ result.files.length }}</span>
              </v-list-item>

            </template>
            <v-list-item v-for="(file_url, index) in result.files" :key="index">
              <!-- Place download and inspect buttons on the right of the file names for tablet and desktop -->
              <div class="hidden-xs">
                <div class="file-actions">
                  <div>
                    {{ getFileName(file_url) }}
                  </div>
                  <div class="file-actions">
                    <DownloadButton :fileUrl="file_url" />
                    <InspectBufrButton :fileUrl="file_url" />
                  </div>
                </div>
              </div>
              <!-- Place download and inspect buttons below the file names for mobile -->
              <div class="hidden-sm-and-up">
                <div>
                  <div>
                    {{ getFileName(file_url) }}
                  </div>
                  <div class="file-actions">
                    <DownloadButton :fileUrl="file_url" />
                    <InspectBufrButton :fileUrl="file_url" />
                  </div>
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
    </v-col>
  </v-row>
</template>
  
<script>
import { defineComponent } from 'vue';
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
    api: {
      type: String,
      default: 'api.opencdms.org'
    },
    path: {
      type: String,
      default: '/processes/wis2box-synop-process/execution'
    }
  },
  data() {
    // Default data values before reactivity
    return {
      // Current month/year to compare against user selection
      date: {
        month: new Date().getMonth(),
        year: new Date().getFullYear()
      },
      datePossible: null, // Verifies entered date is not in the future
      bulletin: "", // FM 12 data
      aaxxPresent: true, // Boolean to check if AAXX is in bulletin
      equalsPresent: true, // Boolean to check if = delimiter is in bulletin
      topicList: ["test1", "test2", "test3"], // List of topic hierarchies 
      // before they are obtained from discovery metadata
      topic: "", // Topic hierarchy selected by user
      notificationsOnPending: true, // Realtime variable for if user has 
      // selected notifications or not
      notificationsOn: true, // Variable that updates to the pending variable 
      // when the user has submitted
      loading: false, // Boolean for the loading animation
      input: null, // JSON object for the concatenated user inputs
      result: null // Output from synop2bufr call
    }
  },
  computed: {
    // Computes the result title re: success, partial success, or failure
    resultTitle() {
      if (this.result && this.result.result) {
        const resultKey = this.result.result;
        return "Result: " + resultKey;
      }
      return "Unknown"
    },
    // Computes how many WIS2 notifications were made, depending on
    // whether the user has selected the notification toggle or not
    numberNotifications() {
      let messagesPublished;
      if (this.result && this.notificationsOn === true) {
        messagesPublished = this.result["messages published"];
      }
      else {
        messagesPublished = 0;
      }
      return "WIS2 notifications published: " + messagesPublished;
    }
  },
  methods: {
    // Check if AAXX and = delimiter present in the FM 12 data entered
    checkMessage() {
      this.aaxxPresent = this.bulletin.includes('AAXX ');
      this.equalsPresent = this.bulletin.includes('=');
    },
    // Allows us to get the current topic hierarchies available
    async fetchTopics() {
      const apiUrl = `${import.meta.env.VITE_API_URL}/collections/discovery-metadata/items?f=json`;
      // check if TEST=True is set in .env file
      console.log(import.meta.env);
      // check if TEST_MODE is set in .env file or if VITE_API_URL is not set
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        console.log("TEST_MODE is enabled");
        this.topicList = ["test1", "test2", "test3"];
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
            // If the features object is in the data
            if (data.features) {
              // Use Array.map to create a new array of the topic hierarchies
              this.topicList = data.features.map(feature => {
                if (feature.properties && feature.properties['wmo:topicHierarchy']) {
                  return feature.properties['wmo:topicHierarchy']
                }
              });
              console.log(this.topicList)
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
    },
    // Simulated output response in test environment representing a success
    testSuccessResult() {
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
      this.result = testData;
    },
    // Simulated output response in test environment representing a partial
    // success
    testPartialSuccessResult() {
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
      this.result = testData;
    },
    // Simulated output response in test environment representing a failure
    testFailureResult() {
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
      this.result = testData;
    },
    // Pushing the user input to the synop2bufr process
    async callSynop2Bufr() {
      var payload = {
        inputs: {
          data: this.bulletin, // Raw FM 12 data
          year: this.date.year, // Year of data
          month: this.date.month + 1, // Month of data, +1 as JS starts 
          // from 0 for months
          channel: this.topic, // Topic hierarchy
          notify: this.notificationsOn // Boolean for WIS2 notifications
        }
      };

      const synopUrl = `${import.meta.env.VITE_API_URL}/processes/wis2box-synop-process/execution`

      console.log(payload);
      console.log(synopUrl);
      this.input = payload;

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
        this.result = {
          "result": "API error",
          "errors": [
            synopUrl + " returned " + response.status
          ]
        };
      } else {
        const data = await response.json();
        this.result = data;
        console.log("Result:"); // TODO: Remove this line
        console.log(this.result); // TODO: Remove this line
      }
    },
    // Method for when the user presses the submit button, including
    // a loading animation, obtaining the result, 
    async submit() {
      // Start loading animation
      this.loading = true;

      // Set result back to null
      this.result = null;

      // Update whether the user wants WIS2 notifications
      this.notificationsOn = this.notificationsOnPending;

      // Check if bulletin contains the word success, failure or partial success
      if (this.bulletin.includes("success")) {
        this.testSuccessResult();
      } else if (this.bulletin.includes("partial")) {
        this.testPartialSuccessResult();
      } else if (this.bulletin.includes("failure")) {
        this.testFailureResult();
      } else {
        // Otherwise, call the synop2bufr process
        await this.callSynop2Bufr();
      }

      await new Promise(r => setTimeout(r, 200)) // Artificial delay to test loading

      // End loading animation
      this.loading = false;
    },
    // Get filename from output BUFR files so it can be displayed on screen
    getFileName(url) {
      const urlParts = url.split('/');
      return urlParts[urlParts.length - 1];
    }
  },
  watch: {
    date: {
      deep: true,
      handler(newVal) {
        const today = new Date();
        today.setHours(0, 0, 0, 0)

        if (newVal) {
          const selectedDate = new Date(newVal.year, newVal.month)
          // If selected date is before now, then it is possible
          this.datePossible = (selectedDate.getTime() <= today.getTime());
        }
        else {
          this.datePossible = null;
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
    VListGroup,
    VueDatePicker,
    InspectBufrButton,
    DownloadButton
  },
  mounted() {
    this.fetchTopics();
  }
});
</script>

<style scoped>
.big-title {
  font-size: 1.4rem;
  font-weight: 700;
}

.small-title {
  font-size: 1.1rem;
  font-weight: 700;
}

.calendar-box {
  width: 250px;
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

.button-align {
  display: flex;
  align-items: center;
  gap: 20px;
}

.warning-color {
  color: #FD9235
}

.warning-item {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px;
  background-color: #FEC89A
}

.error-color {
  color: #EA4848
}

.error-item {
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px;
  background-color: #F08080
}


.file-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px;
}

.divider-spacing {
  margin-top: 10px;
}</style>