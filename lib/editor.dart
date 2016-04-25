import 'dart:io';
import 'dart:convert';

List<WebSocket> client_list = [];
WebSocket editor_socket;

editorSocketSetup(HttpRequest request) async {
			// Upgrade an HttpRequest to a WebSocket connection.
			editor_socket = await WebSocketTransformer.upgrade(request);
			print('Server has gotten a websocket request');
			client_list.add(editor_socket);
			editor_socket.listen(handleEditor);
}

handleEditor(String m) async {
  (new File("files/doc")).createSync(recursive: true);
  print('Message received: $m');

  if (m.startsWith("Synchronize")) {
    // reading
    File f = new File("files/doc");
    if (!f.existsSync()) {
      editor_socket.add("Contents:Error: Could not find file");
    } else {
      String contents = f.readAsStringSync();
      editor_socket.add("Contents:" + contents);
    }
  } else if (m.startsWith("Save:")) {
    // writing
    m = m.replaceFirst("Save:", "", 0);
    File f = (new File("files/doc"));
    f.writeAsStringSync(m);
    for (int i = 0; i < client_list.length; i++) {
      if (client_list[i].readyState != WebSocket.OPEN) {
        client_list.removeAt(i);
      } else {
        f.readAsString().then((String contents) {
          client_list[i].add("Contents:" + contents);
        });
      }
    }
  } else if (m.startsWith("Log:")) {
    // writing
    m = m.replaceFirst("Log:", "", 0);
    print("$m");
  }
}
