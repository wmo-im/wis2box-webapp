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
        path: 'synop_form',
        name: 'SynopForm',
        component: () => import('@/views/SynopForm.vue'),
      },
      {
        path: 'wis2_notifications', // New route for the notifications page
        name: 'wis2_notifications',
        component: () => import('@/views/WIS2Notifications.vue'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory('/wis2box-webapp/'),
  routes,
})

export default router
