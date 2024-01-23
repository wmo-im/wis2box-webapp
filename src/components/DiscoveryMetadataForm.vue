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
            </v-card>

            <v-card class="mt-3 pa-3">
                <!-- Form which provides a 'filled' boolean for other parts of the page -->
                <v-form v-model="formFilled" v-if="metadataLoaded">
                    <!-- <bbox-editor @updated="updateGeometry" @loaded="loadGeometry"
                        :input-feature="form.bounds"></bbox-editor> -->
                    <!-- Schema form here -->

                    <!-- Properties section -->
                    <v-card-title>Dataset Properties</v-card-title>
                    <v-row dense>
                        <v-col cols="4">
                            <v-text-field label="Title" hint="Name of data" type="string" v-model="model.properties.title"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Description" hint="Brief description of data" type="string"
                                v-model="model.properties.description" :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Language" hint="Lower case representation of language in 2-letter code"
                                type="string" v-model="model.properties.language" :rules="[rules.required, rules.language]"
                                variant="outlined" clearable></v-text-field>
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

                        <v-col cols="4">
                            <VueDatePicker placeholder="Date Started" v-model="model.origin.dateStarted" :teleport="true"
                                auto-apply required />
                        </v-col>

                        <v-col cols="4">
                            <VueDatePicker placeholder="Date Stopped" v-model="model.origin.dateStopped" :teleport="true"
                                 class="datepicker" auto-apply required />
                        </v-col>
                    </v-row>
                    <v-row dense>
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

                    <!-- Contact (POC) section -->
                    <v-card-title>Point of Contact Information</v-card-title>
                    <v-row dense>
                        <v-col cols="3">
                            <v-text-field label="Individual" hint="Full name" type="string" v-model="model.poc.individual"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Position Name" hint="Position held" type="string"
                                v-model="model.poc.positionName" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Name" hint="Organization name" type="string" v-model="model.poc.name"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="URL" hint="Organization website" type="string" v-model="model.poc.url"
                                :rules="[rules.url]" variant="outlined" clearable></v-text-field>
                        </v-col>

                    </v-row>
                    <v-row dense>
                        <v-col cols="6">
                            <!-- <v-text-field label="Phone" hint="Full international phone number" type="string"
                                v-model="model.poc.phone" :rules="[rules.required, rules.phone]" clearable></v-text-field> -->
                                <vue-tel-input v-model="model.poc.phone"></vue-tel-input>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Email" hint="Contact email address" type="string" v-model="model.poc.email"
                                :rules="[rules.required, rules.email]" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="6">
                            <v-text-field label="Address" hint="Street address" type="string"
                                v-model="model.poc.deliveryPoint" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="City" hint="Mailing city" type="string" v-model="model.poc.city"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="State" hint="Mailing state or region" type="string"
                                v-model="model.poc.administrativeArea" :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                    </v-row>
                    <v-row dense>
                        <v-col cols="3">
                            <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                                v-model="model.poc.postalCode" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Country" hint="Upper case representation of ISO3166 3-letter code"
                                type="string" v-model="model.poc.country" :rules="[rules.required, rules.country]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Hours of Service" hint="Normal weekday contact hours" type="string"
                                v-model="model.poc.hoursOfService" :rules="[rules.required, rules.hoursOfService]"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
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
                        <v-col cols="3">
                            <v-text-field label="Individual" hint="Full name" type="string"
                                v-model="model.distrib.individual" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Position Name" hint="Position held" type="string"
                                v-model="model.distrib.positionName" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Name" hint="Organization name" type="string" v-model="model.distrib.name"
                                :rules="[rules.required]" variant="outlined" clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="URL" hint="Organization website" type="string" v-model="model.distrib.url"
                                :rules="[rules.url]" variant="outlined" clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="6" :disabled="!distributorFieldsEnabled">
                            <!-- <v-text-field label="Phone" hint="Full international phone number" type="string"
                                v-model="model.distrib.phone" :rules="[rules.required, rules.phone]" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field> -->
                            <vue-tel-input v-model="model.distrib.phone" :disabled="!distributorFieldsEnabled"></vue-tel-input>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Email" hint="Contact email address" type="string"
                                v-model="model.distrib.email" :rules="[rules.required, rules.email]" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="6">
                            <v-text-field label="Address" hint="Street address" type="string"
                                v-model="model.distrib.deliveryPoint" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="City" hint="Mailing city" type="string" v-model="model.distrib.city"
                                :rules="[rules.required]" variant="outlined" clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="State" hint="Mailing state or region" type="string"
                                v-model="model.distrib.administrativeArea" :rules="[rules.required]" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="3">
                            <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                                v-model="model.distrib.postalCode" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Country" hint="Upper case representation of ISO3166 3-letter code"
                                type="string" v-model="model.distrib.country" :rules="[rules.required, rules.country]"
                                variant="outlined" clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Hours of Service" hint="Normal weekday contact hours" type="string"
                                v-model="model.distrib.hoursOfService" :rules="[rules.required, rules.hoursOfService]"
                                variant="outlined" clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="Contact Instructions" hint="Preferred contact method" type="string"
                                v-model="model.distrib.contactInstructions" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>

                    <!-- Settings section -->
                    <v-card-title>Dataset Settings</v-card-title>
                    <v-row dense>
                        <v-col cols="5">
                            <v-text-field label="Identifier" hint="Unique identifier for this data" type="string"
                                v-model="model.settings.identifier" :rules="[rules.required, rules.identifier]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="5">
                            <v-text-field label="WMO Data Policy" hint="Priority of data within WMO" type="string"
                                v-model="model.settings.wmoDataPolicy" :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="2">
                            <v-text-field label="Retention" hint="Minimum length of time data should be retained in WIS2"
                                type="string" v-model="model.settings.retention" :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="12">
                            <v-text-field label="Keywords" hint="Search keywords for data" type="array"
                                v-model="model.settings.keywords" :rules="[rules.required, rules.keywords]" variant="outlined" clearable></v-text-field>
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

                    <v-btn color="#FFA500" class="ma-2" title="Export" @click="downloadMetadata"
                        :disabled="!formFilledAndValidated" v-if="metadataValidated"
                        append-icon="mdi-arrow-down-bold-box-outline">
                        Export
                    </v-btn>

                    <v-btn color="#009900" class="ma-2" title="Submit" @click="submitMetadata"
                        :disabled="!formFilledAndValidated" v-if="metadataValidated" append-icon="mdi-cloud-upload">
                        Submit
                    </v-btn>
                </v-row>

                <!-- If the form can't load, present the error message as to why -->
                <v-row v-if="!metadataLoaded" class="pa-5">
                    <p class="black--text ma-0">{{ message }}</p>
                </v-row>
            </v-card>
        </v-col>
    </v-row>
