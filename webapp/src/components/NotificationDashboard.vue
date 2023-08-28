<template>
  <!-- Dashboard -->
  <v-row>
      <v-col cols="12">
  
        <!-- For desktop and laptop users -->
        <v-row class="hidden-md-and-down">
          <!-- ApexCharts bar graph for latest notifications received -->
          <v-col cols="6">
            <v-fade-transition appear>
              <v-card>
  
                <v-card-title class="text-center">
                  Notifcations
                </v-card-title>
  
                <vue-apex-charts ref="chart" type="bar" height="400" :options="chartOptions"
                  :series="chartSeries"></vue-apex-charts>
              </v-card>
            </v-fade-transition>
          </v-col>
  
          <v-col cols="6">
            <!-- Top right -->
            <v-row>
              <!-- Total number of publications submitted in the last hour -->
              <v-col cols="6">
                <v-fade-transition appear>
  
                  <v-card>
                    <v-card-title class="text-center text-wrap">
                      Total publications in last hour:
                    </v-card-title>
                    <h1 class="text-center">{{ summaryStats.totalFilesLastHour }}</h1>
                  </v-card>
                </v-fade-transition>
              </v-col>
  
              <!-- Total number of publications submitted in the last 24 hours -->
              <v-col cols="6">
                <v-fade-transition appear>
                  <v-card>
                    <v-card-title class="text-center text-wrap">
                      Total publications in last 24 hours:
                    </v-card-title>
                    <h1 class="text-center">{{ summaryStats.totalFilesLastDay }}</h1>
                  </v-card>
                </v-fade-transition>
              </v-col>
            </v-row>
  
            <!-- Bottom right -->
            <!-- Latest files published, ready to download and inspect -->
            <v-row>
              <v-col cols="12">
                <v-fade-transition appear>
                  <v-card>
                    <v-card-title class="text-left">
                      Published Data
                    </v-card-title>
                    <!-- Limit the size of the list and add scroll feature -->
                    <div class="scrollable-file-list">
                      <v-text-field v-model="fileSearch" placeholder="Search for a file..." clearable />
                      <v-list-item v-for="(file_url, index) in filteredFileUrls.reverse()" :key="index">
                        <div class="file-actions">
                          <div>
                            <!-- Display the timestamp -->
                            <div class="secondary">
                              {{ formatTime(filteredPublishTimes[filteredPublishTimes.length - 1 -index])
                              }}
                            </div>
  
                            <!-- Display the file name -->
                            <div>
                              {{ getFileName(file_url) }}
                            </div>
                          </div>
                          <div class="file-actions">
                            <DownloadButton :fileUrl="file_url" />
                            <InspectBufrButton :fileUrl="file_url" />
                          </div>
                        </div>
                        <v-divider v-if="index < notificationData.fileUrls.length - 1" class="divider-spacing"></v-divider>
                      </v-list-item>
                    </div>
                  </v-card>
                </v-fade-transition>
              </v-col>
            </v-row>
  
          </v-col>
        </v-row>

        <!-- For mobile and tablet users -->
        <v-row class="hidden-lg-and-up">
          <!-- ApexCharts bar graph for latest notifications received -->
          <v-col cols="12">
            <v-fade-transition appear>
              <v-card>
  
                <v-card-title class="text-center">
                  Notifcations
                </v-card-title>
  
                <vue-apex-charts ref="chart" type="bar" height="400" :options="chartOptions"
                  :series="chartSeries"></vue-apex-charts>
              </v-card>
            </v-fade-transition>
          </v-col>
  
          <v-col cols="12">
            <!-- Below ApexCharts, include more data -->

            <!-- Mobile view (publication statistics aligned vertically) -->
            <v-row class="hidden-sm-and-up">
              <!-- Total number of publications submitted in the last hour -->
              <v-col cols="12">
                <v-fade-transition appear>
                  <v-card>
                    <v-card-title class="text-center text-wrap">
                      Total publications in last hour:
                    </v-card-title>
                    <h1 class="text-center">{{ summaryStats.totalFilesLastHour }}</h1>
                  </v-card>
                </v-fade-transition>
              </v-col>
  
              <!-- Total number of publications submitted in the last 24 hours -->
              <v-col cols="12">
                <v-fade-transition appear>
                  <v-card>
                    <v-card-title class="text-center text-wrap">
                      Total publications in last 24 hours:
                    </v-card-title>
                    <h1 class="text-center">{{ summaryStats.totalFilesLastDay }}</h1>
                  </v-card>
                </v-fade-transition>
              </v-col>
            </v-row>

            <!-- Tablet view (publication statistics aligned horizontally) -->
            <v-row class="hidden-xs">
              <!-- Total number of publications submitted in the last hour -->
              <v-col cols="6">
                <v-fade-transition appear>
                  <v-card>
                    <v-card-title class="text-center text-wrap">
                      Total publications in last hour:
                    </v-card-title>
                    <h1 class="text-center">{{ summaryStats.totalFilesLastHour }}</h1>
                  </v-card>
                </v-fade-transition>
              </v-col>
  
              <!-- Total number of publications submitted in the last 24 hours -->
              <v-col cols="6">
                <v-fade-transition appear>
                  <v-card>
                    <v-card-title class="text-center text-wrap">
                      Total publications in last 24 hours:
                    </v-card-title>
                    <h1 class="text-center">{{ summaryStats.totalFilesLastDay }}</h1>
                  </v-card>
                </v-fade-transition>
              </v-col>
            </v-row>
  
            <!-- Latest files published, ready to download and inspect -->
            <v-row>
              <v-col cols="12">
                <v-fade-transition appear>
                  <v-card>
                    <v-card-title class="text-left">
                      Published Data
                    </v-card-title>
                    <!-- Limit the size of the list and add scroll feature -->
                    <div class="scrollable-file-list">
                      <v-text-field v-model="fileSearch" placeholder="Search for a file..." clearable />
                      <v-list-item v-for="(file_url, index) in filteredFileUrls.reverse()" :key="index">
                        <!-- Tablet view (download and inspect to the right of file name) -->
                        <div class="hidden-sm-and-down">
                          <div class="file-actions">
                            <div>
                              <!-- Display the timestamp -->
                              <div class="secondary">
                                {{ formatTime(filteredPublishTimes[filteredPublishTimes.length - 1 -index])
                                }}
                              </div>
    
                              <!-- Display the file name -->
                              <div>
                                {{ getFileName(file_url) }}
                              </div>
                            </div>
                            <div class="file-actions">
                              <DownloadButton :fileUrl="file_url" />
                              <InspectBufrButton :fileUrl="file_url" />
                            </div>
                          </div>
                        </div>
                        <!-- Mobile view (download and inspect below file name)-->
                        <div class="hidden-md-and-up">
                          <div>
                            <!-- Display the timestamp -->
                            <div class="secondary">
                              {{ formatTime(filteredPublishTimes[filteredPublishTimes.length - 1 -index])
                              }}
                            </div>
  
                            <!-- Display the file name -->
                            <div>
                              {{ getFileName(file_url) }}
                            </div>
                          </div>
                          <div class="file-actions">
                            <DownloadButton :fileUrl="file_url" />
                            <InspectBufrButton :fileUrl="file_url" />
                          </div>
                        </div>
                        <v-divider v-if="index < notificationData.fileUrls.length - 1" class="divider-spacing"></v-divider>
                      </v-list-item>
                    </div>
                  </v-card>
                </v-fade-transition>
              </v-col>
            </v-row>
  
          </v-col>
        </v-row>
      </v-col>
  </v-row>
