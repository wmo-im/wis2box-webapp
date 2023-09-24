<template>
    <v-row>
        <v-col cols="12">
            <v-card>
                <v-card-title class="text-center text-wrap">Total number of publications with selected features:
                    <v-chip class="number">{{ totalMessages }}</v-chip></v-card-title>
            </v-card>
        </v-col>
    </v-row>
</template>

<script>
import { defineComponent, computed } from 'vue';
import { VCard, VCardTitle } from 'vuetify/lib/components/index.mjs';

export default defineComponent({
    name: 'SummaryStats',
    props: {
        messages: {
            type: Array,
            required: true,
            default: () => []
        }
    },
    components: {
        VCard,
        VCardTitle
    },
    setup(props) {

        const totalMessages = computed(() => {
            // Return the number of messages if there
            // are any, otherwise 0
            return props.messages.length || 0;
        })

        return {
            totalMessages
        }
    }
})
</script>

<style scoped>

.number {
    font-weight: 800;
    font-size: 20px;
    margin-left: 1rem;
}

</style>