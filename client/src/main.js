import Vue from 'vue'
import BootstrapVue from "bootstrap-vue"
import App from './App.vue'
import router from './router'
import VueClipboard from 'vue-clipboard2'
import './assets/bootstrap.css'

Vue.use(BootstrapVue);
Vue.use(VueClipboard);

new Vue({
  el: '#app',
  router,
  VueClipboard,
  render: h => h(App)
});

