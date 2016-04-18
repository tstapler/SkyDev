import 'package:react/react.dart';
import 'package:skydev/skydev_sidebar.dart';
import 'package:skydev/skydev_chatbar.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';

final hud = registerComponent(() => new SkydevHUD());
final current_user = "http://" + Uri.base.host + ":8081" + '/api/username';
final online_users = "http://" + Uri.base.host + ":8081" + '/api/online';

/// The Userlist and Chatbar
class SkydevHUD extends Component {
  @override
  getInitialState() => {
        'current_user': "",
        'friends': [],
        'chat_socket': props["chat_socket"]
      };


	/// Sets the current user to the result of the /api/username endpoint
	getCurrentUser() async{
    await HttpRequest.getString(current_user).then((String raw) {
      var name = JSON.decode(raw);
			if(name != null && name.containsKey("username")){
      state["current_user"] = name["username"];
			}
			else{
		  //For Debugging purposes (using pub serve
			state["current_user"] = "tstapler";
			}
      setState({"current_user": state["current_user"]});
    });
	}

	/// Sets friends state to teh result of the /api/online endpoint
  getOnlineUsers() async {
    await HttpRequest.getString(online_users).then((String raw) {
      var friends = JSON.decode(raw);
      state["friends"] = friends;
      setState({"friends": state["friends"]});
    });
  }

  componentDidMount(rootNode) async {
		// The rate at which the client polls the server for user status
		var duration = new Duration(seconds: 2);
		await getCurrentUser();
		new Timer.periodic(duration, (Timer t) => getOnlineUsers());
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
        }, [])
      ]);
}
