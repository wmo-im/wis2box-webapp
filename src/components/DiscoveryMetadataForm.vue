<template>
    <v-row class="justify-center">
        <v-col cols="12" class="max-dashboard-width">
            <v-card-title class="big-title">Metadata Editor Form</v-card-title>
            <v-card>
                <!-- Toolbar for user to select a dataset -->
                <v-toolbar color="#003DA5">
                    <v-toolbar-title>Please choose a dataset</v-toolbar-title>
                    <v-select class="mt-11" label="Dataset" v-model="identifier" :items="items"
                        @update:modelValue="loadMetadata" variant="underlined"></v-select>
                </v-toolbar>

                <!-- Until loaded, play a loading animation -->
                <v-progress-linear indeterminate color="primary" :active="working" />

                <!-- Dialog window -->
                <v-dialog v-model="showDialog" max-width="600px" persistent>
                    <v-card>
                        <v-card-title>
                            Please enter some initial information
                            <v-btn icon="mdi-comment-question" variant="text" size="small"
                                @click="openInitialHelpDialog = true" />
                        </v-card-title>
                        <v-card-text>
                            <v-text-field v-model="model.identification.centreID" label="Centre ID"
                                variant="outlined"></v-text-field>
                            <v-select v-model="selectedTemplate" :items="templateFiles" item-title="label" return-object
                                label="Data Type" variant="outlined"></v-select>
                        </v-card-text>
                        <v-card-actions>
                            <v-btn color="#009900" variant="flat" block @click="continueToForm"
                                :disabled="!dialogFilled">Continue to
                                Form</v-btn>
                        </v-card-actions>
                    </v-card>
                </v-dialog>

                <!-- Display messages to the user -->
                <v-row class="pa-5">
                    <p class="black--text ma-0">{{ message }}</p>
                </v-row>
            </v-card>

            <v-card class="mt-3 pa-3">
                <!-- Form which when filled and validated, can be exported or submitted -->
                <v-form v-model="formFilled" v-if="metadataLoaded" validate-on="blur">
                    <!-- Identification section -->
                    <v-card-title>
                        Dataset Identification
                        <v-btn icon="mdi-comment-question" variant="text" size="small"
                            @click="openIdentificationHelpDialog = true" />
                    </v-card-title>
                    <v-row>
                        <v-col cols="6">
                            <v-row dense>
                                <v-col cols="12">
                                    <v-text-field label="Title" type="string" v-model="model.identification.title"
                                        :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                                </v-col>
                            </v-row>
                            <v-row dense>
                                <v-col cols="12">
                                    <v-text-field label="Identifier" type="string" v-model="model.identification.identifier"
                                        :rules="[rules.required]" variant="outlined" clearable
                                        :disabled="selectedTemplate?.label !== 'other'"></v-text-field>
                                </v-col>
                            </v-row>
                        </v-col>

                        <v-col cols="6">
                            <v-textarea label="Description" placeholder="Please enter a detailed description of the dataset"
                                type="string" v-model="model.identification.description" :rules="[rules.required]"
                                variant="outlined" clearable></v-textarea>
                        </v-col>
                    </v-row>
                    <v-row>

                    </v-row>
                    <v-row>
                        <v-col cols="2">
                            <v-text-field label="Centre ID" type="string" v-model="model.identification.centreID"
                                :rules="[rules.required, rules.centreID]" variant="outlined" clearable
                                disabled></v-text-field>
                        </v-col>
                        <v-col cols="2">
                            <v-select label="WMO Data Policy" type="string" :items="['core', 'recommended']"
                                v-model="model.identification.wmoDataPolicy" :rules="[rules.required]"
                                variant="outlined"></v-select>
                        </v-col>
                        <!-- Unless the user selects 'other' for the datatype 
                        label, the topic hierarchy should remain disabled as 
                        it is autofilled -->
                        <v-col cols="6">
                            <v-text-field label="Topic Hierarchy" type="string"
                                v-model="model.identification.topicHierarchy" :rules="[rules.required]" variant="outlined"
                                :disabled="selectedTemplate?.label !== 'other'"></v-text-field>
                        </v-col>

                    </v-row>
                    <v-row>
                        <v-col cols="4">
                            <v-select label="Concepts" v-model="model.identification.concepts" multiple
                                :items="['weather']" variant="outlined"></v-select>
                        </v-col>
                        <v-col cols="8">
                            <v-row dense>
                                <v-col cols="4">
                                    <v-text-field label="Keywords (3 minimum)" type="array" v-model="keyword"
                                        @keyup.enter="addKeyword" variant="outlined" clearable></v-text-field>
                                </v-col>
                                <v-col cols="1">
                                    <v-btn color="#003DA5" variant="flat" icon="mdi-plus" size="large" @click="addKeyword"
                                        :disabled="keyword == ''"></v-btn>
                                </v-col>
                                <v-col cols="7">
                                    <v-chip-group :rules="[rules.required, rules.keywords]">
                                        <v-chip v-for="keyword in model.identification.keywords" :key="keyword" closable
                                            label @click:close="removeKeyword(keyword)">
                                            {{ keyword }}
                                        </v-chip>
                                    </v-chip-group>
                                </v-col>
                            </v-row>
                        </v-col>
                    </v-row>

                    <v-card-title>
                        Temporal Properties
                        <v-btn icon="mdi-comment-question" variant="text" size="small"
                            @click="openTemporalHelpDialog = true" />
                    </v-card-title>
                    <v-row>
                        <v-col cols="3">
                            <VueDatePicker placeholder="Begin Date in UTC" v-model="model.extents.dateStarted"
                                :teleport="true" :enable-time-picker="false" auto-apply required />
                        </v-col>

                        <v-col cols="3">
                            <VueDatePicker placeholder="End Date in UTC" v-model="model.extents.dateStopped"
                                :teleport="true" :enable-time-picker="false" auto-apply required />
                        </v-col>

                        <v-col cols="3">
                            <v-row dense>
                                <v-col cols="5">
                                    <v-text-field label="Resolution" type="string" v-model="model.extents.resolution"
                                        :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                                </v-col>
                                <v-col cols="5">
                                    <v-select label="Unit" :items="durations" item-title="name" item-value="code"
                                        v-model="model.extents.resolutionUnit" :rules="[rules.required]"
                                        variant="outlined"></v-select>
                                </v-col>
                            </v-row>
                        </v-col>
                    </v-row>
                    <v-card-title>
                        Spatial Properties
                        <v-btn icon="mdi-comment-question" variant="text" size="small"
                            @click="openSpatialHelpDialog = true" />
                    </v-card-title>
                    <v-row dense>
                        <v-col cols="4">
                            <v-row>
                                <v-col cols="12">
                                    <!-- Allow the user to select a country different to that of the POC for the auto bbox -->
                                    <v-autocomplete label="Choose an automatic bounding box (optional)" item-title="name"
                                        item-value="alpha-3" :items="filteredCountryCodeList" v-model="bboxCountry"
                                        @update:modelValue="getAutoBbox(bboxCountry)"
                                        hint="Your country may not have an automatic bounding box" persistent-hint
                                        variant="outlined"></v-autocomplete>
                                </v-col>
                            </v-row>
                            <v-row style="height: 50px;"></v-row>
                            <v-row style="height: 70px;">
                                <v-col cols="6">
                                    <v-text-field label="North Latitude" type="number" v-model="model.extents.northLatitude"
                                        :rules="[rules.required, rules.latitude]" variant="outlined"
                                        clearable></v-text-field>
                                </v-col>
                                <v-col cols="6">
                                    <v-text-field label="South Latitude" type="number" v-model="model.extents.southLatitude"
                                        :rules="[rules.required, rules.latitude]" variant="outlined"
                                        clearable></v-text-field>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col cols="6">
                                    <v-text-field label="East Longitude" type="number" v-model="model.extents.eastLongitude"
                                        :rules="[rules.required, rules.longitude]" variant="outlined"
                                        clearable></v-text-field>
                                </v-col>
                                <v-col cols="6">
                                    <v-text-field label="West Longitude" type="number" v-model="model.extents.westLongitude"
                                        :rules="[rules.required, rules.longitude]" variant="outlined"
                                        clearable></v-text-field>
                                </v-col>
                            </v-row>
                        </v-col>
                        <v-col cols="8">
                            <!-- Bounding box editor -->
                            <bbox-editor :box-bounds="bounds" id="bbox-editor"></bbox-editor>
                        </v-col>
                    </v-row>

                    <!-- Contact (POC) section -->
                    <v-card-title>
                        Host Contact Information
                        <v-btn icon="mdi-comment-question" variant="text" size="small" @click="openPocHelpDialog = true" />
                    </v-card-title>
                    <v-row>
                        <v-col cols="4">
                            <v-text-field label="Organization Name" type="string" v-model="model.poc.name"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>
                        <v-col cols="4">
                            <v-text-field label="Email" type="string" v-model="model.poc.email"
                                :rules="[rules.required, rules.email]" variant="outlined" clearable></v-text-field>
                        </v-col>
                        <v-col cols="4">
                            <!-- The POC country is disabled as it was selected
                            already in the dialog -->
                            <v-autocomplete label="Country" item-title="name" item-value="alpha-3" :items="countryCodeList"
                                v-model="model.poc.country" :rules="[rules.required]" variant="outlined"></v-autocomplete>
                        </v-col>
                    </v-row>
                </v-form>

                <!-- Toolbar for user to reset, validate, export, or submit the metadata
                from the above form -->
                <v-row class="pt-5" v-if="metadataLoaded">
                    <v-btn color="red" class="ma-2" title="Reset" @click="resetMetadata" append-icon="mdi-sync">
                        Reset
                    </v-btn>
                    <v-spacer />
                    <v-btn color="#009900" class="ma-2" title="Validate" @click="validateMetadata"
                        v-if="!metadataValidated" append-icon="mdi-check-bold">
                        Validate
                    </v-btn>

                    <v-btn color="#E09D00" class="ma-2" title="Export" @click="downloadMetadata"
                        append-icon="mdi-arrow-down-bold-box-outline">
                        Export
                    </v-btn>

                    <v-btn color="#64BF40" class="ma-2" title="Submit" @click="submitMetadata"
                        :disabled="!formFilledAndValidated" v-if="metadataValidated" append-icon="mdi-cloud-upload">
                        Submit
                    </v-btn>
                </v-row>
            </v-card>

            <!-- Help dialogs -->
            <v-dialog v-model="openInitialHelpDialog" max-width="600px">
                <v-card>
                    <v-card-item>
                        <v-card-title class="d-flex justify-space-between">
                            Initial Information
                            <v-btn icon="mdi-close" variant="text" size="small" @click="openInitialHelpDialog = false" />
                        </v-card-title>
                        <v-card-subtitle>
                            What is this section for?
                        </v-card-subtitle>
                    </v-card-item>
                    <v-card-text>
                        <p>To begin creating a new dataset, we require some initial information in order to pre-fill the
                            form.</p>
                        <br>
                        <p><b>Centre ID:</b> The agency acronym (in lower case), as specified by member.</p>
                        <br>
                        <p><b>Data Type:</b> The type of data you are creating metadata for. <i>If 'other' is selected, more
                                fields will have to be manually filled.</i></p>
                        <br>
                    </v-card-text>
                </v-card>
            </v-dialog>
            <v-dialog v-model="openIdentificationHelpDialog" max-width="600px">
                <v-card>
                    <v-card-item>
                        <v-card-title class="d-flex justify-space-between">
                            Dataset Identification
                            <v-btn icon="mdi-close" variant="text" size="small"
                                @click="openIdentificationHelpDialog = false" />
                        </v-card-title>
                        <v-card-subtitle>
                            How do I complete this section?
                        </v-card-subtitle>
                    </v-card-item>
                    <v-card-text>
                        <p><b>Title:</b> A human-readable name of the dataset.</p>
                        <p><i>Note: Unless 'other' was selected initially, this field is pre-filled.</i></p>
                        <br>
                        <p><b>Description:</b> A free-text summary description of the dataset.</p>
                        <br>
                        <p><b>Identifier:</b> The unique identifier for the dataset.</p>
                        <p><i>Note: Unless 'other' was selected initially, this field is pre-filled and cannot be
                                edited.</i></p>
                        <br>
                        <p><b>Centre ID:</b> This was already filled earlier and <i>cannot be edited</i>.</p>
                        <br>
                        <p><b>WMO Data Policy:</b> Classification code of core or recommended based on the WMO Unified Data
                            Policy.</p>
                        <br>
                        <p><b>Topic Hierarchy:</b> The unique hierarchy for this data.</p>
                        <p><i>Note: Unless 'other' was selected initially, this field is pre-filled and cannot be
                                edited.</i></p>
                        <br>
                        <p><b>Concepts:</b> A list of concepts that are referenced to a vocabulary or knowledge organization
                            system used to classify the resource.</p>
                        <br>
                        <p><b>Keywords:</b> A list of at least three keywords, tags or specific phrases associated with the
                            resource, but are not referenced to a particular vocabulary or knowledge organization system.
                        </p>
                        <br>
                    </v-card-text>
                </v-card>
            </v-dialog>
            <v-dialog v-model="openTemporalHelpDialog" max-width="600px">
                <v-card>
                    <v-card-item>
                        <v-card-title class="d-flex justify-space-between">
                            Temporal Properties
                            <v-btn icon="mdi-close" variant="text" size="small" @click="openTemporalHelpDialog = false" />
                        </v-card-title>
                        <v-card-subtitle>
                            How do I complete this section?
                        </v-card-subtitle>
                    </v-card-item>
                    <v-card-text>
                        <p><b>Begin Date:</b> The date in UTC when the dataset begins.</p>
                        <br>
                        <p><b>End Date:</b> The date in UTC when the dataset ends.</p>
                        <br>
                        <p><b>Temporal Resolution:</b> The smallest increment of time that is represented in the dataset.
                        </p>
                        <p>This is split into two parts, the <b>value</b> (e.g. 1) and the <b>unit</b> (e.g. 'hour(s)').</p>
                        <br>
                    </v-card-text>
                </v-card>
            </v-dialog>
            <v-dialog v-model="openSpatialHelpDialog" max-width="600px">
                <v-card>
                    <v-card-item>
                        <v-card-title class="d-flex justify-space-between">
                            Spatial Properties
                            <v-btn icon="mdi-close" variant="text" size="small" @click="openSpatialHelpDialog = false" />
                        </v-card-title>
                        <v-card-subtitle>
                            How do I complete this section?
                        </v-card-subtitle>
                    </v-card-item>
                    <v-card-text>
                        <p>This section describes the general bounding spatial extent of the dataset in the geographic
                            coordinate system. This can be created either:</p>
                        <br>
                        <p><b>Automatically:</b> By using the country dropdown (note that your country may not be found on
                            this list).</p>
                        <br>
                        <p><b>Manually:</b> By the entering the northmost, eastmost, southmost, and westmost coordinates of
                            the dataset.</p>
                        <br>
                        <p><i><b>Warning: The automatic bounding box created may be incorrect for the country, so please
                                    verify it before proceeding!</b></i></p>
                        <br>
                    </v-card-text>
                </v-card>
            </v-dialog>
            <v-dialog v-model="openPocHelpDialog" max-width="600px">
                <v-card>
                    <v-card-item>
                        <v-card-title class="d-flex justify-space-between">
                            Point of Contact Information
                            <v-btn icon="mdi-close" variant="text" size="small" @click="openPocHelpDialog = false" />
                        </v-card-title>
                        <v-card-subtitle>
                            How do I complete this section?
                        </v-card-subtitle>
                    </v-card-item>
                    <v-card-text>
                        <p>This section provides the information associated with one or more responsible parties of the
                            resource.</p>
                        <br>
                        <p><b>Organization Name:</b> The name of the organization.</p>
                        <br>
                        <p><b>Email:</b> The email address of the point of contact.</p>
                        <br>
                        <p><b>Country:</b> The country of the point of contact.</p>
                        <br>
                    </v-card-text>
                </v-card>
            </v-dialog>
        </v-col>
    </v-row>
