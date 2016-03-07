import 'package:react/react.dart';
final navbar = registerComponent(() => new SkydevNav());

class SkydevNav extends Component {
	render() => nav({'className': 'navbar navbar-default'}, [
				div({'className': 'navbar-collapse collapse'}, [
					ul({'className': 'nav navbar-nav'},[
						li({'className': 'navbar-header'},[
							a({'href': '/','id': 'content','className': 'navbar-brand'}, "SkyDev")])]),
					ul({'className': 'nav navbar-nav navbar-right'},[
						li({},[
							a({'href': '/login'}, "Login")])])
					])]);
}
