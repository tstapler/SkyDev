import 'package:react/react.dart';
import 'dart:html';

final user = registerComponent(() => new SkydevUser());

class SkydevUser extends Component {
	createChatWindow () {
		var e = new CustomEvent('addWindow', detail: props["username"]);
		window.dispatchEvent(e);
	}
	
	render()  {
		if(props["online"]){
			return	li({"className": "list-group-item", "onClick": (SyntheticMouseEvent e) => createChatWindow()},

					p({"className":"text-center"},  props["username"],"  ",  span({'className': "glyphicon glyphicon-heart"}, []))
					);

		}	
		else {
			return li({"className": "list-group-item", "onClick": (SyntheticMouseEvent e) => createChatWindow()},

					p({"className":"text-center"}, props["username"],"  ",  span({'className': "glyphicon glyphicon-heart-empty"}, []))
					);

		}
	}
}

final user_list = registerComponent(() => new SkydevUserList());

class SkydevUserList extends Component {
	get friends => props["users"];

	render() => ul(
			{"className": "list-group"},
			props['users'].map((friend) => user({
				'username': friend["username"],
			"online": friend["online"]
			}, [])));
}
