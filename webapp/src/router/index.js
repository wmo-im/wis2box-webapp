// Composables
import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/Home.vue'),
      },
      {
        path: 'csv2bufr_form',
        name: 'CsvToBUFRForm',
        component: () => import('@/views/CsvToBUFRForm.vue'),
        meta: {title: 'wis2box - CSV to BUFR Form'}
      },
      {
        path: 'synop_form',
        name: 'SynopForm',
        component: () => import('@/views/SynopForm.vue'),
        meta: {title: 'wis2box - Synop Form'}
      },
      {
        path: 'monitoring', // New route for the notifications page
        name: 'Monitoring',
        component: () => import('@/views/MonitoringPage.vue'),
        meta: {title: 'wis2box - Monitoring'}
      },
      {
        path: '/station',
        name: 'stationTable',
        component: () => import('@/views/StationTable.vue'),
        meta: {title: 'View stations'}
      },
      {
        path: '/station/:id(.*)',
        children: [
          {
            path: '',
            name: 'stationEditor',
            component: () => import('@/views/StationEditor.vue'),
            meta: {title: 'Create / register new station'}
          }
        ]
      }
    ],
  },
]

// Create the router
const router = createRouter({
  history: createWebHistory('/wis2box-webapp/'),
  routes,
})

// Assign the title of the browser tab for each page
router.beforeEach((to, from, next) => {
  const nearestWithTitle = to.matched.slice().reverse().find(r => r.meta && r.meta.title);
  if(nearestWithTitle) document.title = nearestWithTitle.meta.title;
  next();
});

export default router
