import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:skydev/database.dart';
import 'package:query_string/query_string.dart';




Future handleProfilePage(HttpRequest req) async {
	HttpResponse res = req.response;
	addCorsHeaders(res);
	if(req.method == 'POST'){
		Cookie cookie;
		try{
			cookie = req.cookies.singleWhere( (element) => element.name  == "SessionID");
		}
		catch(e){
			print("Cookie not found or multiple cookies attached");
			res.write('Fail');
			res.close();
			return;
		}
		var jsonString = await req.transform(UTF8.decoder).join();
		Map userData = QueryString.parse(jsonString);
		var model;
		try{
		    model = await users.where((user) => user.username == cookie.value).first();
		  }
	  catch(e){
	    print("Correct User not found in database");
			res.write('Fail');
			res.close();
			return;
		}
		if(check_password(userData['password'], model.password)){
			if(userData['newUsername'] != '' && userData['newUsername'] != null && model.username != userData['newUsername']){
				model.username = userData['newUsername'];
			}
			if(userData['newEmail'] != '' && userData['newEmail'] != null && model.email != userData['newEmail']){
				model.email = userData['newEmail'];
			}
			if(userData['newPassword'] != '' && userData['newPassword'] != null && userData['password'] != userData['newPassword']){
				model.password = hash_password(userData['newPassword']);
			}
		  await users.saveAll([model]);
			res.write('Success');
			res.close();
		}
		else{
			res.write('Fail');
			res.close();
		}
	}
}
void addCorsHeaders(HttpResponse res) {
	res.headers.add('Access-Control-Allow-Origin', '*');
	res.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
	res.headers.add('Access-Control-Allow-Headers',
	'Origin, X-Requested-With, Content-Type, Accept');
}
