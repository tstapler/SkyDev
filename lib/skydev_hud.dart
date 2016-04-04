import 'package:react/react.dart';
import 'package:skydev/skydev_sidebar.dart';
import 'package:skydev/skydev_chatbar.dart';

final hud = registerComponent(() => new SkydevHUD());

class SkydevHUD extends Component {
	@override
		getInitialState() => {
			'current_user': "tstapler",
				'friends': {
					"tyler": {"username": "tstapler", "online": true},
					"sambhav": {"username": "ssrirama", "online": false}
				},
				'chats': [{"recipient": "chris", "messages":
					[ 
					{"sender": "tstapler", 'content': "Hey Man what's Up?", 'timestamp': 'Now'}, {"sender": "tstapler", 'content': "How have you been?", 'timestamp': 'Now'}, {"sender": "cstapler", 'content': "I've been Great Thanks", 'timestamp': 'Now'}]},
				{"recipient": "sambhav", "messages":
				[ {"sender": "tstapler", 'content': "Hey Man what's Up?", 'timestamp': 'Now'}, {"sender": "tstapler", 'content': "How have you been?", 'timestamp': 'Now'}, {"sender": "ssrirama", 'content': "I've been Great Thanks", 'timestamp': 'Now'}]},{"recipient": "josh", "messages":
			[ {"sender": "tstapler", 'content': "Hey Man what's Up?", 'timestamp': 'Now'}, {"sender": "tstapler", 'content': "How have you been?", 'timestamp': 'Now'}, {"sender": "jgn", 'content': "I've been Great Thanks", 'timestamp': 'Now'}]
				}], 
		
		
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
