import 'package:react/react.dart';
import 'package:skydev/skydev_sidebar.dart';
import 'package:skydev/skydev_chatbar.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:cookie/cookie.dart' as cookie;

final hud = registerComponent(() => new SkydevHUD());

class SkydevHUD extends Component {
	@override
		getInitialState() => {
			'current_user': "tstapler", 
				'friends': [],
				'chats': {"cstapler":
					[ 
					{"sender": "tstapler", 'content': "Hey Man what's Up?", 'timestamp': 'Now'}, {"sender": "tstapler", 'content': "How have you been?", 'timestamp': 'Now'}, {"sender": "cstapler", 'content': "I've been Great Thanks", 'timestamp': 'Now'}],
				"ssrirama":
				[ {"sender": "tstapler", 'content': "Hey Man what's Up?", 'timestamp': 'Now'}, {"sender": "tstapler", 'content': "How have you been?", 'timestamp': 'Now'}, {"sender": "ssrirama", 'content': "I've been Great Thanks", 'timestamp': 'Now'}],
				"jgn":
			[ {"sender": "tstapler", 'content': "Hey Man what's Up?", 'timestamp': 'Now'}, {"sender": "tstapler", 'content': "How have you been?", 'timestamp': 'Now'}, {"sender": "jgn", 'content': "I've been Great Thanks", 'timestamp': 'Now'}]
				, "tstapler":
								[ {"sender": "tstapler", 'content': "Hey Man what's Up?", 'timestamp': 'Now'}, {"sender": "tstapler", 'content': "How have you been?", 'timestamp': 'Now'}, {"sender": "jgn", 'content': "I've been Great Thanks", 'timestamp': 'Now'}]
													}, 
		
		
					'chat_socket': props["chat_socket"]
				};
			
		getOnlineUsers() {
			var online_users = "http://" + Uri.base.host + ":8081" + '/online';
			HttpRequest.getString(online_users).then((String raw) {
				var friends = JSON.decode(raw);
				state["friends"] = friends;
				setState({"friends": state["friends"]});
				
			});
		}

		componentDidUpdate(prevProps, prevState, rootNode) {
			getOnlineUsers();
		}
		componentDidMount(rootNode) {
			print( cookie.get("SessionID"));
			getOnlineUsers();
			props["chat_socket"].onMessage.listen((event){
				String m = event.data;
				if(m.startsWith("Chat"))
					{
						print(m);
					}
					else{
				print(JSON.decode(m));
				var message = JSON.decode(m);
				if (state["chats"].containsKey(message["sender"]))
			{
				state["chats"][message["sender"]].add({"sender": message["sender"], "recipient": message["recipient"], "content": message["content"], "timestamp": message["timestamp"]});
			}
			setState({"chats": state["chats"]});
					}
			});
		}

		setName() {
			setState({"current_user": state["current_user"]});
			print(state["current_user"]);
		
		}

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
