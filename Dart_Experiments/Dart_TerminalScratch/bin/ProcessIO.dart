import 'dart:io';
//import 'dart:convert'; //library used in runcat

void runls(){
  Process.run('ls', ['-l']).then((ProcessResult results) {
    print(results.stdout);
  });
}

void runcat(){
  /*Process.run('cat', []).then((Process process) {
    process.stdout
        .transform(UTF8.decoder)
        .listen((data) { print(data); });
    process.stdin.writeln('Hello, world!');
    process.stdin.writeln('Hello, galaxy!');
    process.stdin.writeln('Hello, universe!');
  });*/
}

void runpwd(){
  Process.run('pwd', []).then((ProcessResult results) {
    print(results.stdout);
  });
}

void runwho(){
  Process.run('who', []).then((ProcessResult results) {
    print(results.stdout);
  });
}

void rundate(){
  Process.run('date', []).then((ProcessResult results) {
    print(results.stdout);
  });
}

void runhelp(){
  Process.run('help', []).then((ProcessResult results) {
    print(results.stdout);
  });
}

void runversion(){
  print("Terminal Version: 0.0.1");
}

main() {
  runversion();
}
