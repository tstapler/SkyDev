// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:codemirror/codemirror.dart';
import 'package:codemirror/hints.dart';
import 'package:codemirror/panel.dart';
import 'package:skydev/skydev_hud.dart';
import 'package:skydev/skydev_navbar.dart';
import 'package:bootjack/bootjack.dart';

ButtonElement b1;
WebSocket ws, chat;
ButtonElement consoleSubmitButton;
InputElement consoleInput;
WebSocket ws;
CodeMirror editor;
var file;
bool shouldSave = true;

void main() {
	Bootjack.useDefault();
	Dropdown.use();
	b1 = querySelector('#button1');
	b1.onClick.listen(save);
	b1.hidden = false;
	chat = setupChat();
	consoleInput = querySelector('#cmdLine');
	consoleSubmitButton = querySelector('#ConsoleSubmitButton');
	consoleSubmitButton.onClick.listen((submitConsole) => consoleInput.value = consoleInput.value);
	consoleSubmitButton.hidden = false;


	ws = new WebSocket('ws://localhost:8081/ws');

	ws.onOpen.listen((event){
		ws.send("Synchronize");
	});

	ws.onMessage.listen((event){
		String m = event.data;
		if(m.startsWith("Contents:")){
			m = m.replaceFirst("Contents:", "", 0);
			shouldSave = false;
			outputMsg(m, true);
			shouldSave = true;
		}

	});

	setCodeMirror();

	reactClient.setClientConfiguration();
	render(navbar({}, []), querySelector('#navbar'));
	render(hud({'chat_socket': chat}, []), querySelector('#hud'));
	var component = div({}, "Save");
	render(component, querySelector('#button1'));

	Panel.addPanel(editor, querySelector('#textContainer'));
}

WebSocket setupChat() {
 var websocket = new WebSocket('ws://localhost:8081/chat');
	websocket.onOpen.listen((event){
		websocket.send("Chat Client Connected");
	});

	return websocket;

}

void setCodeMirror(){
	Map options = {
		'theme': 'zenburn',
		'height': '100%',
		'continueComments': {'continueLineComment': false},
		'autoCloseTags': true,
		'mode': 'javascript',
		'extraKeys': {
			'Ctrl-Space': 'autocomplete',
			'Cmd-/': 'toggleComment',
			'Ctrl-/': 'toggleComment'
		}
	};

	editor = new CodeMirror.fromElement(
			querySelector('#textContainer'),
			options: options
	);

	Hints.registerHintsHelper('dart', dartCompletion);
	Hints.registerHintsHelperAsync('dart', dartCompletionAsync);

	editor.setLineNumbers(false);
	editor.setIndentWithTabs(true);

	// Theme control.
	SelectElement themeSelect = querySelector('#theme');
	for (String theme in CodeMirror.THEMES) {
		themeSelect.children.add(new OptionElement(value: theme)..text = theme);
		if (theme == editor.getTheme()) {
			themeSelect.selectedIndex = themeSelect.length - 1;
		}
	}
	themeSelect.onChange.listen((e) {
		String themeName = themeSelect.options[themeSelect.selectedIndex].value;
		editor.setTheme(themeName);
	});

	// Mode control.
	SelectElement modeSelect = querySelector('#mode');
	for (String mode in CodeMirror.MODES) {
		modeSelect.children.add(new OptionElement(value: mode)..text = mode);
		if (mode == editor.getMode()) {
			modeSelect.selectedIndex = modeSelect.length - 1;
		}
	}
	modeSelect.onChange.listen((e) {
		String modeName = modeSelect.options[modeSelect.selectedIndex].value;
		editor.setMode(modeName);
	});

	// Show line numbers.
	InputElement lineNumbers = querySelector('#lineNumbers');
	lineNumbers.onChange.listen((e) {
		editor.setLineNumbers(lineNumbers.checked);
	});

	// Indent with tabs.
	InputElement tabIndent = querySelector('#tabIndent');
	tabIndent.onChange.listen((e) {
		editor.setIndentWithTabs(tabIndent.checked);
	});

	// Status line.
	updateFooter(editor);
	editor.onCursorActivity.listen((_) => updateFooter(editor));

	editor.refresh();
	editor.focus();
	editor.onChange.listen(save);
}

void updateFooter(CodeMirror editor) {
	Position pos = editor.getCursor();
	int off = editor.getDoc().indexFromPos(pos);
	String str = 'line ${pos.line} • column ${pos.ch} • offset ${off}'
		+ (editor.getDoc().isClean() ? '' : ' • (modified)');
	querySelector('#footer').text = str;
}

HintResults dartCompletion(CodeMirror editor, [HintsOptions options]) {
	Position cur = editor.getCursor();
	String word = getCurrentWord(editor).toLowerCase();
	List<HintResult> list = vocab
		.where((s) => s.startsWith(word))
		.map((s) => new HintResult(s))
		.toList();

	HintResults results = new HintResults.fromHints(
			list,
			new Position(cur.line, cur.ch - word.length),
			new Position(cur.line, cur.ch)
			);
	results.registerOnShown(() => print('hints shown'));
	results.registerOnSelect((completion, element) {
		print(['hints select: ${completion}']);
	});
	results.registerOnPick((completion) {
		print(['hints pick: ${completion}']);
	});
	results.registerOnUpdate(() => print('hints update'));
	results.registerOnClose(() => print('hints close'));

	return results;
}

Future<HintResults> dartCompletionAsync(CodeMirror editor, [HintsOptions options]) {
	Position cur = editor.getCursor();
	String word = getCurrentWord(editor).toLowerCase();
	List<String> list = new List.from(vocab.where((s) => s.startsWith(word)));

	return new Future.delayed(new Duration(milliseconds: 200), () {
		return new HintResults.fromStrings(
			list,
			new Position(cur.line, cur.ch - word.length),
			new Position(cur.line, cur.ch));
	});
}

List vocab = [
'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'
];

final RegExp ids = new RegExp(r'[a-zA-Z_0-9]');

String getCurrentWord(CodeMirror editor) {
	Position cur = editor.getCursor();
	String line = editor.getLine(cur.line);
	StringBuffer buf = new StringBuffer();

	for (int i = cur.ch - 1; i >= 0; i--) {
		String c = line[i];
		if (ids.hasMatch(c)) {
			buf.write(c);
		} else {
			break;
		}
	}

	return new String.fromCharCodes(buf.toString().codeUnits.reversed);
}

void save(Event e){
	String contents = editor.getDoc().getValue();
	if(shouldSave){
		ws.send("Save:" + contents);
	}
}

void submitConsole(Event e){
	e.preventDefault(); // Don't do the default submit.
	String cmdArgs = consoleInput.value();
	ws.send("Submit:" + cmdArgs);
	

}

outputMsg(String msg, bool clearConsole) {
	Position p = editor.getDoc().getCursor();
	if(clearConsole){
		editor.getDoc().setValue("");
	}
	editor.getDoc().setValue("$msg");
	editor.getDoc().setCursor(p);
	
	List<String> words = msg.split(" ");
	for(int i = 0; i < words.length; i++){
		vocab.add(words[i]);
	}
	
	vocab = msg.split(" ");
}
