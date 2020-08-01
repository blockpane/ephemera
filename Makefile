LDFLAGS = -s -w
REGION = us-east-1
# NAME = ephemera
NAME = sharedpw

all:
	make save view

save:
	GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o build/main lambda/save/save.go
	cd build && zip save.zip main && rm main
	aws lambda update-function-code --function-name ${NAME}-rw --zip-file fileb://./build/save.zip --region ${REGION}
	rm build/save.zip

view:
	GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o build/main lambda/view/view.go
	cd build && zip view.zip main && rm main
	aws lambda update-function-code --function-name ${NAME}-ro --zip-file fileb://./build/view.zip --region ${REGION}

build: *.go
	rm -f ./build/save* ./build/view*
	GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o build/save lambda/save/save.go
	cd build && zip save.zip save
	GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o build/view lambda/view/view.go
	cd build && zip view.zip view
