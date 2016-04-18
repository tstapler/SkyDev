import 'dart:io';
import 'dart:async';
import 'package:skydev/database.dart';

Future handleCookies(HttpRequest req) async {
	Cookie chkCookie;
	try{
		chkCookie = req.cookies.singleWhere( (element) => element.name  == "SessionID");
	}
	catch(e){
		print("Cookie not found or multiple cookies attached");
		return false;
	}
	if (chkCookie == null){
		return false;
	}
	print("${chkCookie.value}");
	var databaseCookie;
	try{
	    databaseCookie = await users.where((user) => user.sessionid == chkCookie.value).first();
    }
    catch(e){
      print("Correct SessionID not found in database");
			return false;
    }
		var expiress = new DateTime.now();
		expiress = expiress.add(new Duration(minutes: 10));
		chkCookie.expires = expiress;
		req.response.headers.set('Set-Cookie', chkCookie);
	print("${databaseCookie.sessionid}");
	if (chkCookie.value != databaseCookie.sessionid){
		return false;
	}

	print("${req.uri.toString()}");
	if (req.uri.toString() == 'login/' || req.uri.toString() == 'login.html'){
		return true;
	}
	return true;
}
