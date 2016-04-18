import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:skydev/database.dart';
import 'package:query_string/query_string.dart';
import 'package:skydev/utils.dart';

Cookie sessionCookie;

Future handleLogin(HttpRequest req) async {
	HttpResponse res = req.response;
	print('${req.method}: ${req.uri.path}');
	addCorsHeaders(res);
	var jsonString = await req.transform(UTF8.decoder).join();
	Map jsonData = QueryString.parse(jsonString);


	if(await verifyUser(jsonData)){
		res.headers.set('Set-Cookie', sessionCookie);
		res.write('Success');
		res.close();
	}
	else{
		res.write('Fail');
		res.close();
	}
}

Future verifyUser(Map formData) async{
	var uInput;
	var pInput;
  	var uData;
	uInput = formData['username'];
	pInput = formData['password'];
  try{
	    uData = await users.where((user) => user.username == uInput).first();
    }
    catch(e){
      print("Username not found");
      return false;
    }
	if(check_password(pInput, uData.password)){
		cookieMaker("SessionID", uInput);
		uData.sessionid = uInput;
		users.saveAll([uData]);
		print("Passwords matched");
		return true;
	}
	else{
		print("Incorrect Password");
		return false;
	}
}

void cookieMaker(var name, var value){
	sessionCookie = new Cookie(name, value);
	var expiress = new DateTime.now();
	expiress = expiress.add(new Duration(minutes: 10));
	sessionCookie.expires = expiress;
}
