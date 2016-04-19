import 'dart:html';
import 'dart:async';
import 'dart:convert';
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
OutputElement requestUsername;
OutputElement requestEmail;
Map data;
String verifyPass;
String userNameFromRequest;
String emailFromRequest;

void main() {
	reactClient.setClientConfiguration();
	render(navbar({}), querySelector('#navbar'));

	requestUsername = querySelector('#requestUsername');
	requestEmail = querySelector('#requestEmail');
  uName = querySelector('#newUsername');
  oldpWord = querySelector('#oldPassword');
  pWord = querySelector('#newPassword');
  vpWord = querySelector('#vPassword');
  eMail = querySelector('#newEmail');
  error = querySelector('#error');
  submitButton = querySelector('#Button');

	window.onLoad.listen(requestUsernameEvent);
	window.onLoad.listen(requestEmailEvent);

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
Future requestEmailEvent(Event e) async {
	var pathEmail = 'http://127.0.0.1:8081/api/email';
	await HttpRequest.getString(pathEmail).then((string) => emailFromRequest = string);
	Map emailData = JSON.decode(emailFromRequest);
	requestEmail.children.clear();
	requestEmail.children.add(new HeadingElement.h3()..text = emailData['email']);
}

Future requestUsernameEvent(Event e) async {
	var pathUsername = 'http://127.0.0.1:8081/api/username';
	await HttpRequest.getString(pathUsername).then((string) => userNameFromRequest = string);
	Map userNameData = JSON.decode(userNameFromRequest);
	requestUsername.children.clear();
	requestUsername.children.add(new HeadingElement.h3()..text = userNameData['username']);

}

Future makeRequest(Event e) async{
    var path = 'http://127.0.0.1:8081/profile';
    try {
      processRequest(await HttpRequest.postFormData(path, data));
    }
    catch(e){
      print('Couldn\'t open $path');
      error.children.clear();
      error.children.add(new HeadingElement.h3()..text = 'Update of info attempt failed');
    }
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
