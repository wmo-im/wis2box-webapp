<template>
    <div v-if="! errorMessage">
      <v-autocomplete
        v-if="(options !== null)"
        :items="options"
        item-title="name"
        item-value="id"
        label="Observing facility operating status"
        v-model="selected"
        :readonly="readonly"
        :hint="selected ? selected.description : 'Select observing facility operating status'"
        persistent-hint
        return-object
        />
    </div>
    <div v-else class="error">
      <v-text-field class="text-error" read-only :hint="props.defaultHint" persistent-hint>{{ errorMessage }}</v-text-field>
    </div>
</template>

<script>
  import { defineComponent, ref, onBeforeMount, watch, onErrorCaptured, computed} from 'vue';
  import {VAutocomplete, VTextField} from 'vuetify/lib/components/index.mjs';


  export default defineComponent({
    name: 'OperatingStatusSelector',
    components: {
      VAutocomplete, VTextField
    },
    props: {
      modelValue: {},
      readonly: false
    },
    emits: ["update:modelValue"],
    setup(props, {emit}){
      const apiUrl = "/code_lists/operatingStatus.json";
      const options = ref(null);
      const selected = ref(null);
      const errorMessage = ref(null);

      const fetchOptions = async () => {
        try {
          const response = await fetch(apiUrl);
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }
          const data = await response.json();
          options.value = data; // Assuming the API response contains the options in the expected format
        } catch (error) {
          errorMessage.value = 'Error fetching operating status options.';
          console.error('Error fetching operating status options:', error);
        }
      };

      onBeforeMount( async () => {
        await fetchOptions() ;
        // update if we have an initial value
        if( props.modelValue && props.modelValue.length ){
          selected.value = options.value.find(option => option.id === props.modelValue) ;
        }
      });

      watch( selected, (newValue) => {
        if( selected.value ){
          emit("update:modelValue", newValue);
        }
      });

      return {selected, options, errorMessage};
    }
  });
</script>
