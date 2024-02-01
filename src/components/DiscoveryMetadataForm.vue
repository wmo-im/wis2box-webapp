<template>
    <v-row class="justify-center">
        <v-col cols="12" class="max-dashboard-width">
            <v-card-title class="big-title">Metadata Editor Form</v-card-title>
            <v-card>
                <!-- Toolbar for user to select a dataset -->
                <v-toolbar color="#003DA5">
                    <v-toolbar-title>Please choose a dataset</v-toolbar-title>
                    <v-select class="mt-11" label="Dataset" v-model="identifier" :items="items"
                        @update:modelValue="loadMetadata" :disabled="datasetSpecified" variant="underlined"></v-select>
                </v-toolbar>

                <!-- Until loaded, play a loading animation -->
                <v-progress-linear indeterminate color="primary" :active="working" />

                <!-- Dialog window -->
                <v-dialog v-model="showDialog" max-width="600px">
                    <v-card>
                        <v-card-title>
                            Please enter some initial information
                        </v-card-title>
                        <v-card-text>
                            <v-autocomplete label="Country" hint="ISO3166 3-letter code" persistent-hint
                                :items="countryCodeList" v-model="model.poc.country" :rules="[rules.required]"
                                variant="outlined"></v-autocomplete>
                            <v-text-field v-model="model.origin.centreID" label="Centre ID"
                                persistent-hint="Agency acronym (in lower case), as specified by member"
                                variant="outlined"></v-text-field>
                            <v-select v-model="datatype" :items="['synop', 'temp', 'other']" label="Data Type"
                                variant="outlined"></v-select>
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
                    <v-card-title>Dataset Identification</v-card-title>
                    <v-row dense>
                        <v-col cols="5">
                            <v-text-field label="Title" hint="Name of data" type="string" v-model="model.identification.title"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="5">
                            <v-text-field label="Description" hint="Brief description of data" type="string"
                                v-model="model.identification.description" :rules="[rules.required]" variant="outlined"
                                clearable></v-text-field>
                        </v-col>

                        <v-col cols="2">
                            <v-autocomplete label="Language" hint="ISO639 2-letter code" persistent-hint
                                v-model="model.identification.language" :items="languageCodeList" :rules="[rules.required]"
                                variant="outlined"></v-autocomplete>
                        </v-col>
                    </v-row>

                    <!-- Origin section -->
                    <v-card-title>Dataset Origin</v-card-title>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="Centre ID" hint="Agency acronym (in lower case), as specified by member"
                                type="string" v-model="model.origin.centreID" :rules="[rules.required, rules.centreID]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-card-title>Temporal Properties</v-card-title>
                    <v-row dense>
                        <v-col cols="3">
                            <VueDatePicker placeholder="Date Started in UTC" v-model="model.origin.dateStarted"
                                :teleport="true" :enable-time-picker="false" auto-apply required />
                        </v-col>

                        <v-col cols="3">
                            <VueDatePicker placeholder="Date Stopped in UTC" v-model="model.origin.dateStopped"
                                :teleport="true" :enable-time-picker="false" auto-apply required />
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label=" Time Resolution" hint="Frequency of data updates, e.g. 1h" type="string"
                                v-model="model.settings.resolution" :rules="[rules.required]" variant="outlined"
                                clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-card-title>Spatial Properties</v-card-title>
                    <v-row>
                        <v-col cols="12">
                            <!-- Bounding box editor -->
                            <bbox-editor :box-bounds="bounds"></bbox-editor>
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col cols="3">
                            <v-text-field label="North Latitude" hint="Northmost latitude of data region" type="float"
                                v-model="model.origin.northLatitude" :rules="[rules.required, rules.latitude]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="East Longitude" hint="Eastmost longitude of data region" type="float"
                                v-model="model.origin.eastLongitude" :rules="[rules.required, rules.longitude]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="South Latitude" hint="Southmost latitude of data region" type="float"
                                v-model="model.origin.southLatitude" :rules="[rules.required, rules.latitude]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="West Longitude" hint="Westmost longitude of data region" type="float"
                                v-model="model.origin.westLongitude" :rules="[rules.required, rules.longitude]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>

                    <!-- Settings section -->
                    <v-card-title>Dataset Settings</v-card-title>
                    <v-row dense>
                        <v-col cols="6">
                            <v-text-field label="Identifier" hint="Unique identifier for this data" type="string"
                                v-model="model.settings.identifier" :rules="[rules.required, rules.identifier]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Topic Hierarchy" hint="Unique hierarchy for this data" type="string"
                                v-model="model.settings.topicHierarchy" :rules="[rules.required, rules.topicHierarchy]"
                                variant="outlined"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="6">
                            <v-row>
                                <v-col cols="4">
                                    <v-text-field label="Retention"
                                        hint="Minimum length of time data should be retained in WIS2" type="string"
                                        v-model="model.settings.retention" :rules="[rules.required]" variant="outlined"
                                        clearable></v-text-field>
                                </v-col>

                                <v-col cols="4">
                                    <v-select label="WMO Data Policy" hint="Priority of data within WMO" type="string"
                                        :items="['core', 'recommended', 'weather']" v-model="model.settings.wmoDataPolicy"
                                        :rules="[rules.required]" variant="outlined"></v-select>
                                </v-col>

                                <v-col cols="4">
                                    <v-select label="WMO Status" hint="Status of data within WMO" type="string"
                                        :items="['operational', 'not operational']" v-model="model.settings.wmoStatus"
                                        :rules="[rules.required]" variant="outlined"></v-select>
                                </v-col>
                            </v-row>
                        </v-col>
                        <v-col cols="6">
                            <v-row dense>
                                <v-col cols="10">
                                    <v-text-field label="Keywords (3 minimum)" hint="Search keywords for data" type="array"
                                        v-model="keyword" @keyup.enter="addKeyword" variant="outlined"
                                        clearable></v-text-field>

                                </v-col>
                                <v-col cols="2">
                                    <v-btn color="#003DA5" variant="flat" icon="mdi-plus" size="large" @click="addKeyword"
                                        :disabled="keyword == ''"></v-btn>
                                </v-col>
                            </v-row>
                            <v-row dense>
                                <v-col cols="auto">
                                    <v-chip-group :rules="[rules.required, rules.keywords]">
                                        <v-chip v-for="keyword in model.settings.keywords" :key="keyword" closable label
                                            @click:close="removeKeyword(keyword)">
                                            {{ keyword }}
                                        </v-chip>
                                    </v-chip-group>
                                </v-col>
                            </v-row>
                        </v-col>
                    </v-row>

                    <!-- Contact (POC) section -->
                    <v-card-title>Point of Contact Information</v-card-title>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="Individual" hint="Full name" type="string" v-model="model.poc.individual"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Position Name" hint="Position held" type="string"
                                v-model="model.poc.positionName" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Name" hint="Organization name" type="string" v-model="model.poc.name"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="URL" hint="Organization website" type="string" v-model="model.poc.url"
                                :rules="[rules.url]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <vue-tel-input v-model="model.poc.phone" @validate="onPocPhoneValidate"></vue-tel-input>
                            <p v-if="(typeof isPocPhoneValid !== 'undefined') && !isPocPhoneValid"
                                class="hint-text hint-invalid">Phone number is not valid</p>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Email" hint="Contact email address" type="string" v-model="model.poc.email"
                                :rules="[rules.required, rules.email]" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="Address" hint="Street address" type="string"
                                v-model="model.poc.deliveryPoint" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="City" hint="Mailing city" type="string" v-model="model.poc.city"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="State" hint="Mailing state or region" type="string"
                                v-model="model.poc.administrativeArea" :rules="[rules.required]" variant="outlined"
                                clearable></v-text-field>
                        </v-col>

                    </v-row>
                    <v-row dense>
                        <v-col cols="3">
                            <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                                v-model="model.poc.postalCode" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-autocomplete label="Country" hint="ISO3166 3-letter code" persistent-hint
                                :items="countryCodeList" v-model="model.poc.country" :rules="[rules.required]"
                                variant="outlined"></v-autocomplete>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Hours of Service" hint="Time period to be contacted"
                                v-model="model.poc.hoursOfService" :rules="[rules.required]" variant="outlined"
                                clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="6">
                            <v-text-field label="Contact Instructions" hint="Preferred contact method" type="string"
                                v-model="model.poc.contactInstructions" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>

                    <!-- Distributor section -->
                    <v-row dense>
                        <v-card-title>Distributor Information</v-card-title>
                        <v-switch label="Same As Contact Info?" v-model="model.distrib.duplicateFromContact"
                            color="#003DA5"></v-switch>
                    </v-row>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="Individual" hint="Full name" type="string"
                                v-model="model.distrib.individual" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Position Name" hint="Position held" type="string"
                                v-model="model.distrib.positionName" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Name" hint="Organization name" type="string" v-model="model.distrib.name"
                                :rules="[rules.required]" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="URL" hint="Organization website" type="string" v-model="model.distrib.url"
                                :rules="[rules.url]" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                        <v-col cols="4" :disabled="!distributorFieldsEnabled">
                            <vue-tel-input v-model="model.distrib.phone" :disabled="!distributorFieldsEnabled"
                                @validate="onDistribPhoneValidate"></vue-tel-input>
                            <p v-if="(typeof isDistribPhoneValid !== 'undefined') && !isPocPhoneValid"
                                class="hint-text hint-invalid">Phone number is not valid</p>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Email" hint="Contact email address" type="string"
                                v-model="model.distrib.email" :rules="[rules.required, rules.email]" variant="outlined"
                                clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="Address" hint="Street address" type="string"
                                v-model="model.distrib.deliveryPoint" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="City" hint="Mailing city" type="string" v-model="model.distrib.city"
                                :rules="[rules.required]" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="State" hint="Mailing state or region" type="string"
                                v-model="model.distrib.administrativeArea" :rules="[rules.required]" variant="outlined"
                                clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="3">
                            <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                                v-model="model.distrib.postalCode" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-autocomplete label="Country" hint="Upper case representation of ISO3166 3-letter code"
                                persistent-hint :items="countryCodeList" v-model="model.distrib.country"
                                :rules="[rules.required]" :disabled="!distributorFieldsEnabled"
                                variant="outlined"></v-autocomplete>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Hours of Service" hint="Time period to be contacted"
                                v-model="model.distrib.hoursOfService" :rules="[rules.required]" variant="outlined"
                                clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="6">
                            <v-text-field label="Contact Instructions" hint="Preferred contact method" type="string"
                                v-model="model.distrib.contactInstructions" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
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
                    <v-btn color="#009900" class="ma-2" title="Validate" @click="validateMetadata" :disabled="!formFilled"
                        v-if="!metadataValidated" append-icon="mdi-check-bold">
                        Validate
                    </v-btn>

                    <v-btn color="#E09D00" class="ma-2" title="Export" @click="downloadMetadata"
                        :disabled="!formFilledAndValidated" v-if="metadataValidated"
                        append-icon="mdi-arrow-down-bold-box-outline">
                        Export
                    </v-btn>

                    <v-btn color="#64BF40" class="ma-2" title="Submit" @click="submitMetadata"
                        :disabled="!formFilledAndValidated" v-if="metadataValidated" append-icon="mdi-cloud-upload">
                        Submit
                    </v-btn>
                </v-row>
            </v-card>
        </v-col>
    </v-row>
