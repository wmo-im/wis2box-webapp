<template>
  <v-btn color="primary" @click="downloadFile">Download</v-btn>
</template>

<script>
import { defineComponent, ref } from 'vue';
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
        const fileName = ref("");
        // function to download file
        const downloadFile = () => {
            // Extract the file name from the URL
            fileName.value = props.fileUrl.substring(props.fileUrl.lastIndexOf('/') + 1);
            // Create a temporary anchor element to initiate the download
            const link = document.createElement('a');
            link.href = props.fileUrl;
            link.target = '_blank';
            // Programmatically trigger the click event on the link to start the download
            link.click();
        };
        return {
            downloadFile,
            fileName
        };
    },
});  
</script>

<style>

</style>