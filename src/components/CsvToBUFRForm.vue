<template>
        <v-container class="max-form-width">
          <v-card-title class="big-title">Submit CSV Data</v-card-title>
            <v-dialog v-model="showDialog" width="auto">
              <v-card>
                <v-card-text>{{msg}}</v-card-text>
                <v-card-actions>
                  <v-btn color="primary" block @click="showDialog = false">Close</v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
            <v-card-text>
              See the <a href="https://docs.wis2box.wis.wmo.int/en/latest/user/data-ingest.html#wis2box-webapp">
              WIS2box documentation</a> for information on CSV formatted data
            </v-card-text>
            <v-stepper show-actions v-model="step">
                <v-stepper-header>
                    <v-stepper-item
                        :complete="status.fileLoaded"
                        title="Select file"
                        value="1" :color="step1Color">
                    </v-stepper-item>
                    <v-stepper-item
                        :complete="status.fileValidated"
                        :error="validationErrors.length>0"
                        title="Preview / validate"
                        value="2" :color="step2Color">
                    </v-stepper-item>
                    <v-stepper-item
                        :complete="status.datasetIdentifier"
                        title="Select dataset"
                        value="3" :color="step3Color">
                    </v-stepper-item>
                    <v-stepper-item
                        :complete="status.password"
                        title="Authorize / publish"
                        value="4" :color="step4Color">
                    </v-stepper-item>
                    <v-stepper-item
                        :complete="step5Complete"
                        title="Review"
                        value="5" :color="step5Color">
                    </v-stepper-item>
                </v-stepper-header>
                <v-stepper-window>
                    <v-stepper-window-item value="1">
                        <v-card width="100%">
                            <v-card-title>Load data</v-card-title>
                            <v-card-text>
                                <v-file-input label="Select CSV file to upload" accept=".csv" v-model="incomingFile" variant="outlined"/>
                            </v-card-text>
                        </v-card>
                    </v-stepper-window-item>
                    <v-stepper-window-item value="2">
                        <v-card>
                            <v-card-title>Preview</v-card-title>
                            <v-card-item>
                                <div v-if="theData">
                                    <v-data-table :items="theData" :headers="headers" class="elevation-1">
                                        <template v-slot:item="{item}">
                                            <tr>
                                                <td v-for="(value, key) in item" :key="key">
                                                    <v-tooltip
                                                        v-if="item[key].msg !== ''"
                                                        :text="item[key].msg">
                                                        <template v-slot:activator="{ props }">
                                                            <v-chip :color="item[key].status" v-bind="props">
                                                                {{item[key].value}}
                                                            </v-chip>
                                                        </template>
                                                    </v-tooltip>
                                                    <v-chip v-else :color="item[key].status">
                                                        {{item[key].value}}
                                                    </v-chip>
                                                </td>
                                            </tr>
                                        </template>
                                    </v-data-table>
                                </div>
                            </v-card-item>
                            <v-card-item>
                                <v-list v-if="validationWarnings.length > 0">
                                    <v-list-item v-for="message in validationWarnings" :key="message" base-color="warning">
                                        <template v-slot:prepend>
                                            <v-icon icon="mdi-alert-circle"></v-icon>
                                        </template>
                                        {{ message }}
                                    </v-list-item>
                                </v-list>
                                <v-list v-if="validationErrors.length > 0">
                                    <v-list-item v-for="message in validationErrors" :key="message" base-color="error">
                                        <template v-slot:prepend>
                                            <v-icon icon="mdi-alert-circle"></v-icon>
                                        </template>
                                        {{ message }}
                                    </v-list-item>
                                </v-list>
                            </v-card-item>
                        </v-card>
                    </v-stepper-window-item>
                    <v-stepper-window-item value="3">
                        <v-card>
                            <v-card-title>Select dataset identifier</v-card-title>
                            <v-col cols="12">
                                <DatasetIdentifierSelector :value="datasetSelected" @update:modelValue="newValue => datasetSelected = newValue"/>
                            </v-col>
                        </v-card>
                    </v-stepper-window-item>
                    <v-stepper-window-item value="4">
                        <v-card>
                            <v-card-title>Authorize and publish</v-card-title>
                            <v-card-text>
                              <v-text-field label="wis2box auth token for 'processes/wis2box'" v-model="token" rows="1"
                              :append-icon="showToken ? 'mdi-eye' : 'mdi-eye-off'" :type="showToken ? 'text' : 'password'" autocomplete="one-time-code"
                              @click:append="showToken = !showToken"
                              :rules="[v => !!v || 'Token is required']"
                              variant="outlined">
                            </v-text-field>
                            </v-card-text>
                            <v-checkbox v-model="notificationsOnPending" label="Publish on WIS2" color="#" hide-details></v-checkbox>
                            <v-card-item v-if="token">Click next to submit the data</v-card-item>
                        </v-card>
                    </v-stepper-window-item>
                    <v-stepper-window-item value="5">
                      <v-row class="justify-center">
                        <v-col cols="12">
                          <!-- Output data -->
                          <v-card v-if="result">
                            <v-card-title>{{ resultTitle }}</v-card-title>

                            <v-list>

                              <v-list-item class="hint-default">
                                {{ numberNotifications }}</v-list-item>

                              <!-- WARNINGS -->
                              <!-- Warnings drop-down if there are any warnings -->
                              <v-list-group v-if="result.warnings && result.warnings.length > 0" ref="warningList" value="Warnings"
                                @click="scrollToRef('warningList')">
                                <template v-slot:activator="{ props }">
                                  <v-list-item v-bind="props" prepend-icon="mdi-alert-circle">
                                    <template v-slot:prepend>
                                      <v-icon color="#FD9235"></v-icon>
                                    </template>
                                    <!-- If number of warnings > 0, set text to orange -->
                                    <span class="warning-color">Warnings: {{ result.warnings.length }}</span>
                                  </v-list-item>
                                </template>

                                <v-list-item v-for="(warning, index) in result.warnings" :key="index" class="warning-item">
                                  {{ warning }}
                                </v-list-item>
                              </v-list-group>

                              <!-- Warnings drop-down if there are no warnings -->
                              <v-list-item v-else prepend-icon="mdi-alert-circle">
                                <span>Warnings: 0</span>
                              </v-list-item>


                              <!-- ERRORS -->
                              <!-- Errors drop-down if there are any errors -->
                              <v-list-group v-if="result.errors && result.errors.length > 0" ref="errorList" value="Errors"
                                @click="scrollToRef('errorList')">
                                <template v-slot:activator="{ props }">
                                  <v-list-item v-bind="props" prepend-icon="mdi-close-circle">
                                    <template v-slot:prepend>
                                      <v-icon color="#EA4848"></v-icon>
                                    </template>
                                    <!-- If number of errors > 0, set text to red -->
                                    <span class="error-color">Errors: {{ result.errors.length }}</span>
                                  </v-list-item>
                                </template>

                                <v-list-item v-for="(error, index) in result.errors" :key="index" class="error-item">
                                  {{ error }}
                                </v-list-item>
                              </v-list-group>

                              <!-- Errors drop-down if there are no warnings -->
                              <v-list-item v-else prepend-icon="mdi-close-circle">
                                <span>Errors: 0</span>
                              </v-list-item>


                              <!-- OUTPUT BUFR -->
                              <!-- BUFR files drop-down if there are any output files -->
                              <v-list-group v-if="result.files && result.files.length > 0" ref="fileList" value="Files"
                                @click="scrollToRef('fileList')">
                                <template v-slot:activator="{ props }">
                                  <v-list-item v-bind="props" prepend-icon="mdi-check-circle">
                                    <template v-slot:prepend>
                                      <v-icon color="#00BD9D"></v-icon>
                                    </template>
                                    <!-- If number of BUFR files > 0, set text to green -->
                                    <span :style="{ color: '#00BD9D' }">Output BUFR files: {{ result.files.length }}</span>
                                  </v-list-item>

                                </template>
                                <v-list-item v-for="(data_item, index) in result.data_items" :key="index">
                                  <div class="file-actions">
                                    <div>
                                      {{ data_item.filename }}
                                    </div>
                                    <!-- For wider windows, make buttons wider -->
                                      <div class="hidden-md-and-down">
                                        <div class="file-actions" v-if="data_item.file_url">
                                          <DownloadButton :fileName="data_item.filename" :fileUrl="data_item.file_url" :block="true" />
                                          <InspectBufrButton :fileName="data_item.filename" :fileUrl="data_item.file_url" :block="true" />
                                        </div>
                                        <div class="file-actions" v-if="data_item.data">
                                          <DownloadButton :fileName="data_item.filename" :data="data_item.data" :block="true" />
                                          <InspectBufrButton :fileName="data_item.filename" :data="data_item.data" :block="true" />
                                        </div>
                                      </div>
                                      <!-- For narrow windows, make buttons less wide -->
                                      <div class="hidden-lg-and-up">
                                        <div class="file-actions" v-if="data_item.file_url">
                                          <DownloadButton :fileName="data_item.filename" :fileUrl="data_item.file_url" :block="false" />
                                          <InspectBufrButton :fileName="data_item.filename" :fileUrl="data_item.file_url" :block="false" />
                                        </div>
                                        <div class="file-actions" v-if="data_item.data">
                                          <DownloadButton :fileName="data_item.filename" :data="data_item.data" :block="false" />
                                          <InspectBufrButton :fileName="data_item.filename" :data="data_item.data" :block="false" />
                                        </div>
                                      </div>
                                  </div>
                                  <v-divider v-if="index < result.files.length - 1" class="divider-spacing"></v-divider>
                                </v-list-item>
                              </v-list-group>

                              <!-- BUFR files drop-down if there are no warnings -->
                              <v-list-item v-else prepend-icon="mdi-check-circle">
                                <span>Output BUFR files: 0</span>
                              </v-list-item>

                            </v-list>
                          </v-card>
                        </v-col>
                      </v-row>
                    </v-stepper-window-item>
                </v-stepper-window>
                <v-stepper-actions
                    @click:prev="prev"
                    @click:next="next"
                    >
                </v-stepper-actions>
            </v-stepper>
        </v-container>
