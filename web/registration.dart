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
  uName = querySelector('#username');
  pWord = querySelector('#password');
  vpWord = querySelector('#vPassword');
  eMail = querySelector('#email');
  submitButton = querySelector('#Button');
  error = querySelector('#error');
  uName.onKeyUp.listen(addToData);
  pWord.onKeyUp.listen(addToData);
  eMail.onKeyUp.listen(addToData);
  vpWord.onKeyUp.listen(addToData);
  submitButton.onClick.listen(makeRequest);
  addToData(null);

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
    var path = 'http://127.0.0.1:8081/register';
    try {
      processRequest(await HttpRequest.postFormData(path, data));
    }
    catch(e){
      print('Couldn\'t open $path');
      error.children.clear();
      error.children.add(new HeadingElement.h3()..text = 'Registration attempt failed');
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
    error.children.add(new HeadingElement.h3()..text = 'Registration failed on Server');
  }
}
