all: build

build:
	docker build -t jupyter .

push:
	docker tag jupyter:latest luizberti/jupyter:latest
	docker push luizberti/jupyter:latest

