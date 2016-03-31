// Copyright (c) 2016, Chris Stapler. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:skydev/skydev_navbar.dart';

OutputElement login;
ButtonElement submitButton;
ButtonElement registerButton;
Map data;
InputElement uName;
InputElement pWord;

void main() {
		reactClient.setClientConfiguration();
		render(navbar({}), querySelector('#navbar'));

    submitButton = querySelector('#Button');
    login = querySelector('#Login-info');
    uName = querySelector('#username');
    pWord = querySelector('#password');
    registerButton = querySelector('#register');
    uName.onKeyUp.listen(addToData);
    pWord.onKeyUp.listen(addToData);
		submitButton.onClick.listen(makeRequestClick);
    submitButton.onKeyPress.listen(makeRequestEnter);
    registerButton.onClick.listen(toRegister);
    addToData(null);
}

Future toRegister(Event e) async{
  var url = 'http://127.0.0.1:8081/register';
  window.location.replace(url);
}

void addToData(Event e){
  String userName = uName.value;
  String passWord = pWord.value;
  data = {'username' : userName, 'password' : passWord};
}
Future makeRequestClick(Event e) async{
  	var path = 'http://127.0.0.1:8081/login';
  	try {
    	processRequest(await HttpRequest.postFormData(path, data));
  	}
  	catch(e){
    	print('Couldn\'t open $path');
    	errorHandle(e);
  	}
}

Future makeRequestEnter(KeyEvent e) async{
	if(e.keyCode == 13 ){
  	var path = 'http://127.0.0.1:8081/login';
  	try {
    	processRequest(await HttpRequest.postFormData(path, data));
  	}
  	catch(e){
    	print('Couldn\'t open $path');
    	errorHandle(e);
  	}
	}
}
Future processRequest(HttpRequest resp) async{
  if(resp.status == 200){
    var path = 'http://127.0.0.1:8081/index.html';
    String string = resp.responseText;
    print(string);
    if (string.compareTo('Success') == 0){
			window.location.replace(path);
    }
    else{
			login.children.clear();
      login.children.add(new HeadingElement.h3()..text = 'Login Attempt failed');
    }
  }
  else{
		login.children.clear();
    login.children.add(new HeadingElement.h3()..text = 'Request failed, status=${resp.status}');
  }
}

void errorHandle(Object e){
	login.children.clear();
  login.children.add(new HeadingElement.h3()..text = 'Http Request failed.');
}
