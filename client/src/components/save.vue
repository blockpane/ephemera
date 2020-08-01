<template>
    <div id="save">
    <br/>
    <div align="center">
        <b-card border-variant="dark" style="max-width: 75rem;">
            <p class="card-text">
                <b-container fluid>
                    <b-row class="my-1">
                        <b-col sm="12">
                            <b-form-textarea id="secret" size="lg" type="text" placeholder="Secret ...."
                                             v-model="secret" :state="secretState" :rows="3" maxrows="10">
                            </b-form-textarea>
                            <div align="left">
            <p size="-3">{{ secretLen }} of {{ maxLen }} characters allowed.</p>
    </div>
    </b-col>
    </b-row>
    </b-container>
    </p>
    <b-modal id="modalLink" ref="modalLink" title="Provide this URL to the recipient:" centered ok-only
             @cancel="resetAll" @hide="resetAll" @ok="resetAll" size="lg">
        <p :hidden="gotResponse"><img src="../assets/loader.svg" width="48">><br />Loading</p>
        <pre :hidden="!gotResponse">{{ response }}
</pre>
        <!-- WTF:
        <button v-clipboard:copy="response" v-clipboard:success="copyOk(true)" v-clipboard:error="copyOk(false)">
          <img src="../assets/clipboard.svg" width="32" v-b-popover.hover="'Copy to cliboard'">
          <span v-if="copied === true">
            <b-alert >Copied!</b-alert>
          </span>
          <span v-if="copied === false">
            <b-alert >Couldn't copy to clipboard, select the text and copy it manually</b-alert>
          </span>
        </button>
        -->
    </b-modal>
    <span @click="encrypt()">
      <b-button variant="primary" type="button" size="sm" :disabled="!secretState">
          <img src="../assets/link.svg" width="16">&nbsp; Get Link
      </b-button>
    </span>
    <b-button v-b-toggle.collapse1 variant="info-outline" size="sm">Show Advanced Options</b-button>
    <br/>
    <b-collapse id="collapse1" class="mt-2">
        <b-card>
            <b-container fluid>
                <b-row class="my-1">
                    <b-col sm="3" align="right"><label for="timer">Time until secret expires:</label>
                        <img src="../assets/info.svg" width="18"
                             v-b-popover.hover="'Secrets are deleted after 24 hours by default.'">
                    </b-col>
                    <b-col sm="1" class="text-info">{{ expires }} hours</b-col>
                    <b-col sm="5" align="left">
                        <b-form-input id="timer" type="range" min="1" max="72" v-model="expires"></b-form-input>
                    </b-col>
                </b-row>
                <b-row class="my-1">
                    <b-col sm="3" align="right"><label for="ipaddr">Restrict to IP Address:</label>
                        <img src="../assets/info.svg" width="18"
                             v-b-popover.hover="'Only this IP address will be able to access the secret. Limited to a single IPv4 address.'">
                    </b-col>
                    <b-col sm="1" align="right">
                        <b-form-checkbox v-align size="sm" v-model="reqIp"></b-form-checkbox>
                    </b-col>
                    <b-col sm="5" align="left">
                        <b-form-input type="text" :disabled="!reqIp" :state="checkIsIPV4(ip)" v-model="ip"
                                      placeholder="127.0.0.1"></b-form-input>
                    </b-col>
                </b-row>
                <b-row class="my-1" align-v="center">
                    <b-col sm="3" align="right">
                        <label>
                            Secret phrase needed to decrypt:
                        </label>
                        <img src="../assets/info.svg" width="18"
                             v-b-popover.hover="'An additional phrase to decrypt the secret, this will encrypt the secret a second time before sending. (32 characters max)'">
                    </b-col>
                    <b-col sm="1" align="right">
                        <b-form-checkbox v-align size="sm" v-model="reqPass"></b-form-checkbox>
                    </b-col>
                    <b-col sm="5" align="left" align-v="center">
                        <b-form-input type="text" v-model="pass" :disabled="!reqPass" :state="shortPass" placeholder="Passphrase"></b-form-input>
                    </b-col>
                </b-row>
                <b-row class="my-1" align-v="center">
                    <b-col sm="3" align="right">
                        <label>
                            Hint (optional):
                        </label>
                        <img src="../assets/info.svg" width="18"
                             v-b-popover.hover="'A hint for the secret phrase, NOTE: this is stored unencrypted. (64 characters max)'">
                    </b-col>
                    <b-col sm="1" align="right">
                    </b-col>
                    <b-col sm="5" align="left" align-v="center">
                        <b-form-input type="text" v-model="hint" :disabled="!reqPass" :state="shortHint" placeholder="Who sent this to you?"></b-form-input>
                    </b-col>
                </b-row>
            </b-container>
        </b-card>
    </b-collapse>
    </b-card>
    </div>
    <footer class="page-footer font-small fixed-bottom">

    </footer>
    </div>
