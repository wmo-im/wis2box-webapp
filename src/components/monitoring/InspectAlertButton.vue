<template>
    <v-dialog v-model="dialog" width="auto">
        <template v-slot:activator="{ props }">
            <v-btn color="#49C6E5" :block="block" append-icon="mdi-feature-search" v-bind="props"
                @click="inspectFile">Inspect</v-btn>
        </template>
        <v-card class="inspect-content">
            <v-toolbar :title="result.headline" color="#003DA5">
                <v-btn icon="mdi-close" variant="text" size="small"
                    @click="dialog = false" />
            </v-toolbar>
            <v-row>
                <v-col cols="12">
                    <v-card-text>
                        <!-- Essential info -->
                        <div><b>Headline:</b> {{ result.headline }}</div>
                        <div><b>Status:</b> {{ result.status }}</div>
                        <div><b>Scope:</b> {{ result.scope }}</div>
                        <div><b>Sent:</b> {{ result.sent }}</div>
                    </v-card-text>
                </v-col>
            </v-row>
            <v-container class="scrollable-list">
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
                <v-row v-if="result.properties.id">
                    <!-- Left side of window display map -->
                    <v-col cols="5">
                        <v-card-item>
                            <!-- <LocatorMap :longitude="result.longitude" :latitude="result.latitude"/> -->
                        </v-card-item>
                    </v-col>
                    <v-divider vertical inset></v-divider>
                    <!-- Right side of window display more info -->
                    <v-col cols="7">
                        <v-list line="zero">
                            <div v-for="(value, key) in item" :key="key">
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
import LocatorMap from '@/components/LocatorMap.vue';
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
        VDialog, VContainer, VCardText, VTextField, VRow, VCol, VBtn
    },
    setup(props) {
        // Reactive variables
        const result = ref({
            headline: null,
            status: null,
            sent: null,
            scope: null,
            properties: {},
            areas: []
        });
        const dialog = ref(false);

        // Methods
        const makeReadable = (key) => {
            return key.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
        };

        const extractInfo = (data) => {
            // Extract essential info to display at the top of the dialog
            const headline = data?.features[0]?.properties?.headline;
            const status = data?.features[0]?.properties?.status;
            const scope = data?.features[0]?.properties?.scope;
            const sent = data?.features[0]?.properties?.sent;

            // Extract the rest of the properties apart from those above
            const properties = { ...data?.features[0]?.properties };
            delete properties.headline;
            delete properties.status;
            delete properties.scope;
            delete properties.sent;

            // Extract the affected areas
            const areas = data?.features[0]?.geometry?.coordinates;

            return {
                headline,
                status,
                scope,
                sent,
                properties,
                areas
            };
        };

        const loadData = async () => {
            let payload = {
                inputs: {
                    data: props.data
                }
            };

            // Now call to cap to geojson to extract and transform
            const apiURL = `${import.meta.env.VITE_API_URL}/processes/cap2geojson/execution`;
            const response = await fetch(apiURL, {
                method: "POST",
                headers: {
                    "encode": "json",
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(payload)
            });

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
.pad-filename {
    margin-top: 0.2rem;
}

.close-button {
    position: absolute;
    top: 0;
    right: 0;
    z-index: 1;
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
