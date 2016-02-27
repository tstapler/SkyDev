import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http_server/http_server.dart';

WebSocket socket;

main() async {
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
		} else {
	    	var fileUri = new Uri.file(_buildPath).resolve(request.uri.path.substring(1));
	    	_clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
}
/// Handle POST requests
/// Return the same set of data back to the client.
void handleLogin(HttpRequest req) {
  HttpResponse res = req.response;
  print('${req.method}: ${req.uri.path}');

  addCorsHeaders(res);

  req.listen((List<int> buffer) {
    // return the data back to the client
    res.write('Thanks for the data. This is what I heard you say: ');
    res.write(new String.fromCharCodes(buffer));
    res.close();
  }, onError: printError);
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

	if(m.startsWith("Open:")){
		m = m.replaceFirst("Open:", "", 0);
		File f = new File("files/$m");
		if(!f.existsSync()){
			socket.add("Error: Could not find file");
		} else {
			f.readAsString().then((String contents){
				socket.add("Contents:" + contents);
			});
		}
	} else if(m.startsWith("Save:")) {
		// print(m);
		m = m.replaceFirst("Save:", "", 0);
		String filename = m.substring(0, m.indexOf(":"));
		// print(filename);
		m = m.replaceFirst("$filename:", "", 0);
		// print(m.isEmpty);
		(new File("files/$filename")).writeAsStringSync(m);

		// print("Contents:\n\t" + (new File("files/$filename")).readAsStringSync());
	}
}

void printError(error) => print(error);
