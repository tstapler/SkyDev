import 'package:react/react.dart';
import 'package:skydev/skydev_sidebar.dart';
import 'package:skydev/skydev_chatbar.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';

final hud = registerComponent(() => new SkydevHUD());
final current_user = "http://" + Uri.base.host + ":8081" + '/api/username';
final online_users = "http://" + Uri.base.host + ":8081" + '/api/online';

class SkydevHUD extends Component {
  @override
  getInitialState() => {
        'current_user': "tstapler",
        'friends': [],
        'chats': {
          "cstapler": [
            {
              "sender": "tstapler",
              'content': "Hey Man what's Up?",
              'timestamp': 'Now'
            },
            {
              "sender": "tstapler",
              'content': "How have you been?",
              'timestamp': 'Now'
            },
            {
              "sender": "cstapler",
              'content': "I've been Great Thanks",
              'timestamp': 'Now'
            }
          ],
          "ssrirama": [
            {
              "sender": "tstapler",
              'content': "Hey Man what's Up?",
              'timestamp': 'Now'
            },
            {
              "sender": "tstapler",
              'content': "How have you been?",
              'timestamp': 'Now'
            },
            {
              "sender": "ssrirama",
              'content': "I've been Great Thanks",
              'timestamp': 'Now'
            }
          ],
          "jgn": [
            {
              "sender": "tstapler",
              'content': "Hey Man what's Up?",
              'timestamp': 'Now'
            },
            {
              "sender": "tstapler",
              'content': "How have you been?",
              'timestamp': 'Now'
            },
            {
              "sender": "jgn",
              'content': "I've been Great Thanks",
              'timestamp': 'Now'
            }
          ],
          "tstapler": [
            {
              "sender": "tstapler",
              'content': "Hey Man what's Up?",
              'timestamp': 'Now'
            },
            {
              "sender": "tstapler",
              'content': "How have you been?",
              'timestamp': 'Now'
            },
            {
              "sender": "jgn",
              'content': "I've been Great Thanks",
              'timestamp': 'Now'
            }
          ]
        },
        'chat_socket': props["chat_socket"]
      };

	removeWindow(recipient)
	{
		print(state["chats"]);
		var new_chat = state["chats"];
		new_chat.remove(recipient);
		setState({"chats": new_chat});
	}

	getCurrentUser() async {
    await HttpRequest.getString(current_user).then((String raw) {
      var name = JSON.decode(raw);
			if(name){
      print(name);
      print("Setting current_user");
      state["current_user"] = name["username"];
			}
			else{
			state["current_user"] = "tstapler";
			}
      setState({"current_user": state["current_user"]});
    });
	}

  getOnlineUsers() async {
    await HttpRequest.getString(online_users).then((String raw) {
      var friends = JSON.decode(raw);
      print(friends);
      state["friends"] = friends;
      setState({"friends": state["friends"]});
    });
  }

  componentDidMount(rootNode) {
		// The rate at which the client polls the server for user status
		var duration = new Duration(seconds: 2);
		getCurrentUser();
		new Timer.periodic(duration, (Timer t) => getOnlineUsers());
    props["chat_socket"].onMessage.listen((event) {
      String m = event.data;
      if (m.startsWith("Chat")) {
        print(m);
      } else {
        print(JSON.decode(m));
        var message = JSON.decode(m);
        if (state["chats"].containsKey(message["sender"])) {
          state["chats"][message["sender"]].add({
            "sender": message["sender"],
            "recipient": message["recipient"],
            "content": message["content"],
            "timestamp": message["timestamp"]
          });
        }
        setState({"chats": state["chats"]});
      }
    });
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
          'chats': state['chats'], 
					'removeWindow': removeWindow
        }, [])
      ]);
}
