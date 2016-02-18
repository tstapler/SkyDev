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

class bc {
  double first = 0.00;
  double second = 0.00;
  double result = 0.00;
  bc(double first, double second){
    this.first = first;
    this.second = second;
  }
  double get get_result {
    return result;
  }
  double get get_first {
    return first;
  }
  double get get_second {
    return second;
  }
  double addition(){
      result = first + second;
  }
  double multiplication(){
    result = first * second;
  }
  double subtraction(){
      result = first - second;
  }
  double division(){
      result = first / second;
  }
}