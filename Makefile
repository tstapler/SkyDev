it:
	./start_database.sh
	pub get && pub build
	dart server.dart

vm:
	pub get && pub build && pub serve

install-sdk:
	sudo apt-get install curl
	sudo apt-get install apt-transport-https
	# Get the Google Linux package signing key.
	sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
	# Set up the location of the stable repository.
	sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
	sudo apt-get update
	sudo apt-get install dart
	ln -s /usr/lib/dart/bin/* /usr/bin

install-dartium:
	wget "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/dartium/dartium-linux-x64-release.zip"
	unzip dartium-linux-x64-release.zip
	sudo ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0

install-docker:
	#Install docker
	sudo apt-get install aufs-tools
	#Install docker via automated install script
	wget -qO- https://get.docker.com/ | sh
	#Add docker group and add your user (so you dont have to sudo everything)
	sudo usermod -aG docker $(whoami)
	#Install pip if it doesnt exist
	sudo apt-get -y install python-pip
	sudo pip install docker-compose

install-dependencies:
	install-sdk
	install-dartium
	install-docker
