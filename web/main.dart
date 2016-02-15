// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. 
// All rights reserved. Use of this source code
// is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

InputElement toDoInput;
UListElement toDoList;
ButtonElement deleteAll;
ButtonElement reAddAll;
List<LIElement> list;

void main() {
  toDoInput = querySelector('#to-do-input');
  toDoList = querySelector('#to-do-list');
  deleteAll = querySelector("#delete-all");
  reAddAll = querySelector("#reAdd-all");
  list = [];

  toDoInput.onChange.listen(addToDoItem);
  //toDoInput.onChange.listen(sortList);
  
  deleteAll.onClick.listen(deleteAllChildren);
  reAddAll.onClick.listen(reAddAllChildren);
}

void deleteAllChildren(Event e){
  toDoList.children.clear();
}

void reAddAllChildren(Event e){
  for(int i=0; i<list.length; i++){
    var newToDo = new LIElement();
    newToDo.text = list[i].text;
    newToDo.onClick.listen((e){ 
      list.remove(newToDo);
      newToDo.remove(); 
    });
    toDoList.children.add(newToDo);
  }
}

void addToDoItem(Event e) {
  var newToDo = new LIElement();
  newToDo.text = toDoInput.value;
  newToDo.onClick.listen((e){
    list.remove(newToDo);
    newToDo.remove();
  });
  toDoInput.value = '';
  toDoList.children.add(newToDo);
  list.add(newToDo);
}
