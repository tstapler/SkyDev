import 'dart:io';
import 'package:http_server/http_server.dart';

WebSocket socket;

main() async {
	var requestServer = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8081);
	print('listening on localhost, port ${requestServer.port}');
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
	  	} else {
	    	var fileUri = new Uri.file(_buildPath).resolve(request.uri.path.substring(1));
	    	_clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
}

void handleMsg(String m) {
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
	} else if(m.startsWith("Create:")) {
		m = m.replaceFirst("Create:", "", 0);
		File f = new File("files/$m");
		f.create();
	}
}