// Copyright (c) 2016, Chris Stapler. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';

OutputElement login;
ButtonElement submitButton;
Map data;
InputElement uName;
InputElement pWord;

void main() {
    submitButton = querySelector('#Button');
    login = querySelector('#Login-info');
    uName = querySelector('#username');
    pWord = querySelector('#password');
    uName.onKeyUp.listen(addToData);
    pWord.onKeyUp.listen(addToData);

    submitButton.onClick.listen(makeRequest);

    addToData(null);
}

void addToData(Event e){
  String userName = uName.value;
  String passWord = pWord.value;
  data = {'username' : userName, 'password' : passWord};
}

Future makeRequest(Event e) async{
  var path = 'http://127.0.0.1:8080';
  try {
    processRequest(await HttpRequest.postFormData(path, data));
  }
  catch(e){
    print('Couldn\'t open $path');
    errorHandle(e);
  }
}
void processRequest(HttpRequest resp){
  if(resp.status == 200){
    
  }
  else{
    login.children.add(new HeadingElement.h3()..text = 'Request failed, status=${resp.status}');
  }
}

void errorHandle(Object e){
  login.children.add(new HeadingElement.h3()..text = 'Http Request failed.');
}
