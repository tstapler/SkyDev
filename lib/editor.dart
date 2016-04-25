import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';

List<WebSocket> client_list = [];

/**
 * @brief Setup a new websocket
 *
 * @param request The HTTP request to be upgraded to a websocket
 */
editorSocketSetup(HttpRequest request) async {
  // Upgrade an HttpRequest to a WebSocket connection.
  WebSocket websocket = await WebSocketTransformer.upgrade(request);
  print('Configuring New Websocket');
  client_list.add(websocket);
  websocket.listen((message) {
		handleEditorSocket(websocket, message);
	});
}

/**
 * @brief Handle the server side communication of the websocket
 *
 * @param message The string read from the websocket
 */
handleEditorSocket(WebSocket websocket, String message) async {
  var request = JSON.decode(message);
  var response = {};

  (new File("files/doc")).createSync(recursive: true);

  print(request.toString());
  File f = new File("files/" + request["filename"]);
  if (request["command"] == "log") {
    print(request["content"]);
    return;
  } else if (!f.existsSync()) {
    response["command"] = "error";
    response["content"] = "File Not Found";
		response["filename"] = request["filename"];
  } else if (request["command"] == "init") {
		// Initialize a new client
    String contents = f.readAsStringSync();
		contents.replaceAll(new RegExp(r'\n'), '\\n');
    response["command"] = "init";
    response["content"] = contents;
		response["filename"] = request["filename"];
		print("Initialising with: " + contents);

  } else if (request["command"] == "change") {
    // Notify all clients of a change to a file
    print("Writing " + request["content"]);
    f.writeAsStringSync(request["content"]);
		String contents = f.readAsStringSync();
		contents.replaceAll(new RegExp(r'\n'), '\\n');
    for (int i = 0; i < client_list.length; i++) {
      if (client_list[i].readyState != WebSocket.OPEN) {
        // If the websocket is closed remove it from the current list
        client_list.removeAt(i);
      } else if (client_list[i] != websocket){
          client_list[i].add(JSON.encode({
            "command": "change",
            "content": contents,
            "filename": request["filename"],
          }));
      }
    }
    return;
  }
  websocket.add(JSON.encode(response));
}
