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
CodeMirror editor;
var file;

void main() {
	ws = new WebSocket('ws://localhost:8081/ws');

	ws.onOpen.listen((event){
	});

	ws.onMessage.listen((event){
		String m = event.data;
		print("$m");
		if(m.startsWith("Contents:")){
			m = m.replaceFirst("Contents:", "", 0);
			outputMsg(m, true);
			b2.hidden = false;
		}

	});

	b1 = querySelector('#button1');
	b1.onClick.listen(open);

	b2 = querySelector('#button2');
	b2.onClick.listen(save);
	b2.hidden = true;

	reactClient.setClientConfiguration();
	var component = div({}, "SkyDev");
	render(component, querySelector('#content'));
	component = div({}, "Open");
	render(component, querySelector('#button1'));
	component = div({}, "Save");
	render(component, querySelector('#button2'));

	setCodeMirror();
}

void setCodeMirror(){
	Map options = {
		'mode':  'javascript',
		'theme': 'monokai'
	};

	editor = new CodeMirror.fromElement(
		querySelector('#textContainer'), 
		options: options
	);
	editor.getDoc().setValue(
		"public class SkyDev{\n\tpublic static void main(String[] args){\n\n\t}\n}"
	);

	editor.setLineNumbers(false);
	editor.setIndentWithTabs(true);
	editor.refresh();

}

void open(Event e){
	file = querySelector('#file');
	String s = "${file.value}";
	ws.send("Open:" + s);
}

void save(Event e){
	file = querySelector('#file');
	String s = "${file.value}";
	if(s.contains(":")){
		return;
	}
	String contents = (querySelector('#textContainer')).text;
	contents = contents.substring(1, contents.length);
	outputMsg(contents, false);
	ws.send("Save:" + s + ":" + contents);
}

outputMsg(String msg, bool clearConsole) {

	if(clearConsole){
		editor.getDoc().setValue("");
	}
	editor.getDoc().setValue("$msg");

	// var output = querySelector('#output');
	// var text = msg;
	// if(clearConsole){
	// 	output.text = "";	
	// } else { // save contents of console
	// 	if (!output.text.isEmpty) {
	// 		text = "${output.text}\n${text}";
	// 	}
	// }
	// output.text = text;
}