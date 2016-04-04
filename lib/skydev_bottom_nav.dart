import 'package:react/react.dart';

final bottom_navbar = registerComponent(() => new SkydevBottomNav());

class SkydevBottomNav extends Component {
  render() => nav({
        'className': 'navbar navbar-default navbar-fixed-bottom'
      }, [
        div({
          'className': 'container-fluid'
        }, [
					div({'className': 'navbar-header'}, a({"className": "navbar-brand"}, "Current Chats")), 
          ul({
            'className': 'nav nav-justified'
          }, [
            li({}, [
              a({}, "Chat1")
            ]),
            li({}, [
              a({}, "Chat2")
            ])
          ])
        ])
      ]);
}
