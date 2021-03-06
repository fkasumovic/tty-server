TTY_SERVER=./tty-server

TTY_SERVER_ASSETS=$(wildcard frontend/public/*)
TTY_SERVER_SRC=$(wildcard *.go) assets_bundle.go

all: $(TTY_SERVER)
	@echo "Done"

# Building the server and tty-share
$(TTY_SERVER): $(TTY_SERVER_SRC)
	go build -o $@

assets_bundle.go: $(TTY_SERVER_ASSETS)
	go get github.com/go-bindata/go-bindata/...
	go-bindata --prefix frontend/public/ -o $@ $^

%.zip: %
	zip $@ $^

frontend: force
	cd frontend && npm install && npm run build && cd -
force:

clean:
	rm -fr tty-server assets_bundle.go frontend/public
	@echo "Cleaned"

## Development helper targets
### Runs the server, without TLS/HTTPS (no need for localhost testing)
runs: $(TTY_SERVER)
	$(TTY_SERVER) --url http://localhost:9090 --web_address :9090 --sender_address :7654 -frontend_path ./frontend/public
### Runs the sender, without TLS (no need for localhost testing)
runc:
	tty-share  --useTLS=false --server localhost:7654

test:
	@go test github.com/elisescu/tty-share/testing -v
