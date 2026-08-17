<template>
    <v-card variant="outlined" color="#757575">
        <v-card-item style="width: 100%; height: 100%; min-height: 405px" :id="id"></v-card-item>
    </v-card>
</template>

<script>
import { defineComponent, ref, computed, onMounted, watch } from 'vue';
import { VCard } from 'vuetify/lib/components/index.mjs';
import L from "leaflet";
import "leaflet/dist/leaflet.css";

export default defineComponent({
    name: "BboxEditor",
    components: {
        VCard
    },
    props: {
        boxBounds: {
            type: Array,
            default: null
        },
        boxBoundsList: {
            type: Array,
            default: () => []
        },
        selectedBoxIndex: {
            type: Number,
            default: 0
        }
    },
    setup(props, { attrs }) {

        // Reactive variables
        const map = ref(null);
        const fallbackId = `bbox-map-${Math.random().toString(36).slice(2, 8)}`;
        const id = ref(attrs.id || fallbackId);
        const rectangles = ref([]);
        const zoom = ref(1.5);
        const centre = ref([0, 0]);

        const isFiniteBoxBounds = (bounds) => {
            if (!Array.isArray(bounds) || bounds.length !== 4) {
                return false;
            }
            return bounds.every((value) => Number.isFinite(Number(value)));
        };

        // Computed property for one or many bounds
        const boundsList = computed(() => {
            if (Array.isArray(props.boxBoundsList) && props.boxBoundsList.length > 0) {
                return props.boxBoundsList
                    .map((bounds, sourceIndex) => ({ bounds, sourceIndex }))
                    .filter((item) => isFiniteBoxBounds(item.bounds));
            }
            if (isFiniteBoxBounds(props.boxBounds)) {
                return [{ bounds: props.boxBounds, sourceIndex: 0 }];
            }
            return [];
        });

        const clearRectangles = () => {
            rectangles.value.forEach((rectangle) => rectangle.remove());
            rectangles.value = [];
        };

        onMounted(() => {
            // Add 1 second delay to load map or Vue will call mounted before DOM is available
            setTimeout(() => {
                map.value = L.map(id.value).setView(centre.value, zoom.value);
                map.value.attributionControl.setPrefix('');
                L.tileLayer(`${import.meta.env.VITE_BASEMAP_URL}`, { attribution: `${import.meta.env.VITE_BASEMAP_ATTRIBUTION}` }).addTo(map.value);
            }, 1)
        });

        watch([boundsList, map, () => props.selectedBoxIndex], ([newBoundsList, currentMap]) => {
            if (!currentMap) {
                return;
            }

            clearRectangles();

            if (newBoundsList.length > 0) {
                newBoundsList.forEach((boxData) => {
                    const boxBounds = boxData.bounds;
                    const isSelected = boxData.sourceIndex === props.selectedBoxIndex;
                    const bounds = L.latLngBounds(
                        L.latLng(boxBounds[0], boxBounds[1]),
                        L.latLng(boxBounds[2], boxBounds[3])
                    );
                    const rectangle = L.rectangle(bounds, {
                        color: isSelected ? "#003DA5" : "#1FB5DB",
                        weight: 2,
                        fillOpacity: 0.15
                    }).addTo(currentMap);
                    rectangles.value.push(rectangle);
                });

                const featureGroup = L.featureGroup(rectangles.value);
                currentMap.fitBounds(featureGroup.getBounds(), { padding: [10, 10] });
            }
        }, { immediate: true });

        return {
            map,
            id
        }
    }
});
</script>