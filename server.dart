import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http_server/http_server.dart';
import 'package:skydev/database.dart';
import 'package:trestle/gateway.dart';
import 'package:query_string/query_string.dart';

Cookie sessionCookie;
WebSocket socket;
List<WebSocket> list = [];

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
		} else if (request.uri.path == '/ws') {
			// Upgrade an HttpRequest to a WebSocket connection.
			socket = await WebSocketTransformer.upgrade(request);
			print('Server has gotten a websocket request');
			list.add(socket);
			socket.listen(handleMsg);
		} else if (request.uri.path == '/login') {
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
			request.response.headers.clear();
			request.response.redirect(Uri.parse('login.html'));

		}	else if (request.uri.path == '/register') {
			if (request.method == 'POST') {
				handleRegister(request);
			} else {
				request.response.redirect(Uri.parse('registration.html'));
			}
		} else if (request.uri.path == '/viewdb') {
			handleView(request);
		} else {
			var fileUri = new Uri.file(_buildPath).resolve(request.uri.path.substring(1));
			_clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
	await db_gateway.disconnect();
}
Future handleLogout(HttpRequest req) async {
	Cookie cookie;
	try{
		cookie = req.cookies.singleWhere( (element) => element.name  == "SessionID");
	}
	catch(e){
		print("Cookie not found or multiple cookies attached");
		print("Precedes to logout");
	}
	var databaseCookie;
	try{
	    databaseCookie = await users.where((user) => user.username == cookie.value).first();
    }
  catch(e){
    print("Correct SessionID not found in database");

  }
	databaseCookie.sessionid = '';
	var models = [databaseCookie];
	await users.saveAll(models);
	print(databaseCookie.sessionid);

}

Future handleLogin(HttpRequest req) async {
	HttpResponse res = req.response;
	print('${req.method}: ${req.uri.path}');
	addCorsHeaders(res);
	var jsonString = await req.transform(UTF8.decoder).join();
	Map jsonData = QueryString.parse(jsonString);


	if(await verifyUser(jsonData)){
		res.headers.set('Set-Cookie', sessionCookie.toString());
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
	expiress = expiress.add(new Duration(minutes: 30));
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
	print("${chkCookie.name}");
	var databaseCookie;
	try{
	    databaseCookie = await users.where((user) => user.username == chkCookie.value).first();
    }
    catch(e){
      print("Correct SessionID not found in database");
			return false;
    }
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
	res.write(user_list);
	res.close();
}

void printError(error) => print(error);
