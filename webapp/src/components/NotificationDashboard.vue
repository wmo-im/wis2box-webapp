<template>
    <!-- Dashboard -->
    <v-row>
        <v-col cols="12">
            <v-row>
                <!-- ApexCharts bar graph for latest notifications received -->
                <v-col cols="6">
                    <v-fade-transition appear>
                        <v-card>

                            <v-card-title class="text-center">
                                Notifications
                            </v-card-title>

                            <vue-apex-charts ref="chart" type="bar" height="400" :options="chartOptions"
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
                                                        {{ formatTime(message.pubtime) }}
                                                    </div>

                                                    <!-- Display the file name -->
                                                    <div>
                                                        {{ message.filename }}
                                                    </div>
                                                </div>
                                                <div class="file-actions">
                                                    <DownloadButton :fileUrl="message.canonical_url"
                                                        :fileName=message.filename />
                                                    <InspectBufrButton :fileUrl="message.canonical_url"
                                                        :fileName=message.filename />
                                                </div>
                                            </div>
                                            <v-divider v-if="index < messages.length - 1"
                                                class="divider-spacing"></v-divider>
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
import { VCard, VCardTitle } from 'vuetify/lib/components/index.mjs';
import VueApexCharts from 'vue3-apexcharts'
import BarGraph from './BarGraph.vue';
import SummaryStats from './SummaryStats.vue';
import StationStats from './StationStats.vue';
import PublishedData from './PublishedData.vue';
import MapStats from './MapStats.vue';

export default defineComponent({
    name: 'NotificationDashboard',
    props: {
        topicHierarchy: {
            type: String,
            required: true
        },
        startDate: {
            type: Date,
            required: true
        },
        endDate: {
            type: Date,
            required: true
        },
        wsi: {
            type: String,
            required: false
        },
        limit: {
            type: Number,
            required: true
        },
    },
    components: {
        VCard,
        VCardTitle,
        VueApexCharts,
        BarGraph,
        SummaryStats,
        StationStats,
        PublishedData,
        MapStats
    },
    setup(props) {

        // Reactive variables

        // Messages from API call
        const messages = ref([])
        // Example message when Romania synoptic dataset selected
        // by user
        const testMessageSynoptic = ref([
            {
                "id": "8855221f-2112-43fa-b2da-1552e8aa9a2d","geometry": {
                    "type": "Point",
                    "coordinates": [46.223432, 6.146197]
                },
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
        ])
        // Example message when Malawi surface dataset selected by user
        const testMessageSurface = ref([
            {
                "id": "af14d8c4-5f63-45af-8171-7730ec9932ba",
                "geometry": {
                    "type": "Point",
                    "coordinates": [46.223432, 6.146197]
                },
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
        ])

        // Methods

        // Method to get canonical URL from a message
        const getCanonicalUrl = (links) => {
            const canonicalLink = links.find(link => link.rel === "canonical");
            if (canonicalLink) {
                return canonicalLink.href;
            }
            return '';
        }

        // Method to get filename from the canonical href
        const getFileName = (url) => {
            const urlParts = url.split('/');
            return urlParts[urlParts.length - 1];
        }

        // Method to get the messages from the features array
        const getMessagesFromFeatures = (features) => {
            const selectedFields = features.map(item => ({
                pubtime: new Date(item.properties.pubtime + "Z"),
                canonical_url: getCanonicalUrl(item.links),
                filename: getFileName(getCanonicalUrl(item.links)),
                coordinates: item.geometry.coordinates
            }));
            // sort by pubtime descending
            return selectedFields.sort((a, b) => b.pubtime - a.pubtime);
        }

        // Make API call
        const apiCall = async () => {
            const apiUrl = `${import.meta.env.VITE_API_URL}/collections/messages/items`;
            console.log("Fetching notifications from:", apiUrl);
            try {
                let params;
                // If WSI prop is given, include it in the search:
                if (props.wsi) {
                    params = new URLSearchParams({
                        f: 'json', // Specify the response format as JSON
                        data_id: `${props.topicHierarchy}%`, // Filter by data_id that starts with the provided topic hierarchy
                        sortBy: '-datetime', // Sort by time in descending order
                        datetime: `${props.startDate.toISOString()}/${props.endDate.toISOString()}`, // Filter to date range specified by user
                        wigos_station_identifier: `${props.wsi}`, // Filter by WSI searched
                        limit: `${props.limit}`, // Limit number of notifications shown on dashboard
                    });
                }
                else {
                    params = new URLSearchParams({
                        f: 'json', // Specify the response format as JSON
                        data_id: `${props.topicHierarchy}%`, // Filter by data_id that starts with the provided topic hierarchy
                        sortBy: '-datetime', // Sort by time in descending order
                        datetime: `${props.startDate.toISOString()}/${props.endDate.toISOString()}`, // Filter to date range specified by user
                        limit: `${props.limit}`, // Limit number of notifications shown on dashboard
                    });
                }
                // Make the HTTP GET request
                console.log("API request:", `${apiUrl}?${params}`)
                const response = await fetch(`${apiUrl}?${params}`);
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                else {
                    const data = await response.json();
                    if (data.features) {
                        messages.value = getMessagesFromFeatures(data.features);
                    }
                    else {
                        console.error("API response does not contain features:", data);
                    }
                }
            }
            catch (error) {
                console.error("Error fetching notifications:", error)
            }
        }

        // Retrieve messages
        const updateMessages = async () => {
            // Check if TEST_MODE is set in .env file or if VITE_API_URL is not set
            if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
                console.log("TEST_MODE is enabled");
                console.log("Dataset selected: ", props.topicHierarchy);
                // Use example data selected by user
                if (props.topicHierarchy == "test1") {
                    this.messages = this.testMessageSynoptic;
                }
                else if (this.topicHierarchy == "test2") {
                    this.messages = this.testMessageSurface;
                }
            }
            else {
                await this.apiCall();
            }
        }

        return {
            // Fill up
        }
    }
});
</script>