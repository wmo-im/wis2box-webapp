<template>
  <v-app-bar scroll-behavior="hide" scroll-threshold="10" class="bar-sizing" image="@/assets/banner.png">

    <template v-slot:image>
      <!-- Gradient from white to transparent, making the logo and text clearer on tablets/mobiles -->
      <v-img gradient="to left, transparent, #FFFFFF"></v-img>
    </template>


    <img src="@/assets/logo-large.png" alt="Logo" class="wmo-logo" />


    <v-app-bar-title class="wis2-title"> WIS2 in a box
    </v-app-bar-title>

    <!-- Hamburger menu visible only on mobile and tablet -->
    <template v-slot:append>
      <v-app-bar-nav-icon class="hidden-md-and-up" color="#F6FFF8" @click="drawer = !drawer"></v-app-bar-nav-icon>
    </template>

    <!-- App bar buttons only visible on desktop -->
    <div class="hidden-sm-and-down">
      <v-btn color="#F6FFF8" exact to="/">Home</v-btn>
      <v-btn color="#F6FFF8" text to="synop_form">Synop form</v-btn>
      <v-btn color="#F6FFF8" text to="monitoring">Monitoring</v-btn>
    </div>
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
