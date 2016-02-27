// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. 
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:codemirror/codemirror.dart';

ButtonElement b1;
ButtonElement b2;
WebSocket ws;

void main() {
	ws = new WebSocket('ws://localhost:8081/ws');

	ws.onOpen.listen((event){
	});

	ws.onMessage.listen((event){
		String m = event.data;
		if(m.startsWith("Contents:")){
			m = m.replaceFirst("Contents:", "", 0);
			outputMsg(m, true);
			b2.hidden = false;
		}

	});

	b1 = querySelector('#button1');
	b1.onClick.listen(open);

	b2 = querySelector('#button2');
	b2.onClick.listen(open);
	b2.hidden = true;

	reactClient.setClientConfiguration();
	var component = div({}, "SkyDev");
	render(component, querySelector('#content'));

	setCodeMirror();
}

void setCodeMirror(){
	Map options = {
		'mode':  'javascript',
		'theme': 'monokai'
	};

	CodeMirror editor = new CodeMirror.fromElement(
		querySelector('#textContainer'), 
		options: options
	);
	editor.getDoc().setValue(
		"public class SkyDev{\n\tpublic static void main(String[] args){\n\n\t}\n}"
	);

}

void open(Event e){
	var file = querySelector('#file');
	String s = "${file.value}";
	ws.send("Open:" + s);
}

void create(Event e){
	var file = querySelector('#file');
	String s = "${file.value}";
	ws.send("Create:" + s);
}

outputMsg(String msg, bool clearConsole) {
	var output = querySelector('#output');
	var text = msg;
	if(clearConsole){
		output.text = "";	
	} else { // save contents of console
		if (!output.text.isEmpty) {
			text = "${output.text}\n${text}";
		}
	}
	output.text = text;
}