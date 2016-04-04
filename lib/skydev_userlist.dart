import 'package:react/react.dart';

final user = registerComponent(() => new SkydevUser());

class SkydevUser extends Component {
	render()  {
		if(props["online"]){
			return	li({"className": "list-group-item"},
					[
					props["username"],"  ",  span({'className': "glyphicon glyphicon-heart"}, [])
					]);

		}	
		else{
			return li({"className": "list-group-item"},
					[
					props["username"],"  ",  span({'className': "glyphicon glyphicon-heart-empty"}, [])
						]);
					}
		}
	}

	final user_list = registerComponent(() => new SkydevUserList());

	class SkydevUserList extends Component {
		get friends => props["users"];

		render() => ul(
				{"className": "list-group"},
				props['users'].keys.map((user_name) => user({
					'username': props["users"][user_name]["username"],
				"online": props["users"][user_name]["online"]
				}, [])));
	}
