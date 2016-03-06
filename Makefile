it:
	./scripts/start_database.sh
	ansible-playbook -i "localhost," -c local scripts/database_provision.yaml
	pub get && pub build
	dart server.dart

vm:
	pub get && pub build && pub serve

install-dependencies:
	sudo pip install ansible
	ansible-playbook -K -i "localhost," -c local scripts/installer.yaml	
