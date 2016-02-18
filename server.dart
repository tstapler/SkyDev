import 'dart:io';
import 'package:http_server/http_server.dart';

main() async {
	var requestServer = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);
	print('listening on localhost, port ${requestServer.port}');

	await for (HttpRequest request in requestServer) {
		final String _buildPath = Platform.script.resolve('web/').toFilePath();
		final VirtualDirectory _clientDir = new VirtualDirectory(_buildPath);

	    if (request.uri.path == '/') {
		    request.response.redirect(Uri.parse('index.html'));
		} else {
		    var fileUri = new Uri.file(_buildPath)
		        .resolve(request.uri.path.substring(1));
		    _clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
}
