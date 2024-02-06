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
                <v-dialog v-model="showDialog" max-width="600px" persistent>
                    <v-card>
                        <v-card-title>
                            Please enter some initial information
                            <v-btn icon="mdi-comment-question" variant="text" size="small"
                                @click="openInitialHelpDialog = true" />
                        </v-card-title>
                        <v-card-text>
                            <v-autocomplete label="Country" :items="countryCodeList" item-title="name" item-value="alpha-3"
                                v-model="model.poc.country" :rules="[rules.required]" variant="outlined"></v-autocomplete>
                            <v-text-field v-model="model.origin.centreID" label="Centre ID"
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
                    <v-card-title>
                        Dataset Identification
                        <v-btn icon="mdi-comment-question" variant="text" size="small"
                            @click="openIdentificationHelpDialog = true" />
                    </v-card-title>
                    <v-row>
                        <v-col cols="6">
                            <v-text-field label="Title" type="string" v-model="model.identification.title"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Description" type="string" v-model="model.identification.description"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col cols="3">
                            <v-autocomplete label="Language" v-model="model.identification.language"
                                :items="languageCodeList" item-title="name" item-value="code" :rules="[rules.required]"
                                variant="outlined"></v-autocomplete>
                        </v-col>
                        <v-col cols="9">
                            <v-row dense>
                                <v-col cols="3">
                                    <v-text-field label="Keywords (3 minimum)" type="array" v-model="keyword"
                                        @keyup.enter="addKeyword" variant="outlined" clearable></v-text-field>
                                </v-col>
                                <v-col cols="1">
                                    <v-btn color="#003DA5" variant="flat" icon="mdi-plus" size="large" @click="addKeyword"
                                        :disabled="keyword == ''"></v-btn>
                                </v-col>
                                <v-col cols="8">
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

                    <!-- Origin section -->
                    <v-card-title>
                        Dataset Origin
                        <v-btn icon="mdi-comment-question" variant="text" size="small"
                            @click="openOriginHelpDialog = true" />
                    </v-card-title>
                    <v-row>
                        <v-col cols="4">
                            <!-- The centre ID is left disabled as it was selected by the user earlier -->
                            <v-text-field label="Centre ID" type="string" v-model="model.origin.centreID"
                                :rules="[rules.required, rules.centreID]" variant="outlined" clearable
                                disabled></v-text-field>
                        </v-col>
                        <v-col cols="2">
                            <v-select label="WMO Data Policy" type="string" :items="['core', 'recommended']"
                                v-model="model.origin.wmoDataPolicy" :rules="[rules.required]"
                                variant="outlined"></v-select>
                        </v-col>
                        <v-col cols="2">
                            <v-text-field label="Retention in Days" type="number" v-model="model.origin.retention"
                                :rules="[rules.required]" variant="outlined"></v-text-field>
                        </v-col>

                    </v-row>
                    <!-- The identifier and topic hierarchy -->
                    <!-- Unless the user selects 'other' for the datatype,
                    these should remain disabled as they are autofilled -->
                    <v-row>
                        <v-col cols="6">
                            <v-text-field label="Identifier" type="string" v-model="model.origin.identifier"
                                :rules="[rules.required]" variant="outlined" clearable
                                :disabled="datatype !== 'other'"></v-text-field>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Topic Hierarchy" type="string" v-model="model.origin.topicHierarchy"
                                :rules="[rules.required]" variant="outlined"
                                :disabled="datatype !== 'other'"></v-text-field>
                        </v-col>
                    </v-row>

                    <v-card-title>
                        Temporal Properties
                        <v-btn icon="mdi-comment-question" variant="text" size="small"
                            @click="openTemporalHelpDialog = true" />
                    </v-card-title>
                    <v-row>
                        <v-col cols="3">
                            <VueDatePicker placeholder="Begin Date in UTC" v-model="model.origin.dateStarted"
                                :teleport="true" :enable-time-picker="false" auto-apply required />
                        </v-col>

                        <v-col cols="3">
                            <VueDatePicker placeholder="End Date in UTC" v-model="model.origin.dateStopped" :teleport="true"
                                :enable-time-picker="false" auto-apply required />
                        </v-col>

                        <v-col cols="3">
                            <v-row dense>
                                <v-col cols="5">
                                    <v-text-field label="Resolution" type="string" v-model="model.origin.resolution"
                                        :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                                </v-col>
                                <v-col cols="5">
                                    <v-select label="Unit" :items="durations" item-title="name" item-value="code"
                                        v-model="model.origin.resolutionUnit" :rules="[rules.required]"
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
                            <!-- Allow the user to select a country different to that of the POC for the auto bbox -->
                            <v-autocomplete label="Choose another country bounding box (optional)" item-title="name"
                                item-value="alpha-3" :items="filteredCountryCodeList" v-model="bboxCountry"
                                @update:modelValue="getAutoBbox(bboxCountry)"
                                hint="Your country may not have an automatic bounding box" persistent-hint
                                variant="outlined"></v-autocomplete>
                        </v-col>
                    </v-row>
                    <v-row dense>
                        <v-col cols="12">
                            <!-- Bounding box editor -->
                            <bbox-editor :box-bounds="bounds"></bbox-editor>
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col cols="3">
                            <v-text-field label="North Latitude" type="float" v-model="model.origin.northLatitude"
                                :rules="[rules.required, rules.latitude]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="East Longitude" type="float" v-model="model.origin.eastLongitude"
                                :rules="[rules.required, rules.longitude]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="South Latitude" type="float" v-model="model.origin.southLatitude"
                                :rules="[rules.required, rules.latitude]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-text-field label="West Longitude" type="float" v-model="model.origin.westLongitude"
                                :rules="[rules.required, rules.longitude]" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>

                    <!-- Contact (POC) section -->
                    <v-card-title>
                        Point of Contact Information
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
                                v-model="model.poc.country" :rules="[rules.required]" variant="outlined"
                                disabled></v-autocomplete>
                        </v-col>
                    </v-row>
                    <!-- The following contact fields may return later -->
                    <!-- <v-row>
                        <v-col cols="4">
                            <v-text-field label="Organization Name" type="string" v-model="model.poc.name"
                                :rules="[rules.required]" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Individual" hint="Full name" type="string" v-model="model.poc.individual"
                                variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="4">
                            <v-text-field label="Position Name" hint="Position held" type="string"
                                v-model="model.poc.positionName" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row>
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
                    <v-row>
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
                    <v-row>
                        <v-col cols="3">
                            <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                                v-model="model.poc.postalCode" variant="outlined" clearable></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-autocomplete label="Country" item-title="name" item-value="alpha-3" :items="countryCodeList"
                                v-model="model.poc.country" :rules="[rules.required]" variant="outlined"
                                disabled></v-autocomplete>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Hours of Service" hint="Time period to be contacted"
                                v-model="model.poc.hoursOfService" :rules="[rules.required]" variant="outlined"
                                clearable></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col cols="6">
                            <v-text-field label="Contact Instructions" hint="Preferred contact method" type="string"
                                v-model="model.poc.contactInstructions" variant="outlined" clearable></v-text-field>
                        </v-col>
                    </v-row> -->

                    <!-- Distributor section -->
                    <v-card-title>
                        Distributor Information
                        <v-btn icon="mdi-comment-question" variant="text" size="small"
                            @click="openDistribHelpDialog = true" />
                        <v-switch label="Same As Contact Info?" v-model="model.distrib.duplicateFromContact"
                            color="#003DA5"></v-switch>
                    </v-card-title>
                    <v-row>
                        <v-col cols="4">
                            <v-text-field label="Organization Name" type="string" v-model="model.distrib.name"
                                :rules="[rules.required]" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                        <v-col cols="4">
                            <v-text-field label="Email" type="string" v-model="model.distrib.email"
                                :rules="[rules.required, rules.email]" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                        <v-col cols="4">
                            <v-autocomplete label="Country" :items="countryCodeList" item-title="name" item-value="alpha-3"
                                v-model="model.distrib.country" :rules="[rules.required]"
                                :disabled="!distributorFieldsEnabled" variant="outlined"></v-autocomplete>
                        </v-col>
                    </v-row>
                    <!-- The following contact fields may return later -->
                    <!-- <v-row>
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
                    <v-row>
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
                    <v-row>
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
                    <v-row>
                        <v-col cols="3">
                            <v-text-field label="Postal Code" hint="Mailing postal code" type="string"
                                v-model="model.distrib.postalCode" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>

                        <v-col cols="3">
                            <v-autocomplete label="Country" hint="Upper case representation of ISO3166 3-letter code"
                                persistent-hint :items="countryCodeList" item-title="name" item-value="alpha-3"
                                v-model="model.distrib.country" :rules="[rules.required]"
                                :disabled="!distributorFieldsEnabled" variant="outlined"></v-autocomplete>
                        </v-col>

                        <v-col cols="6">
                            <v-text-field label="Hours of Service" hint="Time period to be contacted"
                                v-model="model.distrib.hoursOfService" :rules="[rules.required]" variant="outlined"
                                clearable :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row>
                        <v-col cols="6">
                            <v-text-field label="Contact Instructions" hint="Preferred contact method" type="string"
                                v-model="model.distrib.contactInstructions" variant="outlined" clearable
                                :disabled="!distributorFieldsEnabled"></v-text-field>
                        </v-col>
                    </v-row> -->
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
                        <p><b>Country:</b> The country of your point of contact.</p>
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
                        <p><b>Title:</b> The name of the dataset.</p>
                        <p><i>Note: Unless 'other' was selected initially, this field is pre-filled.</i></p>
                        <br>
                        <p><b>Description:</b> A brief abstract describing the dataset.</p>
                        <br>
                        <p><b>Language:</b> The language of the dataset.</p>
                        <br>
                        <p><b>Keywords:</b> At least three keywords to allow users to search for the data.</p>
                        <br>
                    </v-card-text>
                </v-card>
            </v-dialog>
            <v-dialog v-model="openOriginHelpDialog" max-width="600px">
                <v-card>
                    <v-card-item>
                        <v-card-title class="d-flex justify-space-between">
                            Dataset Origin
                            <v-btn icon="mdi-close" variant="text" size="small" @click="openOriginHelpDialog = false" />
                        </v-card-title>
                        <v-card-subtitle>
                            How do I complete this section?
                        </v-card-subtitle>
                    </v-card-item>
                    <v-card-text>
                        <p><b>Centre ID:</b> This was already filled earlier and <i>cannot be edited</i>.</p>
                        <br>
                        <p><b>WMO Data Policy:</b> Whether the dataset is core or recommended according to the WMO Unified
                            Data Policy.</p>
                        <br>
                        <p><b>Retention Period in Days:</b> Minimum number of days the data should be retained in WIS2 (e.g. 30).</p>
                        <br>
                        <p><b>Identifier:</b> The unique identifier for the data.</p>
                        <p><i>Note: Unless 'other' was selected initially, this field is pre-filled and cannot be
                                edited.</i></p>
                        <br>
                        <p><b>Topic Hierarchy:</b> The unique hierarchy for this data.</p>
                        <p><i>Note: Unless 'other' was selected initially, this field is pre-filled and cannot be
                                edited.</i></p>
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
                        <p><b>Time Resolution:</b> The smallest increment of time that is represented in the dataset.</p>
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
                        <p>This section describes the bounding box of the dataset. By default, the bounding box is
                            automatically filled based on the country of the point of contact. However, this can be changed
                            either:</p>
                        <br>
                        <p><b>Automatically:</b> By using the additional country dropdown (your country may not be found on
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
                        <p>This section provides details for the person that can be contacted for more information about the
                            dataset.</p>
                        <br>
                        <p><b>Organization Name:</b> The name of the organization.</p>
                        <br>
                        <p><b>Email:</b> The email address of the point of contact.</p>
                        <br>
                        <p><b>Country:</b> This was already filled earlier and <i>cannot be edited</i>.</p>
                        <br>
                    </v-card-text>
                </v-card>
            </v-dialog>
            <v-dialog v-model="openDistribHelpDialog" max-width="600px">
                <v-card>
                    <v-card-item>
                        <v-card-title class="d-flex justify-space-between">
                            Distributor Information
                            <v-btn icon="mdi-close" variant="text" size="small" @click="openDistribHelpDialog = false" />
                        </v-card-title>
                        <v-card-subtitle>
                            How do I complete this section?
                        </v-card-subtitle>
                    </v-card-item>
                    <v-card-text>
                        <p>This section provides additional details if the distributor is not the same as the point of
                            contact. <i>By default, this information is identical to that of the point of contact.</i></p>
                        <br>
                        <p><b>Organization Name:</b> The name of the distributing organization.</p>
                        <br>
                        <p><b>Email:</b> The email address of the distributor.</p>
                        <br>
                        <p><b>Country:</b> The country of the distributor.</p>
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
            identification: {
                keywords: []
            },
            origin: {
                centreID: '',
                wmoDataPolicy: 'core',
                identifier: 'urn:x-wmo:md:',
            },
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
            { name: 'hour(s)', code: 'H' },
            { name: 'day(s)', code: 'D' },
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
        const datatype = ref("");
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
        const model = ref({ 'identification': {}, 'origin': {}, 'poc': {}, 'distrib': {}, 'settings': {} });
        // Help dialog windows
        const openInitialHelpDialog = ref(false);
        const openIdentificationHelpDialog = ref(false);
        const openOriginHelpDialog = ref(false);
        const openTemporalHelpDialog = ref(false);
        const openSpatialHelpDialog = ref(false);
        const openPocHelpDialog = ref(false);
        const openDistribHelpDialog = ref(false);

        // Computed variables

        // Has the user filled the dialog window?
        const dialogFilled = computed(() => {
            return model.value.poc.country && model.value.origin.centreID && datatype.value !== "";
        });

        // Filter the country code list so that only the countries
        // which have an automatic bounding box are shown
        const filteredCountryCodeList = computed(() => {
            return countryCodeList.value.filter(country => {
                // Find out if the (lower case) alpha 2 code is in the bbox list
                return country["alpha-2"].toLowerCase() in boundingBoxes.value;
            });
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
            formModel.origin.identifier = schema.id;

            // Time period information
            if (schema.time?.interval) {
                formModel.origin.dateStarted = schema.time.interval[0];
                formModel.origin.dateStopped = schema.time.interval[1];
            }
            // Minimum time period resolvable in the dataset
            // Sets the resolution to the number, and unit to D or H
            if (schema.time?.resolution) {
                const match = schema.time.resolution.match(/P(\d+)([DH])/i);
                if (match) {
                    formModel.origin.resolution = parseInt(match[1]);
                    formModel.origin.resolutionUnit = match[2].toUpperCase();
                }
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
            formModel.identification.keywords = schema.properties.keywords;

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
                    formModel.origin.wmoDataPolicy = schema.properties["wmo:dataPolicy"];
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
        const getAlpha2Code = (alpha3Code) => {
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
            model.value.identification.keywords = template.keywords;
            // Extract value in days (P30D -> 30)
            model.value.origin.retention = template.retention.substring(1, template.retention.length - 1);
            model.value.origin.identifier = template.identifier.replace('$CENTRE_ID', model.value.origin.centreID);
            // Use centre ID and WMO data policy to create topic hierarchy
            model.value.origin.topicHierarchy = template.topicHierarchy
            .replace('$CENTRE_ID', model.value.origin.centreID)
            .replace('$DATA_POLICY', model.value.origin.wmoDataPolicy);
            // Get resolution and resolution unit from template
            const match = template.resolution.match(/P(\d+)([DH])/i);
                if (match) {
                    model.value.origin.resolution = parseInt(match[1]);
                    model.value.origin.resolutionUnit = match[2].toUpperCase();
                }
            model.value.distrib.duplicateFromContact = template.duplicateFromContact;

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
            schemaModel.id = form.origin.identifier;
            schemaModel.conformsTo = [schemaVersion];
            schemaModel.type = "Feature";

            // wis2box information
            // Note: This is an extension to the WCMP2 schema
            schemaModel.wis2box = {};
            schemaModel.wis2box.retention = `P${form.origin.retention}D`;
            schemaModel.wis2box["topic_hierarchy"] = form.origin.topicHierarchy;
            schemaModel.wis2box.country = form.poc.country;
            schemaModel.wis2box["centre_id"] = form.origin.centreID;

            // Time period information
            schemaModel.time = {};
            // Get the start and end dates from the form
            const startDate = getDateFrom(form.origin.dateStarted);
            const endDate = getDateFrom(form.origin.dateStopped);
            schemaModel.time.interval = [startDate, endDate];
            schemaModel.time.resolution = `P${form.origin.resolution}${form.origin.resolutionUnit}`;

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
            schemaModel.properties.keywords = form.identification.keywords;
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
            schemaModel.properties["wmo:dataPolicy"] = form.origin.wmoDataPolicy;


            // Links information
            schemaModel.links = [];
            schemaModel.links.push({
                rel: "collection",
                href: `${form.poc.url}/oapi/collections/${form.origin.identifier}`,
                title: form.origin.identifier
            })
            schemaModel.links.push({
                rel: "canonical",
                href: `${form.poc.url}/oapi/collections/discovery-metadata/items/${form.origin.identifier}`,
                title: form.origin.identifier
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

        // If the user changes the data policy, update the topic hierarcy
        // using the template
        watch(() => model.value.origin.wmoDataPolicy, () => {
            if (datatype.value === 'synop') {
                applyTemplate(synopTemplate);
            } else if (datatype.value === 'temp') {
                applyTemplate(tempTemplate);
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
            dialogFilled,
            filteredCountryCodeList,
            datatype,
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
            openOriginHelpDialog,
            openTemporalHelpDialog,
            openSpatialHelpDialog,
            openPocHelpDialog,
            openDistribHelpDialog,
            formFilledAndValidated,
            distributorFieldsEnabled,
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