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
import BboxEditor from "@/components/leaflet/BboxEditor.vue";
import $RefParser from "@apidevtools/json-schema-ref-parser"
import mergeAllOf from "json-schema-merge-allof"
import { clean } from "@/scripts/helpers.js"
import form_schema from "@/models/DiscoveryMetadataForm.json"

import { defineComponent, ref, onMounted } from 'vue';
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
                date: function (e) {
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

            // Fetch country ISO codes for injection
            try {
                const response = await fetch("https://api.worldbank.org/v2/country?format=json&per_page=500", { method: "get" });
                if (!response.ok) {
                    throw new Error('Network response was not ok')
                }
                const responseData = await response.json();
                responseData[1].forEach((item) => {
                    form.country_codes.push(item.id);
                });
            } catch (error) {
                console.error(error);
            }

            // Load a blank new discovery metadata file
            if (identifier.value === "Create New...") {
                isNew.value = true; // As metadata file is new
                defaults.value = {};
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
                    defaults.value = demodulateModel(responseData);
                    form.value.initialized = true;
                } catch (error) {
                    console.log(error);
                    message.value = "Error loading discovery metadata file.";
                }
            }

            // Now dereference and merge the schema
            $RefParser.dereference(form_schema, (err, schema) => {
                if (err) {
                    console.error(err);
                } else {
                    schema.properties.poc.properties.country.enum = form.value.country_codes;
                    schema.properties.distrib.properties.country.enum = form.value.country_codes;
                    const mergedSchema = mergeAllOf(schema);
                    const parsedSchema = prepareSchema("root", mergedSchema);
                    schema.value = Object.assign({}, parsedSchema);
                }
            })

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
                model.value = defaults.value;
            }
            catch (error) {
                console.error(error);
            }
            loadGeometry();
            form.value.initialized = false;
        };

        // Validate the current metadata, such as checking the topic hierarchy and WCMP2 schema
        const validateMetadata = async () => {
            const isValid = true;

            if (isValid) {
                try {
                    const response = await fetch(url, {
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
                        isValid.value = false
                        alert(responseData.description)
                    }
                } catch (error) {
                    console.log(error)
                    isValid.value = false
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
                alert(is_new.value ? "Error adding discovery metadata." : "Error updating discovery metadata.")
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
                const is_poc = false
                const is_distrib = false
                provider.roles.forEach(function (role) {
                    if (role.name === "pointOfContact") is_poc = true
                    if (role.name === "pointOfContact") is_distrib = true
                })
                if (is_poc) output["poc"] = self.demodulateContact(provider)
                if (is_distrib) {
                    output["distrib"] = self.demodulateContact(provider)
                    if (is_poc) output.distrib["duplicateFromContact"] = true
                    else output.distrib["duplicateFromContact"] = false
                }
            })

            output["settings"] = {}
            output.settings["identifier"] = input.id
            output.settings["topicHierarchy"] = input.properties["wmo:topicHierarchy"].replace("origin/a/wis2/", "")
            output.settings["retention"] = input.properties.wis2box.retention.toLowerCase().replace("p", "")

            output.settings["wmo:dataPolicy"] = "core"
            if ("wmo:dataPolicy" in input.properties) output.settings["wmo:dataPolicy"] = input.properties["wmo:dataPolicy"]

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
            if ("individual" in input) output["individual"] = input.individual

            output["positionName"] = null
            if ("positionName" in input) output["positionName"] = input.positionName

            output["name"] = null
            if ("name" in input) output["name"] = input.name

            output["url"] = null
            if ("url" in input) output["url"] = input.url

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

        const prepareSchema = (title, node) => {
            if (typeof node !== "object") {
                return node;
            } else if (node.length) {
                for (var i = 0; i < node.length; i++) {
                    prepareSchema.value(`node-${i}`, node[i])
                }
                return node;
            } else {
                for (const [key, val] of Object.entries(node)) {
                    if (title === "properties") prepareSchema.value(key, val)
                    else prepareSchema.value("", val)
                }
            }

            if (!title) {
                return node.title = clean(node.title) | clean(title)
            };

            return node;
        };

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
            model,
            isNew,
            schema,
            options,
            form,
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
            demodulateModel,
            demodulateContact,
            prepareSchema
        }
    }
})

</script>