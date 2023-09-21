<template>
  <v-btn color="#00CCAA" :block="block" append-icon="mdi-download" @click="downloadFile">Download</v-btn>
</template>

<script>
import { defineComponent } from 'vue';
import { VBtn } from 'vuetify/lib/components/index.mjs';

export default defineComponent({
    name: 'DownloadButton',
    props: {
        fileName: {
            type: String,
            required: true,
        },
        fileUrl: {
            type: String,
            required: false,
            default: '',
        },
        data: {
            type: String,
            required: false,
            default: '',
        },
        block: {
            type: Boolean,
            required: false,
            default: false
        }
    },
    components: {
        VBtn
    },
    setup(props) {
        // function to download file
        const downloadFile = () => {
            // Create a temporary anchor element to initiate the download
            const link = document.createElement('a');
            if( props.fileUrl != '' ) {
                //console.log("Downloading file from URL: " + props.fileUrl)
                link.href = props.fileUrl;
                link.target = '_blank';
                // Programmatically trigger the click event on the link to start the download
                link.click();
                // Clean up
                URL.revokeObjectURL(link.href);
            }
            else if( props.data != '' ) {
                //console.log("Downloading file from data: " + props.data)
                // Decode the base64 encoded data
                const decodedData = atob(props.data);
                // Convert the decoded data to a Uint8Array
                const uint8Array = new Uint8Array(decodedData.length);
                for (let i = 0; i < decodedData.length; ++i) {
                    uint8Array[i] = decodedData.charCodeAt(i);
                }
                // Create a Blob with the Uint8Array data
                const blob = new Blob([uint8Array], { type: 'application/octet-stream' });
                link.href = URL.createObjectURL(blob);
                link.download = props.fileName;
                // Programmatically trigger the click event on the link to start the download
                link.click();
                // Clean up
                URL.revokeObjectURL(link.href);
            }
            else {
                console.log("No fileURL or data provided");
            }
        };
        return {
            downloadFile
        };
    },
});  
</script>

<style>

</style>