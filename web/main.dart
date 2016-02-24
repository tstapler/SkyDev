// Copyright (c) 2016, Chris Stapler. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

UListElement emailList;
InputElement textBox;
InputElement groupTBox;
ButtonElement groupButton;
ButtonElement deleteAll;
ButtonElement b1;
ButtonElement b2;
ButtonElement b3;
ButtonElement b4;
ButtonElement b5;
ButtonElement b6;
ButtonElement b7;
ButtonElement b8;
ButtonElement b9;
OutputElement result_1;
OutputElement result_2;
OutputElement result_3;
OutputElement result_4;
void main() {
  int n = 1;
  textBox = querySelector('#input_field');
  emailList = querySelector('#email_list');
  groupTBox = querySelector('#group_Name');
  groupButton = querySelector('#group_button');
  groupButton
    ..text = 'Confirm Group Name'
    ..classes.add('important')
    ..onClick.listen((e) => window.alert('Confirmed! Waiting approval'));
  textBox.onChange.listen(addEmail);
  deleteAll = querySelector('#delete-all');
  deleteAll.onClick.listen((e) => emailList.children.clear());
  b1= querySelector('#one');
  b2= querySelector('#two');
  b3= querySelector('#three');
  b4= querySelector('#four');
  b5= querySelector('#five');
  b6= querySelector('#six');
  b7= querySelector('#seven');
  b8= querySelector('#eight');
  b9= querySelector('#nine');
  basiccalc bc = new basiccalc(1,1);
  if(n / 2 != 0){
    n++;
    b1.onClick.listen((e) => bc.setfirst(1));
    b2.onClick.listen((e) => bc.setfirst(2));
    b3.onClick.listen((e) => bc.setfirst(3));
    b4.onClick.listen((e) => bc.setfirst(4));
    b5.onClick.listen((e) => bc.setfirst(5));
    b6.onClick.listen((e) => bc.setfirst(6));
    b7.onClick.listen((e) => bc.setfirst(7));
    b8.onClick.listen((e) => bc.setfirst(8));
    b9.onClick.listen((e) => bc.setfirst(9));
  }
  else{
    n++;
    b1.onClick.listen((e) => bc.setsecond(1));
    b2.onClick.listen((e) => bc.setsecond(2));
    b3.onClick.listen((e) => bc.setsecond(3));
    b4.onClick.listen((e) => bc.setsecond(4));
    b5.onClick.listen((e) => bc.setsecond(5));
    b6.onClick.listen((e) => bc.setsecond(6));
    b7.onClick.listen((e) => bc.setsecond(7));
    b8.onClick.listen((e) => bc.setsecond(8));
    b9.onClick.listen((e) => bc.setsecond(9));
  }
  result_1 = querySelector('#results1');
  result_2 = querySelector('#results2');
  result_3 = querySelector('#results3');
  result_4 = querySelector('#results4');
  bc.multiplication();
  result_1.text = bc.get_first.toString() + ' * ' + bc.get_second.toString() + ' = ' + bc.get_result.toString();
  bc.subtraction();
  result_2.text = bc.get_first.toString() + ' / ' + bc.get_second.toString() + ' = ' + bc.get_result.toString();
  bc.subtraction();
  result_3.text = bc.get_first.toString() + ' - ' + bc.get_second.toString() + ' = ' + bc.get_result.toString();
  bc.addition();
  result_4.text = bc.get_first.toString() + ' + ' + bc.get_second.toString() + ' = ' + bc.get_result.toString();
}
void addEmail(Event e){
  var nextEmail = new LIElement();
  nextEmail.text = textBox.value;
  nextEmail.onClick.listen((e) => nextEmail.remove());
  textBox.value = '';
  emailList.children.add(nextEmail);
}

class basiccalc {
  num first = 0;
  num second = 0;
  num result = 0;
  basiccalc(num first, num second){
    this.first = first;
    this.second = second;
  }
  num get get_result {
    return result;
  }
  num get get_first {
    return first;
  }
  num get get_second {
    return second;
  }
  void setsecond(num second){
    this.second = second;
  }
  void setfirst(num first){
    this.first = first;
  }
  num addition(){
       return result = first + second;
  }
  num multiplication(){
    return result = first * second;
  }
  num subtraction(){
      return result = first - second;
  }
  num division(){
      return result = first / second;
  }
}
