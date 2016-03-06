import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http_server/http_server.dart';
import 'package:skydev/database.dart';
import 'package:trestle/gateway.dart';
import 'package:query_string/query_string.dart';

WebSocket socket;
List<WebSocket> list;

main() async {
await db_gateway.connect();
list = [];
var requestServer = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8081);
print('listening on http://${requestServer.address.host}:${requestServer.port}');
	await for (HttpRequest request in requestServer) {
		final String _buildPath = Platform.script.resolve('build/web/').toFilePath();
		final VirtualDirectory _clientDir = new VirtualDirectory(_buildPath);
		if (request.uri.path == '/') {
		    request.response.redirect(Uri.parse('index.html'));
		} else if (request.uri.path == '/ws') {
			// Upgrade an HttpRequest to a WebSocket connection.
			socket = await WebSocketTransformer.upgrade(request);
			print('Server has gotten a websocket request');
			list.add(socket);
			socket.listen(handleMsg);
		} else if (request.uri.path == '/login'){
			switch (request.method) {
				case 'POST':
					handleLogin(request);
				break;
				case 'OPTIONS':
					handleOptions(request);
				break;
				default:
					request.response.redirect(Uri.parse('login.html'));
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

Future handleLogin(HttpRequest req) async {
	HttpResponse res = req.response;
	print('${req.method}: ${req.uri.path}');
	addCorsHeaders(res);
	var jsonString = await req.transform(UTF8.decoder).join();
	Map jsonData = QueryString.parse(jsonString);
	if(await verifyUser(jsonData)){
		res.write('Success');
		res.close();
	}
	else{
		res.write('Fail');
		res.close();
	}
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
	print('Message received: $m');

	// Reading
	if (m.startsWith("Synchronize:")) { // reading
		File f = new File("files/doc");
		if (!f.existsSync()) {
		  socket.add("Error: Could not find file");
		} else {
			f.readAsString().then((String contents) {
				socket.add(contents);
			});
		}
	} else if (m.startsWith("Save:")) { // writing
		m = m.replaceFirst("Save:", "", 0);
		File f = (new File("files/doc"));
		f.writeAsStringSync(m);
		for (int i = 0; i < list.length; i++){
			f.readAsString().then((String contents) {
				list[i].add("Contents:" + contents);
			});	
		}
	}
}
Future verifyUser(Map formData) async{
	var uInput;
	var pInput;
	uInput = formData['username'];
	pInput = formData['password'];
	var uData = await users.where((user) => user.username == uInput).first();
	print(uData.password);
	if(check_password(pInput, uData.password)){
		print("Passwords matched");
		return true;
	}
	else{
		print("Incorrect Password");
		return false;
	}
}

void createUser(Map formData){
	new User.create(formData['username'],
									formData['email'],
										hash_password(formData['password']));
}

void handleView(HttpRequest req) async {
	HttpResponse res = req.response;
	var user_list = await users.all().toList();
	res.write(user_list);
	res.close();
}

void printError(error) => print(error);
