<template>
    <v-row class="justify-center">
        <v-col cols="12" class="max-form-width">
            <v-card>
                <!-- Toolbar for user to select a dataset -->
                <v-toolbar>
                    <v-toolbar-title>Datasets</v-toolbar-title>

                    <v-select class="mt-3 text-xs-right" v-model="identifier" :items="items" dense
                        @change="loadMetadata" :disabled="specified"></v-select>
                </v-toolbar>

                <!-- Until loaded, play a loading animation -->
                <v-progress-linear indeterminate color="primary" :active="working" />

                <!-- Form which provides a 'filled' boolean for other parts of the page -->
                <v-form v-model="filled" v-if="metadataLoaded">
                    <bbox-editor @updated="updateGeometry" @loaded="loadGeometry"
                        :input-feature="form.bounds"></bbox-editor>
                    <!-- Schema form here -->

                    <!-- Properties section -->
                    <v-row>
                        <v-text-field label="Title" hint="Name of data" type="string" v-model="model.properties.title"
                            :rules="[rules.required]" clearable></v-text-field>

                        <v-text-field label="Description" hint="Brief description of data" type="string"
                            v-model="model.properties.description" :rules="[rules.required]" clearable></v-text-field>

                        <v-text-field label="Language" hint="Lower case representation of language in 2-letter code"
                            type="string" v-model="model.properties.language" :rules="[rules.required, rules.language]"
                            clearable></v-text-field>
                    </v-row>

                    <!-- Origin section -->
                    <v-row>
                        <v-text-field label="Centre ID" hint="Agency acronym (in lower case), as specified by member"
                            type="string" v-model="model.origin.centre_id" :rules="[rules.required, rules.centre_id]"
                            clearable></v-text-field>

                        <VueDatePicker placeholder="Date Started" v-model="model.origin.dateStarted" :teleport="true"
                            auto-apply required />

                        <VueDatePicker placeholder="Date Stopped" v-model="model.origin.dateStopped" :teleport="true"
                            auto-apply required />

                        <v-text-field label="North Latitude" hint="Northmost latitude of data region" type="number"
                            v-model="model.origin.northLatitude" :rules="[rules.required, rules.latitude]"
                            clearable></v-text-field>

                        <v-text-field label="East Longitude" hint="Eastmost longitude of data region" type="number"
                            v-model="model.origin.eastLongitude" :rules="[rules.required, rules.longitude]"
                            clearable></v-text-field>

                        <v-text-field label="South Latitude" hint="Southmost latitude of data region" type="number"
                            v-model="model.origin.southLatitude" :rules="[rules.required, rules.latitude]"
                            clearable></v-text-field>

                        <v-text-field label="West Longitude" hint="Westmost longitude of data region" type="number"
                            v-model="model.origin.westLongitude" :rules="[rules.required, rules.longitude]"
                            clearable></v-text-field>
                    </v-row>

                    <!-- Contact (POC) section -->
                    <v-row>
                        <v-text-field label="Individual" hint="Full name" type="string" v-model="model.poc.individual"
                            clearable></v-text-field>

                        <v-text-field label="Position Name" hint="Position held" type="string"
                            v-model="model.poc.positionName" clearable></v-text-field>

                        <v-text-field label="Name" hint="Organization name" type="string" v-model="model.poc.name"
                            :rules="[rules.required]" clearable></v-text-field>

                        <v-text-field label="URL" hint="Organization website" type="string" v-model="model.poc.url"
                            :rules="[rules.url]" clearable></v-text-field>

                        <v-text-field label="Phone" hint="Full international phone number" type="string"
                            v-model="model.poc.phone" :rules="[rules.required, rules.phone]" clearable></v-text-field>

                        <v-text-field label="Email" hint="Contact email address" type="string" v-model="model.poc.email"
                            :rules="[rules.required, rules.email]" clearable></v-text-field>

                        <v-text-field label="Address" hint="Street address" type="string" v-model="model.poc.deliveryPoint"
                            clearable></v-text-field>

                        <v-text-field label="City" hint="Mailing city" type="string" v-model="model.poc.city"
                            :rules="[rules.required]" clearable></v-text-field>

                        <v-text-field label="State" hint="Mailing state or region" type="string"
                            v-model="model.poc.administrativeArea" :rules="[rules.required]" clearable></v-text-field>

                        <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                            v-model="model.poc.postalCode" clearable></v-text-field>

                        <v-text-field label="Country" hint="Upper case representation of ISO3166 3-letter code"
                            type="string" v-model="model.poc.country" :rules="[rules.required, rules.country]"
                            clearable></v-text-field>

                        <v-text-field label="Hours of Service" hint="Normal weekday contact hours" type="string"
                            v-model="model.poc.hoursOfService" :rules="[rules.required, rules.hoursOfService]"
                            clearable></v-text-field>

                        <v-text-field label="Contact Instructions" hint="Preferred contact method" type="string"
                            v-model="model.poc.contactInstructions" clearable></v-text-field>
                    </v-row>

                    <!-- Distributor section -->
                    <v-row>
                        <v-checkbox label="Same As Contact Info?" v-model="model.distrib.duplicateFromContact"></v-checkbox>

                        <v-text-field label="Individual" hint="Full name" type="string" v-model="model.distrib.individual"
                            clearable :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Position Name" hint="Position held" type="string"
                            v-model="model.distrib.positionName" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Name" hint="Organization name" type="string" v-model="model.distrib.name"
                            :rules="[rules.required]" clearable :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="URL" hint="Organization website" type="string" v-model="model.distrib.url"
                            :rules="[rules.url]" clearable :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Phone" hint="Full international phone number" type="string"
                            v-model="model.distrib.phone" :rules="[rules.required, rules.phone]" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Email" hint="Contact email address" type="string" v-model="model.distrib.email"
                            :rules="[rules.required, rules.email]" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Address" hint="Street address" type="string"
                            v-model="model.distrib.deliveryPoint" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="City" hint="Mailing city" type="string" v-model="model.distrib.city"
                            :rules="[rules.required]" clearable :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="State" hint="Mailing state or region" type="string"
                            v-model="model.distrib.administrativeArea" :rules="[rules.required]" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                            v-model="model.distrib.postalCode" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Country" hint="Upper case representation of ISO3166 3-letter code"
                            type="string" v-model="model.distrib.country" :rules="[rules.required, rules.country]" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Hours of Service" hint="Normal weekday contact hours" type="string"
                            v-model="model.distrib.hoursOfService" :rules="[rules.required, rules.hoursOfService]" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>

                        <v-text-field label="Contact Instructions" hint="Preferred contact method" type="string"
                            v-model="model.distrib.contactInstructions" clearable
                            :disabled="!distributorFieldsEnabled"></v-text-field>
                    </v-row>

                    <!-- Settings section -->
                    <v-row>
                        <v-text-field label="Identifier" hint="Unique identifier for this data" type="string"
                            v-model="model.settings.identifier" rules="[rules.required, rules.identifier]"></v-text-field>

                        <v-text-field label="Topic Hierarchy" hint="Unique hierarchy for this data" type="string"
                            v-model="model.settings.topicHierarchy"
                            rules="[rules.required, rules.topicHierarchy]"></v-text-field>

                        <v-text-field label="WMO Data Policy" hint="Priority of data within WMO" type="string"
                            v-model="model.settings.wmoDataPolicy" rules="[rules.required]"></v-text-field>

                        <v-text-field label="Retention" hint="Minimum length of time data should be retained in WIS2"
                            type="string" v-model="model.settings.retention" rules="[rules.required]"></v-text-field>

                        <v-text-field label="Keywords" hint="Search keywords for data" type="array"
                            v-model="model.settings.keywords" rules="[rules.required, rules.keywords]"></v-text-field>
                    </v-row>
                </v-form>

                <!-- Toolbar for user to reset, validate, export, or submit the metadata
                from the above form -->
                <v-toolbar v-if="metadataLoaded">
                    <v-btn color="red" class="ma-2" title="Reset" @click="resetMetadata" append-icon="mdi-sync">
                        Reset
                    </v-btn>

                    <v-spacer />

                    <v-btn color="#009900" class="ma-2" title="Validate" @click="validateMetadata" :disabled="!filled"
                        v-if="!validated" append-icon="mdi-check-bold">
                        Validate
                    </v-btn>

                    <v-btn color="#FFA500" class="ma-2" title="Export" @click="downloadMetadata"
                        :disabled="!formFilledAndValidated" v-if="validated" append-icon="mdi-arrow-down-bold-box-outline">
                        Export
                    </v-btn>

                    <v-btn color="#009900" class="ma-2" title="Submit" @click="submitMetadata"
                        :disabled="!formFilledAndValidated" v-if="metadataValidated" append-icon="mdi-cloud-upload">
                        Submit
                    </v-btn>
                </v-toolbar>

                <!-- If the form can't load, present the error message as to why -->
                <v-card v-if="!metadataLoaded" class="pa-5">
                    <p class="black--text ma-0">{{ message }}</p>
                </v-card>
            </v-card>
        </v-col>
    </v-row>
