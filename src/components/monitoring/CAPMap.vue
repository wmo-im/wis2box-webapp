<template>
    <v-card>
        <div class="legend">
            <strong>Severity:</strong>

            <i class="fas fa-circle legend-circle" :style="{ color: getColour('Minor') }"></i>
            <b v-if="severity === 'Minor'">Minor</b>
            <span v-else>Minor</span>

            <i class="fas fa-circle legend-circle" :style="{ color: getColour('Moderate') }"></i>
            <b v-if="severity === 'Moderate'">Moderate</b>
            <span v-else>Moderate</span>

            <i class="fas fa-circle legend-circle" :style="{ color: getColour('Severe') }"></i>
            <b v-if="severity === 'Severe'">Severe</b>
            <span v-else>Severe</span>

            <i class="fas fa-circle legend-circle" :style="{ color: getColour('Extreme') }"></i>
            <b v-if="severity === 'Extreme'">Extreme</b>
            <span v-else>Extreme</span>
        </div>
        <v-card-item style="width: 100%; height: 100%; min-height: 600px" :id="id"></v-card-item>
    </v-card>
</template>

<script>
import { defineComponent, ref, computed, onMounted, watch } from 'vue';
import { VCard } from 'vuetify/lib/components/index.mjs';

// Leaflet imports
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import '@fortawesome/fontawesome-free/css/all.css';


export default defineComponent({
    name: "CAPMap",
    props: {
        feature: {
            type: Object,
            required: true,
            default: () => ({})
        },
        center: {
            type: Object,
            required: false,
            default: () => ({ lat: 0, lng: 0 })
        },
        zoom: {
            type: Number,
            required: false,
            default: 8
        },
        id: {
            type: String,
            required: false,
            default: "map"
        }
    },
    components: {
        VCard
    },
    setup(props) {

        // Reactive variables
        const map = ref(null);
        const areaLayer = ref(null);

        // Computed

        // Ensure all necessary data is available before updating the map
        const readyToUpdate = computed(() => {
            return map.value && areaLayer.value;
        });

        const severity = computed(() => {
            return props.feature.properties.severity;
        });

        // Methods

        // Get colour based on the value of the severity property
        const getColour = (severity) => {
            switch (severity) {
                case "Extreme":
                    return "#FF0000";
                case "Severe":
                    return "#FFA500";
                case "Moderate":
                    return "#FFFF00";
                case "Minor":
                    return "#008000";
                default:
                    return "#000000";
            }
        };

        // Fill map with markers when data changes
        const addPolygons = () => {
            if (!readyToUpdate.value) return;

            // Clear the layer
            areaLayer.value.clearLayers();

            // Add the polygons
            let geojson = L.geoJSON(props.feature, {
                style: (feature) => {
                    return {
                        color: 'black',
                        fillColor: getColour(feature.properties.severity),
                        weight: 1,
                        opacity: 1,
                        fillOpacity: 0.6
                    };
                }
            }).addTo(map.value);

            // Fit the map to the bounds of the GeoJSON layer
            map.value.fitBounds(geojson.getBounds());
        };

        onMounted(() => {
            // Create the map, base layer and add it to the DOM
            map.value = L.map(props.id, { zoomAnimation: false, fadeAnimation: true, markerZoomAnimation: true }).setView(props.center, props.zoom);
            map.value.attributionControl.setPrefix('');
            L.tileLayer(`${import.meta.env.VITE_BASEMAP_URL}`, { attribution: `${import.meta.env.VITE_BASEMAP_ATTRIBUTION}` }).addTo(map.value);
            // Initialise the station layer and update with markers
            areaLayer.value = L.layerGroup().addTo(map.value);

            addPolygons();
        })

        watch(props.feature, () => { addPolygons() });

        return { getColour, severity };
    }
})
</script>

<style scoped>
.customIcon {
    /* Ensures the text icon is centered both vertically and horizontally */
    display: flex;
    justify-content: center;
    align-items: center;
    text-align: center;
}

.legend {
    padding: 6px 8px;
    line-height: 24px;
}

.legend-circle {
    margin-left: 3%;
    margin-right: 1%;
}
</style>
