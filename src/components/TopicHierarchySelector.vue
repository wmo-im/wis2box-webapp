<template>
    <div v-if="! errorMessage">
      <v-autocomplete
        v-if="(options !== null)"
        :items="options"
        item-title="name"
        item-value="id"
        label="Topic hierarchy"
        v-model="selected"
        :readonly="readonly"
        :rules="rules"
        :hint="selected ? selected.description : 'Select topic hierarchy'"
        persistent-hint
        :multiple="multiple"
        return-object
        />
    </div>
    <div v-else class="error">
      <v-text-field class="text-error" readonly>{{ errorMessage }}</v-text-field>
    </div>
</template>

<script>
import { defineComponent, ref, onBeforeMount, watch, onErrorCaptured } from 'vue';
import { VAutocomplete, VTextField } from 'vuetify/lib/components/index.mjs';


export default defineComponent({
  name: 'SelectTopicHierarchy',
  components: {
    VAutocomplete, VTextField
  },
  props: {
    modelValue: {},
    readonly: false,
    multiple: false,
    rules: {
      type: Array
    }
  },
  emits: ["update:modelValue"],
  setup(props, { emit }) {
    const apiUrl = `${import.meta.env.VITE_API_URL}/collections/discovery-metadata/items?f=json`;
    const options = ref(null);
    const selected = ref([]);
    const errorMessage = ref(null);

    const fetchOptions = async () => {
      // Get topic hierarchies
      if (import.meta.env.VITE_TEST_MODE === "true" || import.meta.env.VITE_API_URL == undefined) {
        // If test mode enabled, show test topics
        console.log("TEST_MODE is enabled");
        options.value = [
          {name: "test1", id: "test1", description: "Test 1"}, {name: "test2", id: "test2", description: "Test 2"}, {name: "test3", id: "test3", description: "Test 3"}
        ]

      }
      else {
        console.log("Fetching topic hierarchy from:", apiUrl);
        try {
          const response = await fetch(apiUrl);
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }
          else {
            const data = await response.json();
            if (data.features) {
              // Use Array.map to create a new array of the topic hierarchies
              options.value = data.features.map(feature => {
                if (feature.properties && feature.properties['wmo:topicHierarchy']) {
                  return {
                    name: feature.properties['wmo:topicHierarchy'],
                    id: feature.properties['wmo:topicHierarchy'],
                    description: feature.properties['description']
                  }
                }
              }
              );
            }
            else {
              console.error("API response is not an object");
            }
          }
        }
        catch (error) {
          errorMessage.value = "Error fetching topic hierarchy, please check the API end point." +
            " See logs for more information.";
          console.error("Error fetching topic hierarchy:", error)
        }
      }
    };


    onBeforeMount(async () => {
      await fetchOptions();
      if (props.modelValue && props.modelValue.length) {
        for (var topic in props.modelValue) {
          selected.value.push(options.value.find(option => option.id === props.modelValue[topic]));
        }
      }
    });

    watch(selected, (newValue) => {
      if (selected.value) {
        emit("update:modelValue", newValue);
      }
    });

    return { selected, options, errorMessage };
  }
});
</script>
