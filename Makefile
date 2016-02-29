it:
	./start_database.sh
	pub get && pub build
	dart server.dart

vm:
	pub get && pub build && pub serve

install-dependencies: 
	sudo pip install ansible
	ansible-playbook -K -i "localhost," -c local installer.yaml	
