import 'package:react/react.dart';
import 'package:skydev/skydev_userlist.dart';

final sidebar = registerComponent(() => new SkydevSidebar());

class SkydevSidebar extends Component {
  render() => div(
      {"className": "column col-xs-2"},
      div({
        "className": "panel panel-default"
      }, [
        div({
          "className": "panel-heading"
        }, [
          p({"className": "text-center"}, "Users")
        ]),
        div({
          "className": "panel-body"
        }, [
          user_list({"users": props["friends"]}, [])
        ])
      ]));
}
