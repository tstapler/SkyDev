import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http_server/http_server.dart';
import 'package:skydev/database.dart';
//import 'package:trestle/gateway.dart';
import 'package:query_string/query_string.dart';

Cookie sessionCookie;
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
		} else if (request.uri.path == '/online') {
			returnOnlineUsers(request);
		} else {
			var fileUri = new Uri.file(_buildPath).resolve(request.uri.path.substring(1));
			_clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
	await db_gateway.disconnect();
}
Future handleProfilePage(HttpRequest req) async {
	HttpResponse res = req.response;
	addCorsHeaders(res);
	if(req.method == 'POST'){
		Cookie cookie;
		try{
			cookie = req.cookies.singleWhere( (element) => element.name  == "SessionID");
		}
		catch(e){
			print("Cookie not found or multiple cookies attached");
			res.write('Fail');
			res.close();
			return;
		}
		var jsonString = await req.transform(UTF8.decoder).join();
		Map userData = QueryString.parse(jsonString);
		var model;
		try{
		    model = await users.where((user) => user.username == cookie.value).first();
		  }
	  catch(e){
	    print("Correct User not found in database");
			res.write('Fail');
			res.close();
			return;
		}
		if(check_password(userData['password'], model.password)){
			if(userData['newUsername'] != '' && userData['newUsername'] != null && model.username != userData['newUsername']){
				model.username = userData['newUsername'];
			}
			if(userData['newEmail'] != '' && userData['newEmail'] != null && model.email != userData['newEmail']){
				model.email = userData['newEmail'];
			}
			if(userData['newPassword'] != '' && userData['newPassword'] != null && userData['password'] != userData['newPassword']){
				model.password = hash_password(userData['newPassword']);
			}
		  await users.saveAll([model]);
			res.write('Success');
			res.close();
		}
		else{
			res.write('Fail');
			res.close();
		}
	}
}
Future handleLogout(HttpRequest req) async {
	HttpResponse res = req.response;

	Cookie cookie, session;
	try{
		print(req.cookies);
		cookie = req.cookies.singleWhere( (element) => element.name  == "SessionID");
		print(cookie);
	}
	catch(e){
		print(e);
		print("Cookie not found or multiple cookies attached");
		res.redirect(Uri.parse('login.html'));
		return;
	}
	var user;
	try{
			print("Cookie Value:" + cookie.value + "|");
	    user = await users.where((user) => user.username == cookie.value).first();
			print(user);
    }
  catch(e){
		print(e);
    print("Correct SessionID not found in database");
		res.redirect(Uri.parse('login.html'));
		return;
  }

	cookie.value = "";
	user.sessionid = "";
	res.headers.set('Set-Cookie', cookie);
	await users.save(user);
	res.redirect(Uri.parse('login.html'));
}

Future handleLogin(HttpRequest req) async {
	HttpResponse res = req.response;
	print('${req.method}: ${req.uri.path}');
	addCorsHeaders(res);
	var jsonString = await req.transform(UTF8.decoder).join();
	Map jsonData = QueryString.parse(jsonString);


	if(await verifyUser(jsonData)){
		res.headers.set('Set-Cookie', sessionCookie);
		res.write('Success');
		res.close();
	}
	else{
		res.write('Fail');
		res.close();
	}
}

Future handleRegister(HttpRequest req) async {
  HttpResponse res = req.response;
  print('${req.method}: ${req.uri.path}');
  addCorsHeaders(res);
  var queryString = await req.transform(UTF8.decoder).join();
  Map queryData = QueryString.parse(queryString);
  await createUser(queryData);
  res.write('Success');
  res.close();

}
void cookieMaker(var name, var value){
	sessionCookie = new Cookie(name, value);
	var expiress = new DateTime.now();
	expiress = expiress.add(new Duration(minutes: 10));
	sessionCookie.expires = expiress;
}

Future handleCookies(HttpRequest req) async {
	Cookie chkCookie;
	try{
		chkCookie = req.cookies.singleWhere( (element) => element.name  == "SessionID");
	}
	catch(e){
		print("Cookie not found or multiple cookies attached");
		return false;
	}
	if (chkCookie == null){
		return false;
	}
	print("${chkCookie.value}");
	var databaseCookie;
	try{
	    databaseCookie = await users.where((user) => user.username == chkCookie.value).first();
    }
    catch(e){
      print("Correct SessionID not found in database");
			return false;
    }
		var expiress = new DateTime.now();
		expiress = expiress.add(new Duration(minutes: 10));
		chkCookie.expires = expiress;
		req.response.headers.set('Set-Cookie', chkCookie);
	print("${databaseCookie.sessionid}");
	if (chkCookie.value != databaseCookie.sessionid){
		return false;
	}

	print("${req.uri.toString()}");
	if (req.uri.toString() == 'login/' || req.uri.toString() == 'login.html'){
		return true;
	}
	return true;
}



void addCorsHeaders(HttpResponse res) {
	res.headers.add('Access-Control-Allow-Origin', '*');
	res.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
	res.headers.add('Access-Control-Allow-Headers',
	'Origin, X-Requested-With, Content-Type, Accept');
}

void handleOptions(HttpRequest req) {
	HttpResponse res = req.response;
	addCorsHeaders(res);
	print('${req.method}: ${req.uri.path}');
	res.statusCode = HttpStatus.NO_CONTENT;
	res.close();
}

void defaultHandler(HttpRequest req) {
	HttpResponse res = req.response;
	addCorsHeaders(res);
	res.statusCode = HttpStatus.NOT_FOUND;
	res.write('Not found: ${req.method}, ${req.uri.path}');
	res.close();
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

Future verifyUser(Map formData) async{
	var uInput;
	var pInput;
  	var uData;
	uInput = formData['username'];
	pInput = formData['password'];
  try{
	    uData = await users.where((user) => user.username == uInput).first();
    }
    catch(e){
      print("Username not found");
      return false;
    }
	if(check_password(pInput, uData.password)){
		cookieMaker("SessionID", uInput);
		uData.sessionid = uInput;
		users.saveAll([uData]);
		print("Passwords matched");
		return true;
	}
	else{
		print("Incorrect Password");
		return false;
	}
}

Future createUser(Map formData) async{
	var models = [new User.create(formData['username'],
									formData['email'],
										hash_password(formData['password']))];
  await users.saveAll(models);
}

void handleView(HttpRequest req) async {
	HttpResponse res = req.response;
	var user_list = await users.all().toList();
	res.write(JSON.encode(user_list));
	res.close();
}

void returnOnlineUsers(HttpRequest req) async {
	HttpResponse res = req.response;
	var online = await users.all().toList();
  addCorsHeaders(res);
	res.write(JSON.encode(online.map((user) => {"username": user.username, "online": user.sessionid != null && user.sessionid != ""}).toList()));
	res.close();
}

void printError(error) => print(error);
