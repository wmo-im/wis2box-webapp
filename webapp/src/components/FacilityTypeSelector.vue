<template>
    <div v-if="! errorMessage">
      <v-autocomplete
        v-if="(options !== null)"
        :items="options"
        item-title="name"
        item-value="id"
        label="Type of observing facility"
        v-model="selected"
        :readonly="readonly"
        :hint="selected ? selected.description : 'Select facility type'"
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
    name: 'FacilityTypeSelector',
    components: {
      VAutocomplete, VTextField
    },
    props: {
      modelValue: {},
      readonly: false
    },
    emits: ["update:modelValue"],
    setup(props, {emit}){
      const apiUrl = "/code_lists/facilityType.json";
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
          errorMessage.value = 'Error fetching facility type options.';
          console.error('Error fetching facility type options:', error);
        }
      };

      onBeforeMount( async () => {
        await fetchOptions() ;
        // update if we have an initial value
        if( props.modelValue.length ){
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
