import 'dart:html';
import 'dart:async';

ButtonElement submitButton;
InputElement uName;
InputElement pWord;
InputElement eMail;
OutputElement error;
Map data;
void main(){
  uName = querySelector('#username');
  pWord = querySelector('#password');
  eMail = querySelector('#email');
  submitButton = querySelector('#Button');
  error = querySelector('#error');
  uName.onKeyUp.listen(addToData);
  pWord.onKeyUp.listen(addToData);
  eMail.onKeyUp.listen(addToData);

  submitButton.onClick.listen(makeRequest);
  addToData(null);

}
void addToData(Event e){
  String userName = uName.value;
  String passWord = pWord.value;
  String email = eMail.value;
  data = {'username' : userName, 'password' : passWord, 'email' : email};
}

Future makeRequest(Event e) async{
  var path = 'http://127.0.0.1:8081/register';
  try {
    processRequest(await HttpRequest.postFormData(path, data));
  }
  catch(e){
    print('Couldn\'t open $path');
    error.children.clear();
    error.children.add(new HeadingElement.h3()..text = 'Registration attempt failed');
  }
}

Future processRequest(HttpRequest res) async{
  if (res.responseText.compareTo('Success') == 0){
      var url = 'http://127.0.0.1:8081/index.html';
      window.location.replace(url);
  }
  else{
    error.children.clear();
    error.children.add(new HeadingElement.h3()..text = 'Registration failed on Server');
  }
}
