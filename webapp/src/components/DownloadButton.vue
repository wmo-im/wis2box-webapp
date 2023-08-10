<template>
  <v-btn color="#00BD9D" append-icon="mdi-download" @click="downloadFile">Download</v-btn>
</template>

<script>
import { defineComponent } from 'vue';
import { VBtn } from 'vuetify/lib/components/index.mjs';

export default defineComponent({
    name: 'DownloadButton',
    props: {
        fileUrl: {
            type: String,
            required: true,
        },
    },
    components: {
        VBtn
    },
    setup(props) {
        // Extract the file name from the URL
        const fileName = props.fileUrl.split('/').pop();

        // function to download file
        const downloadFile = () => {
            // Create a temporary anchor element to initiate the download
            const link = document.createElement('a');
            link.href = props.fileUrl;
            link.target = '_blank';
            // Programmatically trigger the click event on the link to start the download
            link.click();
        };
        return {
            fileName,
            downloadFile
        };
    },
});  
</script>

<style>

</style>