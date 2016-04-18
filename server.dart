import 'dart:io';
import 'dart:convert';
//import 'dart:async';
import 'package:http_server/http_server.dart';
import 'package:skydev/database.dart';
//import 'package:trestle/gateway.dart';
import 'package:skydev/serverHandleProfilePage.dart';
import 'package:skydev/serverHandleLogin.dart';
import 'package:skydev/serverHandleRegistration.dart';
import 'package:skydev/serverHandleLogout.dart';
import 'package:skydev/serverHandleCookies.dart';
import 'package:skydev/api.dart';
import 'package:skydev/utils.dart';
import 'package:query_string/query_string.dart';

WebSocket socket, chat_socket, console_socket;
List<WebSocket> list = [];
List<WebSocket> chat_list = [];
List<WebSocket> console_list = [];

main() async {
	await db_gateway.connect();
	var requestServer = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8081);
	print('listening on http://${requestServer.address.host}:${requestServer.port}');
	await for (HttpRequest request in requestServer) {
		final String _buildPath = Platform.script.resolve('build/web/').toFilePath();
		final VirtualDirectory _clientDir = new VirtualDirectory(_buildPath);
		if (request.uri.path == '/') {
			if(await handleCookies(request)){
				request.response.redirect(Uri.parse('index.html'));
			}
			else{
				request.response.redirect(Uri.parse('login.html'));
			}
		} else if (request.uri.path == '/profile'){
			if(request.method == 'POST'){
				handleProfilePage(request);
			}
			else{
				if(await handleCookies(request)){
					request.response.redirect(Uri.parse('user_management.html'));
				}
				else{
					request.response.redirect(Uri.parse('login.html'));
				}
			}
		} else if (request.uri.path == '/ws') {
			// Upgrade an HttpRequest to a WebSocket connection.
			socket = await WebSocketTransformer.upgrade(request);
			print('Server has gotten a websocket request');
			list.add(socket);
			socket.listen(handleMsg);
			//Handler for the chat system
			} else if (request.uri.path == '/chat') {
			// Upgrade an HttpRequest to a WebSocket connection.
			chat_socket = await WebSocketTransformer.upgrade(request);
			print('Server has gotten a websocket request');
			chat_list.add(chat_socket);
			chat_socket.listen(handleChat);
		  }else if (request.uri.path == '/console') {
		  // Upgrade an HttpRequest to a WebSocket connection.
		  console_socket = await WebSocketTransformer.upgrade(request);
		  print('Server has gotten a websocket console request');
		  console_list.add(console_socket);
		  console_socket.listen(handleConsole);
	  }else if (request.uri.path == '/login') {
			if (request.method == 'POST') {
				handleLogin(request);
			} else {
				if(await handleCookies(request)){
					request.response.redirect(Uri.parse('index.html'));
				}
				else{
					request.response.redirect(Uri.parse('login.html'));
				}
			}
		}	else if (request.uri.path == '/logout'){
			handleLogout(request);

		}	else if (request.uri.path == '/register') {
			if (request.method == 'POST') {
				handleRegister(request);
			} else {
				request.response.redirect(Uri.parse('registration.html'));
			}
		} else if (request.uri.path == '/viewdb') {
			handleView(request);
		} else if (request.uri.path == '/api/online') {
			returnOnlineUsers(request);
		} else if (request.uri.path == '/api/username') {
			getUsernameFromSession(request);
		} else {
			var fileUri = new Uri.file(_buildPath).resolve(request.uri.path.substring(1));
			_clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
	await db_gateway.disconnect();
}


void handleMsg(String m) async {
	(new File("files/doc")).createSync(recursive: true);
	print('Message received: $m');

	if (m.startsWith("Synchronize")) { // reading
		File f = new File("files/doc");
		if (!f.existsSync()) {
		  socket.add("Contents:Error: Could not find file");
		} else {
			String contents = f.readAsStringSync();
			socket.add("Contents:" + contents);
		}
	} else if (m.startsWith("Save:")) { // writing
		m = m.replaceFirst("Save:", "", 0);
		File f = (new File("files/doc"));
		f.writeAsStringSync(m);
		for (int i = 0; i < list.length; i++){
			if(list[i].readyState != WebSocket.OPEN){
				list.removeAt(i);
			} else{
				f.readAsString().then((String contents) {
					list[i].add("Contents:" + contents);
				});
			}
		}
	} else if (m.startsWith("Log:")) { // writing
		m = m.replaceFirst("Log:", "", 0);
		print("$m");
	}
	/*else if (m.startsWith("Submit:")){
		m = m.replaceFirst("Submit:", "", 0);
		List<String> cmdArgs = m.split(' ');
		if (cmdArgs.length == 1){
			runarbitrarycommands(cmdArgs[0]);}
		else{
			runarbitrarycommands(cmdArgs[0],cmdArgs.sublist(1,cmdArgs.length));
		}
	}*/
}

void handleChat(String m) async {
	print('Message received: $m');
		for (int i = 0; i < chat_list.length; i++){
			if(chat_list[i].readyState != WebSocket.OPEN){
				chat_list.removeAt(i);
			} else{
				chat_list[i].add(m);
			}
		}
}

void runarbitrarycommands(String cmd, [List<String> listInput]){
	if(cmd == null)
		print("Null or no string input from terminal");

		else if(listInput == null){
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
					if(error != null){
						console_socket.add("ConsoleErrorResults:"+error);
					}
			});//}
			/*catch(e){
				print(e);
			}*/
		}

		else{
			Process.run(cmd, listInput).then((ProcessResult result) {
				String results = result.stdout;
				String error = result.stderr;
				print("$results");
				console_socket.add("ConsoleResults:"+results);
				//websocket send the resuls back to the client side to display the correct
				// content
				if(error != null){
					console_socket.add("ConsoleErrorResults:"+error);
				}
			});
		}
}

void handleConsole(String m) async {
		List<String> cmdArgs = JSON.decode(m);
		if (cmdArgs.length == 1){
			runarbitrarycommands(cmdArgs[0]);
		}
		else {
			runarbitrarycommands(cmdArgs[0],cmdArgs.sublist(1,cmdArgs.length));
		}
}


void handleView(HttpRequest req) async {
	HttpResponse res = req.response;
	var user_list = await users.all().toList();
	res.write(JSON.encode(user_list));
	res.close();
}


void printError(error) => print(error);
