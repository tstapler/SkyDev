import 'package:react/react.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';

final file = registerComponent(() => new File());
final folder = registerComponent(() => new Folder());
final filebrowser = registerComponent(() => new FileBrowser());

final files = "http://" + Uri.base.host + ":8081" + '/api/files';
final current_user = "http://" + Uri.base.host + ":8081" + '/api/username';

level_to_str(level_num) {
  var level_str = "";
  for (var i = 0; i < level_num * 4; i++) {
    level_str = level_str + "\t";
  }
  return level_str;
}

file_or_folder(name, item, level) {
  if (item is String) {
    return file({"name": name, "path": item, "level": level}, []);
  } else {
    return folder({"name": name, "files": item, "level": level}, []);
  }
}

class File extends Component {
  render() {
    var level_str = level_to_str(props["level"]);
    return li({"className": "list-group-item"}, [level_str + props["name"]]);
  }
}

class Folder extends Component {
	getInitialState() => {
		"children_hidden": false
	};

	toggleChildren() {
		state["children_hidden"] = !state["children_hidden"];
		setState({"children_hidden": state["children_hidden"]});
	}

  render() {
    var level = level_to_str(props["level"]);
		var children = div({});
		if(!state["children_hidden"]){
			 children = new List.from(props['files'].keys.map((item) {
			return file_or_folder(item, props['files'][item], props["level"] + 1);
				}));
		}

		return li({"className": "list-group-item"}, [
      label({"onClick": (SyntheticMouseEvent e) => toggleChildren()}, [level + props["name"]]),
      ul({"className": "list-group"}, [
				children
				])
    ]);
  }
}

class FileBrowser extends Component {
  getInitialState() {
    var init_state = {};
    init_state["files"] = {"Nothing Yet!": "/not/a/path"};
		init_state["current_user"] = "";
    return init_state;
  }

  componentDidMount(rootNode) async {
    ;
		var duration = new Duration(seconds: 5);
		await getCurrentUser();
		new Timer.periodic(duration, (Timer t) => getFiles(props["current_user"]));
  }

	/// Sets the current user to the result of the /api/username endpoint
	getCurrentUser() async{
    await HttpRequest.getString(current_user).then((String raw) {
      var name = JSON.decode(raw);
			if(name != null && name.containsKey("username")){
      state["current_user"] = name["username"];
			}
			else{
		  //For Debugging purposes (using pub serve
			state["current_user"] = "tstapler";
			}
      setState({"current_user": state["current_user"]});
    });
	}

  getFiles(String username) async {
    await HttpRequest.getString(files).then((String raw) {
      if (raw != null) {
        var tree = JSON.decode(raw);
        setState({"files": tree});
      }
    });
  }

  render() {
    return 
			div({"className": "column col-xs-2"}, 
			div({ "className" : "panel panel-default"
				}, [
					div({"className": "panel-heading text-center"}, "File Browser"),
					div({"className": "panel-body"},
						ul({"className": "list-group list-group-root well"}, [
						new List.from(state['files'].keys.map((item) {
							return file_or_folder(item, state['files'][item], 0);
						}))
					]))
				]));
  }
}
