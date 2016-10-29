build: | output
	docker build -t dlite-os-build .
	docker volume create --name dlite-dl
	docker volume create --name dlite-ccache
	docker run -it --name dlite-os-builder \
		-v ${PWD}/config:/tmp/config \
		-v dlite-dl:/tmp/buildroot/dl \
		-v dlite-ccache:/tmp/buildroot/ccache \
		dlite-os-build make --quiet
	docker cp dlite-os-builder:/tmp/buildroot/output/images/bzImage output/
	docker cp dlite-os-builder:/tmp/buildroot/output/images/rootfs.cpio.xz output/
	docker rm dlite-os-builder

config:
	docker build -t dlite-os-build .
	docker run -it --name dlite-os-builder \
		-v ${PWD}/config:/tmp/config \
		dlite-os-build /bin/bash -c 'cd /tmp/buildroot; make nconfig && cp /tmp/buildroot/.config /tmp/config/buildroot || true'
	docker rm dlite-os-builder

linux-config:
	docker build -t dlite-os-build .
	docker volume create --name dlite-dl
	docker volume create --name dlite-ccache
	docker run -it --name dlite-os-builder \
		-v ${PWD}/config:/tmp/config \
		-v dlite-dl:/tmp/buildroot/dl \
		-v dlite-ccache:/tmp/buildroot/ccache \
		dlite-os-build /bin/bash -c 'cd /tmp/buildroot; make linux-menuconfig'
	docker rm dlite-os-builder

clean:
	rm -rf output
	-docker rm dlite-os-builder

dist-clean: clean
	-docker volume rm dlite-dl
	-docker volume rm dlite-ccache
	-docker rmi dlite-os-build

output:
	mkdir -p $@

.PHONY: build config linux-config clean dist-clean
