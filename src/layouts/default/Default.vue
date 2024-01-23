<template>
  <v-app>
    <default-bar />
    <!-- Add space after AppBar -->
    <div style="margin-top: 30px;"/>
    <default-view />
    <default-footer />
  </v-app>
</template>

<script setup>
  import DefaultBar from './AppBar.vue'
  import DefaultView from './View.vue'
  import DefaultFooter from './Footer.vue'
</script>

<style>
/* Alter cell size of VueDatePicker to match that of Vuetify fields */
.dp__input_readonly.dp__input.dp__input_icon_pad.dp__input_reg {
  height: 56px;
  outline: 1px solid #BDBDBD;
}

/* Alter cell size of vue-tel-input to match that of Vuetify fields */
.vue-tel-input input {
  height: 55px;
}

/* When vue-tel-input cell is disabled, match colour palette of disabled Vuetify cells */
.vue-tel-input.disabled {
  background-color: #f0f0f0;
  color: #b0b0b0;
}

</style>
