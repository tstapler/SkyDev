// Copyright (c) 2016, Chris Stapler. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

UListElement emailList;
InputElement textBox;
void main() {
  querySelector('#heading1').text = 'Group Page!!!';
  textBox = querySelector('#input_field');
  emailList = querySelector('#email_list');
  textBox.onChange.listen(addEmail);
}
void addEmail(Event e){
  var nextEmail = new LIElement();
  nextEmail.text = textBox.value;
  textBox.value = '';
  emailList.children.add(nextEmail);
}
