.PHONY: build
build:
	cd /home/isucon/webapp/go; \
	go build -o isucondition main.go; \
	sudo systemctl restart isucondition.go.service;