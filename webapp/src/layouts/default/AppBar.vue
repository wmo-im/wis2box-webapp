<template>
  <v-app-bar image="@/assets/banner.png">
    <img src="@/assets/logo-large.png" alt="Logo" class="wmo-logo" />

    <template v-slot:image>
      <!-- Gradient from white to transparent, making the logo and text clearer on tablets/mobiles -->
      <v-img gradient="to left, transparent, #FFFFFF"></v-img>
    </template>

    <v-app-bar-title class="wis2-title"> WIS2 in a box
    </v-app-bar-title>

    <template v-slot:append>
      <v-app-bar-nav-icon color="#F6FFF8" @click="drawer = !drawer"></v-app-bar-nav-icon>
    </template>

  </v-app-bar>

  <v-navigation-drawer v-model="drawer" location="right" :width="200" :rail="rail" permanent>

    <v-list-item :class="rail ? 'left-chevron' : 'right-chevron'">
      <template v-slot:append>
        <v-btn v-if="rail === true" variant="text" icon="mdi-chevron-left" @click.stop="rail = !rail"></v-btn>
        <v-btn v-if="rail === false" variant="text" icon="mdi-chevron-right" @click.stop="rail = !rail"></v-btn>
      </template>
    </v-list-item>

    <v-list v-model:opened="open" dense nav>
      <v-list-item prepend-icon="mdi-home" title="Home" exact to="/" />

      <v-list-group value="Forms">
        <template v-slot:activator="{ props }">
          <v-list-item v-bind="props" prepend-icon="mdi-notebook-edit" title="Forms" 
          v-if="rail === true" @click.stop="rail = !rail" />
          <v-list-item v-bind="props" prepend-icon="mdi-notebook-edit" title="Forms" 
          v-else />
        </template>

        <v-list-item v-if="rail === false" title="SYNOP" to="synop_form" />
        <v-list-item v-if="rail === false" title="CSV" to="csv2bufr_form" />
      </v-list-group>

      <v-list-item prepend-icon="mdi-satellite-uplink" title="Stations" to="station" />
      <v-list-item prepend-icon="mdi-chart-box" title="Monitoring" to="monitoring" />
    </v-list>
  </v-navigation-drawer>
</template>

<script setup>

import { ref } from 'vue';

const drawer = ref(false)
const rail = ref(true)
const open = ref(["Forms"])

</script>

<style scoped>
.bar-sizing {
  padding: 5px;
}

.wmo-logo {
  height: 60px;
}

.wis2-title {
  color: #003DA5;
  font-size: 2rem;
  font-weight: 300;
}

.left-chevron {
   justify-content: center;
}

.right-chevron {
   justify-content: flex-start;
   padding-left: 4px;
}
</style>
