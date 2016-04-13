import 'dart:convert';
import 'package:skydev/database.dart';

getUsernameFromSession(HttpRequest req) async {
	HttpResponse res = req.response;
	Cookie cookie;
	User user;
	try {
		cookie = req.cookies.singleWhere( (element) => element.name =="SessionID");
		user = await users.where((user) => user.sessionid == cookie.value).first();
		print(user.toString() + "is the current user");
		res.write(JSON.encode({"username": user.username}));
		}
	catch(e){
		print(e);
		res.write(JSON.encode(null));
	}
	res.close();
}
