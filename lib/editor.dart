import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';

List<WebSocket> client_list = [];
WebSocket editor_socket;

/**
 * @brief Setup a new websocket
 *
 * @param request The HTTP request to be upgraded to a websocket
 */
editorSocketSetup(HttpRequest request) async {
  // Upgrade an HttpRequest to a WebSocket connection.
  editor_socket = await WebSocketTransformer.upgrade(request);
  print('Configuring New Websocket');
  client_list.add(editor_socket);
  editor_socket.listen(handleEditorSocket);
}

/**
 * @brief Handle the server side communication of the websocket
 *
 * @param message The string read from the websocket
 */
handleEditorSocket(String message) async {
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
  } else if (request["command"] == "init") {
    // reading
    String contents = f.readAsStringSync();
    response["command"] = "init";
    response["content"] = contents;
  } else if (request["command"] == "change") {
    // writing
		print("Writing " + request["content"]);
    f.writeAsStringSync(request["content"]);
		for(int i = 0; i < client_list.length; i++){
      if (client_list[i].readyState != WebSocket.OPEN) {
        // If the websocket is closed remove it from the current list
				client_list.removeAt(i);
      } else {
        f.readAsString().then((String contents) {
          client_list[i].add(JSON.encode({"command": "change", "content": request["content"]}));
        });
      }
    }
		return;
  }
  editor_socket.add(JSON.encode(response));
}
