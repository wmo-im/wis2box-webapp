<template>
  <v-btn color="#49C6E5" :block="block" append-icon="mdi-feature-search" @click="downloadAndFormatXML">Inspect
    Alert</v-btn>
  <v-dialog v-model="dialog" max-width="1000px">
    <v-card>
      <v-toolbar :title="fileName" :color="errorMsg ? error : '#49C6E5'">
        <v-btn icon="mdi-close" variant="text" size="small" @click="dialog = false" />
      </v-toolbar>
      <v-container class="scrollable-alert px-5">
        <div v-if="errorMsg">{{ errorMsg }}</div>
        <div id="result" v-html="transformedHtml" />
      </v-container>
    </v-card>
  </v-dialog>
</template>

<script>
import { defineComponent, ref } from 'vue';
import { VDialog, VCard, VToolbar } from 'vuetify/lib/components/index.mjs';


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
    VDialog, VCard, VToolbar
  },
  setup(props) {
    const dialog = ref(false);
    const transformedHtml = ref('');
    const errorMsg = ref(null);

    const loadScript = (src) => {
      return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = src;
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
      });
    };

    const insertAndExecute = async (id, htmlResult) => {
      const container = document.getElementById(id);
      if (!container) {
        console.error(`Element with id ${id} not found`);
        return;
      }
      container.appendChild(htmlResult);
      const scripts = container.getElementsByTagName("script");
      const externalScripts = [];

      // First load all external scripts
      for (const script of scripts) {
        if (script.src) {
          externalScripts.push(loadScript(script.src));
        }
      }

      // Wait for all external scripts to load
      await Promise.all(externalScripts);

      // Execute inline scripts
      for (const script of scripts) {
        if (!script.src) {
          new Function(script.innerText || script.textContent)();
        }
      }
    };

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

        // Create XSLTProcessor using stylesheet
        const xsltProcessor = new XSLTProcessor();
        xsltProcessor.importStylesheet(xslData);

        // Transform XML data using XSLTProcessor
        const resultDocument = xsltProcessor.transformToFragment(xmlData, document);

        // Insert and execute scripts
        await insertAndExecute('result', resultDocument);
        transformedHtml.value = new XMLSerializer().serializeToString(resultDocument);
      } catch (error) {
        console.error('Error fetching or transforming XML:', error);
        errorMsg.value = 'Error fetching or transforming XML, please check the console.';
      }
      dialog.value = true;
    };

    return {
      props,
      transformedHtml,
      dialog,
      errorMsg,
      downloadAndFormatXML
    };
  }
});
</script>

<style scoped>
.scrollable-alert {
  overflow-y: auto;
  max-height: 800px;
  max-width: 1600px;
}
</style>
