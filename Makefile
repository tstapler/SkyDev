it:
	pub get && pub serve

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
