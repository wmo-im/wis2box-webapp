<template>
    <v-row class="justify-center">
        <v-col cols="12" class="max-dashboard-width">
            <v-card-title class="big-title">WIS2 Notifications Monitoring Dashboard</v-card-title>

            <v-card-item>
                <!-- Drop down selection for the topic the user wants to monitor -->
                <v-row>
                    <v-col cols="10">
                        <TopicHierarchySelector v-model="selectedTopicTemp" class="mb-3"></TopicHierarchySelector>
                    </v-col>
                </v-row>
                <!-- Remaining selections: datetime range, WSI, and limit -->
                <v-row>
                    <v-col>
                        <v-row>
                            <v-col cols="5">
                                <VueDatePicker v-model="selectedDateRangeTemp" range multi-calendars auto-apply required
                                    :teleport="true" placeholder="Datetime range" format="yyyy/MM/dd HH:mm" />
                                <p class="hint-text">Choose the datetime range for the notifications (default: previous 24
                                    hours)</p>
                            </v-col>


                            <v-col cols="3">
                                <!-- Search bar to search for a WSI and only monitor that station -->
                                <v-text-field v-model="searchedWsiTemp" label="WSI"
                                    hint="Search a WMO Station Identifier (optional)" persistent-hint></v-text-field>
                            </v-col>

                            <!-- Limit for how many notifications to display (default = 100) -->
                            <v-col cols="2">
                                <v-select v-model="selectedLimitTemp" :items="limits" hint="Limit"
                                    persistent-hint></v-select>
                            </v-col>


                            <!-- Monitor button, that is only clickable when topic and date range selected -->
                            <v-col cols="2">
                                <v-btn class="update-button" size="x-large" block append-icon="mdi-database-search"
                                    :disabled="updateDisabled" @click="handleUpdate">Update</v-btn>
                            </v-col>
                        </v-row>
                    </v-col>
                </v-row>
            </v-card-item>
        </v-col>

        <v-col cols="12" class="max-dashboard-width">
            <v-divider :thickness="2" />
        </v-col>

        <v-col cols="12" class="max-dashboard-width">
            <!-- Dashboard visualising the notifications of the topic selected -->
            <NotificationDashboard :topicHierarchy="selectedTopic.id" :startDate="selectedStartDate"
                :endDate="selectedEndDate" :wsi="searchedWsi" :limit="selectedLimit" v-if="showDashboard" class="my-4" />
        </v-col>
    </v-row>
</template>
  
<script>
import { defineComponent, ref, computed } from 'vue';
import { VCardTitle } from 'vuetify/lib/components/index.mjs';
import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';
import TopicHierarchySelector from './TopicHierarchySelector.vue';
import NotificationDashboard from '@/components/NotificationDashboard.vue';

export default defineComponent({
    name: 'MonitoringPage',
    components: {
        VCardTitle,
        VueDatePicker,
        TopicHierarchySelector,
        NotificationDashboard
    },
    setup() {
        // Static variables
        const now = new Date().toISOString().replace('Z', '');
        const twentyFourHoursAgo = new Date((new Date()).getTime() - 24 * 60 * 60 * 1000).toISOString().replace('Z', '');

        // Reactive variables

        // For each prop, we have a temporary and a final version.
        // The temporary version is what the user selects before clicking update
        // The final version is what has been selected when clicking update

        // Topic selected by the user, used to get the topic hierarchy
        // from the topics array
        const selectedTopicTemp = ref(null);
        const selectedTopic = ref(null);
        // Date range for notifications, defaults to [24 hours from now, now]
        const selectedDateRangeTemp = ref([twentyFourHoursAgo, now]);
        const selectedStartDate = ref(twentyFourHoursAgo);
        const selectedEndDate = ref(now);
        // WSI searched by the user
        const searchedWsiTemp = ref(null);
        const searchedWsi = ref(null);
        // Array of limits for user to select
        const limits = ref([10, 50, 100, 500, 1000]);
        // Limits optionally configured by user, defaults to 100
        const selectedLimitTemp = ref(100);
        const selectedLimit = ref(100);
        // Boolean to show the notification dashboard
        const showDashboard = ref(false);

        // Computed

        // Boolean for whether the monitor button is disabled or not
        const updateDisabled = computed(() => {
            return !selectedTopicTemp.value || !selectedDateRangeTemp.value || (selectedDateRangeTemp.value.length !== 2)
        })

        // Methods

        // Method to update the props and display the notificaiton dashboard when the 
        // user clicks on the monitor button
        const handleUpdate = () => {
            // Update props
            selectedTopic.value = selectedTopicTemp.value;
            selectedStartDate.value = new Date(selectedDateRangeTemp.value[0]);
            selectedEndDate.value = new Date(selectedDateRangeTemp.value[1]);
            searchedWsi.value = searchedWsiTemp.value;
            selectedLimit.value = selectedLimitTemp.value;
            // Display dashboard
            showDashboard.value = true;
        }

        return {
            selectedTopicTemp,
            selectedTopic,
            selectedDateRangeTemp,
            selectedStartDate,
            selectedEndDate,
            searchedWsiTemp,
            searchedWsi,
            limits,
            selectedLimitTemp,
            selectedLimit,
            showDashboard,
            updateDisabled,
            handleUpdate
        }
    }
});
</script>
  
<style scoped>
.max-dashboard-width {
    max-width: 1500px;
}

.hint-text {
    font-size: 0.75rem;
    margin-top: 0.25rem;
    padding-left: 1rem;
    color: #888;
}

.update-button {
    margin-left: -3px;
}
</style>