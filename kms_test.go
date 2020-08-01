package sharedpw

import (
	"encoding/base64"
	"fmt"
	"net"
	"testing"
)

func TestGetRandomId(t *testing.T) {
	id, err := GetRandomId()
	if err != nil || len(id) != 16 {
		t.Error(fmt.Sprintf("should be able to get random id:\n%v\n", err))
	}
	fmt.Println("random id:", id)
}

// This does a lot more than just encrypt, but since everything is so tightly coupled, it makes sense.
func TestEncryptSecret(t *testing.T) {
	mySecret := `this is a test.`
	fmt.Println("plain text:       ", mySecret)
	cipherText, err := EncryptSecret(base64.StdEncoding.EncodeToString([]byte(mySecret)))
	if err != nil {
		t.Errorf("could not encrypt %v\n", err)
	}
	fmt.Println("encrypted string: ", cipherText)

	// now decrypt it and see if it matches:
	decrypted, err := DecryptSecret(cipherText)
	if err != nil {
		t.Errorf("could not decrypt: %v\n", err)
	}
	decBytes, err := base64.StdEncoding.DecodeString(decrypted)
	if err != nil {
		t.Errorf("could not deocde from base64: %v\n", err)
	}
	if string(decBytes) != mySecret {
		t.Errorf("decrypted value did not match, expected '%s' but got '%s'\n", mySecret, string(decBytes))
	}
	fmt.Println("decrypted string: ", string(decBytes))

	secret := NewSecret()
	err = secret.Save(cipherText)
	if err != nil {
		t.Errorf("could not save secret: %v\n", err)
	}

	ip := net.ParseIP("127.0.0.1")
	revealed, err := Reveal(secret.Secret, ip, true)
	if err != nil {
		t.Errorf("could not reveal secret: %v\n", err)
	}
	dRev, err := DecryptSecret(revealed)
	if err != nil {
		t.Errorf("could not decrypt secret: %v\n", err)
	}
	result, _ := base64.StdEncoding.DecodeString(dRev)
	if string(result) != mySecret {
		t.Errorf("Secret '%s' did not match '%s'", string(result), mySecret)
	}
	fmt.Println("revealed:        ", string(result))

}
