<template>
    <v-dialog v-model="showDialog" width="auto">
      <v-card>
        <v-card-text>Unable to fetch code list, please see console.</v-card-text>
        <v-card-actions>
          <v-btn color="primary" block @click="showDialog=false" elevation=2>Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <div v-if="!error_">
    <v-autocomplete
      v-if="options !== null"
      :items="options"
      item-title="rdfs:label"
      item-value="skos:notation"
      :label="props.label"
      v-model="selected"
      :rules="[value => !!value ? true : props.defaultHint]"
      :hint="selected ? (selected['dct:description'] ? selected['dct:description']['@value']: props.defaultHint) : props.defaultHint"
      :readonly="props.readonly"
      clearable
      persistent-hint
      return-object
      />
    </div>
    <div v-else class="error">
      <v-text-field :label="props.label" class="text-error" readonly hint="Unable to fetch code list, please see console." persistent-hint/>
    </div>
</template>

<script>
  import { defineComponent, ref, onBeforeMount, watch, onMounted} from 'vue';
  import { VCard, VCardItem, VAutocomplete} from 'vuetify/lib/components/index.mjs';


  export default defineComponent({
    name: 'CodeListSelector',
    components: {
      VCard, VCardItem, VAutocomplete
    },
    props: {
      codeList: {type: String},
      label: {type: String},
      defaultHint: {type: String},
      readonly: false,
      modelValue: null
    },
    emits: ["update:modelValue"],
    setup(props, {emit}){
      const options = ref(null);
      const selected = ref(null);
      const showDialog = ref(false);
      const error_ = ref(false);

      const fetchOptions = async() => {
        try {
          var apiUrl = `${import.meta.env.VITE_BASE_URL}/codelists/${props.codeList}.json`;
          const response = await fetch(apiUrl);
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }
          const data = await response.json();
          // extract only code list entries, we don't need the metadata
          options.value = data['@graph'].filter(item => item['@type'] === "skos:Concept");
        } catch (error) {
          console.error('Error fetching ' + props.label + ' options:', error);
          showDialog.value = true;
          error_.value = true;
        }
      };

      onBeforeMount( async () => {
        await fetchOptions();
        selected.value = options.value && props.modelValue ? options.value.find( item => item['skos:notation'] === props.modelValue) : null;
      });

      watch( () => props.modelValue, (newValue) => {
        selected.value = newValue;
      });

      watch( () => selected.value, (newValue) => {
        emit("update:modelValue", newValue);
      });
      return {selected, options, props, showDialog, error_};
    }
  });
</script>
