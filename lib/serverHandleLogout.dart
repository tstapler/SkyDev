import 'dart:io';
import 'dart:async';
import 'package:skydev/database.dart';

Future handleLogout(HttpRequest req) async {
	HttpResponse res = req.response;

	Cookie cookie, session;
	try{
		print(req.cookies);
		cookie = req.cookies.singleWhere( (element) => element.name  == "SessionID");
		print(cookie);
	}
	catch(e){
		print(e);
		print("Cookie not found or multiple cookies attached");
		res.redirect(Uri.parse('login.html'));
		return;
	}
	var user;
	try{
			print("Cookie Value:" + cookie.value + "|");
	    user = await users.where((user) => user.username == cookie.value).first();
			print(user);
    }
  catch(e){
		print(e);
    print("Correct SessionID not found in database");
		res.redirect(Uri.parse('login.html'));
		return;
  }

	cookie.value = "";
	user.sessionid = "";
	res.headers.set('Set-Cookie', cookie);
	await users.save(user);
	res.redirect(Uri.parse('login.html'));
}
