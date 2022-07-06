WEBHOOK_URL=https://discord.com/api/webhooks/993867060528549928/79xOfLjqv1PHuwyP6JCZeO2ShK4pHdL9qJSCOh7v5xd5bZIwhu-g4tWVR9MpP-7oE_0k

.PHONY: build
build:
	cd /home/isucon/webapp/go; \
	go build -o isucondition main.go; \
	sudo systemctl restart isucondition.go.service;

.PHONY: alp
alp:
	sudo cat /var/log/nginx/access.log | alp ltsv -m '/api/isu/[a-z0-9-]+/graph,/api/isu/[a-z0-9-]+/icon,/api/condition/[a-z0-9-]+,/api/isu/[a-z0-9-]+,/api/condition/[a-z0-9-]+,/isu/[a-z0-9-]+/graph,/isu/[a-z0-9-]+/condition,/isu/[a-z0-9-]+' --sort avg -r > alp_log.txt
	sudo mv alp_log.txt /temp/alp_log.txt
	curl -X POST -F alp_log=@/temp/alp_log.txt ${WEBHOOK_URL}

.PHONY: slow-show
slow-show:
	sudo mysqldumpslow -s t -t 10 > mysqldumpslow_log.txt
	sudo pt-query-digest /var/log/mysql/mariadb-slow.log > pt-query-digest_log.txt
	sudo mv mysqldumpslow_log.txt /temp/mysqldumpslow_log.txt
	sudo mv pt-query-digest_log.txt /temp/pt-query-digest_log.txt
	curl -X POST -F mysqldumpslow_log=@/temp/mysqldumpslow_log.txt ${WEBHOOK_URL}
	curl -X POST -F pt-query-digest_log=@/temp/pt-query-digest_log.txt ${WEBHOOK_URL}

.PHONY: pprof
pprof:
	go tool pprof -http=0.0.0.0:8080 /home/isucon/webapp/go/isucondition http://localhost:6060/debug/pprof/profile
.PHONY: pprof-image
pprof-image:
	go tool pprof -png -output pprof.png http://localhost:6060/debug/pprof/profile
	sudo mv pprof.png /temp/pprof.png
	curl -X POST -F pprof=@/temp/pprof.png ${WEBHOOK_URL}

.PHONY: truncate
truncate:
	sudo truncate -s 0 -c /var/log/nginx/access.log

.PHONY: restart-mysql
restart-mysql:
	sudo systemctl restart mysql.service
.PHONY: restart-nginx
restart-nginx:
	sudo systemctl restart nginx

.PHONY: setting-mysql
setting-mysql:
	sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
.PHONY: setting-nginx
setting-nginx:
	sudo nano /etc/nginx/nginx.conf

.PHONY: pre-bench
pre-bench:
	make restart-mysql
	make restart-nginx
	make build
	make truncate
	make pprof-image
.PHONY: after-bench
after-bench:
	make alp
	make slow-show