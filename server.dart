import 'dart:io';
import 'dart:convert';
import 'package:http_server/http_server.dart';
import 'package:skydev/database.dart';
import 'package:skydev/console.dart';
import 'package:skydev/chat.dart';
import 'package:skydev/editor.dart';
import 'package:skydev/serverHandleProfilePage.dart';
import 'package:skydev/serverHandleLogin.dart';
import 'package:skydev/serverHandleRegistration.dart';
import 'package:skydev/serverHandleLogout.dart';
import 'package:skydev/serverHandleCookies.dart';
import 'package:skydev/api.dart';

main() async {
	await db_gateway.connect();
	var requestServer = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8081);
	print('listening on http://${requestServer.address.host}:${requestServer.port}');
	await for (HttpRequest request in requestServer) {
		final String _buildPath = Platform.script.resolve('build/web/').toFilePath();
		final VirtualDirectory _clientDir = new VirtualDirectory(_buildPath);
		if (request.uri.path == '/') {
			if(await handleCookies(request)){
				request.response.redirect(Uri.parse('index.html'));
			}
			else{
				request.response.redirect(Uri.parse('login.html'));
			}
		} else if (request.uri.path == '/profile'){
			if(request.method == 'POST'){
				handleProfilePage(request);
			}
			else{
				if(await handleCookies(request)){
					request.response.redirect(Uri.parse('profilePage.html'));
				}
				else{
					request.response.redirect(Uri.parse('login.html'));
				}
			}
		} else if (request.uri.path == '/ws') {
				editorSocketSetup(request);
			} else if (request.uri.path == '/chat') {
				chatSocketSetup(request);
		  }else if (request.uri.path == '/console') {
				consoleSocketSetup(request);
	  }else if (request.uri.path == '/login') {
			if (request.method == 'POST') {
				handleLogin(request);
			} else {
				if(await handleCookies(request)){
					request.response.redirect(Uri.parse('index.html'));
				}
				else{
					request.response.redirect(Uri.parse('login.html'));
				}
			}
		}	else if (request.uri.path == '/logout'){
			handleLogout(request);

		}	else if (request.uri.path == '/register') {
			if (request.method == 'POST') {
				handleRegister(request);
			} else {
				request.response.redirect(Uri.parse('registration.html'));
			}
		} else if (request.uri.path == '/api/users') {
			getAllUsers(request);
		} else if (request.uri.path == '/api/online') {
			getOnlineUsers(request);
		} else if (request.uri.path == '/api/username') {
			getUsernameFromSession(request);
		} else if (request.uri.path == '/api/email') {
      getEmailFromSession(request);
		} else if (request.uri.path == '/api/files') {
			getFilesDirectory(request);
		} else {
			var fileUri = new Uri.file(_buildPath).resolve(request.uri.path.substring(1));
			_clientDir.serveFile(new File(fileUri.toFilePath()), request);
		}
	}
	await db_gateway.disconnect();
}

