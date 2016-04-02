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
import 'package:codemirror/hints.dart';
import 'package:codemirror/panel.dart';
import 'package:skydev/skydev_navbar.dart';

ButtonElement b1;
WebSocket ws;
CodeMirror editor;
var file;
bool shouldSave = true;

List<String> vocab = [
'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'
];

void main() {
	b1 = querySelector('#button1');
	b1.onClick.listen(save);
	b1.hidden = false;

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

	reactClient.setClientConfiguration();
	render(navbar({}), querySelector('#navbar'));
	var component = div({}, "SkyDev");
	render(component, querySelector('#content'));

	setCodeMirror();
	Panel.addPanel(editor, querySelector('#textContainer'));
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

outputMsg(String msg, bool clearConsole) {
	Position p = editor.getDoc().getCursor();
	if(clearConsole){
		editor.getDoc().setValue("");
	}
	editor.getDoc().setValue("$msg");
	editor.getDoc().setCursor(p);
	vocab = msg.split(" ");
}
