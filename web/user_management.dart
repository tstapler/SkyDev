import 'dart:html';
import 'dart:async';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:skydev/skydev_navbar.dart';

ButtonElement submitButton;
InputElement uName;
InputElement pWord;
InputElement eMail;
InputElement vpWord;
OutputElement error;
Map data;
String verifyPass;
void main(){
	reactClient.setClientConfiguration();
	render(navbar({}), querySelector('#navbar'));

  uName = querySelector('#newUsername');
  pWord = querySelector('#newPassword');
  vpWord = querySelector('#vPassword');
  eMail = querySelector('#Newemail');

  error = querySelector('#error');

}
void addToData(Event e){
  String userName = uName.value;
  String passWord = pWord.value;
  String email = eMail.value;
  verifyPass = vpWord.value;
  data = {'username' : userName, 'password' : passWord, 'email' : email};
}

Future makeRequest(Event e) async{
  if (verifyPass.compareTo(data['password']) == 0){
    var path = 'http://127.0.0.1:8081/profile';
    try {
      processRequest(await HttpRequest.postFormData(path, data));
    }
    catch(e){
      print('Couldn\'t open $path');
      error.children.clear();
      error.children.add(new HeadingElement.h3()..text = 'Update of info attempt failed');
    }
  }else{
    error.children.clear();
    error.children.add(new HeadingElement.h3()..text = 'Passwords do not match');
  }
}

Future processRequest(HttpRequest res) async{
  if (res.responseText.compareTo('Success') == 0){
      var url = 'http://127.0.0.1:8081/login';
      window.location.replace(url);
  }
  else{
    error.children.clear();
    error.children.add(new HeadingElement.h3()..text = 'Update of info failed on Server');
  }
}
