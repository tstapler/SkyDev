import 'package:react/react.dart';

final user = registerComponent(() => new SkydevUser());

class SkydevUser extends Component {
	render() => li({"className": "list-group-item"}, props["username"]);
}

final user_list = registerComponent(() => new SkydevUserList());

class SkydevUserList extends Component {
	get friends => props["users"];

	render() => ul({"className": "list-group"}, props['users'].keys.map(
	(user_name) => user({'username': props["users"][user_name]["username"]}, []))
			);

}
