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
  


  if(toDoList.children.length > 5){
  

    List<String> list = new List<String>();
    var n = new LIElement();
    n.text = "test1";
    toDoList.children.add(n);
    int x = toDoList.children.length;
    n = new LIElement();
    n.text = "test2";
    toDoList.children.add(n);
    for(int i=0; i<x; i++){
      n = new LIElement();
      n.text = "test3";
      toDoList.children.add(n);      
    }
    
    for(int i=0; i<list.length; i++){
      var newToDo = new LIElement();
      newToDo.text = list[i];
      toDoList.children.add(newToDo);
    }
  }
}
