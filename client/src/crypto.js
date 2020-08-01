

export function encrypt(plaintext) {
    if (plaintext.length < 128) {
        // add some length to the message
        plaintext = plaintext.padEnd(128, ' ');
    }
    const forge = require('node-forge');
    const key = forge.random.getBytesSync(16);
    const iv = forge.util.bytesToHex(forge.random.getBytesSync(12));
    let cipher = forge.cipher.createCipher("AES-GCM", key);
    cipher.start({ iv: iv });
    cipher.update(forge.util.createBuffer(plaintext, 'utf8'));
    cipher.finish();
    return {
        'ciphertext': cipher.output.toHex(),
        'key': Base64EncodeUrl(forge.util.encode64(key)),
        'tag': cipher.mode.tag.toHex(),
        'iv': iv,
    }
}

export function encryptPass(plaintext, pass) {
    const forge = require('node-forge');
    const iv = forge.util.bytesToHex(forge.random.getBytesSync(12));
    const key = forge.pkcs5.pbkdf2(pass, [], 100, 16);
    let cipher = forge.cipher.createCipher("AES-GCM", key);
    cipher.start({ iv: iv });
    cipher.update(forge.util.createBuffer(plaintext, 'utf8'));
    cipher.finish();
    return {
        'ciphertext': cipher.output.toHex(),
        'pw_tag': cipher.mode.tag.toHex(),
        'pw_iv': iv,
    }
}

export function decrypt(ciphertext, key, tag, iv) {
    const forge = require('node-forge');
    let cipher = forge.cipher.createDecipher("AES-GCM",forge.util.decode64(Base64DecodeUrl(key)));
    cipher.start({iv:iv, tag: forge.util.hexToBytes(tag)});
    cipher.update(forge.util.createBuffer(forge.util.hexToBytes(ciphertext)));
    cipher.finish();
    return cipher.output.toString('utf8').trim();
}

export function decryptPass(ciphertext, key, tag, iv, pw_tag, pw_iv, pass) {
    const forge = require('node-forge');
    const passKey = forge.pkcs5.pbkdf2(pass, [], 100, 16);
    let cipher = forge.cipher.createDecipher("AES-GCM", passKey);
    cipher.start({iv: pw_iv, tag: forge.util.hexToBytes(pw_tag) });
    cipher.update(forge.util.createBuffer(forge.util.hexToBytes(ciphertext)));
    cipher.finish();
    //return decrypt(cipher.output.toString('utf8'), key, tag, iv)
    return decrypt(cipher.output.toString('utf8'), key, tag, iv)
}

function Base64EncodeUrl(str){
    return str.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function Base64DecodeUrl(str){
    str = (str + '===').slice(0, str.length + (str.length % 4));
    return str.replace(/-/g, '+').replace(/_/g, '/');
}
