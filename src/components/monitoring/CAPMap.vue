<template>
    <div class="column is-two-fifths-widescreen is-full-touch">
        <div class="cap-map-wrapper">
            <div id="map" class="map">
                <!-- Map here -->
            </div>
            <div class="map-legend">
                <div>
                    Alert Severity:
                </div>
                <div class="legend-items">
                    <div class="legend-item">
                        <div class="legend-color" style="background-color: rgb(215, 47, 42);"></div>
                        <div class="legend-label">
                            Extreme
                        </div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color" style="background-color: rgb(254, 153, 0);"></div>
                        <div class="legend-label">
                            Severe
                        </div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color" style="background-color: rgb(255, 255, 0);"></div>
                        <div class="legend-label">
                            Moderate
                        </div>
                    </div>
                    <div class="legend-item">
                        <div class="legend-color" style="background-color: rgb(3, 255, 255);"></div>
                        <div class="legend-label">
                            Minor
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { defineComponent, onMounted } from 'vue';
import maplibregl from 'maplibre-gl';
import * as turf from '@turf/turf';

export default defineComponent({
    name: 'CAPMap',
    setup() {
        onMounted(() => {
            loadLayer();
        });

        // default base style
        const defaultStyle = {
            'version': 8,
            'sources': {
                'carto-dark': {
                    'type': 'raster',
                    'tiles': [
                        "https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png",
                        "https://b.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png",
                        "https://c.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png",
                        "https://d.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png"
                    ]
                },
                'carto-light': {
                    'type': 'raster',
                    'tiles': [
                        "https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png",
                        "https://b.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png",
                        "https://c.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png",
                        "https://d.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png"
                    ]
                },
                'wikimedia': {
                    'type': 'raster',
                    'tiles': [
                        "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png"
                    ]
                }
            },
            'layers': [{
                'id': 'carto-light-layer',
                'source': 'carto-light',
                'type': 'raster',
                'minzoom': 0,
                'maxzoom': 22
            }]
        }

        const capData = {
            'type': 'FeatureCollection',
            'features': []
        };

        let layerAddedToMap = false;

        // initialize map
        const map = new maplibregl.Map({
            container: "map",
            style: defaultStyle,
            center: [0, 0],
            zoom: 1,
        });

        // add zoom control
        map.addControl(
            new maplibregl.NavigationControl({
                showCompass: false,
            })
        );

        map.on("load", () => {
            // add cap source
            map.addSource('cap', {
                'type': 'geojson',
                'data': capData
            });

            // add cap layer
            map.addLayer({
                'id': 'cap-layer',
                'type': 'fill',
                'source': 'cap',
                'paint': {
                    'fill-color': [
                        'match',
                        ['get', 'severity'],
                        'Extreme', '#d72f2a',
                        'Severe', '#f89904',
                        'Moderate', '#e4e616',
                        'Minor', '#53ffff',
                        '#3366ff'
                    ],
                    'fill-opacity': 0.7,
                    'fill-outline-color': '#000000'
                }
            });
            layerAddedToMap = true;
        });

        // create cap layer
        const addAreaPolygon = (capPolygonString, severity, featureId) => {
            const parts = capPolygonString.split(" ");
            const coordinates = parts.map((part) => {
                const [lat, lng] = part.split(",");
                return [parseFloat(lng), parseFloat(lat)];
            });

            const feature = {
                'type': 'Feature',
                'properties': {
                    'id': featureId,
                    'severity': severity
                },
                'geometry': {
                    'type': 'Polygon',
                    'coordinates': [coordinates]
                }
            };

            capData.features.push(feature);
        }

        const addAreaCircle = (capCircleString, severity, featureId) => {
            const parts = capCircleString.split(" ");
            const [lat, lng] = parts[0].split(",");
            const center = [parseFloat(lng), parseFloat(lat)];
            const radius = parseFloat(parts[1]);

            const options = {
                units: 'kilometers',
                properties: { "severity": severity, "id": featureId }
            };
            const circle = turf.circle(center, radius, options);
            capData.features.push(circle);
        };

        let timerId
        const loadLayer = () => {
            if (layerAddedToMap) {
                console.log("Map Loaded...")
                console.log("Adding CAP data to map...")
                map.getSource('cap').setData(capData);

                const bounds = turf.bbox(capData);
                map.fitBounds(bounds, {
                    padding: 100
                });

                if (timerId) {
                    clearTimeout(timerId);
                }
            } else {
                console.log("Waiting for map to load....")
                timerId = setTimeout(loadLayer, 1000);
            }
        }

        return {
            map, loadLayer
        };
    }
});

</script>
