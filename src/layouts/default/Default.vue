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

/* Alter colour of disabled VueDatePicker cell to match that of Vuetify fields */
.dp__disabled.dp__input_readonly.dp__input.dp__input_icon_pad.dp__input_reg {
  color: #BDBDBD;
  background-color: #FFFFFF;
  outline: 1px
}

/* Alter cell size of vue-tel-input to match that of Vuetify fields */
.vue-tel-input input {
  height: 55px;
}

/* Alter colour of disabled vue-tel-input cell to match that of Vuetify fields */
.vti__input:disabled {
    color: #BDBDBD;
}

</style>
