.PHONY: test build release

%-release:
	@echo -e "Release $$(git semver --dryrun $*):\n" > /tmp/CHANGELOG
	@echo -e "$$(git log --pretty=format:"%h (%an): %s" $$(git describe --tags --abbrev=0 @^)..@)\n" >> /tmp/CHANGELOG
	@cat /tmp/CHANGELOG CHANGELOG > /tmp/NEW_CHANGELOG
	@mv /tmp/NEW_CHANGELOG CHANGELOG

	@gsed -i 's#tag: .*#tag: $(shell git semver --dryrun $*)#g' charts/flux-cloud/values.yaml

	@git add CHANGELOG examples/fluxcloud.yaml examples/flux-deployment-sidecar.yaml
	@git commit -m "Release $(shell git semver --dryrun $*)"
	@git semver $*

test:
	test -z $(shell gofmt -l ./cmd/ ./pkg/)
	go test ./...

build:
	gofmt -w ./cmd ./pkg
	CGO_ENABLED=0 go build -ldflags '-w -s' -installsuffix cgo -o fluxcloud ./cmd/
