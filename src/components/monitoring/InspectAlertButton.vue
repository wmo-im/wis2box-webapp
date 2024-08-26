<template>
  <v-btn color="#49C6E5" :block="block" append-icon="mdi-feature-search"
    @click="downloadAndInspectXML">Inspect Alert</v-btn>
  <v-dialog v-model="dialog" max-width="1000px">
    <v-card>
      <v-card-title>{{ props.fileName }}</v-card-title>
      <v-container>
        <div v-html="parsedXMLContent"/>
      </v-container>
    </v-card>
  </v-dialog>
</template>

<script>
import { defineComponent, ref } from 'vue';
import { VCard, VCardTitle, VDialog } from 'vuetify/lib/components/index.mjs';

export default defineComponent({
  name: 'InspectAlertButton',
  props: {
    fileUrl: {
      type: String,
      required: true
    },
    fileName: {
      type: String,
      required: true
    },
    block: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  components: {
    VCard, VCardTitle, VDialog
  },
  setup(props) {
    const dialog = ref(false);
    const parsedXMLContent = ref(null);

    const parseXML = (data) => {
      const parser = new DOMParser();
      const xmlDoc = parser.parseFromString(data, 'application/xml');
      const serializer = new XMLSerializer();
      return serializer.serializeToString(xmlDoc);
    };

    const downloadAndInspectXML = async () => {
      const response = await fetch(props.fileUrl);
      if (!response.ok) {
        console.error("HTTP error", response.status);
        return;
      }
      const data = await response.text();
      parsedXMLContent.value = parseXML(data);
      dialog.value = true;
    };

    return {
      props,
      parsedXMLContent,
      dialog,
      downloadAndInspectXML
    };
  }
});
</script>
