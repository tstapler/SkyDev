// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math' show Random;
import 'dart:convert' show JSON;
import 'dart:async' show Future;

SpanElement badgeNameElement;

ButtonElement genButton;

void main() async{
  InputElement inputField = querySelector('#inputName');
  inputField.onInput.listen(updateBadge);
  querySelector('#inputName').onInput.listen(updateBadge);
  genButton = querySelector('#generateButton');
  genButton.onClick.listen(generateBadge);
  badgeNameElement = querySelector('#badgeName');

  try {
    await PirateName.readyThePirates();
    //on success
    inputField.disabled = false; //enable
    genButton.disabled = false; //enable
  } catch (arrr) {
    print('Error initializing pirate names: $arrr');
    badgeNameElement.text = 'Arrr! No names.';
  }
}

void updateBadge(Event e) {
  String inputName = (e.target as InputElement).value;

  setBadgeName(new PirateName(firstName: inputName));
  //setBadgeName(inputName);
  if (inputName.trim().isEmpty) {
    genButton..disabled = false
      ..text = 'Aye! Gimme a name!';
  } else {
    genButton..disabled = true
      ..text = 'Arrr! Write yer name!';
  }
}

void setBadgeName(PirateName newName) {
  querySelector('#badgeName').text = newName.pirateName;
}

void generateBadge(Event e) {
  setBadgeName(new PirateName());
}

class PirateName {
  static final Random indexGen = new Random();

  static List<String> names = [];
  static List<String> appellations = [];

  String _firstName;
  String _appellation;

  PirateName({String firstName, String appellation}) {
    if (firstName == null) {
      _firstName = names[indexGen.nextInt(names.length)];
    } else {
      _firstName = firstName;
    }
    if (appellation == null) {
      _appellation =
      appellations[indexGen.nextInt(appellations.length)];
    } else {
      _appellation = appellation;
    }
  }

  String get pirateName =>
      _firstName.isEmpty ? '' : '$_firstName the $_appellation';

  String toString() => pirateName;

  String get jsonString =>
      JSON.encode({"f": _firstName, "a": _appellation});

  static Future readyThePirates() async {
    String path =
        'https://www.dartlang.org/codelabs/darrrt/files/piratenames.json';
    String jsonString = await HttpRequest.getString(path);
    _parsePirateNamesFromJSON(jsonString);
  }

  static _parsePirateNamesFromJSON(String jsonString) {
    Map pirateNames = JSON.decode(jsonString);
    names = pirateNames['names'];
    appellations = pirateNames['appellations'];
  }
}
