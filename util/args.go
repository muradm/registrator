package args

import (
	"strings"
	"errors"
)

// credits: https://lawlessguy.wordpress.com/2013/07/23/filling-a-slice-using-command-line-flags-in-go-golang/
type StringArray []string

func (s *StringArray) String() string {
	return strings.Join(*s, ",")
}

func (s *StringArray) addIfNotExists(v string) {
	for _, _v := range *s {
		if _v == v {
			return
		}
	}
	*s = append(*s, v)
}

func (s *StringArray) Set(value string) error {
	if strings.Contains(value, " ") {
		return errors.New("invalid tags value argument")
	}
	if strings.Contains(value, ",") {
		for _, val := range strings.Split(value, ",") {
			s.addIfNotExists(val)
		}
	} else {
		s.addIfNotExists(value)
	}
	return nil
}