SHELL := /bin/bash
DOCKER_IMAGE = "prom-image-exporter:latest"
APP_NAME = "prom-image-exporter"

setup:
	pip install pipenv

build_docker:
	docker build --rm -t $(DOCKER_IMAGE) .

run_docker:
	docker run -it --rm  $(DOCKER_IMAGE)

run:
	pipenv run python $(APP_NAME).py

run_bin:
	./dist/$(APP_NAME)
build_bin:
	pipenv run pyinstaller --noconfirm --log-level=INFO \
    --onefile --nowindow \
	$(APP_NAME).py
	du -hs ./dist/$(APP_NAME)
	ldd ./dist/$(APP_NAME)

.PHONY: clean
clean:
	rm -rf build dist $(APP_NAME).spec

.PHONY: all
all: clean build_bin run_bin