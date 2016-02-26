// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. 
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'dart:async';

ButtonElement b;
WebSocket ws;

void main() {
	ws = new WebSocket('ws://localhost:8081/ws');

	ws.onOpen.listen((event){
		outputMsg('Socket connection opened');
		ws.send('Hello from client');
	});

	ws.onMessage.listen((event){
		if(event.data == 'Connected to server'){
			outputMsg('Connected to server');
		} else {
			outputMsg(event.data);
		}
	});

	b = querySelector('#button');
	b.onClick.listen(handle);

	reactClient.setClientConfiguration();
	var component = div({}, "SkyDev");
	render(component, querySelector('#content'));
}

void handle(Event e){
	ws.send("Hello from client button press");
}

outputMsg(String msg) {
	var output = querySelector('#output');
	var text = msg;
	if (!output.text.isEmpty) {
		text = "${output.text}\n${text}";
	}
	output.text = text;
}