import 'dart:io';
import 'dart:convert';
import 'dart:async';

List<WebSocket> chat_list = [];

chatSocketSetup(HttpRequest request) async {
	// Upgrade an HttpRequest to a WebSocket connection.
	WebSocket chat_socket = await WebSocketTransformer.upgrade(request);
	print('Server has gotten a websocket request');
	chat_list.add(chat_socket);
	chat_socket.listen(handleChat);
}

handleChat(String m) async {
	print('Message received: $m');
	for (int i = 0; i < chat_list.length; i++) {
		if (chat_list[i].readyState != WebSocket.OPEN) {
			chat_list.removeAt(i);
		} else {
			chat_list[i].add(m);
		}
	}
}