</template>

<script>
import BboxEditor from "@/components/BboxEditor.vue";
import schema from '@/models/DiscoveryMetadataForm.json';
import { clean } from "@/scripts/helpers.js"
import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';

import { defineComponent, ref, computed, onMounted, watch } from 'vue';
import { VCard, VForm, VBtn } from 'vuetify/lib/components/index.mjs';

const oapi = import.meta.env.VITE_API_URL;
// const mqtt = window.MQTT_HOST;

export default defineComponent({
    name: "DiscoveryMetadataForm",
    template: "#discovery-metadata-form",
    props: ["topic"],
    components: {
        BboxEditor,
        VueDatePicker,
        VCard,
        VForm,
        VBtn
    },
    setup() {
        // Static variables

        // Default value of the form, not an exhaustive list of all fields
        // Note: This default will change depending on whether the metadata is new or existing
        let defaults = {
            poc: {
                phone: '+',
                hoursOfService: '0900h - 1700h UTC',
                contactInstructions: 'email'
            },
            distrib: {
                duplicateFromContact: false,
                phone: '+',
                hoursOfService: '0900h - 1700h UTC',
                contactInstructions: 'email'
            },
            settings: {
                identifier: 'urn:x-wmo:md:',
                retention: '30d'
            }
        };

        // WCMP2 schema version
        const schemaVersion = schema.version;

        // Validation patterns for form fields
        const rules = {
            required: (value) => !!value || "Field is required",
            language: (value) => /^[a-z]{2}$/.test(value) || "Language must be a 2-letter code",
            centre_id: value => /^[a-z_-]{2,}$/.test(value) || 'Invalid centre ID. Must be lowercase with at least 2 characters.',
            latitude: value => value >= -90 && value <= 90 || 'Latitude must be between -90 and 90.',
            longitude: value => value >= -180 && value <= 180 || 'Longitude must be between -180 and 180.',
            url: value => value === '' || /^https?:\/\/[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)$/.test(value) || 'Invalid URL format.',
            phone: value => value === '' || /^\+\d+[\d\s.()-]{10,}$/.test(value) || 'Invalid phone number. Must start with \'+\' and include country code.',
            email: value => /^[a-z0-9._-]+@[a-z0-9-]+\.[a-z0-9.-]+$/.test(value) || 'Invalid email format.',
            country: value => /^[A-Z]{3}$/.test(value) || 'Invalid country code. Must be 3 uppercase letters.',
            hoursOfService: value => /^\d{4}h\s-\s\d{4}h\s[A-Z\d]{3}$/.test(value) || 'Invalid hours of service. Expected format: 0900h - 1700h UTC',
            identifier: value => /^urn:x-wmo:md:[a-z]{3}:[a-z0-9_-]+:[a-z0-9_-]+[a-z0-9:-]*$/.test(value) || 'Invalid identifier. Must start with \'urn:x-wmo:md:\'',
            topicHierarchy: value => /^[a-z]{3}\/[_a-z-]+\/(data|metadata|reports)\/(core|recommended)\/[\\w]+\/[\\w-]+\/[\\w]*$/.test(value) || 'Invalid topic hierarchy. Follow the specified pattern.',
            keywords: value => Array.isArray(value) && value.length >= 3 || 'Keywords must be an array with at least 3 items.',
        };

        // Reactive variables
        
        // Controls loading animation
        const working = ref(false);
        // Controls which parts of the page are displayed
        const metadataLoaded = ref(false);
        const metadataValidated = ref(false);
        const formFilled = ref(false);
        // If no datasets can be found and the user must create a new one, disable the dataset selection
        const specified = ref(false);
        // Messages to display to user (this changes overtime)
        const message = ref("Select existing discovery metadata file or create new.");
        // List of datasets to select from, if any
        const items = ref([]);
        // Identifier of the selected dataset, used to load metadata from OAPI
        const identifier = ref("");
        // Whether or not the metadata is new or existing
        const isNew = ref(false);
        // Metadata form according to the WCMP2, initialized with default values
        const model = ref({ ...defaults });

        // Computed variables

        // Controls which parts of the page are displayed
        const formFilledAndValidated = computed(() => {
            return filled.value && metadataValidated.value;
        });
        // Whether or not the distributor fields should be enabled, based on whether the user checks the box to duplicate the contact info
        const distributorFieldsEnabled = computed(() => {
            return !model.value.distrib.duplicateFromContact;
        });

        // Methods - TO DO

        // Fetches a list of metadata items from the OAPI and updates the list
        const loadList = async (id) => {
            try {
                // Get list of metadata items from wis2box
                const response = await fetch(`${oapi}/collections/discovery-metadata/items`)
                if (!response.ok) {
                    throw new Error('Network response was not okay, failed to load discovery metadata list.');
                }
                // Finish code
            } catch (error) {
                console.error(error);
                items.value = ['Create New...'];
                message.value = 'Error loading discovery metadata list.';
            }
        };

        // Mounted - TO DO

        // Watched

         // Watch for the distributor checkbox to duplicate the contact info
         watch(() => model.value.distrib.duplicateFromContact, (newValue) => {
            if (newValue) {
                // Copy the POC fields to the distributor fields
                Object.keys(model.value.poc).forEach(key => {
                    model.value.distrib[key] = model.value.poc[key];
                });
            };
        });

        return {
            defaults,
            schemaVersion,
            rules,
            working,
            metadataLoaded,
            metadataValidated,
            formFilled,
            specified,
            message,
            items,
            identifier,
            isNew,
            model,
            formFilledAndValidated,
            distributorFieldsEnabled,
            loadList
        }
    }
});

</script>