</template>

<script>
import BboxEditor from "@/components/BboxEditor.vue";
import { clean } from "@/scripts/helpers.js";
import synopTemplate from '@/models/synop-template.json';
import tempTemplate from '@/models/temp-template.json';

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
            identification: {},
            origin: {},
            poc: {
                hoursOfService: "Hours: Mo-Fr 9am-5pm Sa 10am-5pm Su 10am-4pm",
                contactInstructions: 'Email'
            },
            distrib: {
                duplicateFromContact: true
            },
            settings: {
                identifier: 'urn:x-wmo:md:',
                wmoDataPolicy: 'core',
                wmoStatus: 'operational',
                keywords: []
            }
        };

        // Test model
        const testModel = {
            identification: {
                title: "Test Dataset",
                description: "This is a test dataset",
                language: "en"
            },
            origin: {
                centreID: "test",
                dateStarted: "2021-01-01T00:00:00Z",
                dateStopped: "2021-01-01T00:00:00Z",
                resolution: "1h",
                northLatitude: 90,
                eastLongitude: 180,
                southLatitude: -90,
                westLongitude: -180
            },
            poc: {
                individual: "Test User",
                positionName: "Test Position",
                name: "Test Organization",
                url: "https://www.test.com",
                phone: "+41 77 345 67 89",
                email: "contact@example.org",
                deliveryPoint: "123 Test Street",
                city: "Test City",
                administrativeArea: "Test State",
                postalCode: "12345",
                country: "USA",
                hoursOfService: "Hours: Mo-Fr 9am-5pm Sa 10am-5pm Su 10am-4pm",
                contactInstructions: "Email"
            },
            distrib: {
                duplicateFromContact: false,
                individual: "Test User",
                positionName: "Test Position",
                name: "Test Organization",
                url: "https://www.test.com",
                phone: "+41 77 345 67 89",
                email: "contact@example.org",
                deliveryPoint: "123 Test Street",
                city: "Test City",
                administrativeArea: "Test State",
                postalCode: "12345",
                country: "USA",
                hoursOfService: "Hours: Mo-Fr 9am-5pm Sa 10am-5pm Su 10am-4pm",
                contactInstructions: "Email"
            },
            settings: {
                identifier: "urn:x-wmo:md:zmb:zambia_met_service:surface-weather-observations",
                wmoDataPolicy: "core",
                wmoStatus: "operational",
                retention: "30d",
                keywords: [
                    "weather",
                    "climate",
                    "data"
                ]
            }
        };

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
            country: value => /^[A-Z]{3}$/.test(value) || 'Invalid country code. Must be 3 uppercase letters.',
            identifier: value => /^urn:x-wmo:md:[a-z]{3}:[a-z0-9_-]+:[a-z0-9_-]+[a-z0-9:-]*$/.test(value) || 'Invalid identifier. Must start with \'urn:x-wmo:md:\'',
            topicHierarchy: value => /^[a-z]{3}\/[_a-z-]+\/(data|metadata|reports)\/(core|recommended)\/[\\w]+\/[\\w-]+\/[\\w]*$/.test(value) || 'Invalid topic hierarchy. Follow the specified pattern.',
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
        const datatype = ref("");
        // Identifier of the selected dataset, used to load metadata from OAPI
        const identifier = ref("");
        // List of language codes to select from
        const languageCodeList = ref([]);
        // List of country codes to select from
        const countryCodeList = ref([]);
        // Whether or not the metadata is new or existing
        const isNew = ref(false);
        // Geometry bounds
        const bounds = ref([[0, 0], [0, 0]]);
        // Phone number validation for each field
        const isPocPhoneValid = ref(null);
        const isDistribPhoneValid = ref(null);
        // Each keyword added by the user, before being added to the model
        const keyword = ref("");
        // Metadata form to be filled
        const model = ref({ 'identification': {}, 'origin': {}, 'poc': {}, 'distrib': {}, 'settings': {} });

        // Computed variables

        // Has the user filled the dialog window?
        const dialogFilled = computed(() => {
            return model.value.poc.country && model.value.origin.centreID && datatype.value !== "";
        });

        // Controls which parts of the page are displayed
        const formFilledAndValidated = computed(() => {
            return formFilled.value && metadataValidated.value;
        });
        // Whether or not the distributor fields should be enabled, based on whether the user checks the box to duplicate the contact info
        const distributorFieldsEnabled = computed(() => {
            return !model.value.distrib.duplicateFromContact;
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

        // When the metadata is loaded, it must be transformed to the format of the form
        // (this is because the form has a different structure to the schema)
        // It is easier to understand the transformToSchema method first, because this
        // method is just the inverse of that one
        const transformToForm = (schema) => {
            // Initialize form model
            let formModel = {
                identification: {},
                origin: {},
                poc: {},
                distrib: {},
                settings: {}
            };

            // Retrieve the identifier from the schema
            formModel.settings.identifier = schema.id;

            // Time period information
            if (schema.time?.interval) {
                formModel.origin.dateStarted = schema.time.interval[0];
                formModel.origin.dateStopped = schema.time.interval[1];
            }
            // Minimum time period resolvable in the dataset
            if (schema.time?.resolution) {
                formModel.origin.resolution = schema.time.resolution.replace('P', '').toLowerCase();
            }

            // Geometry information
            if (schema.geometry?.coordinates) {
                const coordinates = schema.geometry.coordinates[0];
                if (coordinates.length >= 4) {
                    formModel.origin.westLongitude = coordinates[0][0];
                    formModel.origin.northLatitude = coordinates[0][1];
                    formModel.origin.eastLongitude = coordinates[2][0];
                    formModel.origin.southLatitude = coordinates[2][1];
                }
            }

            // Properties information
            formModel.identification.title = schema.properties.title;
            formModel.identification.description = schema.properties.description;
            formModel.identification.language = schema.properties.language;
            formModel.settings.keywords = schema.properties.keywords;

            // Contacts information
            schema.properties.contacts.forEach(contact => {
                if (contact.roles?.includes("pointOfContact")) {
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
                } else if (contact.roles?.includes("distributor")) {
                    formModel.distrib = {
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
                    formModel.settings.wmoDataPolicy = schema.properties["wmo:dataPolicy"];
                }
                if (schema.properties["wmo:status"]?.id) {
                    formModel.settings.wmoStatus = schema.properties["wmo:status"].id;
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
                    // As form was loaded, it must be already validated
                    // Note: Set time delay to prevent watcher from firing too early
                    setTimeout(() => {
                        metadataValidated.value = true;
                    }, 1000); // Delay of 1 second
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

            // Autofill the form based on the input datatype
            if (datatype.value === 'synop') {
                applyTemplate(synopTemplate);
            } else if (datatype.value === 'temp') {
                applyTemplate(tempTemplate);
            }
            else {
                // At a minimum, automatically find the bounding box
                getAutoBbox(model.value.poc.country)
            }
        }

        // Find the corresponding alpha-2 code to an alpha-3 code
        const getAlpha2Code = (alpha3Code, countries) => {
            const country = countries.find(item => item["alpha-3"] === alpha3Code);
            // Return the code in lower case as we need it in this
            // form for founding the corresponding bbox
            return country["alpha-2"].toLowerCase();
        }

        // Get an automatic bounding box using the country code
        const getAutoBbox = async (alpha3Code) => {
            try {
                // Load country codes
                const countriesResponse = await fetch(`${import.meta.env.VITE_BASE_URL}/codelists/iso-3366-1-countries.json`);
                if (!countriesResponse.ok) {
                    throw new Error('Failed to load country codes.');
                }
                const countries = await countriesResponse.json();

                // Use this to find the corresponding alpha-2 code
                const alpha2Code = getAlpha2Code(alpha3Code, countries);

                // Load bounding boxes
                const bboxesResponse = await fetch(`${import.meta.env.VITE_BASE_URL}/codelists/country-bbox.json`);
                if (!bboxesResponse.ok) {
                    throw new Error('Failed to load bounding boxes.');
                }
                const bboxes = await bboxesResponse.json();

                // Use the alpha-2 code to get the corresponding bbox
                const boundingBox = bboxes['countries'][alpha2Code]['bbox'];

                // Now populate the form with the bounding box values
                model.value.origin.northLatitude = boundingBox.maxy;
                model.value.origin.eastLongitude = boundingBox.maxx;
                model.value.origin.southLatitude = boundingBox.miny;
                model.value.origin.westLongitude = boundingBox.minx;

            } catch (error) {
                console.error(error);
                message.value = "Error loading automatic bounding box.";
            }
        }

        // Autofill form based on template
        const applyTemplate = (template) => {
            model.value.identification.title = template.title.replace('$CENTRE_ID', model.value.origin.centreID);
            model.value.identification.language = template.language;
            model.value.origin.resolution = template.resolution;
            model.value.distrib.duplicateFromContact = template.duplicateFromContact;
            // Remove the P and make lower case (P30D -> 30d)
            model.value.settings.retention = template.retention.substring(1).toLowerCase();
            model.value.settings.identifier = template.identifier.replace('$CENTRE_ID', model.value.origin.centreID);
            model.value.settings.topicHierarchy = template.topicHierarchy.replace('$CENTRE_ID', model.value.origin.centreID);
            model.value.settings.keywords = template.keywords;

            // Now update the bounding box values
            getAutoBbox(model.value.poc.country);
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
                languageCodeList.value = responseData.map(item => item.code);
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
                countryCodeList.value = responseData.map(item => item["alpha-3"]);
            } catch (error) {
                console.error(error);
                message.value = "Error loading country codes.";
            }
        };

        // Update the rectangle in the map when the user changes the bounding box
        const updateBbox = () => {
            bounds.value = [
                model.value.origin.northLatitude || 90,
                model.value.origin.eastLongitude || -180,
                model.value.origin.southLatitude || -90,
                model.value.origin.westLongitude || 180
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
                (model.value).settings.keywords.push(keyword.value);
                keyword.value = "";
            }
        };

        // Remove keyword from model when chip is clicked
        const removeKeyword = (keywordToRemove) => {
            const index = model.value.settings.keywords.indexOf(keywordToRemove);
            if (index > -1) {
                // Create a shallow copy first
                let updatedKeywords = [...model.value.settings.keywords];

                // Remove the item at the specified index
                updatedKeywords.splice(index, 1);

                // Reassign the model's keywords to the updated array
                model.value.settings.keywords = updatedKeywords;
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
            schemaModel.id = form.settings.identifier;
            schemaModel.conformsTo = [schemaVersion];
            schemaModel.type = "Feature";

            // Time period information
            schemaModel.time = {};
            // Get the start and end dates from the form
            const startDate = getDateFrom(form.origin.dateStarted);
            const endDate = getDateFrom(form.origin.dateStopped);
            schemaModel.time.interval = [startDate, endDate];
            schemaModel.time.resolution = `P${form.origin.resolution.toUpperCase()}`;

            // Geometry information
            schemaModel.geometry = {
                type: "Polygon",
                coordinates: [
                    [
                        // Top left corner
                        [form.origin.westLongitude, form.origin.northLatitude],
                        // Top right corner
                        [form.origin.eastLongitude, form.origin.northLatitude],
                        // Bottom right corner
                        [form.origin.eastLongitude, form.origin.southLatitude],
                        // Bottom left corner
                        [form.origin.westLongitude, form.origin.southLatitude],
                        // Back top top left corner to close the polygon
                        [form.origin.westLongitude, form.origin.northLatitude]
                    ]
                ]
            };

            // Properties information
            schemaModel.properties = {};
            schemaModel.properties.title = form.identification.title;
            schemaModel.properties.description = form.identification.description;
            schemaModel.properties.keywords = form.settings.keywords;
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
                roles: ["pointOfContact"]
            });
            // Distributor
            schemaModel.properties.contacts.push({
                name: form.distrib.individual,
                position: form.distrib.positionName,
                organization: form.distrib.name,
                phones: [{
                    value: form.distrib.phone
                }],
                emails: [{
                    value: form.distrib.email
                }],
                addresses: [{
                    deliveryPoint: form.distrib.deliveryPoint,
                    city: form.distrib.city,
                    administrativeArea: form.distrib.administrativeArea,
                    postalCode: form.distrib.postalCode,
                    country: form.distrib.country
                }],
                links: [{
                    href: form.distrib.url
                }],
                hoursOfService: form.distrib.hoursOfService,
                contactInstructions: form.distrib.contactInstructions,
                roles: ["distributor"]
            });

            // Extra information
            schemaModel.properties.language = form.identification.language;
            // How should we approach the creation date?
            schemaModel.properties.updated = new Date().toISOString();
            schemaModel.properties["wmo:dataPolicy"] = form.settings.wmoDataPolicy;
            schemaModel.properties["wmo:status"] = {
                id: form.settings.wmoStatus
            };

            // Links information
            schemaModel.links = [];
            schemaModel.links.push({
                rel: "collection",
                href: `${form.poc.url}/oapi/collections/${form.settings.identifier}`,
                type: "OAFeat",
                title: form.settings.identifier
            })
            schemaModel.links.push({
                rel: "canonical",
                href: `${form.poc.url}/oapi/collections/discovery-metadata/items/${form.settings.identifier}`,
                type: "OARec",
                title: form.settings.identifier
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
                    metadataValidated.value = false;
                }
                else {
                    // Otherwise, the validation succeeded
                    message.value = "Discovery metadata validated successfully.";
                    metadataValidated.value = true;
                }
            } catch (error) {
                console.error(error);
                message.value = "Error validating discovery metadata.";
                metadataValidated.value = false;
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
                    response = await fetch(`${oapi.value}/collections/discovery-metadata/items`, {
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
                    response = await fetch(`${oapi.value}/collections/discovery-metadata/items/${identifier.value}`, {
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
            loadCodes();
        });

        // Watched

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
        watch(() => deepClone(model.value.origin), () => {
            updateBbox();
        });

        // Watch for the distributor checkbox to duplicate the contact info any time the POC information is changed
        // Note that watchEffect is used here instead of watch, because it should re run whenever any reactive dependency changes
        watchEffect(() => {
            if (model.value.distrib.duplicateFromContact) {
                // Copy the POC fields to the distributor fields
                Object.keys(model.value.poc).forEach(key => {
                    model.value.distrib[key] = model.value.poc[key];
                });
            }
        });

        return {
            defaults,
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
            dialogFilled,
            datatype,
            identifier,
            languageCodeList,
            countryCodeList,
            isNew,
            bounds,
            isPocPhoneValid,
            isDistribPhoneValid,
            keyword,
            model,
            formFilledAndValidated,
            distributorFieldsEnabled,
            loadList,
            loadMetadata,
            continueToForm,
            onPocPhoneValidate,
            onDistribPhoneValidate,
            addKeyword,
            removeKeyword,
            resetMetadata,
            validateMetadata,
            downloadMetadata,
            submitMetadata,
        }
    }
});

</script>