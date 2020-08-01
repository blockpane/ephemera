import Vue from 'vue'
import Router from 'vue-router'
import save from '../components/save.vue'
import view from '../components/view.vue'

Vue.use(Router);

export default new Router({
    routes: [
        {
            path: '/',
            name: 'save',
            component: save
        },
        {
            path: '/view*',
            name: 'view',
            component: view
        }
    ]
})
