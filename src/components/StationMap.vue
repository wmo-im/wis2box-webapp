<template>
    <v-card>
        <v-card-title>Map View</v-card-title>
        <v-card-item style="width: 100%; height: 100%; min-height: 600px" :id="id"></v-card-item>
    </v-card>
</template>

<script>
import { defineComponent, ref, computed, onMounted, watch } from 'vue';
import { VCard } from 'vuetify/lib/components/index.mjs';

// Leaflet imports
import 'leaflet/dist/leaflet.css';
import 'leaflet.markercluster/dist/MarkerCluster.css';
import 'leaflet.markercluster/dist/MarkerCluster.Default.css';
import L from 'leaflet';
import 'leaflet.markercluster';

export default defineComponent({
    name: "StationMap",
    props: {
        messages: {
            type: Array,
            required: true,
            default: () => []
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
        const stationLayer = ref(null);

        // Create geoJSON data from the messages prop
        const features = computed(() => {
            return props.messages.map(msg => {
                return {
                    type: 'Feature',
                    id: msg.id,
                    properties: {
                        wigos_station_identifer: msg.wsi
                    },
                    geometry: {
                        type: 'Point',
                        coordinates: msg.coordinates
                    }
                }
            })
        });

        // Fill map with markers when data changes
        const updateMarkers = () => {
            if (map.value && props.messages.length > 0) {
                stationLayer.value.clearLayers();
                // Instantiate LatLngBounds object
                var bounds = L.latLngBounds()
                // Structure features array in form [lat, lon]
                // required for markers
                features.value.map((feature) => {
                    let coords = feature.geometry?.coordinates;
                    // Check if coordinates are defined before proceeding
                    if (coords) {
                        // Swap coordinates to [lat, lon] for Leaflet
                        coords = [feature.geometry.coordinates[1], feature.geometry.coordinates[0]];
                        const marker = L.marker(coords, {
                            // Set the marker icon, if desired
                            icon: L.icon({
                                iconUrl: import.meta.env.VITE_BASE_URL + '/assets/marker-icon.png',
                                shadowUrl: import.meta.env.VITE_BASE_URL + '/assets/marker-shadow.png',
                                iconSize: [25, 41],
                                iconAnchor: [12, 41],
                                popupAnchor: [1, -34]
                            })
                        });
                        // Set ID for marker, which is a link to
                        // the notification
                        marker.id = feature.id;
                        // Set type of marker
                        marker.type = "host";
                        // Extend LatLngBounds with coordinates
                        bounds.extend(coords)
                        stationLayer.value.addLayer(marker);
                    }
                })
                map.value.fitBounds(bounds);
            }
        };

        onMounted(() => {
            map.value = L.map(props.id, { zoomAnimation: false, fadeAnimation: true, markerZoomAnimation: true }).setView(props.center, props.zoom);
            map.value.attributionControl.setPrefix('');
            L.tileLayer(`${import.meta.env.VITE_BASEMAP_URL}`, { attribution: `${import.meta.env.VITE_BASEMAP_ATTRIBUTION}` }).addTo(map.value);
            // Disable the spiderfy and zoom effects
            let clusters = new L.markerClusterGroup({
                spiderfyOnMaxZoom: false,
                showCoverageOnHover: false,
                // Clicking on a cluster zooms in to show more clusters
                zoomToBoundsOnClick: true,
                // Shows a marker as a size 1 cluster
                singleMarkerMode: false,
                // decrease the cluster radius to show more clusters
                maxClusterRadius: 5
            });
            clusters.addTo(map.value);
            stationLayer.value = clusters;
            // Update markers then cluster
            updateMarkers();
        })

        watch(features, () => { updateMarkers() });
    }
})

</script>