</template>

<script>
import BboxEditor from "@/components/BboxEditor.vue";
import { clean } from "@/scripts/helpers.js";

import { defineComponent, ref, computed, onMounted, watch, watchEffect } from 'vue';
import { VCard, VForm, VBtn, VChipGroup, VChip } from 'vuetify/lib/components/index.mjs';

const oapi = import.meta.env.VITE_API_URL;

export default defineComponent({
    name: "DiscoveryMetadataForm",
    template: "#discovery-metadata-form",
    props: ["topic"],
    components: {
        BboxEditor,
        VCard,
        VForm,
        VBtn,
        VChipGroup,
        VChip
    },
    setup() {
        // Static variables

        // Default value of the form, not an exhaustive list of all fields
        const defaults = {
            identification: {
                identifier: 'urn:x-wmo:md:',
                keywords: [],
                wmoDataPolicy: 'core',
                concept: ['weather'],
                conceptSchemes: ['https://codes.wmo.int/wis/topic-hierarchy/earth-system-discipline']
            },
            extents: {},
            poc: {
                hoursOfService: "Hours: Mo-Fr 9am-5pm Sa 10am-5pm Su 10am-4pm",
                contactInstructions: 'Email'
            },
            distrib: {
                duplicateFromContact: true
            }
        };

        // Time durations for resolution
        const durations = [
            { name: 'minutes(s)', code: 'M' },
            { name: 'hour(s)', code: 'H' },
        ];

        // WCMP2 schema version
        const schemaVersion = "http://wis.wmo.int/spec/wcmp/2.0";

        // Validation patterns for form fields
        const rules = {
            required: (value) => !!value || "Field is required",
            centreID: value => /^[a-z_-]{2,}$/.test(value) || 'Invalid centre ID. Must be lowercase with at least 2 characters.',
            latitude: value => value >= -90 && value <= 90 || 'Latitude must be between -90 and 90.',
            longitude: value => value >= -180 && value <= 180 || 'Longitude must be between -180 and 180.',
            url: value => value === '' || /^https?:\/\/[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)$/.test(value) || 'Invalid URL format.',
            email: value => /^[a-z0-9._-]+@[a-z0-9-]+\.[a-z0-9.-]+$/.test(value) || 'Invalid email format.',
            keywords: value => Array.isArray(value) && value.length >= 3 || 'Keywords must be an array with at least 3 items.',
        };

        // Deep clone function to avoid reference issues between model and default model
        function deepClone(obj) {
            return JSON.parse(JSON.stringify(obj));
        }

        // Reactive variables

        // Controls loading animation
        const working = ref(false);
        // Controls which parts of the page are displayed
        const metadataLoaded = ref(false);
        const metadataValidated = ref(false);
        const formFilled = ref(true);
        // If no datasets can be found and the user must create a new one, disable the dataset selection
        const datasetSpecified = ref(false);
        // Messages to display to user (this changes overtime)
        const message = ref("Select existing discovery metadata file or create a new file.");
        // List of datasets to select from, if any
        const items = ref([]);
        // Dialog window
        const showDialog = ref(false);
        const templateFiles = ref([]);
        const selectedTemplate = ref(null);
        // Identifier of the selected dataset, used to load metadata from OAPI
        const identifier = ref("");
        // List of languages and language codes
        const languageCodeList = ref([]);
        // List of country names, alph-2 codes, and alpha-3 codes
        const countryCodeList = ref([]);
        // Object of country alpha-2 codes with bounding boxes
        const boundingBoxes = ref({});
        // Whether or not the metadata is new or existing
        const isNew = ref(false);
        // Geometry bounds
        const bounds = ref([[0, 0], [0, 0]]);
        // Country for the bbox - defaults to the POC country
        const bboxCountry = ref(null);
        // Phone number validation for each field
        const isPocPhoneValid = ref(null);
        const isDistribPhoneValid = ref(null);
        // Each keyword added by the user, before being added to the model
        const keyword = ref("");
        // Metadata form to be filled
        const model = ref({ 'identification': {}, 'extents': {}, 'poc': {}, 'distrib': {}, 'settings': {} });
        // Help dialog windows
        const openInitialHelpDialog = ref(false);
        const openIdentificationHelpDialog = ref(false);
        const openTemporalHelpDialog = ref(false);
        const openSpatialHelpDialog = ref(false);
        const openPocHelpDialog = ref(false);
        const openDistribHelpDialog = ref(false);

        // Computed variables

        // Has the user filled the dialog window?
        const dialogFilled = computed(() => {
            return model.value.identification.centreID && selectedTemplate.value;
        });

        // Filter the country code list so that only the countries
        // which have an automatic bounding box are shown
        const filteredCountryCodeList = computed(() => {
            const filteredList = countryCodeList.value.filter(country => {
                // Find out if the (lower case) alpha 2 code is in the bbox list
                return country["alpha-2"].toLowerCase() in boundingBoxes.value;
            });
            // Create a global option
            const global = { "name": "Global", "alpha-2": "int", "alpha-3": "int" };
            // Add this global option to the start of the list
            filteredList.unshift(global);
            return filteredList;
        });

        // Controls which parts of the page are displayed
        const formFilledAndValidated = computed(() => {
            return formFilled.value && metadataValidated.value;
        });

        // Methods

        // Fetches a list of metadata items from the OAPI and updates the list
        // This will be shown in the v-select component at the top of the page
        const loadList = async () => {
            try {
                // Get list of metadata items from wis2box
                const response = await fetch(`${oapi}/collections/discovery-metadata/items`)
                if (!response.ok) {
                    throw new Error('Network response was not okay, failed to load discovery metadata list.');
                }
                const responseData = await response.json();

                // Update the list of items
                items.value = responseData.features.map(item => item.properties.identifier);
                // At this point, the user has not specified a dataset
                datasetSpecified.value = false;
            } catch (error) {
                console.error(error);
                // Display error message to the user
                message.value = 'Error loading discovery metadata list.';
            }
            // Now add the option to create a new dataset, regardless of whether
            // the list could be loaded or not
            items.value.push('Create New...');
        };

        // Loads the data type templates
        const loadTemplates = async () => {
            // Load all JSON files in the models folder
            const files = import.meta.glob('@/models/*.json');

            // For each file, add the JSON data to the template list
            for (const path in files) {
                const file = await files[path]();
                templateFiles.value.push(file.default);
            }

            // Also push the 'other' datatype label
            templateFiles.value.push({ 'label': 'other' });
        }

        // When the metadata is loaded, it must be transformed to the format of the form
        // (this is because the form has a different structure to the schema)
        // It is easier to understand the transformToSchema method first, because this
        // method is just the inverse of that one
        const transformToForm = (schema) => {
            // Initialize form model
            let formModel = {
                identification: {},
                extents: {},
                poc: {},
                distrib: {},
                settings: {}
            };

            // Retrieve the identifier from the schema
            formModel.identification.identifier = schema.id;

            // Centre ID and topic hierarchy from wis2box section
            formModel.identification.centreID = schema.wis2box['centre_id'];
            formModel.identification.topicHierarchy = schema.wis2box['topic_hierarchy'];

            // Time period information
            if (schema.time?.interval) {
                formModel.extents.dateStarted = schema.time.interval[0];
                formModel.extents.dateStopped = schema.time.interval[1];
            }
            // Minimum time period resolvable in the dataset
            // Sets the resolution to the number, and unit to D or H
            if (schema.time?.resolution) {
                const match = schema.time.resolution.match(/P(\d+)([DH])/i);
                if (match) {
                    formModel.extents.resolution = parseInt(match[1]);
                    formModel.extents.resolutionUnit = match[2].toUpperCase();
                }
            }

            // Geometry information
            if (schema.geometry?.coordinates) {
                const coordinates = schema.geometry.coordinates[0];
                if (coordinates.length >= 4) {
                    formModel.extents.westLongitude = coordinates[0][0];
                    formModel.extents.northLatitude = coordinates[0][1];
                    formModel.extents.eastLongitude = coordinates[2][0];
                    formModel.extents.southLatitude = coordinates[2][1];
                }
            }

            // Properties information
            formModel.identification.title = schema.properties.title;
            formModel.identification.description = schema.properties.description;
            formModel.identification.language = schema.properties.language;
            formModel.identification.keywords = schema.properties.keywords;

            // Themes - hardcoded for now
            formModel.identification.concepts = ["weather"];
            formModel.identification.conceptSchemes = ["https://codes.wmo.int/wis/topic-hierarchy/earth-system-discipline"];

            // Contacts information
            schema.properties.contacts.forEach(contact => {
                if (contact.roles?.includes("host")) {
                    formModel.poc = {
                        individual: contact.name,
                        positionName: contact.position,
                        name: contact.organization,
                        phone: contact.phones ? contact.phones[0].value : '',
                        email: contact.emails ? contact.emails[0].value : '',
                        deliveryPoint: contact.addresses ? contact.addresses[0].deliveryPoint : '',
                        city: contact.addresses ? contact.addresses[0].city : '',
                        administrativeArea: contact.addresses ? contact.addresses[0].administrativeArea : '',
                        postalCode: contact.addresses ? contact.addresses[0].postalCode : '',
                        country: contact.addresses ? contact.addresses[0].country : '',
                        hoursOfService: contact.hoursOfService,
                        contactInstructions: contact.contactInstructions,
                        url: contact.links ? contact.links[0].href : ''
                    };
                }

                // Additional settings information
                if (schema.properties["wmo:dataPolicy"]) {
                    formModel.identification.wmoDataPolicy = schema.properties["wmo:dataPolicy"];
                }
            });
            return formModel;
        }

        // When the user specifies a dataset identifier, load the corresponding metadata
        const loadMetadata = async () => {
            // Page values
            console.log("Loading metadata...")
            working.value = true;
            metadataLoaded.value = false;
            datasetSpecified.value = true;
            message.value = 'Loading discovery metadata...';

            // If the user selects 'Create New...', populate the form with default values
            if (identifier.value === "Create New...") {
                isNew.value = true;
                // Set model to default values
                model.value = deepClone(defaults);
                metadataValidated.value = false;
                // Open the dialog window
                showDialog.value = true;
            }
            // Otherwise, populate the form with the loaded values
            else {
                isNew.value = false;
                try {
                    const response = await fetch(`${oapi}/collections/discovery-metadata/items/${identifier.value}`);
                    if (!response.ok) {
                        throw new Error('Network response was not okay, failed to load selected discovery metadata.');
                    }
                    const responseData = await response.json();
                    // The response data will have a different format to that of the form, so the data must be transformed
                    const formModel = transformToForm(responseData);
                    // Update the form (model) with the loaded values
                    model.value = formModel;
                    // Note: Set time delay to prevent watchers from firing too early
                    setTimeout(() => {
                        // Force bounding box map to update
                        updateBbox();
                        // As form was loaded, it must be already validated
                        metadataValidated.value = true;
                    }, 500); // Delay of 0.5 seconds
                } catch (error) {
                    console.log(error);
                    message.value = "Error loading selected discovery metadata file.";
                }
            }

            // Now update the UI

            // If no error, display the form and present a success message
            if (!message.value.includes("Error")) {
                metadataLoaded.value = true;
                message.value = "Discovery metadata loaded successfully.";
            }
            // Remove working animation
            working.value = false;
        };

        // Dialog window for autofilling form
        const continueToForm = () => {
            // Close the dialog
            showDialog.value = false;

            // Autofill the form based on the input datatype label
            if (selectedTemplate.value.label !== 'other') {
                applyTemplate(selectedTemplate.value);
            }
            else {
                // Apply sensible defaults for 'other' datatype
                defaultIdentification();
            }
        }

        // Find the corresponding alpha-2 code to an alpha-3 code
        const getAlpha2Code = (alpha3Code) => {
            // Check if the alpha-3 code is 'int' first
            if (alpha3Code === 'int') {
                return 'int';
            }
            // If it isn't 'int', find the corresponding alpha-2 code
            const country = countryCodeList.value.find(item => item["alpha-3"] === alpha3Code);
            // Return the code in lower case as we need it in this
            // form for founding the corresponding bbox
            return country["alpha-2"].toLowerCase();
        }

        // Get an automatic bounding box using the country code
        const getAutoBbox = async (alpha3Code) => {
            try {
                // Use this to find the corresponding alpha-2 code
                const alpha2Code = getAlpha2Code(alpha3Code);

                // Use the alpha-2 code to get the corresponding bbox
                const boundingBox = boundingBoxes.value[alpha2Code]['bbox'];

                // Now populate the form with the bounding box values
                model.value.extents.northLatitude = boundingBox.maxy;
                model.value.extents.eastLongitude = boundingBox.maxx;
                model.value.extents.southLatitude = boundingBox.miny;
                model.value.extents.westLongitude = boundingBox.minx;

            } catch (error) {
                console.error(error);
                message.value = "Error loading automatic bounding box.";
            }
        }

        // Autofill form based on template
        const applyTemplate = (template) => {
            model.value.identification.title = template.title.replace('$CENTRE_ID', model.value.identification.centreID);
            model.value.identification.identifier = template.identifier.replace('$CENTRE_ID', model.value.identification.centreID);
            // Converts the theme structure into a list of the theme labels
            model.value.identification.concepts = template.themes.flatMap(theme => theme.concepts.map(concept => concept.label));
            model.value.identification.conceptSchemes = template.themes.map(theme => theme.scheme);
            model.value.identification.keywords = template.keywords;
            // Use centre ID and WMO data policy to create topic hierarchy
            model.value.identification.topicHierarchy = template.topicHierarchy
                .replace('$CENTRE_ID', model.value.identification.centreID)
                .replace('$DATA_POLICY', model.value.identification.wmoDataPolicy);
            // Get resolution and resolution unit from template
            const match = template.resolution.match(/P(\d+)([DH])/i);
            if (match) {
                model.value.extents.resolution = parseInt(match[1]);
                model.value.extents.resolutionUnit = match[2].toUpperCase();
            }
            model.value.distrib.duplicateFromContact = template.duplicateFromContact;
        };

        // Load language/country codes from a JSON file
        const loadCodes = async () => {
            // Load language codes
            try {
                const response = await fetch(`${import.meta.env.VITE_BASE_URL}/codelists/iso-639-1-languages.json`);
                if (!response.ok) {
                    throw new Error('Failed to load language codes.');
                }
                const responseData = await response.json();
                languageCodeList.value = responseData;
            } catch (error) {
                console.error(error);
                message.value = "Error loading language codes.";
            }
            // Load country codes
            try {
                const response = await fetch(`${import.meta.env.VITE_BASE_URL}/codelists/iso-3366-1-countries.json`);
                if (!response.ok) {
                    throw new Error('Failed to load country codes.');
                }
                const responseData = await response.json();
                countryCodeList.value = responseData;
            } catch (error) {
                console.error(error);
                message.value = "Error loading country codes.";
            }
            // Load bounding boxes
            try {
                const response = await fetch(`${import.meta.env.VITE_BASE_URL}/codelists/country-bbox.json`);
                if (!response.ok) {
                    throw new Error('Failed to load bounding boxes.');
                }
                const responseData = await response.json();
                // Remove the countries header as it is redundant
                boundingBoxes.value = responseData['countries'];
            } catch (error) {
                console.error(error);
                message.value = "Error loading default bounding boxes.";
            }
        };

        // Create sensible defaults for the identifier and topic
        // hierarchy when the user selects the 'other' datatype
        const defaultIdentification = () => {
            // If the template datatype label is not 'other', exit
            if (selectedTemplate.value?.label !== 'other') {
                return;
            }

            // Otherwise, create sensible defaults
            model.value.identification.identifier = 'urn:x-wmo:md:' + model.value.identification.centreID + ':';
            model.value.identification.topicHierarchy = model.value.identification.centreID + '.data.' + model.value.identification.wmoDataPolicy + '.';
        }

        // Update the rectangle in the map when the user changes the bounding box
        const updateBbox = () => {
            bounds.value = [
                model.value.extents.northLatitude || 90,
                model.value.extents.eastLongitude || -180,
                model.value.extents.southLatitude || -90,
                model.value.extents.westLongitude || 180
            ];
        };

        // Validates the phone numbers entered by the user
        const onPocPhoneValidate = (output) => {
            isPocPhoneValid.value = output.valid;
        };

        const onDistribPhoneValidate = (output) => {
            isDistribPhoneValid.value = output.valid;
        }

        // Adds a keyword to the model
        const addKeyword = () => {
            if (keyword.value !== "") {
                // Add keyword to array
                model.value.identification.keywords.push(keyword.value);
                keyword.value = "";
            }
        };

        // Remove keyword from model when chip is clicked
        const removeKeyword = (keywordToRemove) => {
            const index = model.value.identification.keywords.indexOf(keywordToRemove);
            if (index > -1) {
                // Create a shallow copy first
                let updatedKeywords = [...model.value.identification.keywords];

                // Remove the item at the specified index
                updatedKeywords.splice(index, 1);

                // Reassign the model's keywords to the updated array
                model.value.identification.keywords = updatedKeywords;
            }
        };

        // Resets the metadata form to the default state
        const resetMetadata = () => {
            model.value = deepClone(defaults);
            metadataValidated.value = false;
            formFilled.value = false;
            message.value = "Discovery metadata reset successfully.";
        };

        // Method to get the date from a datetime
        const getDateFrom = (datetime) => {
            let date = new Date(datetime);
            let year = date.getFullYear();
            // getMonth() returns 0-11, so we add 1
            let month = date.getMonth() + 1;
            let day = date.getDate();

            // Format the date as YYYY-MM-DD
            let dateString = `${year}-${month}-${day}`;
            return dateString;
        }

        // Transforms the form data to the WCMP2 schema format
        const transformToSchema = (form) => {
            // Initialise schema model
            let schemaModel = {};

            // Starting information
            schemaModel.id = form.identification.identifier;
            schemaModel.conformsTo = [schemaVersion];
            schemaModel.type = "Feature";

            // wis2box information
            // Note: This is an extension to the WCMP2 schema
            schemaModel.wis2box = {};
            schemaModel.wis2box["topic_hierarchy"] = form.identification.topicHierarchy;
            schemaModel.wis2box.country = form.poc.country;
            schemaModel.wis2box["centre_id"] = form.identification.centreID;

            // Time period information
            schemaModel.time = {};
            // Get the start and end dates from the form
            const startDate = getDateFrom(form.extents.dateStarted);
            const endDate = getDateFrom(form.extents.dateStopped);
            schemaModel.time.interval = [startDate, endDate];
            schemaModel.time.resolution = `P${form.extents.resolution}${form.extents.resolutionUnit}`;

            // Geometry information
            schemaModel.geometry = {
                type: "Polygon",
                coordinates: [
                    [
                        // Top left corner
                        [form.extents.westLongitude, form.extents.northLatitude],
                        // Top right corner
                        [form.extents.eastLongitude, form.extents.northLatitude],
                        // Bottom right corner
                        [form.extents.eastLongitude, form.extents.southLatitude],
                        // Bottom left corner
                        [form.extents.westLongitude, form.extents.southLatitude],
                        // Back top top left corner to close the polygon
                        [form.extents.westLongitude, form.extents.northLatitude]
                    ]
                ]
            };

            // Properties information
            schemaModel.properties = {};
            schemaModel.properties.title = form.identification.title;
            schemaModel.properties.description = form.identification.description;
            schemaModel.properties.keywords = form.identification.keywords;
            // Themes
            const concepts = form.identification.concepts.map(item => ({ title: item }));
            schemaModel.properties.themes = [
                {
                    concepts: concepts,
                    scheme: form.identification.conceptSchemes
                }
            ]
            // Contacts information
            schemaModel.properties.contacts = [];
            // Point of contact
            schemaModel.properties.contacts.push({
                name: form.poc.individual,
                position: form.poc.positionName,
                organization: form.poc.name,
                phones: [{
                    value: form.poc.phone
                }],
                emails: [{
                    value: form.poc.email
                }],
                addresses: [{
                    deliveryPoint: form.poc.deliveryPoint,
                    city: form.poc.city,
                    administrativeArea: form.poc.administrativeArea,
                    postalCode: form.poc.postalCode,
                    country: form.poc.country
                }],
                links: [{
                    href: form.poc.url
                }],
                hoursOfService: form.poc.hoursOfService,
                contactInstructions: form.poc.contactInstructions,
                roles: ["host"]
            });

            // How should we approach the creation date?
            schemaModel.properties.updated = new Date().toISOString();
            schemaModel.properties["wmo:dataPolicy"] = form.identification.wmoDataPolicy;


            // Links information
            schemaModel.links = [];
            schemaModel.links.push({
                rel: "collection",
                href: `${form.poc.url}/oapi/collections/${form.identification.identifier}`,
                title: form.identification.identifier
            })
            schemaModel.links.push({
                rel: "canonical",
                href: `${form.poc.url}/oapi/collections/discovery-metadata/items/${form.identification.identifier}`,
                title: form.identification.identifier
            });

            return schemaModel;
        };

        // Validate the metadata generated by the format against the WCMP2 schema
        const validateMetadata = async () => {
            // Push the form data transformed to the schema format
            try {
                const schemaModel = transformToSchema(model.value);
                const response = await fetch(`${oapi}/processes/pywcmp-wis2-wcmp2-ets/execution`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        "inputs": {
                            "record": schemaModel
                        }
                    })
                })

                if (!response.ok) {
                    throw new Error('Network response was not okay, failed to validate discovery metadata.');
                }

                const responseData = await response.json();

                // If there is a code in the response, then the validation failed
                if ("code" in responseData) {
                    // Display the error message to the user
                    message.value = `Discovery metadata not valid: ${responseData.message}`;
                    // Temporary set the validation state to true regardless
                    metadataValidated.value = true;
                }
                else {
                    // Otherwise, the validation succeeded
                    message.value = "Discovery metadata validated successfully.";
                    metadataValidated.value = true;
                }
            } catch (error) {
                console.error(error);
                message.value = "Error validating discovery metadata.";
                // Temporary set the validation state to true regardless
                metadataValidated.value = true;
            }
        };

        // Generates a downloadable JSON file from the filled and validated form, which follows the WCMP2 schema
        const downloadMetadata = () => {
            // Transform the model to the WCMP2 schema formatted version
            const schemaModel = transformToSchema(model.value);
            // Encode as a JSON
            const content = encodeURI(JSON.stringify(schemaModel, null, 4))
            const element = document.createElement("a")
            // Download the file
            element.href = "data:attachment/text," + content
            element.target = "_blank"
            element.download = "discovery-metadata.json"
            element.click()
        }

        // Submits the metadata to the wis2box OAPI endpoint
        const submitMetadata = async () => {
            try {
                let response;
                // If metadata is new, post the schema formatted version to the OAPI
                if (isNew.value) {
                    const schemaModel = transformToSchema(model.value);
                    response = await fetch(`${oapi}/collections/discovery-metadata/items`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(schemaModel)
                    })
                }
                // If updating existing metadata, put the schema formatted version to the OAPI
                else {
                    const schemaModel = transformToSchema(model.value);
                    response = await fetch(`${oapi}/collections/discovery-metadata/items/${identifier.value}`, {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(schemaModel)
                    })
                }
                // Check response from OAPI
                if (!response.ok) {
                    throw new Error('Network response was not okay, failed to submit discovery metadata.');
                }

                // If post/put successful, redirect user to home page
                if ((isNew.value && response.status === 201) || (!isNew.value && response.status === 204)) {
                    window.location.href = "/"
                }
                // Otherwise, show a message with the description of the response
                else {
                    const responseData = await response.json()
                    message.value = responseData.description;
                }
            } catch (error) {
                console.error(error);
                // If there is an error, display the appropriate error message to the user
                message.value = isNew.value ? "Error adding discovery metadata." : "Error updating discovery metadata.";
            }
        };

        // Mounted
        onMounted(() => {
            loadList();
            loadTemplates();
            loadCodes();
        });

        // Watched

        // If the user changes the data policy, update the topic hierarcy
        // using the template
        watch(() => model.value.identification.wmoDataPolicy, () => {
            if (selectedTemplate.value && selectedTemplate.value?.label !== 'other') {
                applyTemplate(selectedTemplate.value);
            }
        });

        // Set the validation state to false when the user makes a change to the form
        watch(() => deepClone(model.value), (oldVal, newVal) => {
            if (oldVal !== newVal) {
                metadataValidated.value = false;
            }
        });

        // Also set the validation state to false if the formFilled value changes
        watch(() => formFilled.value, (oldVal, newVal) => {
            // Set metadataValidated.value to false whenever formFilled is changed
            if (oldVal !== newVal) {
                metadataValidated.value = false;
            }
        });

        // Update the map when the user changes the bounding box
        watch(() => deepClone(model.value.extents), () => {
            updateBbox();
        });

        return {
            defaults,
            durations,
            schemaVersion,
            rules,
            working,
            metadataLoaded,
            metadataValidated,
            formFilled,
            datasetSpecified,
            message,
            items,
            showDialog,
            templateFiles,
            dialogFilled,
            filteredCountryCodeList,
            selectedTemplate,
            identifier,
            languageCodeList,
            countryCodeList,
            isNew,
            bounds,
            bboxCountry,
            isPocPhoneValid,
            isDistribPhoneValid,
            keyword,
            model,
            openInitialHelpDialog,
            openIdentificationHelpDialog,
            openTemporalHelpDialog,
            openSpatialHelpDialog,
            openPocHelpDialog,
            openDistribHelpDialog,
            formFilledAndValidated,
            loadList,
            loadMetadata,
            continueToForm,
            getAutoBbox,
            onPocPhoneValidate,
            onDistribPhoneValidate,
            addKeyword,
            removeKeyword,
            resetMetadata,
            validateMetadata,
            downloadMetadata,
            submitMetadata
        }
    }
});

</script>