</template>

<script>
import BboxEditor from "@/components/BboxEditor.vue";
import { clean } from "@/scripts/helpers.js"

import { defineComponent, ref, computed, onMounted, watch } from 'vue';
import { VCard, VForm, VBtn } from 'vuetify/lib/components/index.mjs';

const oapi = import.meta.env.VITE_API_URL;

export default defineComponent({
    name: "DiscoveryMetadataForm",
    template: "#discovery-metadata-form",
    props: ["topic"],
    components: {
        BboxEditor,
        VCard,
        VForm,
        VBtn
    },
    setup() {
        // Static variables

        // Default value of the form, not an exhaustive list of all fields
        // Note: This default will change depending on whether the metadata is new or existing
        let defaults = {
            properties: {},
            origin: {},
            poc: {
                hoursOfService: '0900h - 1700h UTC',
                contactInstructions: 'email'
            },
            distrib: {
                duplicateFromContact: false,
                hoursOfService: '0900h - 1700h UTC',
                contactInstructions: 'email'
            },
            settings: {
                identifier: 'urn:x-wmo:md:',
                retention: '30d'
            }
        };

        // WCMP2 schema version
        const schemaVersion = "http://wis.wmo.int/spec/wcmp/2.0";

        // Validation patterns for form fields
        const rules = {
            required: (value) => !!value || "Field is required",
            language: (value) => /^[a-z]{2}$/.test(value) || "Language must be a 2-letter code",
            centreID: value => /^[a-z_-]{2,}$/.test(value) || 'Invalid centre ID. Must be lowercase with at least 2 characters.',
            latitude: value => value >= -90 && value <= 90 || 'Latitude must be between -90 and 90.',
            longitude: value => value >= -180 && value <= 180 || 'Longitude must be between -180 and 180.',
            url: value => value === '' || /^https?:\/\/[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)$/.test(value) || 'Invalid URL format.',
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
        const datasetSpecified = ref(false);
        // Messages to display to user (this changes overtime)
        const message = ref("Select existing discovery metadata file or create a new file.");
        // List of datasets to select from, if any
        const items = ref([]);
        // Identifier of the selected dataset, used to load metadata from OAPI
        const identifier = ref("");
        // Whether or not the metadata is new or existing
        const isNew = ref(false);
        // Metadata form to be filled, initialized with default values
        const model = ref({ ...defaults });

        // Computed variables

        // Controls which parts of the page are displayed
        const formFilledAndValidated = computed(() => {
            return formFilled.value && metadataValidated.value;
        });
        // Whether or not the distributor fields should be enabled, based on whether the user checks the box to duplicate the contact info
        const distributorFieldsEnabled = computed(() => {
            return !model.value.distrib.duplicateFromContact;
        });

        // Methods - TO DO

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
                // If the list cannot be loaded, the only option is to create a new dataset
                items.value = ['Create New...'];
                // Display error message to the user
                message.value = 'Error loading discovery metadata list.';
            }
        };

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
                metadataValidated.value = false;
            }
            // Otherwise, populate the form with the loaded values
            else {
                isNew.value = false;
                metadataValidated.value = true;

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

        // Resets the metadata form to the default state
        const resetMetadata = () => {
            model.value = defaults;
            metadataValidated.value = false;
            formFilled.value = false;
            message.value = "Discovery metadata reset successfully.";
            // Reload the map
            // loadGeometry();
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
        });

        // Watched

        // Watch for the distributor checkbox to duplicate the contact info
        watch(() => model.value.distrib.duplicateFromContact, (newValue) => {
            if (newValue) {
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
            identifier,
            isNew,
            model,
            formFilledAndValidated,
            distributorFieldsEnabled,
            loadList,
            loadMetadata,
            resetMetadata,
            validateMetadata,
            downloadMetadata,
            submitMetadata,
        }
    }
});

</script>