</template>

<script>
import { defineComponent } from 'vue';
import { VCard, VCardTitle, VBtn } from 'vuetify/lib/components/index.mjs';
import VueApexCharts from 'vue3-apexcharts'
import InspectBufrButton from '@/components/InspectBufrButton.vue';
import DownloadButton from '@/components/DownloadButton.vue';

export default defineComponent({
  name: 'NotificationDashboard',
  props: {
    topicHierarchy: {
      type: String,
      required: true
    }
  },
  watch: {
    // Watcher for the topicHierarchy prop, so that this component
    // is updated when the user selects another dataset in MonitoringPage.vue
    topicHierarchy(newVal, oldVal) {
      if (newVal !== oldVal) {
        // Run all important methods
        this.getNotifications();
        this.getTimestampCounts();
        this.getWsiCounts();
        this.getSummary();
        this.initChartData();
      }
    }
  },
  components: {
    VCard,
    VCardTitle,
    VBtn,
    VueApexCharts,
    InspectBufrButton,
    DownloadButton,
  },
  data() {
    return {
      // Messages from API call
      messages: [],
      // Example message when Romania synoptic dataset selected by user
      testMessageSynoptic: [
        {
          "id": "8855221f-2112-43fa-b2da-1552e8aa9a2d",
          "properties": {
            "data_id": "wis2/rou/rnimh/data/core/weather/surface-based-observations/synop/WIGOS_0-20000-0-15020_20220331T000000",
            "datetime": "2022-03-31T00:00:00Z",
            "pubtime": "2023-08-24T13:58:20Z",
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
      ],
      // Example message when Malawi surface dataset selected by user
      testMessageSurface: [
        {
          "id": "af14d8c4-5f63-45af-8171-7730ec9932ba",
          "properties": {
            "data_id": "wis2/rou/rnimh/data/core/weather/surface-based-observations/synop/WIGOS_0-20000-0-15015_20220331T000000",
            "datetime": "2022-03-31T00:00:00Z",
            "pubtime": "2023-08-24T13:40:49Z",
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
        }
      ],
      // Object containing the publish time and associated file URLs of
      // each notification from the last 24 hours
      notificationData: {
        "publishTimes": [],
        "fileUrls": []
      },
      // Count for how many files were published at a given time, rounded
      // to the nearest minute
      timestampCounts: {},
      // Count for how files were published from a given WSI
      wsiCounts: {},
      // Object for notification summary statistics
      summaryStats: {
        "totalFilesLastHour": 0,
        "totalFilesLastDay": 0
      },
      // One minute in milliseconds
      mins: 60 * 1000,
      // Variable to update the ApexCharts graph in realtime
      updateInterval: null,
      // ApexCharts time zoom selected. Defaults to the last hour
      selectedZoom: "one_hour",
      // Initiate ApexCharts series to be filled with data later
      chartSeries: [
        {
          name: 'BUFR files published',
          data: []
        }
      ],
      // Search parameter for published files
      fileSearch: null
    }
  },
  computed: {
    // Get current time
    now() {
      return new Date();
    },
    // Get time 1 hour ago from now
    oneHourAgo() {
      return new Date(this.now.getTime() - 1 * 60 * this.mins);
    },
    // Get time 24 hours ago from now
    oneDayAgo() {
      return new Date(this.now.getTime() - 24 * 60 * this.mins);
    },
    // Options for the ApexChart bar graph
    chartOptions() {
      return {
        chart: {
          type: 'bar',
          id: 'realtime',
          animations: {
            enable: true,
            easy: 'linear'
          },
          toolbar: {
            show: false
          }
        },
        plotOptions: {
          bar: {
            borderRadius: 2,
            columnWidth: '10%',
            dataLabels: {
              position: 'top',
            },
          }
        },
        dataLabels: {
          enabled: true,
          offsetY: -20,
          style: {
            fontSize: '12px',
            colors: ["#304758"]
          }
        },
        stroke: {
          curve: 'straight'
        },
        tooltip: {
          x: {
            format: 'dd MMM HH:mm'
          }
        },
        colors: ['#00BD9D'], // Colour of bars
        xaxis: {
          type: 'datetime',
          // Earliest displayed time 1 hour from current
          min: this.oneHourAgo.getTime(),
          // Latest displayed time is current time
          max: this.now.getTime()
        },
        yaxis: {
          min: 0,
          labels: {
            show: false
          },
          axisBorder: {
            show: false
          },
          axisTicks: {
            show: false
          }
        }
      }
    },
    // Filter the file URLs in published data by the search parameter
    filteredFileUrls() {
      let fileUrls = this.notificationData.fileUrls;
      if (this.fileSearch) {
        fileUrls = fileUrls.filter(url => {
          const fileName = this.getFileName(url);
          return fileName.includes(this.fileSearch);
        });
      }
      // Return the urls filtered by the search
      return fileUrls;
    },
    // Filter the associated publish times by the search parameter
    filteredPublishTimes() {
      let publishTimes = this.notificationData.publishTimes;

      if (this.fileSearch) {
        return publishTimes.filter((_, index) => {
          const fileUrl = this.notificationData.fileUrls[index];
          const fileName = this.getFileName(fileUrl);
          return fileName.includes(this.fileSearch);
        });
      }

      else {
        return publishTimes;
      }

    }
  },
  methods: {
    // Builds a topic hierarchy dependent url and fetches the notifications
    async apiCall() {
      // If in TEST_MODE or API URL is not defined, just return.
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        return;
      }

      const apiUrl = `${import.meta.env.VITE_API_URL}/collections/messages/items`;
      console.log("Fetching notifications from:", apiUrl);

      try {
        const params = new URLSearchParams({
          f: 'json', // Specify the response format as JSON
          data_id: `${this.topicHierarchy}%`, // Filter by data_id that starts with the provided topic hierarchy
          sortBy: '-datetime', // Sort by time in descending order
          limit: 50, // Limit the results to the last 9999 features
          datetime: `${this.oneDayAgo.toISOString()}/${this.now.toISOString()}`, // Filter to last 24 hours
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
            this.messages = data.features;
            console.log("Messages:", this.messages);
          }
          else {
            console.error("API response does not contain features:", data);
          }
        }
      }
      catch (error) {
        console.error("Error fetching notifications:", error)
      }
    },
    // Method to get summary statistics of total published files in the
    // past hour and past 24 hours
    async getSummary() {
      // Get the number of publish times from the last hour
      const timesWithinHour = this.notificationData.publishTimes.filter(time => {
        return time >= this.oneHourAgo;
      }).length;

      // Get the number of publish times from the last 24 hours
      // (which is all of the publish times by the way we call the API)
      const timesWithinDay = this.notificationData.publishTimes.length;

      // Update the summary statistics object
      this.summaryStats.totalFilesLastHour = timesWithinHour;
      this.summaryStats.totalFilesLastDay = timesWithinDay;
    },
    // Loads notification data of publish times and file urls
    async getNotifications() {
      // Check if TEST_MODE is set in .env file or if VITE_API_URL is not set
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        console.log("TEST_MODE is enabled");
        console.log("Dataset selected: ", this.topicHierarchy);
        // Use example data selected by user
        if (this.topicHierarchy == "rou/rnimh/data/core/weather/surface-based-observations/synop") {
          this.messages = this.testMessageSynoptic;
        }
        else if (this.topicHierarchy == "mwi/mwi_met_centre/data/core/weather/surface-based-observations/synop") {
          this.messages = this.testMessageSurface;
        }
      }
      else {
        await this.apiCall();
      }

      this.notificationData = {
        // Get the publish times of the notifications as an array
        publishTimes: this.messages.map(item =>
          new Date(item.properties.pubtime)),
        // Get the file urls of the notifications as an array
        fileUrls: this.messages.map(item => {
          const canonicalLink = item.links.find(link => link.rel === "canonical");
          // The file url is the href value associated with the canonical relation
          return canonicalLink ? canonicalLink.href : null;
        })
      }

      // Get summary statistics of notification data
      await this.getSummary();

      console.log("Publish times and URLs: ", this.notificationData);
    },
    roundToNearestMinute(time) {
      // Get minutes and seconds of the datetime
      let minutes = time.getMinutes();
      let seconds = time.getSeconds();

      if (seconds >= 30) {
        // Round to the next minute
        time.setMinutes(minutes + 1);
      }
      // As rounded to the nearest minute, set the seconds/ms to 0
      time.setSeconds(0);
      time.setMilliseconds(0);

      return time;
    },
    // Builds the timestamp count array used in the ApexCharts bar graph
    async getTimestampCounts() {
      // Reset the timestamp counts
      this.timestampCounts = {};

      // For each publish time, round to the nearest minute and update
      // the count
      this.notificationData["publishTimes"].forEach(time => {

        const roundedTime = this.roundToNearestMinute(time);

        // Update timestampCount object with this rounded publish time
        if (this.timestampCounts[roundedTime]) {
          // If the key already exists, add to the count
          this.timestampCounts[roundedTime]++;
        }
        else {
          // Otherwise begin the count at 1
          this.timestampCounts[roundedTime] = 1;
        }
      });

      console.log("Timestamp counts: ", this.timestampCounts)
    },
    // Builds the wsiCounts object
    async getWsiCounts() {

      // Reset the wsi counts
      this.wsiCounts = {};

      // Check if TEST_MODE is set in .env file or if VITE_API_URL is not set
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        // Use example data selected by user
        if (this.topicHierarchy == "rou/rnimh/data/core/weather/surface-based-observations/synop") {
          this.messages = this.testMessageSynoptic;
        }
        else if (this.topicHierarchy == "mwi/mwi_met_centre/data/core/weather/surface-based-observations/synop") {
          this.messages = this.testMessageSurface;
        }
      }
      else {
        await this.apiCall();
      }

      // Group the messages based on 'wigos_station_identifier' add canonical_url property to each item
      this.messages.forEach((item) => {
        const canonicalLink = item.links.find(link => link.rel === "canonical");
        if (canonicalLink) {
          item.canonical_url = canonicalLink.href;
        }
        const identifier = item.properties.wigos_station_identifier;
        if (this.wsiCounts[identifier]) {
          this.wsiCounts[identifier]++;
        }
        else {
          this.wsiCounts[identifier] = 1
        }
      })

      console.log("WSI counts: ", this.wsiCounts);
    },
    // Initialise the data for ApexCharts series bar graph based on 
    // allNotifications
    initChartData() {
      // Creates a nested array structure of form [[timestamp1, count1],...]
      const chartData = Object.entries(this.timestampCounts);

      // Update the chartSeries data with the above
      this.chartSeries[0].data = chartData;
    },
    // Enables zoom functionality on bar graph
    updateData: function (timeline) {
      this.selectedZoom = timeline;
      // Get current time
      const now = new Date().getTime();

      // Depending on the button pressed, zoom the x-axis of the bar graph accordingly
      switch (timeline) {
        case 'one_hour':
          this.$refs.chart.zoomX(now - (60 * this.mins), now);
          break;
        case 'three_hours':
          this.$refs.chart.zoomX(now - (3 * 60 * this.mins), now);
          break;
        case 'six_hours':
          this.$refs.chart.zoomX(now - (6 * 60 * this.mins), now);
          break;
        case 'twenty_four_hours':
          this.$refs.chart.zoomX(now - (24 * 60 * this.mins), now);
          break;
        default:
      }
    },
    // Shows the HH:mm timestamp for the newest notifications
    formatTime(timestamp) {
      const year = timestamp.getFullYear();
      const month = String(timestamp.getMonth() + 1).padStart(2, '0');
      const day = String(timestamp.getDate()).padStart(2, '0');
      const hours = String(timestamp.getHours()).padStart(2, '0');
      const minutes = String(timestamp.getMinutes()).padStart(2, '0');
      return `${year}/${month}/${day} ${hours}:${minutes}`;
    },
    // Gets the filename from the canonical href
    getFileName(url) {
      const urlParts = url.split('/');
      return urlParts[urlParts.length - 1];
    },
  },
  mounted() {
    this.apiCall();
    // Get notification data
    this.getNotifications();
    // Get timestamp count data
    this.getTimestampCounts();
    // Get WSI file count data
    this.getWsiCounts();
    // Get summary statistics
    this.getSummary();
    // Fill ApexCharts with latest data
    this.initChartData();
  }
});
</script>

<style scoped>
.selected-zoom {
  color: #00BD9D;
}

.secondary {
  color: #767B91;
}

.scrollable-file-list {
  max-height: 345px;
  overflow-y: auto;
}

.file-actions {
  display: flex;
  align-items: center;
  gap: 30px;
  padding: 2px;
}

.divider-spacing {
  margin-top: 10px;
}
</style>