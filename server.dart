import 'dart:io';
import 'package:http_server/http_server.dart';

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
	    	WebSocket socket = await WebSocketTransformer.upgrade(request);
	    	socket.listen(handleMsg);
	    	// socket.add('Connected to server');
	  	} else {
	    	var fileUri = new Uri.file(_buildPath).resolve(request.uri.path.substring(1));
	    	_clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
}

handleMsg(msg) {
	print('Message received: $msg');
}