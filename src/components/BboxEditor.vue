<template>
    <v-lazy>
        <v-img>
            <l-map ref="map" :zoom="zoom" :center="rectangle.center" @ready="loadMapObjects"
                style="height: 300px; width: 100%">
                <l-control-layers position="bottomleft" :collapsed="true" :sort-layers="true" />
                <l-tile-layer v-for="tileProvider in tileProviders" :key="tileProvider.name" :name="tileProvider.name"
                    :visible="tileProvider.visible" :url="tileProvider.url" :attribution="tileProvider.attribution"
                    layer-type="base" />
                <l-feature-group ref="features">
                    <l-rectangle v-if="rectangle.visible" :autoPan="true" :autofocus="true" :bounds="rectangle.bounds"
                        :draggable="true"></l-rectangle>
                </l-feature-group>
            </l-map>
        </v-img>
    </v-lazy>
</template>

<script>
import { defineComponent, ref, watch } from 'vue';
import { LMap, LTileLayer, LControlLayers, LRectangle, LFeatureGroup } from "@vue-leaflet/vue-leaflet";
import * as L from "leaflet";
import "leaflet/dist/leaflet.css";
// Allow the user to draw the bounding box
import 'leaflet-draw';
import 'leaflet-draw/dist/leaflet.draw.css';

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
            visible: true,
            center: [0, 0],
            bounds: [[0, 0], [0, 0]]
        });

        // Methods

        // Add the drawing controls
        const loadMapObjects = () => {
            if (map.value?.mapObject) {
                let drawControl = new L.Control.Draw({
                    // Only allow the user to draw a rectangle (bounding box
                    draw: {
                        polyline: false,
                        polygon: false,
                        circle: false,
                        marker: false,
                        circlemarker: false,
                        rectangle: true
                    }
                });
                map.value.mapObject.addControl(drawControl);

                // Save the corresponding bounding box coordinates
                map.value.mapObject.on('draw:created', function (e) {
                    let type = e.layerType,
                        layer = e.layer;

                    if (type === 'rectangle') {
                        let bounds = layer.getBounds();
                        let northLatitude = bounds.getNorth();
                        let southLatitude = bounds.getSouth();
                        let eastLongitude = bounds.getEast();
                        let westLongitude = bounds.getWest();

                        // Emit an event with the bounding box coordinates to be accessed by form
                        emit('update-geometry', { northLatitude, southLatitude, eastLongitude, westLongitude });

                        // Add the drawn layer to the map
                        map.value.mapObject.addLayer(layer);
                    }
                });
            }
            emit('loaded');
        };

        // Load the maps that can be chosen by the user
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
                const topleft = new L.LatLng(input[0], input[1]);
                const bottomright = new L.LatLng(input[2], input[3]);
                const tmp = new L.LatLngBounds(topleft, bottomright);
                rectangle.value.center = tmp.getCenter();
                rectangle.value.bounds = [tmp.getNorthWest(), tmp.getSouthEast()];
                map.value?.mapObject.fitBounds([
                    [input[0] + zoom_factor, input[1] + zoom_factor],
                    [input[2] - zoom_factor, input[3] - zoom_factor]
                ]);
                rectangle.value.visible = true;
            } else {
                map.value?.mapObject.setZoom(1.5);
            }
        });

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
