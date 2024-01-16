<template>
    <v-lazy>
        <v-img>
        <l-map
            ref="map"
            :zoom="zoom"
            :center="rectangle.center"
            @ready="loadMapObjects"
            style="height: 300px; width: 100%"
        >
            <l-control-layers
                position="bottomleft"
                :collapsed="true"
                :sort-layers="true"
            />
            <l-tile-layer
                v-for="tileProvider in tileProviders"
                :key="tileProvider.name"
                :name="tileProvider.name"
                :visible="tileProvider.visible"
                :url="tileProvider.url"
                :attribution="tileProvider.attribution"
                layer-type="base"
            />
            <l-feature-group ref="features">
                <l-rectangle 
                    v-if="rectangle.visible" 
                    :autoPan="true"
                    :autofocus="true"
                    :bounds="rectangle.bounds"
                    :draggable="true"
                ></l-rectangle>
            </l-feature-group>
        </l-map>
        </v-img>
    </v-lazy>
</template>

<script>
import { defineComponent, ref, watch } from 'vue';
import { LMap, LTileLayer, LControlLayers, LRectangle, LFeatureGroup } from "@vue-leaflet/vue-leaflet";
import { LatLng, LatLngBounds } from "leaflet";
import "leaflet/dist/leaflet.css";

export default defineComponent({
    name: "BboxEditor",
    components: {
        LMap,
        LTileLayer,
        LControlLayers,
        LRectangle,
        LFeatureGroup
    },
    props: {
        inputFeature: {},
    },
    setup(props, { emit }) {

        // Reactive variables
        const map = ref(null);
        const features = ref(null);
        const zoom = ref(1.5);
        const rectangle = ref({
            visible: false,
            center: [0, 0],
            bounds: [[0, 0], [0, 0]]
        });

        // Methods
        const loadMapObjects = () => {
            map.value.mapObject.on("draw:created", (event) => {
                console.log(event);
            });
            emit('loaded');
        };

        const loadBasemaps = () => {
            return [
                {
                name: 'OpenStreetMap',
                visible: true,
                attribution:
                    '&copy; <a target="_blank" href="http://osm.org/copyright">OpenStreetMap</a> contributors',
                url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                },
                {
                name: 'OpenTopoMap',
                visible: false,
                url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
                attribution:
                    'Map data: &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)',
                },
                {
                name: 'ESRI World Imagery',
                visible: false,
                url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
                }
            ];
        };

        const tileProviders = loadBasemaps();

        // Watchers
        watch(() => props.inputFeature, (input) => {
            if (input && input.length === 4) {
                const zoom_factor = 0.05;
                const topleft = new LatLng(input[0], input[1]);
                const bottomright = new LatLng(input[2], input[3]);
                const tmp = new LatLngBounds(topleft, bottomright);
                rectangle.value.center = tmp.getCenter();
                rectangle.value.bounds = [tmp.getNorthWest(), tmp.getSouthEast()];
                map.value?.mapObject.fitBounds([
                    [input[0] + zoom_factor, input[1] + zoom_factor],
                    [input[2] - zoom_factor, input[3] - zoom_factor]
                ]);
                rectangle.value.visible = true;
            } else {
                map.value?.mapObject.setZoom(1.5);
                rectangle.value.center = [0, 0];
                rectangle.value.bounds = [[0, 0], [0, 0]];
                rectangle.value.visible = false;
            }
        }, { deep: true });

        return {
            map,
            features,
            zoom,
            rectangle,
            tileProviders,
            loadMapObjects
        };
    }
});
</script>

<style>
@import "leaflet/dist/leaflet.css";
</style>
