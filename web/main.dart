// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. 
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart';

InputElement toDoInput;
UListElement toDoList;
ButtonElement deleteAll;
ButtonElement reAddAll;
ButtonElement sortByLengthAll;
List<LIElement> list;

void main() {
  //  hook into html elements
  toDoInput = querySelector('#to-do-input');
  toDoList = querySelector('#to-do-list');
  deleteAll = querySelector("#delete-all");
  reAddAll = querySelector("#reAdd-all");
  sortByLengthAll = querySelector("#sortByLength-all");
  list = [];

  //  set listeners for each button in the html
  toDoInput.onChange.listen(addToDoItem);
  deleteAll.onClick.listen(deleteAllChildren);
  reAddAll.onClick.listen(reAddAllChildren);
  sortByLengthAll.onClick.listen(sortByLengthAllChildren);
}

void sortByLengthAllChildren(Event e){
  //  since dart does copy by reference and not copy by shallow clone, copy the list of elements currently in the to-do list 
  List<LIElement> s = [];
  for(int i = 0; i < toDoList.children.length; i++){
    s.add(toDoList.children[i]);
  }

  s.sort((x, y) => x.text.length.compareTo(y.text.length));

  //  clear the list currently shown to user
  //  then load the sorted list
  deleteAllChildren(e);
  for(int i = 0; i < s.length; i++){
    addE(s[i].text);  
  }
}

void addE(String s){
  var newToDo = new LIElement();
  newToDo.text = s;
  newToDo.onClick.listen((e){
    newToDo.remove();
    list.remove(newToDo);
  });
  toDoInput.value = '';
  toDoList.children.add(newToDo);
  list.add(newToDo);
}

void deleteAllChildren(Event e){
  toDoList.children.clear();
}

void reAddAllChildren(Event e){
  for(int i=0; i<list.length; i++){
    addE(list[i].text);
  }
}

void addToDoItem(Event e) {
  addE(toDoInput.value);
}
