import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';

void addCorsHeaders(HttpResponse res) {
  res.headers.add('Access-Control-Allow-Origin', '*');
  res.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.headers.add('Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept');
}

/// Return a hashmap representing a directory tree
dirContents(String dir) {
  var directory = new Directory(dir);
  var files = directory.listSync(recursive: false, followLinks: false);
  var tree = {};
  files.forEach((item) {
      if (item is Directory) {
        tree[basename(item.path)] = dirContents(item.path);
      } else {
        tree[basename(item.path)] = relative(item.path, from: Directory.current.path + "/files");
      }
  });

  return tree;
}
