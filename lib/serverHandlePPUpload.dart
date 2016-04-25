import 'dart:io';
import 'dart:convert';
import 'package:skydev/database.dart';

handlePPUpload(HttpRequest req) async {
      print(req.toString());
      Cookie cookie;
      HttpResponse res = req.response;
      User user;
      try {
        cookie = req.cookies.singleWhere((element) => element.name == "SessionID");
        user = await users.where((user) => user.sessionid == cookie.value).first();
      } catch (e) {
        print(e);
        res.write(JSON.encode(null));
      }
      var reqString = await req.transform(UTF8.decoder).join();
      //print(reqString);
      //Image newImage = decodeImage(reqString.codeUnits);
      (new File("web/profileImages/${user.username}.txt")).createSync(recursive: true);
      File newFile = new File("web/profileImages/${user.username}.txt");
      newFile.writeAsStringSync(reqString);
      user.profilepicturename = "profileImages/${user.username}.txt";
      users.saveAll([user]);
      res.statusCode = HttpStatus.CREATED;
      res.contentLength = 0;
      res.close();
}
