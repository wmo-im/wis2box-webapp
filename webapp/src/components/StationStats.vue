<template>
    <v-row>
        <v-col cols="12">
            <v-card>
                <v-card-title class="text-center text-wrap">Number of publications per station</v-card-title>
                <v-divider />
                <div class="scrollable-list">
                    <template v-for="(count, wsi) in wsiCounts" :key="wsi">
                        <v-list-item lines="one">
                            <span class="wsi-font">{{ wsi }}</span>
                            <v-chip class="count-font">{{ count }}</v-chip>
                        </v-list-item>
                        <v-divider />
                    </template>
                </div>
            </v-card>

        </v-col>
    </v-row>
</template>

<script>
import { defineComponent, computed } from 'vue';
import { VCard, VCardTitle, VListItem } from 'vuetify/lib/components/index.mjs';

export default defineComponent({
    name: 'StationStats',
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
        VListItem
    },
    setup(props) {

        // Computed

        // Builds an object containing WSIs as keys and associated
        // number of publications as items
        const wsiCounts = computed(() => {
            const counts = {};
            let wsi;

            // For each message, get the WSI and add to
            // its count in the count object
            props.messages.forEach((message) => {
                if (message.wsi) {
                    wsi = message.wsi;
                    if (counts[wsi]) {
                        counts[wsi]++;
                    }
                    else {
                        counts[wsi] = 1
                    }
                }
            });

            // If the counts object is still empty, return it and move on
            if (Object.keys(counts).length === 0) {
                return {};
            }

            // Now sort from highest to lowest count by converting
            // the counts object to an array of arrays, sorting that,
            // then converting back to an object
            const sortedArray = Object.entries(counts).sort((a, b) => b[1] - a[1]);
            const sortedCounts = {};
            for (const [wsi, count] of sortedArray) {
                sortedCounts[wsi] = count;
            }

            return sortedCounts;
        })

        return {
            wsiCounts
        }
    }
})
</script>

<style scoped>
.scrollable-list {
    height: 343px;
    overflow-y: auto;
}

.wsi-font {
    font-size: 20px;
    margin-left: 1rem;
    margin-right: 12rem;
}

.count-font {
    font-weight: 800;
    font-size: 20px;
}
</style>