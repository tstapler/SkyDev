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
ImageElement profilePicture;
InputElement fileUploadSelect;
Map data;
String verifyPass;
String userNameFromRequest;
String emailFromRequest;
String pictureLocationFromRequest;

void main() {
	reactClient.setClientConfiguration();
	render(navbar({}), querySelector('#navbar'));

	requestUsername = querySelector('#requestUsername');
	requestEmail = querySelector('#requestEmail');
	profilePicture = querySelector('#profilePic');
	fileUploadSelect = querySelector('#pictureUpload');
  uName = querySelector('#newUsername');
  oldpWord = querySelector('#oldPassword');
  pWord = querySelector('#newPassword');
  vpWord = querySelector('#vPassword');
  eMail = querySelector('#newEmail');
  error = querySelector('#error');
  submitButton = querySelector('#Button');

	window.onLoad.listen(requestUsernameEvent);
	window.onLoad.listen(requestEmailEvent);
	window.onLoad.listen(requestProfilePicture);

	fileUploadSelect.onChange.listen((e) {
    final files = fileUploadSelect.files;
    if (files.length == 1) {
      final file = files[0];
      final reader = new FileReader();
      reader.onLoad.listen((e) {
        uploadPictureData(reader.result);
      });
      reader.readAsDataUrl(file);
    }
  });

  uName.onKeyUp.listen(addToData);
  oldpWord.onKeyUp.listen(addToData);
  pWord.onKeyUp.listen(addToData);
  vpWord.onKeyUp.listen(addToData);
  eMail.onKeyUp.listen(addToData);
  submitButton.onClick.listen(makeRequest);
	addToData(null);
}
Future uploadPictureData(dynamic data) async{
	final req = new HttpRequest();
	req.onReadyStateChange.listen((e) {
		if(req.readyState == HttpRequest.DONE &&
				(req.status == 201 || req.status == 0)) {
					window.alert("upload complete");
					requestProfilePicture(e);
		}
	});
	print("request should be sent now");
	req.open("POST", "http://127.0.0.1:8081/uploadPic");
  await req.send(data);
}
void addToData(Event e){
  String newUserName = uName.value;
  String passWord = oldpWord.value;
  String newEmail = eMail.value;
  String newPassWord = pWord.value;
  verifyPass = vpWord.value;
  data = {'newUsername' : newUserName, 'newPassword': newPassWord, 'password' : passWord, 'newEmail' : newEmail};
}
Future requestProfilePicture(Event e) async {
	var pathPicture = 'http://127.0.0.1:8081/api/profilePic';
	await HttpRequest.getString(pathPicture).then((string) => pictureLocationFromRequest = string);
	profilePicture.src = pictureLocationFromRequest;
	profilePicture.width = 400;
	profilePicture.height = 400;
	profilePicture.className = "img-rounded";
}
Future requestEmailEvent(Event e) async {
	var pathEmail = 'http://127.0.0.1:8081/api/email';
	await HttpRequest.getString(pathEmail).then((string) => emailFromRequest = string);
	Map emailData = JSON.decode(emailFromRequest);
	requestEmail.children.clear();
	requestEmail.children.add(new ParagraphElement()..text = emailData['email']);
}

Future requestUsernameEvent(Event e) async {
	var pathUsername = 'http://127.0.0.1:8081/api/username';
	await HttpRequest.getString(pathUsername).then((string) => userNameFromRequest = string);
	Map userNameData = JSON.decode(userNameFromRequest);
	requestUsername.children.clear();
	requestUsername.children.add(new ParagraphElement()..text = userNameData['username']);

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
