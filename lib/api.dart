import 'dart:io';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' show dirname;
import 'package:skydev/database.dart';
import 'package:skydev/utils.dart';

getUsernameFromSession(HttpRequest req) async {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  Cookie cookie;
  User user;
  try {
    cookie = req.cookies.singleWhere((element) => element.name == "SessionID");
    user = await users.where((user) => user.sessionid == cookie.value).first();
    print(user.toString() + "is the current user");
    res.write(JSON.encode({"username": user.username}));
  } catch (e) {
    print(e);
    res.write(JSON.encode(null));
  }
  res.close();
}

getOnlineUsers(HttpRequest req) async {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  var online = await users.all().toList();
  res.write(JSON.encode(online
      .map((user) => {
            "username": user.username,
            "online": user.sessionid != null && user.sessionid != ""
          })
      .toList()));
  res.close();
}

getEmailFromSession(HttpRequest req) async {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  Cookie cookie;
  User user;
  try {
    cookie = req.cookies.singleWhere((element) => element.name == "SessionID");
    user = await users.where((user) => user.sessionid == cookie.value).first();
    print(user.toString() + "is the current user");
    res.write(JSON.encode({"email": user.email}));
  } catch (e) {
    print(e);
    res.write(JSON.encode(null));
  }
  res.close();
}
getProfilePictureFromSession(HttpRequest req) async {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  Cookie cookie;
  User user;
  try {
    cookie = req.cookies.singleWhere((element) => element.name == "SessionID");
    user = await users.where((user) => user.sessionid == cookie.value).first();
    (new File("web/profileImages/${user.username}.txt")).createSync(recursive: true);
    File newFile = new File("web/profileImages/${user.username}.txt");
    res.statusCode = HttpStatus.CREATED;
    res.write(newFile.readAsStringSync());
  } catch (e) {
    print(e);
    res.write(JSON.encode(null));
  }
  res.close();
}
getFilesDirectory(HttpRequest req) async {
  HttpResponse res = req.response;
  addCorsHeaders(res);
  var files =
      await dirContents(Directory.current.path + "/files");
  res.write(JSON.encode(files));
  res.close();
}

getAllUsers(HttpRequest req) async {
  HttpResponse res = req.response;
  var user_list = await users.all().toList();
  res.write(JSON.encode(user_list));
  res.close();
}
