<template>
    <v-row class="justify-center">
        <v-col cols="12" class="max-form-width">
            <v-card>
                <v-toolbar color="#014e9e" dark flat>
                    <v-toolbar-title>Datasets</v-toolbar-title>

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
                        :disabled="!validated || !filled" v-if="validated" append-icon="mdi-arrow-down-bold-box-outline">
                        Export
                    </v-btn>

                    <v-btn color="#009900" class="ma-2" title="Submit" @click="submitMetadata"
                        :disabled="!validated || !filled" v-if="validated && form.modified" append-icon="mdi-cloud-upload">
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
import BboxEditor from "@/components/BboxEditor.vue";
import { clean } from "@/scripts/helpers.js"
import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';

import { defineComponent, ref, onMounted, watch } from 'vue';
import { VCard, VForm, VBtn } from 'vuetify/lib/components/index.mjs';

let oapi = window.VUE_APP_OAPI;
let mqtt = window.MQTT_HOST;

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
                phone: '+',
                hoursOfService: '0900h - 1700h UTC',
                contactInstructions: 'email'
            },
            settings: {
                identifier: 'urn:x-wmo:md:',
                retention: '30d'
            }
        };

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
        const loaded = ref(false);
        const working = ref(false);
        const validated = ref(false);
        const filled = ref(false);
        const specified = ref(false);
        const message = ref("Select existing discovery metadata file or create new.");
        const items = ref([]);
        const identifier = ref("");
        const isNew = ref(false);
        const schema = ref({});
        const form = ref({
            bounds: [0],
            initialized: true,
            modified: false,
            manual_ids: true,
            country_codes: []
        });
        // Metadata form, initialized with default values
        const model = ref({ ...defaults });
        // Boolean for enabling distributor fields
        const distributorFieldsEnabled = ref(true);

        // Methods

        // Fetches a list of metadata items from the OAPI and updates the list
        const loadList = async (id) => {
            try {
                const response = await fetch(
                    `${oapi}/collections/discovery-metadata/items`, { method: 'get' }
                );
                if (!response.ok) {
                    throw new Error('Network response was not ok')
                }
                const responseData = await response.json();
                responseData.features.forEach((item) => {
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

        // Loads the metadata for a specific item or creates a new metadata structure
        // Also fetches additional required data like country ISO codes
        const loadMetadata = async () => {
            loaded.value = false;
            working.value = true;
            message.value = "Working...";
            form.value.modified = false;

            // Load a blank new discovery metadata file
            if (identifier.value === "Create New...") {
                // As metadata file is new
                isNew.value = true;
                // Reset the defaults to that of the schema
                defaults = {
                    poc: {
                        phone: '+',
                        hoursOfService: '0900h - 1700h UTC',
                        contactInstructions: 'email'
                    },
                    distrib: {
                        phone: '+',
                        hoursOfService: '0900h - 1700h UTC',
                        contactInstructions: 'email'
                    },
                    settings: {
                        identifier: 'urn:x-wmo:md:',
                        retention: '30d'
                    }
                };
                form.value.bounds = [0];
                form.value.initialized = false;
                form.value.manual_ids = false;
                validated.value = false;
            }
            // Load the corresponding discovery metadata file
            else {
                isNew.value = false; // As metadata file is already exists
                validated.value = true;
                try {
                    const response = await fetch(`${oapi}/collections/discovery-metadata/items/${identifier.value}`, { method: "get" });
                    if (!response.ok) {
                        throw new Error('Network response was not ok')
                    }
                    const responseData = await response.json();
                    defaults = demodulateModel(responseData);
                    form.value.initialized = true;
                } catch (error) {
                    console.log(error);
                    message.value = "Error loading discovery metadata file.";
                }
            }

            // Finally, update the UI
            if (!message.value.includes("Error")) {
                model.value = defaults.value;
                loaded.value = true;
            }
            working.value = false;
            message.value = "Select existing discovery metadata file or create new.";
        };

        // Resets the metadata form to the default state
        const resetMetadata = () => {
            try {
                model.value = defaults;
            }
            catch (error) {
                console.error(error);
            }
            loadGeometry();
            form.value.initialized = false;
        };

        // Validate the current metadata, such as checking the topic hierarchy and WCMP2 schema
        const validateMetadata = async () => {
            let isValid = true;

            if (isValid) {
                try {
                    const response = await fetch(`${oapi}/processes/pywcmp-wis2-wcmp2-ets/execution`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            "inputs": {
                                "record": modulateModel(model.value)
                            }
                        })
                    })

                    if (!response.ok) {
                        throw new Error('Network response was not ok')
                    }

                    const responseData = await response.json()
                    console.log(responseData)

                    if ("code" in responseData) {
                        isValid = false
                        alert(responseData.description)
                    }
                } catch (error) {
                    console.log(error)
                    isValid = false
                    alert("Error validating WCMP2 schema.")
                }
            }

            // If network response valid, update the UI
            if (isValid) {
                validated.value = true;
            }
        };

        // Generates a downloadable JSON file from the current metadata state
        const downloadMetadata = () => {
            const content = encodeURI(JSON.stringify(modulateModel(model.value), null, 4))
            const element = document.createElement("a")
            element.href = "data:attachment/text," + content
            element.target = "_blank"
            element.download = "discovery-metadata.json"
            element.click()
        };

        // Submits the current metadata to the OAPI endpoint
        const submitMetadata = async () => {
            try {
                let response;
                if (isNew.value) {
                    // Post to create new metadata
                    response = await fetch(`${oapi.value}/collections/discovery-metadata/items`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(modulateModel(model.value))
                    })
                } else {
                    // Put to update existing metadata
                    response = await fetch(`${oapi.value}/collections/discovery-metadata/items/${defaults.value.settings.identifier}`, {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(modulateModel(model.value))
                    })
                }

                if (!response.ok) {
                    throw new Error('Network response was not ok')
                }

                // If post/put successful, redirect to home page
                if ((isNew.value && response.status === 201) || (!isNew.value && response.status === 204)) {
                    window.location.href = "/"
                }
                // // Otherwise, show an alert with the description of the response
                else {
                    const responseData = await response.json()
                    alert(responseData.description)
                }
            } catch (error) {
                console.log(error)
                alert(isNew.value ? "Error adding discovery metadata." : "Error updating discovery metadata.")
            }
        }

        const loadGeometry = () => {
            updateModel({ "fullKey": "origin.northLatitude" })

            document.querySelectorAll(".v-btn--icon").forEach((element) => {
                element.tabIndex = -1
            })

            const settingsKeywordsElement = document.getElementById("settings-keywords")
            settingsKeywordsElement.addEventListener("keyup", (event) => {
                if (event.key === " ") {
                    const ev = new KeyboardEvent('keydown', {
                        altKey: false,
                        bubbles: true,
                        cancelBubble: false,
                        cancelable: true,
                        charCode: 0,
                        code: "Enter",
                        composed: true,
                        ctrlKey: false,
                        currentTarget: null,
                        defaultPrevented: true,
                        detail: 0,
                        eventPhase: 0,
                        isComposing: false,
                        isTrusted: true,
                        key: "Enter",
                        keyCode: 13,
                        location: 0,
                        metaKey: false,
                        repeat: false,
                        returnValue: false,
                        shiftKey: false,
                        type: "keydown",
                        which: 13
                    })
                    settingsKeywordsElement.dispatchEvent(ev)
                }
            })
        };

        // Update bounds of the form and origin of the model
        const updateGeometry = (input) => {
            console.log('Updating geometry');
            if (input.length === 4) {
                form.value.bounds = input;
                if (!("origin" in model.value)) {
                    model.value["origin"] = {};
                };
                model.value.origin["northLatitude"] = input[0]
                model.value.origin["eastLongitude"] = input[1]
                model.value.origin["southLatitude"] = input[2]
                model.value.origin["westLongitude"] = input[4]
            }
        };

        // Updates the form and model objects based on the provided event
        const updateModel = ($event) => {
            if ($event.fullKey !== "origin.northLatitude") {
                form.value.modified = true;
            };

            // Pre-fill form with automatic values
            if (!form.value.initialized) {
                const today = new Date();
                model.value.origin["dateStarted"] = today.toISOString().split('T')[0];
                model.value.origin["dateEnded"] = null;

                model.value.poc.individual = null;
                model.value.poc.positionName = null;
                model.value.poc.deliveryPoint = null;
                model.value.poc.postalCode = null;
                model.value.poc.hoursOfService =
                    `0900h - 1700h ${today.toLocaleTimeString('en-us', { timeZoneName: 'short' }).split(' ')[2]}`;

                model.value.distrib.individual = null;
                model.value.distrib.positionName = null;
                model.value.distrib.deliveryPoint = null;
                model.value.distrib.postalCode = null;
                model.value.distrib.hoursOfService =
                    `0900h - 1700h ${today.toLocaleTimeString('en-us', { timeZoneName: 'short' }).split(' ')[2]}`;

                form.value.initialized = true;
            }

            // Disable editing identifiers if manually changed
            if (
                ($event.fullKey === "settings.identifier") ||
                ($event.fullKey === "settings.topicHierarchy")
            ) {
                form.value.manual_ids = true;
                validated.value = false;
            }

            // Auto-fill topic identifiers
            if (
                ($event.fullKey === "poc.country") ||
                ($event.fullKey === "origin.centre_id") ||
                ($event.fullKey === "properties.wmo:dataPolicy")
            ) {

                // Only auto-fill if all components are entered, but not manually edited
                if (
                    ("country" in model.value.distrib) &&
                    (model.value.distrib.country.length > 0) &&
                    ("centre_id" in model.value.origin) &&
                    (model.value.origin.centre_id.length > 0) &&
                    ("wmo:dataPolicy" in model.value.properties) &&
                    !form.value.manual_ids
                ) {
                    validated.value = false;
                    model.value.settings.identifier =
                        `urn:x-wmo:md:${model.value.distrib.country.toLowerCase()}:${model.value.origin.centre_id.toLowerCase()}:weather-observations`;
                    model.value.settings.topicHierarchy =
                        `${model.value.distrib.country.toLowerCase()}/${model.value.origin.centre_id.toLowerCase()}/data/${model.value.properties["wmo:dataPolicy"]}/weather/observations`;
                }
            }

            // Null out stop date if empty
            if ($event.fullKey === "origin.dateStopped") {
                if (
                    (!("dateStopped" in model.value.origin)) ||
                    (model.value.origin.dateStopped === null) ||
                    (model.value.origin.dateStopped === "")
                ) {
                    model.value.origin["dateStopped"] = null;
                }
            }

            // Update map if coordinates are changed
            if (
                ($event.fullKey === "origin.northLatitude") ||
                ($event.fullKey === "origin.eastLongitude") ||
                ($event.fullKey === "origin.southLatitude") ||
                ($event.fullKey === "origin.westLongitude")
            ) {
                try {
                    if (
                        ((parseFloat(model.value.origin.northLatitude) >= -90) && (parseFloat(model.value.origin.northLatitude) <= 90)) &&
                        ((parseFloat(model.value.origin.eastLongitude) >= -180) && (parseFloat(model.value.origin.eastLongitude) <= 180)) &&
                        ((parseFloat(model.value.origin.southLatitude) >= -90) && (parseFloat(model.value.origin.southLatitude) <= 90)) &&
                        ((parseFloat(model.value.origin.westLongitude) >= -180) && (parseFloat(model.value.origin.westLongitude) <= 180))
                    ) {
                        form.value.bounds = [
                            parseFloat(model.value.origin.northLatitude),
                            parseFloat(model.value.origin.eastLongitude),
                            parseFloat(model.value.origin.southLatitude),
                            parseFloat(model.value.origin.westLongitude)
                        ];
                    }
                }
                catch {
                    form.value.bounds = [0];
                }
            }

            // Auto-fill distributor if copy is selected
            if ($event.fullKey === "distrib.duplicateFromContact") {
                if (model.value.distrib.duplicateFromContact) {
                    const tmp = JSON.parse(JSON.stringify(model.value.poc))
                    tmp["duplicateFromContact"] = true;
                    model.value.distrib = tmp;
                }
                else {
                    model.value.distrib = {};
                }
            }

            // Automatically correct case
            if ($event.fullKey === "properties.language") {
                model.value.properties.language = model.value.properties.language.toLowerCase();
            }
            if ($event.fullKey === "origin.centre_id") {
                model.value.origin.centre_id = model.value.origin.centre_id.toLowerCase();
            }
            if ($event.fullKey === "poc.email") {
                model.value.poc.email = model.value.poc.email.toLowerCase();
            }
            if ($event.fullKey === "poc.postalCode") {
                model.value.poc.postalCode = model.value.poc.postalCode.toUpperCase();
            }
            if ($event.fullKey === "distrib.email") {
                model.value.distrib.email = model.value.distrib.email.toLowerCase();
            }
            if ($event.fullKey === "distrib.postalCode") {
                model.value.distrib.postalCode = model.value.distrib.postalCode.toUpperCase();
            }
        };

        // Transforms the form data into a structured object, handling properties like "id", "conformsTo", and "time"
        const modulateModel = (input) => {
            const today = new Date();
            const output = {};

            // "id"
            output["id"] = input.settings.identifier;

            // "conformsTo"
            output["conformsTo"] = [schema.value.version];

            // "time"
            output["time"] = {}
            if (input.origin.dateStopped == null) {
                output.time["interval"] = [input.origin.dateStarted.split(" ")[0], null]
            }
            else if (input.origin.dateStopped === input.origin.dateStarted) {
                if (input.origin.dateStarted.split(" ").length > 1) {
                    const chunk = input.origin.dateStarted.split(" ")
                    output.time["timestamp"] = `${chunk[0]}T${chunk[1]}Z`
                }
                else {
                    output.time["timestamp"] = input.origin.dateStarted
                }
            }
            else {
                output.timestamp["interval"] = [input.origin.dateStarted.split(" ")[0], input.origin.dateStopped.split(" ")[0]]
            }

            // "type"
            output["type"] = "Feature"

            // "geometry"
            output["geometry"] = {}
            output["geometry"]["type"] = "Polygon"
            output["geometry"]["coordinates"] = [[
                [input.origin.westLongitude, input.origin.southLatitude],
                [input.origin.westLongitude, input.origin.northLatitude],
                [input.origin.eastLongitude, input.origin.northLatitude],
                [input.origin.eastLongitude, input.origin.southLatitude],
                [input.origin.westLongitude, input.origin.southLatitude]
            ]]

            // "properties"
            output["properties"] = input.properties
            output["properties"]["type"] = "dataset"
            output["properties"]["wmo:topicHierarchy"] = `origin/a/wis2/${input.settings.topicHierarchy}`
            output["properties"]["wmo:dataPolicy"] = input.settings["wmo:dataPolicy"]
            output["properties"]["updated"] = today.toISOString().split('T')[0]
            if (!("created" in output["properties"])) {
                output["properties"]["created"] = today.toISOString().split('T')[0]
            }

            // "properties"."wis2box"
            output["properties"]["wis2box"] = {}
            output["properties"]["wis2box"]["country"] = input.poc.country.toLowerCase()
            output["properties"]["wis2box"]["centre_id"] = input.origin.centre_id
            output["properties"]["wis2box"]["retention"] = `P${input.settings.retention.toUpperCase()}`

            // "properties"."themes"
            output["properties"]["themes"] = [{ "concepts": [] }]
            input.settings.keywords.forEach(function (keyword) {
                output.properties.themes[0]["concepts"].push({ "id": keyword })
            })

            // "properties"."providers"
            output["properties"]["providers"] = []
            const poc = modulateContact.value(input.poc)
            poc.roles.push({ "name": "pointOfContact" })
            if (input.distrib.duplicateFromContact) {
                poc.roles.push({ "name": "distributor" })
            }
            else {
                const distrib = modulateContact.value(input.distrib)
                distrib.roles.push({ "name": "distributor" })
                output.properties.providers.push(distrib)
            }
            output.properties.providers.push(poc)

            // "links"
            output["links"] = []
            output.links.push({
                "rel": "collection",
                "href": `${oapi}/oapi/collections/${input.settings.identifier}`,
                "type": "OAFeat",
                "title": input.settings.identifier
            })
            output.links.push({
                "rel": "data",
                "href": `mqtt://everyone:everyone@${mqtt}:1883`,
                "type": "MQTT",
                "title": input.settings.topicHierarchy.replace(/\//g, "."),
                "channel": `origin/a/wis2/${input.settings.topicHierarchy}`
            })
            output.links.push({
                "rel": "canonical",
                "href": `${oapi}/oapi/collections/discovery-metadata/items/${input.settings.identifier}`,
                "type": "OARec",
                "title": input.settings.identifier
            })

            return output;
        };

        const modulateContact = (input) => {
            const output = JSON.parse(JSON.stringify(input));

            output["contactInfo"] = {};

            output.contactInfo["phone"] = {};
            output.contactInfo.phone = JSON.parse(JSON.stringify({ "office": output.phone }));
            delete output.phone;

            output.contactInfo["email"] = {};
            output.contactInfo.email = JSON.parse(JSON.stringify({ "office": output.email }));
            delete output.email;

            output.contactInfo["address"] = {};
            output.contactInfo.address = JSON.parse(JSON.stringify({
                "office": {
                    "deliveryPoint": output.deliveryPoint,
                    "city": output.city,
                    "administrativeArea": output.administrativeArea,
                    "postalCode": output.postalCode,
                    "country": output.country
                }
            }));
            delete output.deliveryPoint;
            delete output.city;
            delete output.administrativeArea;
            delete output.postalCode;
            delete output.country;

            output.contactInfo["hoursOfService"] = JSON.parse(JSON.stringify(output.hoursOfService));
            delete output.hoursOfService;

            output.contactInfo["contactInstructions"] = JSON.parse(JSON.stringify(output.contactInstructions));
            delete output.contactInstructions;

            if ((input.url != null) && (input.url != "")) {
                console.log(input.url);
                output.contactInfo["url"] = {};
                output.contactInfo.url = JSON.parse(JSON.stringify({
                    "rel": "canonical",
                    "type": "text/html",
                    "href": input.url
                }));
            }
            else {
                delete output.url;
            };

            output["roles"] = [];

            return output;
        }

        const demodulateModel = (input) => {
            const today = new Date();
            const output = {};

            if (!("wis2box" in input.properties)) {
                input.properties["wis2box"] = {}
                input.properties.wis2box["country"] = input.properties["wmo:topicHierarchy"].split("/")[0]
                input.properties.wis2box["centre_id"] = input.properties["wmo:topicHierarchy"].split("/")[1]
                input.properties.wis2box["retention"] = "30d"
            }

            output["properties"] = {}
            output.properties["title"] = input.properties.title
            output.properties["description"] = input.properties.description
            output.properties["wmo:dataPolicy"] = input.properties["wmo:dataPolicy"]
            output.properties["created"] = input.properties.created

            output.properties["language"] = "en"
            if (("language" in input.properties) && (input.properties.language != null)) output.properties["language"] = input.properties.language

            output["origin"] = {}
            output.origin["centre_id"] = input.properties.wis2box.centre_id
            if ("interval" in input.time) {
                output.origin["dateStarted"] = input.time.interval[0]
                output.origin["dateStopped"] = input.time.interval[1]
            }
            else if ("timestamp" in input.time) {
                output.origin["dateStarted"] = input.time.timestamp.replace("T", "").replace("Z", "")
                output.origin["dateStopped"] = input.time.timestamp.replace("T", "").replace("Z", "")
            }
            else {
                output.origin["dateStarted"] = today.toISOString().split('T')[0]
                output.origin["dateStopped"] = null
            }

            try {
                output.origin["northLatitude"] = input.geometry.coordinates[0][0][1][1]
                output.origin["eastLongitude"] = input.geometry.coordinates[0][0][2][0]
                output.origin["southLatitude"] = input.geometry.coordinates[0][0][0][1]
                output.origin["westLongitude"] = input.geometry.coordinates[0][0][0][0]
            }
            catch {
                output.origin["northLatitude"] = input.geometry.coordinates[0][1][1]
                output.origin["eastLongitude"] = input.geometry.coordinates[0][2][0]
                output.origin["southLatitude"] = input.geometry.coordinates[0][0][1]
                output.origin["westLongitude"] = input.geometry.coordinates[0][0][0]
            }

            input.properties.providers.forEach(function (provider) {
                let is_poc = false
                let is_distrib = false
                provider.roles.forEach(function (role) {
                    if (role.name === "pointOfContact") {
                        is_poc = true
                    }
                    if (role.name === "pointOfContact") {
                        is_distrib = true
                    }
                })
                if (is_poc) output["poc"] = self.demodulateContact(provider)
                if (is_distrib) {
                    output["distrib"] = self.demodulateContact(provider)
                    if (is_poc) {
                        output.distrib["duplicateFromContact"] = true
                    }
                    else {
                        output.distrib["duplicateFromContact"] = false
                    }
                }
            })

            output["settings"] = {}
            output.settings["identifier"] = input.id
            output.settings["topicHierarchy"] = input.properties["wmo:topicHierarchy"].replace("origin/a/wis2/", "")
            output.settings["retention"] = input.properties.wis2box.retention.toLowerCase().replace("p", "")

            output.settings["wmo:dataPolicy"] = "core"
            if ("wmo:dataPolicy" in input.properties) {
                output.settings["wmo:dataPolicy"] = input.properties["wmo:dataPolicy"]
            }

            output.settings["keywords"] = []
            input.properties.themes.forEach(function (theme) {
                theme.concepts.forEach(function (concept) {
                    output.settings.keywords.push(concept.id)
                })
            })

            return JSON.parse(JSON.stringify(output));
        };

        const demodulateContact = (input) => {
            const output = {};

            output["individual"] = null
            if ("individual" in input) {
                output["individual"] = input.individual
            }

            output["positionName"] = null
            if ("positionName" in input) {
                output["positionName"] = input.positionName
            }

            output["name"] = null
            if ("name" in input) {
                output["name"] = input.name
            }

            output["url"] = null
            if ("url" in input) {
                output["url"] = input.url
            }

            output["phone"] = input.contactInfo.phone.office
            output["email"] = input.contactInfo.email.office
            output["deliveryPoint"] = input.contactInfo.address.office.deliveryPoint
            output["city"] = input.contactInfo.address.office.city
            output["administrativeArea"] = input.contactInfo.address.office.administrativeArea
            output["postalCode"] = input.contactInfo.address.office.postalCode
            output["country"] = input.contactInfo.address.office.country.slice(0, 3).toUpperCase()
            output["hoursOfService"] = input.contactInfo.hoursOfService
            output["contactInstructions"] = input.contactInfo.contactInstructions

            return JSON.parse(JSON.stringify(output))
        };

        // Recursively process a node object
        const prepareSchema = (title, node) => {
            if (typeof node !== "object") {
                return node;
            } else if (node.length) {
                for (let i = 0; i < node.length; i++) {
                    prepareSchema(`node-${i}`, node[i])
                }
                return node;
            } else {
                for (const [key, val] of Object.entries(node)) {
                    if (title === "properties") {
                        prepareSchema(key, val)
                    }
                    else {
                        prepareSchema("", val)
                    }
                }
            }

            if (!title) {
                node.title = clean(node.title) | clean(title);
                return node;
            };

            return node;
        };

        // Mounted methods
        onMounted(() => {
            const tmp = window.location.href.split("/");
            loadList(tmp[tmp.length - 1]);
        })

        // Watch for the distributor checkbox to enable/disable distributor fields
        watch(() => model.value.distrib.duplicateFromContact, (newValue) => {
            if (newValue) {
                // If 'Yes', disable the fields
                distributorFieldsEnabled.value = false;
                // and copy the POC fields to the distributor fields
                Object.keys(model.value.poc).forEach(key => {
                    model.value.distrib[key] = model.value.poc[key];
                });
            } else {
                // If 'No', enable the fields
                distributorFieldsEnabled.value = true;
            }
        });

        return {
            loaded,
            working,
            validated,
            filled,
            specified,
            message,
            items,
            identifier,
            defaults,
            isNew,
            schema,
            form,
            model,
            distributorFieldsEnabled,
            rules,
            loadList,
            loadMetadata,
            resetMetadata,
            validateMetadata,
            downloadMetadata,
            submitMetadata,
            loadGeometry,
            updateGeometry,
            updateModel,
            modulateModel,
            modulateContact,
            demodulateModel,
            demodulateContact,
            prepareSchema
        }
    }
})

</script>