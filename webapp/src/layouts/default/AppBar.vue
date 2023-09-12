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
</template>

<script setup>
  //
</script>

<style scoped>
.bar-sizing {
  padding-top: 10px;
  padding-bottom: 10px;
}

.wmo-logo {
  height: 70px;
  width: auto;
  margin-left: 22px;
}

.wis2-title {
  color: #003DA5;
  font-size: 2rem;
  font-weight: 300;
}

.bar-button {
  color: #F6FFF8;
}
</style>
