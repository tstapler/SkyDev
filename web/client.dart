// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
//import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:codemirror/codemirror.dart';
import 'package:codemirror/hints.dart';
import 'package:codemirror/panel.dart';
import 'package:skydev/skydev_hud.dart';
import 'package:skydev/skydev_navbar.dart';
import 'package:skydev/skydev_filebrowser.dart';
import 'package:bootjack/bootjack.dart';
import 'package:cookies/cookies.dart';

ButtonElement b1;
WebSocket ws, chat;
//ButtonElement consoleSubmitButton;
//InputElement consoleInput;
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
	/*consoleInput = document.querySelector('#cmdLine');
	consoleSubmitButton = document.querySelector('#ConsoleSubmitButton');
	consoleSubmitButton.onClick.listen((submitConsole) => consoleInput.value = consoleInput.value);
	consoleSubmitButton.hidden = false;*/


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
		else if (m.startsWith("ConsoleResults:")){
			m = m.replaceFirst("ConsoleResults:", "",0);
			outputMsg(m, false);
		}

	});

	new TerminalFilesystem().run();

	setCodeMirror();

	reactClient.setClientConfiguration();
	
	render(navbar({}, []), querySelector('#navbar'));
	render(hud({'chat_socket': chat}, []), querySelector('#hud'));
	render(filebrowser({}, []), querySelector('#filebrowser'));
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

List vocab = [];
List baseVocab = [
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

/*void submitConsole(Event e){
	//e.preventDefault(); // Don't do the default submit.
	String cmdArgs = consoleInput.toString();
	ws.send("Submit:" + cmdArgs);
	print(cmdArgs);
}*/

outputMsg(String msg, bool clearConsole) {
	Position p = editor.getDoc().getCursor();
	if(clearConsole){
		editor.getDoc().setValue("");
	}
	editor.getDoc().setValue("$msg");
	editor.getDoc().setCursor(p);

	List<String> words = msg.split(" ");
	vocab.clear();
	vocab = baseVocab;
	vocab.addAll(words);
}

class Terminal{
  String cmdLineContainer;
  String outputContainer;
  String cmdLineInput;
  OutputElement output;
  InputElement input;
  DivElement cmdLine;
  List<String> history = [];
  int historyPosition = 0;
  Map<String, Function> cmds;
  HtmlEscape sanitizer = new HtmlEscape();
	WebSocket console_ws;

  Terminal(this.cmdLineContainer, this.outputContainer, this.cmdLineInput) {
    cmdLine = document.querySelector(cmdLineContainer);
    output = document.querySelector(outputContainer);
    input = document.querySelector(cmdLineInput);

    // Always force text cursor to end of input line.
    window.onClick.listen((event) => cmdLine.focus());

    // Trick: Always force text cursor to end of input line.
    cmdLine.onClick.listen((event) => input.value = input.value);

    // Handle up/down key presses for shell history and enter for new command.
    cmdLine.onKeyDown.listen(historyHandler);
    cmdLine.onKeyDown.listen(processNewCommand);

		//Initializing websocket
		console_ws = new WebSocket('ws://localhost:8081/console');

		console_ws.onMessage.listen((event){
			String m = event.data;
 			if (m.startsWith("ConsoleResults:")){
				m = m.replaceFirst("ConsoleResults:", "",0);
				//outputMsg(m, false);
				List<String> list_results = m.split(' ');
				for(int i = 0; i<list_results.length; i++){
					writeOutput(list_results[i]);

				}
			}
			else if (m.startsWith("ConsoleErrorResults:")){
				m = m.replaceFirst("ConsoleErrorResults:", "",0);
				//outputMsg(m, false);
				writeOutput(m);
			}

			else {
				writeOutput(JSON.decode(m));
			}

		});

  }

  void historyHandler(KeyboardEvent event) {
		print("History hit");
    var histtemp = "";
    int upArrowKey = 38;
    int downArrowKey = 40;

    /* keyCode == up-arrow || keyCode == down-arrow */
    if (event.keyCode == upArrowKey || event.keyCode == downArrowKey) {
      event.preventDefault();

      // Up or down
      if (historyPosition < history.length) {
        history[historyPosition] = input.value;
      } else {
        histtemp = input.value;
      }
    }

    if (event.keyCode == upArrowKey) { // Up-arrow keyCode
      historyPosition--;
      if (historyPosition < 0) {
        historyPosition = 0;
      }
    } else if (event.keyCode == downArrowKey) { // Down-arrow keyCode
      historyPosition++;
      if (historyPosition >= history.length) {
        historyPosition = history.length - 1;
      }
    }

    /* keyCode == up-arrow || keyCode == down-arrow */
    if (event.keyCode == upArrowKey || event.keyCode == downArrowKey) {
      // Up or down
      input.value = history[historyPosition] != null ? history[historyPosition]  : histtemp;
    }
  }

  void processNewCommand(KeyboardEvent event) {
		print("ProcessNewCommand hit");
    int enterKey = 13;
    int tabKey = 9;

    if (event.keyCode == tabKey) {
      event.preventDefault();
    } else if (event.keyCode == enterKey) {

      if (!input.value.isEmpty) {
        history.add(input.value);
        historyPosition = history.length;
      }

      // Move the line to output and remove id's.
      DivElement line = input.parent.parent.clone(true);
      line.attributes.remove('id');
      line.classes.add('line');
      InputElement cmdInput = line.querySelector(cmdLineInput);
      cmdInput.attributes.remove('id');
      cmdInput.autofocus = false;
      cmdInput.readOnly = true;
      output.children.add(line);
      String cmdline = input.value;
      input.value = ""; // clear input

      // Parse out command, args, and trim off whitespace.
      List<String> args;
      if (!cmdline.isEmpty) {
        cmdline.trim();
        args = sanitizer.convert(cmdline).split(' ');
      }
      runarbitrarycommands(args);
      window.scrollTo(0, window.innerHeight);
    }
  }

  void runarbitrarycommands(List<String> cmdArgs){
		print("Command function called");
    if(cmdArgs == null)
      print("Null or no string input from terminal");
		else {
				console_ws.send(JSON.encode(cmdArgs));
				print(cmdArgs);
				//writeOutput(cmdArgs);
    }
  }

  void writeOutput(String h) {
    output.insertAdjacentHtml('beforeEnd', h);
  }

}

class TerminalFilesystem {
  Terminal term;

  void run() {
    term = new Terminal('#input-line', '#output', '#cmdline');
  }
}
