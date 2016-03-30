
import 'dart:convert' show HtmlEscape;
import 'dart:convert';
import 'dart:html';
import 'dart:io';

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
  }

  void historyHandler(KeyboardEvent event) {
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
      String cmd = "";
      if (!cmdline.isEmpty) {
        cmdline.trim();
        args = sanitizer.convert(cmdline).split(' ');
        cmd = args[0];
        args.removeRange(0, 1);
      }
      if(args == null || args.length == 0)
        runarbitrarycommands(cmd);
      else
        runarbitrarycommands(cmd, args);
      // Function look up
      // if (cmds[cmd] is Function) {
      //   cmds[cmd](cmd, args);
      //   runarbitrarycommands(cmd, args);
      // } else {
      //   writeOutput('${sanitizer.convert(cmd)}: command not found');
      // }

      window.scrollTo(0, window.innerHeight);
    }
  }

  void runarbitrarycommands(String cmd, [List<String> listInput]){
    if(cmd == null)
      print("Null or no string input from terminal");

      else if(listInput == null){
        try{
        Process.run(cmd, []).then((ProcessResult result) {
            writeOutput('${sanitizer.convert(result.stdout)}');
            //process.exitCode.then(print);
          //print(result.stderr); test
        });}
        catch(e){
          print(e);
        }
      }

      else{
        Process.run(cmd, listInput).then((ProcessResult result) {
          print(result.stdout);
          writeOutput('${sanitizer.convert(result.stdout)}');
          //print(result.stderr); test
        });
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

void main() {
  new TerminalFilesystem().run();
  //Terminal term = new Terminal('#input-line', '#output', '#cmdline');
}

/*void runarbitrarycommands(List<String> listInput){
  if(listInput == null || listInput.length == 0)
    print("Null or no string input from terminal");

    else if(listInput.length == 1){
      Process.run(listInput[0], []).then((ProcessResult results){
        print(results.stdout);
      });
    }

    else{
      Process.run(listInput[0], listInput.sublist(1, listInput.length)).then((ProcessResult result) {
        print(result.stdout);
        //print(result.stderr); test
      });
    }
}*/

/*void main(List<String> arguments){
    stdout.writeln('Type Command:');
    String input = stdin.readLineSync();
    List<String> inputArguments = input.split(" ");
    runarbitrarycommands(inputArguments);
}*/
