import 'package:react/react.dart';
import 'dart:html';
import 'dart:core';
import 'dart:convert';

final message_list = registerComponent(() => new SkydevMessageList());

class SkydevMessageList extends Component {
	render() {
		return				ul({'className': 'list-group message-list'},
				props["messages"].map((message) => li({'className': 'list-group-item'}, message['sender'] + ': ' + message['content'] + " at " + message['timestamp']))
				);
	}
}


final chat_window = registerComponent(() => new SkydevChatWindow());

class SkydevChatWindow extends Component {

	getInitialState() => {
	 "visible": props["visible"],
	 "messages": props["messages"], 
	 "new_messages": props["new_messages"]
	};


	toggleVisible(err) {
		var dropdown_div = querySelector('#chat_with'+ props['recipient']);
		dropdown_div.classes.toggle('open');
		var e = new CustomEvent('resetNewMessages', detail: props['recipient']);
		window.dispatchEvent(e);
	}

	removeWindow(err) {
		var e = new CustomEvent('removeWindow', detail: props['recipient']);
		window.dispatchEvent(e);
	}

	addMessage(err) {
		var input = querySelector('#chat_with' + props['recipient'] + "send");
		var message = {'sender': props['current_user'], 'recipient': props['recipient'],  'content': input.value, 'timestamp': new DateTime.now().toString()};
		state['messages'].add(message);
		props['chat_socket'].send(JSON.encode(message));
		setState({'messages': state['messages']});
	}

	@override
		render() {
			return li({},  
					div({'className': "dropup", 'id': 'chat_with' + props['recipient']}, [
					button({'className': 'btn', 'onClick': toggleVisible}, [props['recipient'], " ",  span({"className": "badge alert-info"}, props["new_messages"])]), 
						div({'className': 'dropdown-menu'}, [ 
							div({"className": "panel panel-default"}, [
								p({'className': 'panel-heading'}, ['Chat with ' + props['recipient'] + "   ", button({'className': 'btn btn-default', 'onClick': removeWindow}, span({'className': 'glyphicon glyphicon-remove'}))]),
								div({'className': 'panel-body'}, [
									message_list({'messages': props['messages']}, []), 
									div({'className': 'input-group'}, [
										input({'className':'form-control', 'type':'text', 'id': 'chat_with' + props['recipient'] + "send"},[]),
										span({'className': 'input-group-btn'}, [
											button({'className': 'btn btn-default', 'onClick': addMessage}, "Send")
											]),
										])
									])
								])
							])
					]));
		}
}

final chatbar = registerComponent(() => new SkydevChatBar());

class SkydevChatBar extends Component {
	@override
	getInitialState() =>
	{
		'chats': {
			"cstapler": 
			{ "visible": true,
				"new_messages": "",
				"messages" :[
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
			]
			},
			"ssrirama": { "visible": true,
				"new_messages": 6,
				"messages" :[
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
			] },
			"jgn": {"visible": true,
				"new_messages": "",
				"messages" : [
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
			] },
			"tstapler": { 
				"visible": true,
				"new_messages": "",
				"messages": [
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
			] }
		}
	};

	componentDidMount(rootNode) {
    props["chat_socket"].onMessage.listen((event) {
      String m = event.data;
      if (m.startsWith("Chat")) {
      } else {
				var new_chat = state["chats"];
        var message = JSON.decode(m);
        if (props["current_user"] == message["recipient"] && state["chats"].containsKey(message["sender"])) {
          new_chat[message["sender"]]["messages"].add({
            "sender": message["sender"],
            "recipient": message["recipient"],
            "content": message["content"],
            "timestamp": message["timestamp"]
          });
					if(new_chat[message["sender"]]["new_messages"] == "" || new_chat[message["sender"]]["new_messages"] == null)
					{
					new_chat[message["sender"]]["new_messages"] = 1;
					}
					else
					{
					new_chat[message["sender"]]["new_messages"] = new_chat[message["sender"]]["new_messages"] + 1;
					}
        }
        setState({"chats": new_chat});
      }
    });

		window.on["removeWindow"].listen((e) {
			state["chats"][e.detail]["visible"] = false;
			setState({"chats": state["chats"]});
			});

		window.on["addWindow"].listen((e) {
			state["chats"][e.detail]["visible"] = true;
			setState({"chats": state["chats"]});
		});

		window.on["resetNewMessages"].listen((e) {
		state["chats"][e.detail]["new_messages"] = "";
		setState({"chats": state["chats"]});
		});

		window.on["addMessage"].listen((e) {
		});
	}

	componentDidChange(rootNode) {
	
	}

	render() => nav({
		'className': 'navbar navbar-default navbar-fixed-bottom'
	}, [
	div({
		'className': 'container-fluid'
	}, [
	div({'className': 'navbar-header'}, a({'className': 'navbar-brand'}, 'Current Chats')), 
	ul({
		'className': 'nav nav-tabs nav-justified'
	}, [
	new List.from(state['chats'].keys.map((recipient)  {
		if(state["chats"][recipient]["visible"])
		{
			return chat_window({'recipient': recipient,
				'current_user': props['current_user'],
				'messages':  state["chats"][recipient]["messages"],
				'chat_socket': props['chat_socket'],
				'new_messages': state["chats"][recipient]["new_messages"], 
				});
		}
	}
	))
	])
	])
	]);
}
