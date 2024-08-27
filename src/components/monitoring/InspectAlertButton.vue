<template>
  <v-btn color="#49C6E5" :block="block" append-icon="mdi-feature-search" @click="downloadAndFormatXML">Inspect
    Alert</v-btn>
  <v-dialog v-model="dialog" max-width="1000px">
    <v-card>
      <v-card-title>{{ props.fileName }}</v-card-title>
      <v-container>
        <div v-html="transformedHtml" />
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
    const transformedHtml = ref('');

    const downloadAndFormatXML = async () => {
      try {
        // Fetch XML data
        const xmlResponse = await fetch(props.fileUrl);
        const xmlText = await xmlResponse.text();
        const parser = new DOMParser();
        const xmlData = parser.parseFromString(xmlText, 'application/xml');

        // Fetch XSL stylesheet
        const xslResponse = await fetch(`${import.meta.env.VITE_BASE_URL}/styles/cap-style.xsl`);
        const xslText = await xslResponse.text();
        const xslData = parser.parseFromString(xslText, 'application/xml');

        // Transform XML using XSLTProcessor
        const xsltProcessor = new XSLTProcessor();
        xsltProcessor.importStylesheet(xslData);

        const resultDocument = xsltProcessor.transformToFragment(xmlData, document);
        transformedHtml.value = new XMLSerializer().serializeToString(resultDocument);
      } catch (error) {
        console.error('Error fetching or transforming XML:', error);
      }
      dialog.value = true;
    };

    return {
      props,
      transformedHtml,
      dialog,
      downloadAndFormatXML
    };
  }
});
</script>
