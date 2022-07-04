.PHONY: build
build:
	cd /home/isucon/webapp/go; \
	go build -o isucondition main.go; \
	sudo systemctl restart isucondition.go.service;

.PHONY: alp
alp:
	sudo cat /var/log/nginx/access.log | alp ltsv -m '/api/isu/[a-z0-9-]+/graph,/api/isu/[a-z0-9-]+/icon,/api/condition/[a-z0-9-]+,/api/isu/[a-z0-9-]+,/api/condition/[a-z0-9-]+,/isu/[a-z0-9-]+/graph,/isu/[a-z0-9-]+/condition,/isu/[a-z0-9-]+' --sort avg -r

.PHONY: slow-show
slow-show:
	sudo mysqldumpslow -s t -t 10

.PHONY: pprof
pprof:
	go tool pprof -http=0.0.0.0:8080 /home/isucon/webapp/go/isucondition http://localhost:6060/debug/pprof/profile

.PHONY: truncate
truncate:
	sudo truncate -s 0 -c /var/log/nginx/access.log

.PHONY: restart-mysql
restart-mysql:
	sudo systemctl restart mysql.service

.PHONY: setting-mysql
setting-mysql:
	sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

.PHONY: setting-nginx
setting-nginx:
	sudo nano /etc/nginx/nginx.conf