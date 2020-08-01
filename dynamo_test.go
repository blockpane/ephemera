package sharedpw

import (
	"fmt"
	"testing"
)

func TestNewSecret(t *testing.T) {
	s := NewSecret()
	if s.Err != nil {
		t.Error(fmt.Sprintf("could not create new secret:\n%v\n", s.Err))
	}
	j, err := s.ToJson()
	if err != nil || len(j) < 1 {
		t.Error(fmt.Sprintf("error marshalling to json got:\n%s\n%v\n", j, err))
	}
	fmt.Println(j)
}
