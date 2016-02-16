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
ButtonElement sortAll;
List<LIElement> list;

void main() {
  toDoInput = querySelector('#to-do-input');
  toDoList = querySelector('#to-do-list');
  deleteAll = querySelector("#delete-all");
  reAddAll = querySelector("#reAdd-all");
  sortAll = querySelector("#sort-all");
  list = [];

  toDoInput.onChange.listen(addToDoItem);
  deleteAll.onClick.listen(deleteAllChildren);
  reAddAll.onClick.listen(reAddAllChildren);
  sortAll.onClick.listen(sortAllChildren);
}

void sortAllChildren(Event e){
  List<LIElement> s = [];
  for(int i = 0; i < toDoList.children.length; i++){
    s.add(toDoList.children[i]);
  }
  s.sort((x, y) => x.text.length.compareTo(y.text.length));

  deleteAllChildren(e);
  for(int i = 0; i < s.length; i++){
    toDoList.children.add(s[i]);  
  }
}

void addE(String s){
  var newToDo = new LIElement();
  newToDo.text = s;
  newToDo.onClick.listen((e){
    newToDo.remove();
  });
  toDoInput.value = '';
  toDoList.children.add(newToDo);
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
