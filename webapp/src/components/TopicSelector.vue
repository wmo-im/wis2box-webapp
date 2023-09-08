<template>
  <v-card>
    <v-card-item>
      <v-select label="Channel" v-model="hierarchy" :items="hierarchyList" v-if="hierarchyList.length"
        hint="Topic hierarchy for ingestion of data" persistent-hint></v-select>
    </v-card-item>
  </v-card>
</template>
