// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. 
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

InputElement toDoInput;
UListElement toDoList;
ButtonElement deleteAll;

void main() {
  toDoInput = querySelector('#to-do-input');
  toDoList = querySelector('#to-do-list');
  toDoInput.onChange.listen(addToDoItem);
  toDoInput.onChange.listen(sortList);

  deleteAll = querySelector("#delete-all");
  deleteAll.onClick.listen(deleteAllChildren);
}

void deleteAllChildren(Event e){
  toDoList.children.clear();
}

void addToDoItem(Event e) {
  var newToDo = new LIElement();
  newToDo.text = toDoInput.value;
  newToDo.onClick.listen((e) => newToDo.remove());
  toDoInput.value = '';
  toDoList.children.add(newToDo);
}

void sortList(Event e){
  List<LIElement> list = toDoList.children;
  for(int i = 0; i < list.length; i++){
    list[i].text = "lol";
    toDoList.children.add(list[i]);
  }
  var newToDo = new LIElement();
  newToDo.text = "haha";
  newToDo.onClick.listen((e) => newToDo.remove());
  toDoList.children.add(newToDo);
}
