<template>
  <v-card style="width: 100%; height: 100%; min-height: 400px" :id="id" ></v-card>
</template>

<script>
import { defineComponent, ref, computed, onMounted, watch } from 'vue';
import { VCard, VCardTitle, VCardText } from 'vuetify/lib/components/index.mjs';
import "leaflet/dist/leaflet.css";
import L from 'leaflet'
// geojson validator
import * as gjv from 'geojson-validation';

export default defineComponent({
  name: "LocatorMap",
  props: {
    center: {
      type: Object,
      default: () => ({ lat: -6.155595235231087, lng: 106.84202325990253})
    },
    zoom: {
      type: Number,
      default: 10
    },
    id: {
      type: String,
      default: "map"
    },
    longitude: {
      type: Number,
      default: 0
    },
    latitude: {
      type: Number,
      default: 0
    }
  },
  data(){
    return {
    }
  },
  components: {
    VCard,
    VCardTitle,
    VCardText,
  },
  setup( props, {emit} ) {
    const mapContainer = ref(null);
    const map = ref(null);
    const markerLayer = ref(null);

    mapContainer.value = props.id;

    const geom = computed( () => ({
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [props.longitude, props.latitude]
      },
      properties: {}
      }));

    onMounted( () =>{
      map.value = L.map(props.id, {zoomAnimation:false, fadeAnimation:true, markerZoomAnimation:true}).setView( props.center, props.zoom );
      map.value.attributionControl.setPrefix('<a href="https://leafletjs.com/">Leaflet</a>')
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {attribution: '&copy; OpenStreetMap contributors'}).addTo(map.value);
      // check whether we have a location to show
      if( geom.value.geometry ){
        updateMarker();
      };
      emit('mapLoaded', map.value);
    });

    const updateMarker = async () => {
      if( markerLayer.value ){
        markerLayer.value.remove();
      }
      // now check whether the new marker is valid and plot
      if( ! (isNaN(geom.value.geometry.coordinates[0]) || isNaN(geom.value.geometry.coordinates[1]))  ){
        if( gjv.isFeature(geom.value) ){
          markerLayer.value = L.geoJSON(geom.value).addTo(map.value);
          map.value.fitBounds(markerLayer.value.getBounds());
          map.value.setZoom(12);
        }
      }
    };

    watch( geom, () => {
      updateMarker();
    })


    return {mapContainer};
  }
})
</script>