</template>

<script>
    import { defineComponent, ref, onMounted, watch, computed} from 'vue';
    import { VFileInput, VCardActions, VBtn, VCard, VCardText, VCardItem, VChip, VTooltip } from 'vuetify/lib/components/index.mjs';
    import { VList, VListItem, VContainer, VCardTitle, VIcon, VDialog} from 'vuetify/lib/components/index.mjs';
    import { VDataTable} from 'vuetify/lib/components/index.mjs';
    import { VStepper, VStepperHeader, VStepperItem, VStepperWindow, VStepperWindowItem, VStepperActions} from 'vuetify/lib/components/index.mjs';
    import InspectBufrButton from '@/components/InspectBufrButton.vue';
    import DownloadButton from '@/components/DownloadButton.vue';
    import DatasetIdentifierSelector from '@/components/DatasetIdentifierSelector.vue';
    import * as d3 from 'd3';
    export default defineComponent({
        name: 'CsvToBUFRForm',
        components: {
            VFileInput, VCardActions, VBtn, VCard, VCardText, VCardItem, VDataTable,
            VChip, VTooltip, VListItem, VList, VContainer,
            VCardTitle, VIcon, VStepper, VStepperHeader, VStepperItem, VStepperWindow, VStepperWindowItem,
            VStepperActions, VDialog, InspectBufrButton, DownloadButton,
            DatasetIdentifierSelector
        },
        setup() {
            // reactive variables
            const theData = ref(null);
            const headers = ref(null);
            const incomingFile = ref(null);
            const schema = ref(null);
            const step=ref(0);
            const validationWarnings = ref([]);
            const validationErrors = ref([]);
            const status = ref({
                fileLoaded: false,
                fileValidated: false,
                datasetIdentifier: false,
                password: false
            });
            // Variable to control whether token is seen or not
            const showToken = ref(false);
            const token = ref(null);
            const datasetSelected = ref(null);
            const rawCSV = ref(null);
            const msg = ref(null);
            const showDialog = ref(null);
            const scrollRef = ref(null);
            const result = ref(null);
            const notificationsOnPending = ref(false);

            // computed properties

            const step1Color = computed(() => {
                if (status.value.fileLoaded) {
                    return "#64BF40"
                }
                return "#003DA5"
            })
            const step2Color = computed(() => {
                if (status.value.fileValidated) {
                    return "#64BF40"
                }
                else if (validationErrors.value.length > 0) {
                    return "error"
                }
                return "#003DA5"
            })
            const step3Color = computed(() => {
                if (status.value.datasetIdentifier) {
                    return "#64BF40"
                }
                return "#003DA5"
            })
            const step4Color = computed(() => {
                if (status.value.password) {
                    return "#64BF40"
                }
                return "#003DA5"
            })
            const step5Complete = computed(() => {
                return status.value.fileLoaded && status.value.fileValidated && status.value.datasetIdentifier && status.value.password && status.value.submitted;
            })
            const step5Color = computed(() => {
                if (step5Complete.value) {
                    return "#64BF40"
                }
                return "#003DA5"
            })

            const resultTitle = computed( () => {
                if( result.value && result.value.result){
                  return "Result: " + result.value.result;
                }
                return "Unknown";
            });
            const numberNotifications = computed( () => {
                let messagesPublished = 0;
                if( result.value ){
                  messagesPublished = result.value['messages published'];
                }
                return "WIS2 notifications published: " + messagesPublished;
            });
            // life cycle hooks
            onMounted( () => {
                setTimeout(scrollToRef(200));
            });

            const scrollToRef = () => {
              if (scrollRef.value) {
                scrollRef.value.scrollIntoView({ behavior: 'smooth' });
              }
            };

            const loadCSV = async() => {
                if( incomingFile.value ){
                    // load schema
                    await fetch("./csv2bufr/csvw_schema.json").then( (response) => response.json() ).then( (theData) => {schema.value = theData.tableSchema.columns});
                    // now load the data file
                    let reader = new FileReader();
                    reader.readAsText(incomingFile.value);
                    reader.onload = async () => {
                        validationErrors.value = [];
                        validationWarnings.value = [];
                        // load the data
                        rawCSV.value = reader.result;
                        theData.value = await d3.csvParse(reader.result, d3.autoType);
                        // create header object for table
                        headers.value = Object.keys(theData.value[0]).map( key => ({
                            title: key,
                            value: key,
                            key: key,
                            sortable: true,
                            divider: true
                        }));
                        // check the headers against the schema
                        for(let column in headers.value ){
                            let key = headers.value[column].key
                            let schemaColumn = schema.value.find( col => col.titles === key )
                            if( ! schemaColumn ){
                                validationWarnings.value.push("Column '" + key +
                                    "' not found in schema, data will be skipped")
                                headers.value[column].dataType = {base: null, minimum: null, maximum: null};
                                headers.value[column].inSchema = false;
                            }else{
                                headers.value[column].dataType = schemaColumn.datatype;
                                headers.value[column].inSchema = true;
                                schemaColumn.present = true;
                            }
                        }
                        for(let col in schema.value){
                            if(!schema.value[col].present){
                                let key = schema.value[col].titles;
                                validationWarnings.value.push("Column '" + key +
                                    "' missing from data file, data will be set to missing in BUFR encoding");
                            }
                        }
                        // now validate the data
                        let count = 0;
                        for(const record of theData.value){
                            count++;
                            for( const key in record){
                                let header = headers.value.find(header => header.key === key );
                                let value = record[key];
                                record[key] = {
                                    value: value,
                                    status: "",
                                    msg: ""
                                }
                                let valid_min = false;
                                let valid_max = false;
                                let msg = "";
                                let status = "success";
                                if( header.inSchema ){
                                    if( header.dataType.minimum ){
                                        valid_min = header.dataType.minimum
                                    }
                                    if( value && valid_min && (value < valid_min)){
                                        msg = "Line " + count + ": Column '" +
                                            key + "' out of range, value (" + value + ") < valid min (" +
                                            valid_min + ")";
                                        status = 'error';
                                        validationErrors.value.push(msg);
                                    }
                                    if( header.dataType.maximum ){
                                        valid_max = header.dataType.maximum
                                    }
                                    if( value && valid_max && (value > valid_max)){
                                        msg = "Line " + count + ": Column '" + key +
                                            "' out of range, value (" + value + ") > valid max (" + valid_max + ")";
                                        status = 'error';
                                        validationErrors.value.push(msg);
                                    }
                                }else{
                                    status = "warning";
                                    msg = "Field not in schema";
                                }
                                if(((! value) && (value!==0)) | ( value === 'null')){  // this is horrible, there must be a better way
                                    msg = "Line " + count + ": Column '" + key + "' contains missing data";
                                    status = "warning"
                                    validationWarnings.value.push(msg);
                                }
                                record[key].status = status;
                                record[key].msg = msg;
                            }
                        }
                        // get limits and kind from schema
                    };
                    step.value = 1;
                }
            };
            const submit = async() => {
                CsvToBUFR();
                status.value.submitted = true;
            };
            const CsvToBUFR = async() => {
              const payload = {
                  inputs: {
                      data: rawCSV.value,
                      channel: datasetSelected.value.metadata.topic,
                      metadata_id: datasetSelected.value.metadata.id,
                      notify: notificationsOnPending.value,
                      template: "aws-template"
                  }
              };
              const apiURL = `${import.meta.env.VITE_API_URL}/processes/wis2box-csv2bufr/execution`;

              const response = await fetch(apiURL, {
                method: 'POST',
                headers: {
                    'encode': 'json',
                    'Content-Type': 'application/geo+json',
                    'Authorization': 'Bearer '+ token.value
                },
                body: JSON.stringify(payload)
              });
              if (!response.ok) {
                if (response.status == 401) {
                  msg.value = "Unauthorized, please provide a valid 'processes/wis2box' token"
                }
                else if (response.status == 404) {
                  msg.value = "Error submitting data: API not found"
                }
                else if (response.status == 500) {
                  msg.value = "Error submitting data: Internal server error"
                }
                else {
                  msg.value = "API Error, please check the console";
                  console.error('HTTP error', response.status);
                }
                showDialog.value = true;
                result.value = {
                  "result": "API error",
                  "errors": [
                    apiURL + " returned " + response.status
                  ]
                };
              } else {
                const data = await response.json();
                result.value = data;
                result.value.files = [];
                for( let item in result.value.data_items){
                  result.value.files.push( result.value.data_items[item].file_url);
                }
              }
            }
            const prev = () => {
                step.value = step.value === 0 ? 0 : step.value - 1;
            };
            const next = () => {
                let proceed = false;
                switch (step.value){
                  case 0:
                    if( status.value.fileLoaded){
                      proceed = true;
                      loadCSV()
                    }else{
                      showDialog.value = true;
                      msg.value = "Please select or drag and drop a file to upload";
                    }
                    break;
                  case 1:
                    if( validationErrors.value.length === 0 ){
                      proceed = true;
                      status.value.fileValidated = true;
                    }else{
                      showDialog.value = true;
                      status.value.fileValidated = false;
                      msg.value = "Please fix validation errors before proceeding";
                    }
                    break;
                  case 2:
                    if( status.value.datasetIdentifier ){
                      proceed = true;
                    }else{
                      showDialog.value = true;
                      msg.value = "Please select a dataset to publish on before proceeding";
                    }
                    break;
                  case 3:
                    if( status.value.password ){
                      proceed = true;
                      submit();
                    }else{
                      showDialog.value = true;
                      msg.value = "Please enter the authorization token before proceeding";
                    }
                    break;
                }
                if( proceed ){
                  step.value = step.value === 4 ? 4 : step.value + 1;
                }
            };

            // Watchers
            watch( datasetSelected, (val) => {
              status.value.datasetIdentifier = !!val;
            });

            watch( incomingFile, (val) => {
              status.value.fileLoaded = !!val;
            });

            watch( validationErrors, (val) => {
              if( val && val.length > 0 ){
                status.value.fileValidated = false;
              }else{
                status.value.fileValidated = true;
              }
            });

            watch( token, () => {
              if( token.value && token.value.length > 0 ){
                status.value.password = true;
              }else{
                status.value.password = false;
              }
            });

            return {theData, headers, incomingFile, loadCSV, step, prev, next, scrollToRef,
                    validationWarnings, validationErrors, status, showToken, token, notificationsOnPending, step1Color, step2Color, step3Color, step4Color, step5Complete, step5Color,
                    datasetSelected, submit, msg, showDialog, result, resultTitle, numberNotifications};
        },
    })
</script>
