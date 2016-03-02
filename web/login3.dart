// Copyright (c) 2016, Chris Stapler. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

InputElement userName;
InputElement passWord;
ButtonElement submitButton;
void main() {
    submitButton = querySelector('#submit-Button');
    submitButton.onClick.listen(makeRequest);
    userName = querySelector('POST-username');
    passWord = querySelector('POST-password');
}

void makeRequest(Event e){
  var path = 'http://127.0.0.1:8081';
  var httpRequest = new HttpRequest();
}
