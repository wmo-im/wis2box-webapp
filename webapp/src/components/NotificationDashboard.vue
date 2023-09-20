<template>
    <!-- Dashboard -->
    <v-row>
        <v-col cols="12">
            <v-row>
                <!-- ApexCharts bar graph for latest notifications received -->
                <v-col cols="7">
                    <v-fade-transition appear>
                        <BarChart :messages="messages" :startDate="startDate" :endDate="endDate"></BarChart>
                    </v-fade-transition>
                </v-col>

                <v-col cols="5">
                    <!-- Top right -->
                    <v-row>
                        <!-- Total number of publications submitted in the last hour -->
                        <v-col cols="12">
                            <v-fade-transition appear>
                                <SummaryStats :messages="messages"></SummaryStats>
                            </v-fade-transition>
                        </v-col>
                    </v-row>

                    <!-- Bottom right -->
                    <!-- List of WSIs and the number of associated notifications -->
                    <v-row>
                        <v-col cols="12">
                            <v-fade-transition appear>
                                <StationStats :messages="messages"></StationStats>
                            </v-fade-transition>
                        </v-col>
                    </v-row>

                </v-col>
            </v-row>

            <v-row>
                <v-col cols="12">
                    <v-fade-transition appear>
                        <!-- Files published, ready to download and inspect -->
                        <PublishedData :messages="messages"></PublishedData>
                    </v-fade-transition>
                </v-col>
            </v-row>
        </v-col>
    </v-row>
</template>

<script>
import { defineComponent, ref, onMounted } from 'vue';
import BarChart from './BarChart.vue';
import SummaryStats from './SummaryStats.vue';
import StationStats from './StationStats.vue';
import PublishedData from './PublishedData.vue';

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
        BarChart,
        SummaryStats,
        StationStats,
        PublishedData
    },
    setup(props) {

        // Reactive variables

        // Messages from API call
        const messages = ref([])
        // Example message of Romania synoptic dataset
        const testMessageSynoptic = ref([
            {
                "id": "8855221f-2112-43fa-b2da-1552e8aa9a2d", "geometry": {
                    "type": "Point",
                    "coordinates": [46.223432, 6.146197]
                },
                "properties": {
                    "data_id": "wis2/rou/rnimh/data/core/weather/surface-based-observations/synop/WIGOS_0-20000-0-15020_20220331T000000",
                    "datetime": "2022-03-31T00:00:00Z",
                    "pubtime": "2023-09-19T13:58:20Z",
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
        // Example message of Malawi surface dataset
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
                    "pubtime": "2023-09-19T13:40:49Z",
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

        // Method to get the messages from the features array
        const getMessagesFromFeatures = (features) => {
            const selectedFields = features.map(item => ({
                pubtime: new Date(item.properties.pubtime),
                canonical_url: getCanonicalUrl(item.links),
                wsi: item.properties.wigos_station_identifier,
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
                    messages.value = getMessagesFromFeatures(testMessageSynoptic.value);
                    console.log(messages.value)
                }
                else if (props.topicHierarchy == "test2") {
                    messages.value = getMessagesFromFeatures(testMessageSurface.value);
                }
                else if (props.topicHierarchy == "test3") {
                    messages.value = getMessagesFromFeatures(testMessageSynoptic.value);
                }
            }
            // If not in test mode, make the API call
            else {
                await apiCall();
            }
        }

        // Mounted lifecycle hook to display newest notification dashboard
        onMounted(() => {
            console.log("Mounted updateMessages")
            updateMessages();
        })

        return {
            messages,
            updateMessages
        }
    }
});
</script>