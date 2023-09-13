<template>
  <v-app-bar image="@/assets/banner.png">
    <img src="@/assets/logo-large.png" alt="Logo" class="wmo-logo" />


    <v-app-bar-title class="wis2-title"> WIS2 in a box
    </v-app-bar-title>
    <v-btn class="bar-button" exact to="/">Home</v-btn>
    <v-btn class="bar-button" text to="/synop_form">Synop form</v-btn>
    <v-btn class="bar-button" text to="/csv2bufr_form">CSV to BUFR form</v-btn>
    <v-btn class="bar-button" text to="/station">Stations</v-btn>
    <v-btn class="bar-button" text to="/monitoring">Monitoring</v-btn>
  </v-app-bar>

  <!-- Navigation drawer opens when hamburger menu clicked -->
  <v-navigation-drawer v-if="isMobile" v-model="drawer" location="right">
    <v-list dense nav>
      <v-list-item exact to="/">
        <v-list-item-title>HOME</v-list-item-title>
      </v-list-item>
      <v-list-item to="synop_form">
        <v-list-item-title>SYNOP FORM</v-list-item-title>
      </v-list-item>
      <v-list-item to="csv2bufr_form">
        <v-list-item-title>CSV FORM</v-list-item-title>
      </v-list-item>
      <v-list-item to="monitoring">
        <v-list-item-title>MONITORING</v-list-item-title>
      </v-list-item>
    </v-list>
  </v-navigation-drawer>
</template>

<script setup>

import { ref } from 'vue';

const drawer = ref(false)

// Initial state of boolean to determine if the page is viewed on mobile
const isMobile = ref(window.innerWidth <= 960);

// Event listener to update the boolean when the window size changes
window.addEventListener('resize', () => {
  isMobile.value = window.innerWidth <= 960;
});


</script>

<style scoped>
.bar-sizing {
  padding: 5px;
}

.wmo-logo {
  height: 70px;
}

.wis2-title {
  color: #003DA5;
  font-size: 2rem;
  font-weight: 300;
}
</style>
