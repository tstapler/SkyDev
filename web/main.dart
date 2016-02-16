// Copyright (c) 2016, Chris Stapler. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

UListElement emailList;
InputElement textBox;
InputElement groupTBox;
ButtonElement groupButton;
void main() {
  textBox = querySelector('#input_field');
  emailList = querySelector('#email_list');
  groupTBox = querySelector('#group_Name');
  groupButton = querySelector('#group_button');
  groupButton
    ..text = 'Confirm Group Name'
    ..classes.add('important')
    ..onClick.listen((e) => window.alert('Confirmed! Waiting approval'));
  textBox.onChange.listen(addEmail);

}
void addEmail(Event e){
  var nextEmail = new LIElement();
  nextEmail.text = textBox.value;
  textBox.value = '';
  emailList.children.add(nextEmail);
}
