import { pageTitle } from 'ember-page-title';
import AppMain from '../components/app-main';

<template>
  {{pageTitle "Jacobs Squares"}}
  
  <AppMain 
    @initialRules={{@model.rules}}
    @initialPattern={{@model.initial}}
  />

  {{outlet}}
</template>
