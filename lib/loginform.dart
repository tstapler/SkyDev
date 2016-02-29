@HtmlImport('loginform.html')
library G39_SkyDev.lib.loginform;

import 'dart:html';
import 'dart:convert';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;

@PolymerRegister('login-form', extendsTag: 'form')
class LoginFormComponent extends FormElement with
    PolymerMixin, PolymerBase, JsProxy {

  LoginData _myData = new LoginData();

  // This "@Property(observer:submitForm" declaration on myData
  // means that the submitForm function will be called when
  // "myData" changes.
  // See "Property Change Observers"
  // https://github.com/dart-lang/polymer-dart/wiki/properties#property-change-observers
  // Calling "notifyPath" informs the system that a value has changed.
  // See "Path change notification"
  // https://github.com/dart-lang/polymer-dart/wiki/data-binding-syntax#path-change-notification
  @Property(observer: 'submitForm')
  LoginData get myData => _myData;
  void set myData(LoginData newValue) {
    _myData = newValue;
    notifyPath('myData', _myData);
  }

  LoginFormComponent.created() : super.created() {
    polymerCreated();
  }

  @Property(observer: 'submitForm')
  String serverResponse = '';

  HttpRequest request;

  @reflectable
  void submitForm(var e, [_]) {
    if (e is Event) e.preventDefault(); // Don't do the default submit.

    request = new HttpRequest();

    request.onReadyStateChange.listen(onData);

    // POST the data to the server.
    var url = 'http://127.0.0.1:8081';
    request.open('POST', url);
    request.send(myData.jsonSerialize());
  }


  void onData(_) {
    if (request.readyState == HttpRequest.DONE &&
        request.status == 200) {
      // Data saved OK.
      serverResponse = 'Server Sez: ' + request.responseText;
      notifyPath('serverResponse', serverResponse);
    } else if (request.readyState == HttpRequest.DONE &&
        request.status == 0) {
      // Status is 0...most likely the server isn't running.
      serverResponse = 'No server';
      notifyPath('serverResponse', serverResponse);
    }
  }

  // See "Event listener setup"
  // https://github.com/dart-lang/polymer-dart/wiki/events#event-listener-setup
  @reflectable
  void resetForm(var e, [_]) {
    if (e is Event) e.preventDefault(); // Default behavior clears elements,
                        // but bound values don't follow
                        // so have to do this explicitly.

    myData.resetData();
    serverResponse = 'Data cleared.';
    notifyPath('serverResponse', serverResponse);
  }
}

// The Polymer Dart 0.16.0 version of slambook stored the data
// using a Map. It's more efficient, and more Darty, to use
// a class. When extending JsProxy, Polymer reads and writes
// directly to the Dart object; when modifying a Map
// value, Polymer copies the entire map to a new JS object.
class LoginData extends JsProxy {
  String userName = 'Enter pasword here';
  String password = 'Enter password here';


  String jsonSerialize() {
    var theData = {
      'userName': userName,
      'password': password,
    };

    return JSON.encode(theData);
  }

  void resetData() {
    userName = ' ';
    password = ' ';
  }
}
