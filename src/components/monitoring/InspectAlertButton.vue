<template>
    <v-dialog v-model="dialog" class="max-dashboard-width">
        <template v-slot:activator="{ props }">
            <v-btn color="#49C6E5" :block="block" append-icon="mdi-feature-search" v-bind="props"
                @click="inspectFile">View Alert</v-btn>
        </template>
        <v-card>
            <v-toolbar :title="result.headline" color="#003DA5">
                <v-btn icon="mdi-close" variant="text" size="small"
                    @click="dialog = false" />
            </v-toolbar>
            <!-- Essential info -->
            <v-card-text align="center" class="pb-1">
                <div class="summary-info">
                    <b>Status:</b> {{ result.status }} <b class="info-label">Scope:</b> {{ result.scope }}
                    <b class="info-label">Sent:</b> {{ result.sent }} <b class="info-label">Sender:</b> {{ result.senderName }}
                </div>
                <v-divider width="90%"></v-divider>
            </v-card-text>

            <v-container class="scrollable-list py-0">
                <!-- display error in result.error exists -->
                <v-row v-if="result.error">
                    <v-col cols="12">
                        <v-alert type="error" dismissible>
                            <v-row>
                                <v-col cols="12">
                                    <div class="text-h6">Error</div>
                                    <div>{{ result.error }}</div>
                                </v-col>
                            </v-row>
                        </v-alert>
                    </v-col>
                </v-row>
                <!-- Display result if it exists -->
                <v-row v-if="result.properties.identifier">
                    <!-- Left side of window display map -->
                    <v-col cols="6">
                        <v-card-item>
                            <CAPMap :feature="result.feature"/>
                        </v-card-item>
                    </v-col>
                    <v-divider vertical inset></v-divider>
                    <!-- Right side of window display more info -->
                    <v-col cols="6">
                        <v-list line="zero">
                            <div v-for="(value, key) in result.properties" :key="key">
                                <v-list-item class="key-value-pair">
                                    <div class="key">{{ makeReadable(key) }}:</div>
                                    <div>{{ value }}</div>
                                </v-list-item>
                            </div>
                        </v-list>
                    </v-col>
                </v-row>
            </v-container>
        </v-card>
    </v-dialog>
</template>

<script>
// imports
import { defineComponent, ref } from "vue";
import { VCard, VCardTitle, VCardText, VCardItem, VBtn, VDialog, VContainer, VRow, VCol, VTextField } from "vuetify/lib/components/index.mjs";
import CAPMap from '@/components/monitoring/CAPMap.vue';
// now component to export
export default defineComponent({
    name: "InspectBufrButton",
    props: {
        fileUrl: {
            type: String,
            required: false,
            default: ""
        },
        data: {
            type: String,
            required: false,
            default: ""
        },
        fileName: {
            type: String,
            required: true
        },
        block: {
            type: Boolean,
            required: false,
            default: false
        }
    },
    components: {
        VCard, VCardTitle, VCardItem,
        VDialog, VContainer, VCardText, VTextField, VRow, VCol, VBtn,
        CAPMap
    },
    setup(props) {
        // Reactive variables
        const result = ref({
            headline: null,
            status: null,
            scope: null,
            sent: null,
            senderName: null,
            properties: {},
            feature: {}
        });
        const dialog = ref(false);
        const testMode = import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined;

        // Methods
        const makeReadable = (key) => {
            if (key === 'msgType') {
                return 'Message Type';
            }
            if (key === 'areaDesc') {
                return 'Area Description';
            }
            return key.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
        };

        const extractInfo = (data) => {
            // Extract essential info to display at the top of the dialog
            const headline = data?.features[0]?.properties?.headline;
            const status = data?.features[0]?.properties?.status;
            const scope = data?.features[0]?.properties?.scope;
            const senderName = data?.features[0]?.properties?.senderName;

            // Extract the rest of the properties apart from those above
            const properties = { ...data?.features[0]?.properties };
            delete properties.headline;
            delete properties.status;
            delete properties.scope;
            delete properties.senderName;
            delete properties.severity;

            // Format 'sent', 'effective', 'onset', and 'expires' dates
            for (const key of ['sent', 'effective', 'onset', 'expires']) {
                if (properties[key]) {
                    properties[key] = new Date(properties[key]).toLocaleString();
                }
            }
            const sent = properties.sent;
            delete properties.sent;

            // Also parse the entire features object
            const feature = data?.features[0];

            return {
                headline,
                status,
                scope,
                sent,
                senderName,
                properties,
                feature
            };
        };

        const loadData = async () => {
            let payload = {
                inputs: {
                    data: props.data
                }
            };

            let response;

            if (!testMode) {
                const apiURL = `${import.meta.env.VITE_API_URL}/processes/wis2box/execution`;
                response = await fetch(apiURL, {
                    method: "POST",
                    headers: {
                        "encode": "json",
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(payload)
                });
            }
            else {
                response = await fetch("../tests/wis2box_data/alert.geojson");
            }

            // check response status
            if (!response.ok) {
                console.error("HTTP error", response.status);
                return;
            }

            const data = await response.json();
            // check for errors
            if (data.error) {
                console.info("bufr2geojon returned the error:", data.error);
                result.value.error = data.error;
            }

            result.value = extractInfo(data);
        };

        const inspectFile = async () => {
            await loadData();
            dialog.value = true;
        };

        return { result, dialog, makeReadable, inspectFile };
    }
});
</script>
<style scoped>
.summary-info {
    font-size: 1.2rem;
    margin-bottom: 1%;
}

.info-label {
    margin-left: 4%;
}

.inspect-content {
    align-self: center;
    align-items: center;
}

.scrollable-list {
    overflow-y: auto;
    max-height: 800px;
    max-width: 1600px;
}

.item-container {
    margin-bottom: 10px;
    border: 1px solid #ccc;
    padding: 10px;
    border-radius: 4px;
}

.key-value-pair {
    margin-bottom: 5px;
}

.key {
    font-weight: bold;
    margin-right: 5px;
}
</style>
