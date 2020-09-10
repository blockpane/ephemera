<template>
    <div id="app">
        <b-navbar type="dark" variant="primary" sticky="true">
            <b-container>
                <b-col cols="2" align="left">
                    <img src="./assets/lock.svg" @click="$router.push('/')" width="36">
                </b-col>
                <b-col cols="8" align="center">
                    <h3 class="text-white">ephemera</h3>
                    <p class="text-sm-center text-white">one-time secret sharing</p>
                </b-col>
                <b-col cols="2" align="right">
                        <b-btn v-b-modal.modalHelp variant="primary"><img src="./assets/help-circle.svg" width="32"></b-btn>
                </b-col>
            </b-container>
        </b-navbar>
        <b-modal id="modalHelp" size="lg" ok-only variant="btn-outline" title="Help">
            <p class="my-4">
                This is an application for sharing a secret, the secret can only be accessed once, and then it is gone
                forever.<br/>
            </p>
            <h3>Basic Usage:</h3>
            <p class="my-4">
                Type in the secret you want to share, and click "Get Link", provide this to the recipient and they can
                retrieve it.<br/>
            </p>
            <p class="my-4">
                In the advanced settings you can control more of the behavior:<br />
            </p>
                <list>
                    <ul><img src="./assets/chevron-right.svg" width="24">How long the secret is valid, the default is 24 hours.</ul>
                    <ul><img src="./assets/chevron-right.svg" width="24">Restrict access to the secret for a specific internet address.</ul>
                    <ul><img src="./assets/chevron-right.svg" width="24">Add an additional layer of password protection that is neither stored in the database or as part of the link.</ul>
                </list>
            <h3>Is this safe?</h3>
            <p class="my-4">
            This application was designed to offer a moderate level of security, slightly better than pasting a password
            in a chat window. But,
            there is no provable way to know what is being done behind the scenes, and the only way to be entirely sure
            is to get the source from
            <a href="https://github.com/blockpane/ephemera">Github</a>, audit the code, and deploy it under your own
            control.
            </p>
            <p class="my-4">
            This application is designed to run as a serverless app in the AWS cloud, with the goal to be almost cost,
            and maintenance free.
            It uses KMS to encrypt the secrets in the database, which costs ~$1/month, specifically so that it could be
            easily deployed within
            an organization for exclusive use with little effort.
            </p>
            <h3>How does it work?</h3>
            <list>
                <ul><img src="./assets/chevron-right.svg" width="24">When clicking on "Get Link", the browser uses javascript to create an encryption key,
                and encrypts the secret using AES-128 GCM with this key. Short secrets have additional plaintext added to further obfuscate the length of the message.</ul>
                <ul><img src="./assets/chevron-right.svg" width="24">The key is included as part of the URL that is displayed in the browser, but is *not* sent to the servers, a
                    random IV, and the authentication tag are stored in the database.</ul>
                <ul><img src="./assets/chevron-right.svg" width="24">The storage is handled by an AWS Lambda function that: Uses KMS to encrypt the secret with AES-256 a second time,
                    sets a timeout value for the secret to be deleted, and stores it in DynamoDB. This means by default
                    the secret is encrypted twice, only Amazon has one key, and whoever has the link gets the second.
                </ul>
                <ul><img src="./assets/chevron-right.svg" width="24">When the recipient visits the site to retrieve the secret, the browser extracts the random ID for
                    the stored secret and sends that to the Lambda function, which performs the first layer of decryption--immediately deleting the database record,
                    and sends the result to the browser.</ul>
                <ul><img src="./assets/chevron-right.svg" width="24">The recipient's browser then decrypts the ciphertext sent back from the lambda function.
                </ul>
                <ul><img src="./assets/chevron-right.svg" width="24">If an optional passphrase was used, another key is created using a pbkdf2 algorithm,
                    and will require the recipient to supply it for a third round of AES-128 GCM decryption. This could be something simple that is
                    conveyed out of band to add a small additional layer of protection.</ul>
            </list>
            <h3>Why Bother?</h3>
            <ul><img src="./assets/chevron-right.svg" width="24">I appreciate that there are other similar services, such as <a href="https://viacry.pt/">viacry.pt</a> and have used them, but ...
            if you want to ensure exclusive access for your organization for example, these rely on running a server full-time for the storage and back-end service.
                By using server-less technology in the cloud, anyone can deploy ephemera without committing to the cost of running, and maintaining a VPS.</ul>
            <ul><img src="./assets/chevron-right.svg" width="24">Most of the existing solutions immediately display the link when visited, this creates problems with tools
                that prefetch an image of a website (like a chat program.)</ul>
            <ul><img src="./assets/chevron-right.svg" width="24">Being able to limit by IP is crucial when users are on a known network.</ul>
            <ul><img src="./assets/chevron-right.svg" width="24">I wanted to be sure the tool I was using used a stronger cipher, with random IV, and message authentication.</ul>
            <ul><img src="./assets/chevron-right.svg" width="24">The ability to have an additional layer of encryption is nice.
                Not shared via a link, and unknown to the backend ... adds a distinct and important layer of security</ul>
            <div class="footer-copyright text-sm-center py-3">© 2020 Copyright:
                <a href="https://github.com/blockpane/ephemera/">Todd Garrison</a>
            </div>
        </b-modal>
        <router-view></router-view>
    </div>
</template>

<script>
</script>

<style>
</style>
