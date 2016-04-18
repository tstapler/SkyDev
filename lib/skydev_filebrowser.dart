import 'package:react/react.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';

final filebrowser = registerComponent(() => new FileBrowser());

class FileBrowser extends Component {

	render() {
	
		return div({"className": "column col-sm-3"});
	}
}
