import 'package:react/react.dart';
import 'package:skydev/skydev_sidebar.dart';
import 'package:skydev/skydev_chatbar.dart';

final hud = registerComponent(() => new SkydevHUD());

class SkydevHUD extends Component {
  @override
  getInitialState() => {
        'current_user': "",
        'friends': {
					"tyler": {"username": "tstapler", "online": true},
          "sambhav": {"username": "ssrirama", "online": false}
        },
        'chats': ["chris", "sambhav", "josh"],
        'chat_socket': null
      };

  render() => div({}, [
        sidebar({
          'current_user': state['current_user'],
          'chat_socket': state['chat_socket'],
          'friends': state['friends'],
        }, []),
        chatbar({
          'current_user': state['current_user'],
          'chat_socket': state['chat_socket'],
          'chats': state['chats']
        }, [])
      ]);
}
