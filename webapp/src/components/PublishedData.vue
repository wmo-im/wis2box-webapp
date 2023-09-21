<template>
  <v-card>
    <v-card-title class="text-left">
      Published Data
    </v-card-title>
    <!-- Limit the size of the list and add scroll feature -->
    <v-text-field v-model="fileSearch" placeholder="Search for a file..." clearable />
    <div class="scrollable-file-list">
      <template v-for="(file_url, index) in filteredFileUrls" :key="index">
        <v-list class="file-list">
            <v-row justify="center" align="center">
              <v-col cols="5">

                <!-- Display the timestamp -->
                <div class="secondary">
                  {{ formatTime(filteredPublishTimes[index]) }}
                </div>

                <!-- Display the file name -->
                <div class="url-font">
                  {{ getFileName(file_url) }}
                </div>
              </v-col>

              <v-col cols="3">
                <DownloadButton :fileName="getFileName(file_url)" :fileUrl="file_url" :block="true" />
              </v-col>

              <v-col cols="3">
                <InspectBufrButton :fileName="getFileName(file_url)" :fileUrl="file_url" :block="true" />
              </v-col>
            </v-row>
        </v-list>
        <v-divider />
      </template>
    </div>
  </v-card>
</template>

<script>
import { defineComponent, ref, computed } from 'vue';
import { VCard, VCardTitle } from 'vuetify/lib/components/index.mjs';
import DownloadButton from './DownloadButton.vue';
import InspectBufrButton from './InspectBufrButton.vue';

export default defineComponent({
  name: 'PublishedData',
  props: {
    messages: {
      type: Array,
      required: true,
      default: () => []
    }
  },
  components: {
    VCard,
    VCardTitle,
    DownloadButton,
    InspectBufrButton
  },
  setup(props) {

    // Reactive variables

    // The string searched by the user
    const fileSearch = ref(null)

    // Computed

    // Filter the file URLs in published data by the search parameter
    const filteredFileUrls = computed(() => {
      // Create array of file urls from the messages
      let fileUrls = props.messages.map(message => message.canonical_url);

      if (fileSearch.value) {
        return fileUrls.filter(url => getFileName(url).includes(fileSearch.value));
      }
      return fileUrls;
    });

    // Filter the associated publish times by the search parameter
    const filteredPublishTimes = computed(() => {
      // Create array of file urls and publish times from the messages
      let fileUrls = props.messages.map(message => message.canonical_url);
      let publishTimes = props.messages.map(message => new Date(message.pubtime));

      if (fileSearch.value) {
        return publishTimes.filter((_, index) => getFileName(fileUrls[index]).includes(fileSearch.value));
      }
      return publishTimes;
    });

    // Methods

    // Method to get filename from the canonical href
    const getFileName = (url) => {
      const urlParts = url.split('/');
      return urlParts[urlParts.length - 1];
    };

    // Shows the publish time in a more readable format
    const formatTime = (timestamp) => {
      const year = timestamp.getFullYear();
      const month = String(timestamp.getMonth() + 1).padStart(2, '0');
      const day = String(timestamp.getDate()).padStart(2, '0');
      const hours = String(timestamp.getHours()).padStart(2, '0');
      const minutes = String(timestamp.getMinutes()).padStart(2, '0');
      return `${year}/${month}/${day} ${hours}:${minutes}`;
    };

    return {
      fileSearch,
      filteredFileUrls,
      filteredPublishTimes,
      getFileName,
      formatTime
    }
  }
})
</script>

<style scoped>
.scrollable-file-list {
  max-height: 500px;
  overflow-y: auto;
}

.file-list {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
}

.file-container {
  display: flex;
  flex-direction: column;
  margin-left: 1rem;
}

.button-container {
  display: flex;
  gap: 50px;
  flex-grow: 1;
  margin-right: 1rem;
}

.button {
  flex-grow: 1;
  min-width: 100px;
}

.url-font {
  font-size: 18px;
}
</style>