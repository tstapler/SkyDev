import 'dart:io';


Map<String, Function> cmds;

void runls(){
  Process.run('ls', ['-l']).then((ProcessResult results) {
    print(results.stdout);
  });
}

void runcat(String filename){
  // test case filename = 'pubspec.yaml';
  if(filename == null){
    print("usage: cat filename");
  }
  else{
    Process.run('cat', ['$filename']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
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

void rungitversion(){
  Process.run('git', ['version']).then((ProcessResult results) {
    print(results.stdout);
  });
}

void runmkdir(String dirName){
  if(dirName == null)
    print("There is no new directory");
  else{
    Process.run('mkdir', ['$dirName']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
}

void runcd(String dir){
  if(dir == null){
    print("There is no directory to go to.");
  }
  else if(dir == '..'){
    Process.run('mkdir', ['..']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
  else{
    Process.run('mkdir', ['$dir']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
}

void runmv(String target, String dir){
  if(target == null || dir == null){
    print("usage: my source target\n\tmy source directory");
  }
  else{
    Process.run('mv', ['$target','$dir']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
}

void runrmdir(String dir){
  if(dir == null){
    print("useage: rmdir directory/");
  }
  else{
    Process.run('rmdir', ['$dir']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
}

void runrm(String filename){
  if(filename == null){
    print("useage: mkdir directory/");
  }
  else{
    Process.run('rm', ['$filename']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
}

void runcp(String target, String dir){
  if(target == null || dir == null){
    print("usage: cp source target\n\tcp source directory/");
  }
  else{
    Process.run('cp', ['$target','$dir']).then((ProcessResult results) {
      print(results.stdout);
    });
  }
}

void helpCommand(String cmd, List<String> args) {
    StringBuffer sb = new StringBuffer();
    sb.write('<div class="ls-files">');
    cmds.keys.forEach((key) => sb.write('$key<br>'));
    sb.write('</div>');
    sb.write('<p>Add files by dragging them from your desktop.</p>');
    //writeOutput(sb.toString());
}

main() {
    runls();
}
