<template>
    <v-row class="justify-center">
        <v-col cols="12" class="max-form-width">
            <v-card>
                <v-toolbar color="#014e9e" dark flat>
                    <v-toolbar-title v-html="$t(`datasets.dm`)" />

                    <v-spacer />

                    <div style="width:66%; max-width: 66%">
                        <v-select class="mt-3 text-xs-right" v-model="identifier" :items="items" dense
                            @change="loadMetadata" :disabled="specified"></v-select>
                    </div>
                </v-toolbar>

                <v-progress-linear indeterminate color="primary" :active="working" />

                <v-form v-model="filled" v-if="loaded">
                    <bbox-editor @updated="updateGeometry" @loaded="loadGeometry"
                        :input-feature="form.bounds"></bbox-editor>
                    <!-- Original VJSF form -->
                    <!-- <v-jsf v-model="model" :schema="schema" :options="options" @change-child="updateModel" /> -->
                </v-form>

                <v-toolbar color="#DDD" dark flat v-if="loaded">
                    <v-btn color="red" class="ma-2" title="Reset" @click="resetMetadata" append-icon="mdi-sync">
                        Reset
                    </v-btn>

                    <v-spacer />

                    <v-btn color="#009900" class="ma-2" title="Validate" @click="validateMetadata" :disabled="!filled"
                        v-if="!validated" append-icon="mdi-check-bold">
                        Validate
                    </v-btn>

                    <v-btn color="#FFA500" class="ma-2" title="Export" @click="downloadMetadata"
                        :disabled="!validated || !filled" v-if="validated"
                        append-icon="mdi-arrow-down-bold-box-outline">
                        Export
                    </v-btn>

                    <v-btn color="#009900" class="ma-2" title="Submit" @click="submitMetadata"
                        :disabled="!validated || !filled" v-if="validated && form.modified"
                        append-icon="mdi-cloud-upload">
                        Submit
                    </v-btn>
                </v-toolbar>

                <v-card color="#DDD" dark flat v-if="!loaded" class="pa-5">
                    <p class="black--text ma-0">{{ message }}</p>
                </v-card>
            </v-card>
        </v-col>
    </v-row>
</template>

<script>
import BboxEditor from "@/components/leaflet/BboxEditor.vue";
import $RefParser from "@apidevtools/json-schema-ref-parser"
import mergeAllOf from "json-schema-merge-allof"
import { clean } from "@/scripts/helpers.js"
import form_schema from "@/models/DiscoveryMetadataForm.json"

import { defineComponent, ref, onMounted} from 'vue';
import { VCard, VCardTitle, VCardText, VCardItem, VForm, VTextarea, VBtn, VListGroup } from 'vuetify/lib/components/index.mjs';

let oapi = window.VUE_APP_OAPI;
let mqtt = window.MQTT_HOST;

export default defineComponent({
    name: "DiscoveryMetadataForm",
    template: "#discovery-metadata-form",
    props: ["topic"],
    components: {
        VCard,
        VCardTitle,
        VCardText,
        VCardItem,
        VTextarea,
        VForm,
        VBtn,
        VListGroup,
        BBoxEditor
    },
    setup() {
        // Reactive variables
        const loaded = ref(false);
        const working = ref(false);
        const validated = ref(false);
        const filled = ref(false);
        const specified = ref(false);
        const message = ref("Select existing discovery metadata file or create new.");
        const items = ref([]);
        const identifier = ref("");
        const defaults = ref({});
        const model = ref({});
        const isNew = ref(false);
        const schema = ref({});
        const options = ref({
            editMode: "inline",
            rootDisplay: "stepper",
            autoFocus: true,
            tooltipProps: {
                left: true,
                openOnHover: true,
                openOnClick: true
            },
            formats: {
                date: function(e) {
                    return new Date(e).toISOString().split("T")[0];
                }
            }
        });
        const form = ref({
            bounds: [0],
            initialized: true,
            modified: false,
            manual_ids: true,
            country_codes: []
        });

        // Methods
        const loadList = async (id) => {
            try {
                const response = await fetch(
                    `${oapi}/collections/discovery-metadata/items`, {method: 'get'}
                );
                response.data.features.forEach((item) => {
                items.value.push(item.id);
                });
                items.value.push('Create New...');
                specified.value = false;
            } catch (error) {
                console.error(error);
                items.value = ['Create New...'];
                message.value = 'Error loading discovery metadata list.';
            }

            if (items.value.includes(id)) {
                identifier.value = id;
                specified.value = true;
                await loadMetadata();
            } else if (id === 'new') {
                identifier.value = 'Create New...';
                specified.value = true;
                await loadMetadata();
            }
        };
    }
})

</script>