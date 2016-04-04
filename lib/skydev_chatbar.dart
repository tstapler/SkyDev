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
	@override
	getInitialState() => {
	 "messages": props["messages"]
	};

	toggleVisible(err) {
		var dropdown_div = querySelector('#chat_with'+props['recipient']);
		dropdown_div.classes.toggle('open');
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
						button({'className': 'btn btn-default', 'onClick': toggleVisible}, props['recipient']), 
						div({'className': 'dropdown-menu'}, [ 
							div({"className": "panel panel-default"}, [
								p({'className': 'panel-heading'}, 'Chat with ' + props['recipient']),
								div({'className': 'panel-body'}, [
									message_list({'messages': state['messages']}, []), 
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
	new List.from(props['chats'].keys.map((recipient) => chat_window({'recipient': recipient, 'current_user': props['current_user'], 'messages':  props["chats"][recipient] , 'chat_socket': props['chat_socket']})))
	])
	])
	]);
}
