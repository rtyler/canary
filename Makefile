
all: check container

check: depends spec

spec:
	./scripts/ruby bundle exec rspec -c

depends: Gemfile
	./scripts/ruby bundle install

run: depends
	./scripts/ruby bundle exec rackup -o 0.0.0.0

container: depends Dockerfile
	docker build -t rtyler/codevalet-canary .

clean:
	rm -rf vendor

.PHONY: all depends clean run check container spec
