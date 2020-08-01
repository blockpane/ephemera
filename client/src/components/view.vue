<template>
    <div id="view">
        <br/>
        <div align="center">
            <b-card border-variant="dark" style="max-width: 85rem;">
                <p class="card-text">
                    <span v-if="exists === null">
                        <b-alert show variant="primary">Loading ...</b-alert>
                        <img src="../assets/loader.svg" width="48" />
                    </span>
                    <span v-else-if="exists && !done">
                        <b-alert show variant="light"><h4>Reveal Secret?</h4></b-alert>
                        <h5>Someone has shared a secret with you!</h5>
                        <p>Once the secret has been viewed, it will be irretrievable.</p>
                        <span @click="revealSecret"><b-button variant="primary" type="button">
                            <img src="../assets/eye.svg" width="16">&nbsp;
                            Reveal
                        </b-button></span>
                    </span>
                    <span v-else-if="exists && done">
                        <b-alert show variant="light"><h4>Decrypted Secret</h4></b-alert>
                        <span v-if="requestPass">
                              This secret is protected by a password:
                              <b-row class="my-1">
                                  <b-col sm="1"><label for="input-pass"><em>Hint: </em></label></b-col>
                                  <b-col sm="3"><h5>{{ passParams.passHint }}</h5></b-col>
                                    <b-col sm="4">
                                        <b-form-input id="input-pass" v-model="pass" type="text" placeholder="Enter your passphrase"></b-form-input>
                                    </b-col>
                                    <b-col sm="4"></b-col>
                              </b-row>
                            <br />
                        </span>
                        <b-card border-variant="dark" style="max-width: 95rem;">
                            <div align="left">
                                <pre>{{ Decipher }}
</pre>
                                <br /><br />
                            </div>
                        </b-card><br />
                        <span @click="$router.push('/')"><b-button variant="primary" type="button">Share a new secret?</b-button></span>
                    </span>
                    <span v-else>
                    <b-alert show variant="warning">
                        <h4><img src="../assets/alert-triangle.svg" width="32"> &nbsp;That secret doesn't exist!</h4>
                </b-alert>
                        <p>The link is not valid, the secret has already been viewed, or it has been
                        restricted to a different IP address.</p>
                <span @click="$router.push('/')"><b-button variant="warning" type="button">Share a secret instead?</b-button></span>
                </span>
                </p>
            </b-card>
            <b-popover id="showSecret" v-b-popover.hover="'I am popover content!'" title="Popover Title">
            </b-popover>
            <b-modal v-model="showSecret">

            </b-modal>
        </div>
    </div>
</template>

<script>
    import axios from 'axios';

    const decrypt = require('../crypto.js').decrypt;
    const decryptPass = require('../crypto.js').decryptPass;
    export default {
        data () {
            return {
                valid: false,
                id: '',
                key: '',
                message: 'Loading . . .',
                response: {},
                exists: null,
                done: false,
                url: process.env.VUE_APP_API_URL,
                parsed: this.parse(),
                showSecret: false,
                decrypted: '',
                requestPass: false,
                pass: '',
                passParams: {
                    iv: '',
                    tag: '',
                    ciphertext: '',
                    passHint: '',
                    pw_iv: '',
                    pw_tag: '',
                }
            }
        },
        computed: {
            /**
             * @return {string}
             */
            // FIXME:
            /* eslint-disable */
            Decipher() {
                if (this.decrypted.length > 0) return this.decrypted;
                const p= this.passParams;
                if (this.requestPass && this.pass.length > 0) {
                    const pt = decryptPass(p.ciphertext, this.parsed.key, p.tag, p.iv, p.pw_tag, p.pw_iv, this.pass);
                    if (pt.length > 0 ) this.requestPass = false;
                    return pt;
                }
            }
            /* eslint-enable */
        },
        methods: {
            setExist (really) {
                this.exists = really
            },
            getUrl() {
                return this.url
            },
            parse() {
                const h = this.$route.path;
                let message, key, id = '';
                let ok = false;
                let exists = this.setExist;
                let response = {};
                if (h.length === 45){
                    key = h.slice(6,28);
                    id = h.slice(29);
                    ok = true;
                    axios.post(process.env.VUE_APP_API_URL+'/view', {id: id, retrieve: false} )
                        .then(res => {
                            response = res.data;
                            exists(response.exists);
                        })
                } else {
                    this.$router.push('/')
                }
                return {
                    id: id,
                    key: key,
                    ok: ok,
                    message: message,
                    exists: response.exists,
                }
            },
            setDone() {
                this.done = true
            },
            setSecret(s) {
                this.decrypted = s
            },
            setParams(iv, tag, ct, hint, pw_iv, pw_tag) {
                if (hint.length === 0) hint = "no hint was provided";
                this.passParams = {
                    iv: iv,
                    tag: tag,
                    pw_iv: pw_iv,
                    pw_tag: pw_tag,
                    ciphertext: ct,
                    passHint: hint,
                };
                this.requestPass = true;
            },
            revealSecret () {
                const h = this.$route.path;
                let secret, key, id = '';
                if (h.length === 45){
                    key = h.slice(6,28);
                    id = h.slice(29);
                    axios.post(this.url + '/view', {
                        id: id,
                        retrieve: true
                    })
                        .then(res => {
                            if (res.data.has_pass) {
                                this.setDone();
                                this.setParams(res.data.iv, res.data.tag, res.data.secret, res.data.hint, res.data.pw_iv, res.data.pw_tag);
                            } else if (res.data.exists) {
                                secret = decrypt(res.data.secret, key, res.data.tag, res.data.iv);
                                this.setDone();
                                this.setSecret(secret);
                            }
                        })
                }
            }
        }
    }
</script>

<style>
</style>
