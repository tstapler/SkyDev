it:
	./scripts/start_database.sh
	pub get && pub build
	ansible-playbook -i "localhost," -c local scripts/database_provision.yaml
	dart server.dart

vm:
	pub get && pub build && pub serve

install-dependencies:
	sudo pip install ansible
	ansible-playbook -K -i "localhost," -c local scripts/installer.yaml

clean:
	rm -r build/*
	rm -r packages
	# rm ~/.pub-cache
