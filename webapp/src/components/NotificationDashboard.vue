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
                  Notifications
                </v-card-title>
  
                <vue-apex-charts ref="chart" type="bar" height="400" 
                  :options="chartOptions"
                  :series="chartSeries">
                </vue-apex-charts>
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
                      <v-list-item v-for="(message, index) in messages" :key="index">
                        <div class="file-actions">
                          <div>
                            <!-- Display the timestamp -->
                            <div class="secondary">
                              {{ formatTime(message.pubtime)}}
                            </div>
  
                            <!-- Display the file name -->
                            <div>
                              {{ message.filename }}
                            </div>
                          </div>
                          <div class="file-actions">
                            <DownloadButton :fileUrl="messages.canonical_url" :fileName=message.filename />
                            <InspectBufrButton :fileUrl="messages.canonical_url" :fileName=message.filename />
                          </div>
                        </div>
                        <v-divider v-if="index < messages.length - 1" class="divider-spacing"></v-divider>
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
                  Notifications
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
                      <v-list-item v-for="(message, index) in messages" :key="index">
                        <!-- Tablet view (download and inspect to the right of file name) -->
                        <div class="hidden-sm-and-down">
                          <div class="file-actions">
                            <div>
                              <!-- Display the timestamp -->
                              <div class="secondary">
                                {{ formatTime(message.pubtime)}}
                              </div>
    
                              <!-- Display the file name -->
                              <div>
                                {{ message.filename }}
                              </div>
                            </div>
                            <div class="file-actions">
                              <DownloadButton :fileUrl="message.canonical_url" :fileName=message.filename />
                              <InspectBufrButton :fileUrl="message.canonical_url" :fileName=message.filename />
                            </div>
                          </div>
                        </div>
                        <!-- Mobile view (download and inspect below file name)-->
                        <div class="hidden-md-and-up">
                          <div>
                            <!-- Display the timestamp -->
                            <div class="secondary">
                              {{ formatTime(message.pubtime)}}
                            </div>
  
                            <!-- Display the file name -->
                            <div>
                              {{ message.filename }}
                            </div>
                          </div>
                          <div class="file-actions">
                            <DownloadButton :fileUrl="message.canonical_url" :fileName=message.filename />
                            <InspectBufrButton :fileUrl="message.canonical_url" :fileName=message.filename />
                          </div>
                        </div>
                        <v-divider v-if="index < messages.length - 1" class="divider-spacing"></v-divider>
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
        console.log("Topic hierarchy changed to:", newVal);
        this.update_messages();
      }
    },
    messages: {
      immediate: false, // To not trigger the watcher immediately on component mount
      deep: false, // To not deep watch changes within the array
      handler(newMessages) {
        console.log("Messages changed");
        // Run the methods dependent on the messages
        console.log("Messages: ", newMessages);
        this.updateSummary();
        this.updateChartData();
      },
    },
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
      messages: [], // Array of messages
      messages: [], // Array of messages sorted by pubtime
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
          name: 'WIS2 notifications published',
          data: []
        }
      ],
      // ApexCharts options
      // Options for the ApexChart bar graph
      chartOptions: {
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
            format: 'dd MMM HH:mm',
          }
        },
        colors: ['#00BD9D'], // Colour of bars
        xaxis: {
          type: 'datetime',
          categories: this.getLast24Hours(),
          labels: {
            format: "dd MMM HH:mm", // Format the x-axis labels as desired
          }
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
      },
      // Search parameter for published files
      fileSearch: null
    }
  },
  methods: {
    getLast24Hours() {
            const now = new Date();
            const past24Hours = new Date(now - 24 * 60 * 60 * 1000); // Subtract 24 hours in milliseconds
            const timeRange = [];

            for (let time = past24Hours; time <= now; time += 60 * 60 * 1000) { // Generate data points every hour
                timeRange.push(time);
            }

            return timeRange;
    },
    now() {
      return new Date();
    },
    // Get time 1 hour ago from now
    oneHourAgo() {
      return new Date(this.now().getTime() - 1 * 60 * this.mins);
    },
    // Get time 24 hours ago from now
    oneDayAgo() {
      return new Date(this.now().getTime() - 24 * 60 * this.mins);
    },
    // Builds a topic hierarchy dependent url and fetches the notifications
    async update_messages() {
      console.log("Dataset selected: ", this.topicHierarchy);
      // Check if TEST_MODE is set in .env file or if VITE_API_URL is not set
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        console.log("TEST_MODE is enabled");
        // Use example data selected by user
        let test_features = [];
        if (this.topicHierarchy == "rou/rnimh/data/core/weather/surface-based-observations/synop") {
          test_features = this.testMessageSynoptic;
        }
        else if (this.topicHierarchy == "mwi/mwi_met_centre/data/core/weather/surface-based-observations/synop") {
          test_features = this.testMessageSurface;
        }
        const selectedFields = test_features.map(item => ({
            pubtime: new Date(item.properties.pubtime),
            canonical_url: this.getCanonicalUrl(item.links),
            filename: this.getFileName(this.getCanonicalUrl(item.links))
            // Add more fields as needed
          }));
        console.log(selectedFields);
        this.messages = selectedFields;
      }
      else {
        // Use API to get data
        await this.apiCall();
      }
    },
    async apiCall() {
      const apiUrl = `${import.meta.env.VITE_API_URL}/collections/messages/items`;
      console.log("Fetching notifications from:", apiUrl);
      try {
        const params = new URLSearchParams({
          f: 'json', // Specify the response format as JSON
          data_id: `${this.topicHierarchy}%`, // Filter by data_id that starts with the provided topic hierarchy
          sortBy: '-datetime', // Sort by time in descending order
          limit: 500, // Limit the results to the last 500 features
          datetime: `${this.oneDayAgo().toISOString()}/${this.now().toISOString()}`, // Filter to last 24 hours
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
            const selectedFields = data.features.map(item => ({
              pubtime: new Date(item.properties.pubtime),
              canonical_url: this.getCanonicalUrl(item.links),
              filename: this.getFileName(this.getCanonicalUrl(item.links))
              // Add more fields as needed
            }));
            console.log(selectedFields);
            this.messages = selectedFields;
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
    updateSummary() {
      console.log("Update summary statistics");
      // Get the number of publish times from the last hour
      const timesWithinHour = this.messages.filter(message => {
        const publishTime = message.pubtime;
        return publishTime >= this.oneHourAgo();
      }).length;
      // Get the number of publish times from the last 24 hours
      // (which is all of the publish times by the way we call the API)
      const timesWithinDay = this.messages.length;
      // Update the summary statistics object
      this.summaryStats.totalFilesLastHour = timesWithinHour;
      this.summaryStats.totalFilesLastDay = timesWithinDay;
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
    updateTimestampCounts() {
      console.log("Update timestamp counts");
      // Reset the timestamp counts
      this.timestampCounts = {};

      // For each publish time, round to the nearest minute and update
      // the count
      this.messages.forEach(message => {
          const publishTime = new Date(message.pubtime);
          const roundedTime = this.roundToNearestMinute(publishTime);
          if (this.timestampCounts[roundedTime]) {
            this.timestampCounts[roundedTime]++;
          } else {
            this.timestampCounts[roundedTime] = 1;
        }
      });
      console.log("Timestamp counts: ", this.timestampCounts);
    },
    // Initialise the data for ApexCharts series bar graph based on 
    // allNotifications
    updateChartData() {
      console.log("update chart data");
      // count messages per minutes and uses this create the chart data
      const timestampCounts = {};
      this.messages.forEach(message => {
          const publishTime = new Date(message.pubtime);
          const roundedTime = this.roundToNearestMinute(publishTime);
          if (this.timestampCounts[roundedTime]) {
            timestampCounts[roundedTime]++;
          } else {
            timestampCounts[roundedTime] = 1;
        }
      });
      const chartData = Object.keys(timestampCounts).map(key => {
        return [new Date(key).getTime(), timestampCounts[key]];
      });
      console.log("Chart data: ", chartData);
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
    getCanonicalUrl(links) {
      const canonicalLink = links.find(link => link.rel === "canonical");
      if (canonicalLink) {
        return canonicalLink.href;
      }
      return '';
    }
  },
  mounted() {
    console.log("Mounted NotificationDashboard");
    this.update_messages();
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