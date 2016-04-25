import 'dart:io';
import 'dart:convert';
import 'dart:async';

List<WebSocket> console_list = [];
WebSocket console_socket;

/* Console Methods */
consoleSocketSetup(HttpRequest request) async {
	// Upgrade an HttpRequest to a WebSocket connection.
	console_socket = await WebSocketTransformer.upgrade(request);
	print('Server has gotten a websocket console request');
	console_list.add(console_socket);
	console_socket.listen(handleConsole);
}

runarbitrarycommands(String cmd, [List<String> listInput]) {
	if (cmd == null)
		print("Null or no string input from terminal");
	else if (listInput == null) {
		print(cmd);
		//try{
		Process.run(cmd, []).then((ProcessResult result) {
			//websocket send the resuls back to the client side to display the correct
			// content
			String results = result.stdout;
			String error = result.stderr;
			print("$results");
			//console_socket.add("ConsoleResults:"+results);
			console_socket.add(JSON.encode(result.stdout));
			if (error != null) {
				console_socket.add("ConsoleErrorResults:" + error);
			}
		}); //}
		/*catch(e){
			print(e);
			}*/
	} else {
		Process.run(cmd, listInput).then((ProcessResult result) {
			String results = result.stdout;
			String error = result.stderr;
			print("$results");
			console_socket.add("ConsoleResults:" + results);
			//websocket send the resuls back to the client side to display the correct
			// content
			if (error != null) {
				console_socket.add("ConsoleErrorResults:" + error);
			}
		});
	}
}

handleConsole(String m) async {
	List<String> cmdArgs = JSON.decode(m);
	if (cmdArgs.length == 1) {
		runarbitrarycommands(cmdArgs[0]);
	} else {
		runarbitrarycommands(cmdArgs[0], cmdArgs.sublist(1, cmdArgs.length));
	}
}