</template>

<script>
    import axios from 'axios';
    const enc = require('../crypto.js').encrypt;
    const encPass = require('../crypto.js').encryptPass;
    export default {
        name: 'app',
        data() {
            return {
                secretLink: 'Sorry: unable to generate a link.',
                secret: '',
                cipher: {},
                expires: 24,
                reqPass: false,
                hint: '',
                pass: '',
                reqIp: false,
                ip: '',
                maxLen: 512,
                hours: 24,
                message: {},
                status: {},
                gotResponse: false,
                copied: null,
                url: process.env.VUE_APP_API_URL,
            }
        },
        computed: {
            secretState() {
                if (this.secret.length === 0) return null;
                return (this.secret.length <= this.maxLen && this.secret.length > 0)
                    && (this.checkIsIPV4(this.ip) || this.checkIsIPV4(this.ip) === null && !this.reqIp)
                    && (!this.reqPass || this.reqPass && this.pass.length > 0)
            },
            shortPass() {
                if (this.pass.length === 0) return null;
                return this.pass.length <= 32;
            },
            shortHint() {
                if (this.hint.length === 0) return null;
                return this.hint.length <= 64;
            },
            secretLen() {
                return this.secret.length
            },
            response() {
                return window.location + 'view.' + this.cipher.key + '_' + this.status.id;
            }
        },
        methods: {
            copyOk(b) {
                this.copied = b
            },
            checkIsIPV4(ip) {
                if (ip.length === 0) return null;
                ip = ip.toString().trim();
                return /^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$/.test(ip);
            },
            resetAll() {
                this.secretLink = 'Sorry: unable to generate a link.';
                this.secret = '';
                this.cipher = {};
                this.message = {};
                this.expires = 24;
                this.reqPass = false;
                this.pass = '';
                this.reqIp = false;
                this.hint = '';
                this.ip = '';
                this.gotResponse = false;
                this.status = {};
            },
            encrypt() {
                let cipher = this.cipher;
                let passCipher = {
                    pw_iv: '',
                    pw_tag: '',
                    ciphertext: '',
                };
                cipher = enc(this.secret);
                if (this.reqPass && this.pass.length > 0) {
                    passCipher = encPass(cipher.ciphertext, this.pass);
                    cipher.ciphertext = passCipher.ciphertext;
                }
                this.cipher = cipher;
                if (!this.reqIp) this.ip = '';
                this.message = {
                    'hours': parseInt(this.expires),
                    'message': cipher.ciphertext,
                    'ip': this.ip,
                    'has_pass': this.reqPass,
                    'hint': this.hint,
                    'tag': this.cipher.tag,
                    'iv': this.cipher.iv,
                    'pw_tag': passCipher.pw_tag,
                    'pw_iv': passCipher.pw_iv
                };
                this.save();
                this.secretLink = window.location + 'view#' + this.cipher.key + '_' + this.status.id;
                this.$refs.modalLink.show();
            },
            save () {
                axios.post(this.url + '/save', this.message)
                    .then(res => {
                    this.gotResponse = true;
                    this.status = res.data;
                })
            }
        }
    }
</script>

<style>
</style>
