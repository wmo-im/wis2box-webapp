/**
 * plugins/index.js
 *
 * Automatically included in `./src/main.js`
 */

// Plugins
import { loadFonts } from './webfontloader';
import vuetify from './vuetify';
import router from '../router';

import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css'

import VueApexCharts from 'vue3-apexcharts';

import VueTelInput from 'vue-tel-input';
import 'vue-tel-input/vue-tel-input.css';
const globalOptions = {
  mode: 'international',
  autoFormat: true,
  validCharactersOnly: true,
  dropdownOptions: {
    showSearchBox: true
  },
  inputOptions: {
    required: false,
    placeholder: 'Phone number (optional)',
    autocomplete: 'off',
  },
}

export function registerPlugins (app) {
  loadFonts()
  app
    .use(vuetify)
    .use(router)
    .use(VueApexCharts)
    .use(VueTelInput, globalOptions)

  app.component('VueDatePicker', VueDatePicker);
}
