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
                    <v-jsf v-model="model" :schema="schema" :options="options" @change-child="updateModel" />
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


</script>