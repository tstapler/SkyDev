import 'dart:html';
import 'dart:async';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';
import 'package:skydev/skydev_navbar.dart';

ButtonElement submitButton;
InputElement uName;
InputElement pWord;
InputElement oldpWord;
InputElement eMail;
InputElement vpWord;
OutputElement error;
Map data;
String verifyPass;

void main() {
	reactClient.setClientConfiguration();
	render(navbar({}), querySelector('#navbar'));


  uName = querySelector('#newUsername');
  oldpWord = querySelector('#oldPassword');
  pWord = querySelector('#newPassword');
  vpWord = querySelector('#vPassword');
  eMail = querySelector('#newEmail');
  error = querySelector('#error');
  submitButton = querySelector('#Button');

  uName.onKeyUp.listen(addToData);
  oldpWord.onKeyUp.listen(addToData);
  pWord.onKeyUp.listen(addToData);
  vpWord.onKeyUp.listen(addToData);
  eMail.onKeyUp.listen(addToData);
  submitButton.onClick.listen(makeRequest);
	addToData(null);
}
void addToData(Event e){
  String newUserName = uName.value;
  String passWord = oldpWord.value;
  String newEmail = eMail.value;
  String newPassWord = pWord.value;
  verifyPass = vpWord.value;
  data = {'newUsername' : newUserName, 'newPassword': newPassWord, 'password' : passWord, 'newEmail' : newEmail};
}

Future makeRequest(Event e) async{
  //if (verifyPass.compareTo(data['password']) == 0 || data['password'].toString().isEmpty || data['newPassword'].toString().isEmpty || true){
    var path = 'http://127.0.0.1:8081/profile';
    try {
      processRequest(await HttpRequest.postFormData(path, data));
    }
    catch(e){
      print('Couldn\'t open $path');
      error.children.clear();
      error.children.add(new HeadingElement.h3()..text = 'Update of info attempt failed');
    }
//  }else{
  //  error.children.clear();
  //  error.children.add(new HeadingElement.h3()..text = 'Passwords do not match');
//  }
}

Future processRequest(HttpRequest res) async{
  if (res.responseText.compareTo('Success') == 0){
      var url = 'http://127.0.0.1:8081/index.html';
      window.location.replace(url);
  }
  else{
    error.children.clear();
    error.children.add(new HeadingElement.h3()..text = 'Update of info failed on Server');
  }
}
