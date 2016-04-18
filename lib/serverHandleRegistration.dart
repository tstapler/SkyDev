import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:skydev/database.dart';
import 'package:query_string/query_string.dart';
import 'package:skydev/utils.dart';

Future handleRegister(HttpRequest req) async {
  HttpResponse res = req.response;
  print('${req.method}: ${req.uri.path}');
  addCorsHeaders(res);
  var queryString = await req.transform(UTF8.decoder).join();
  Map queryData = QueryString.parse(queryString);
  await createUser(queryData);
  res.write('Success');
  res.close();
}

Future createUser(Map formData) async{
	var models = [new User.create(formData['username'],
									formData['email'],
										hash_password(formData['password']))];
  await users.saveAll(models);
}
