import 'package:react/react.dart';
import 'dart:html';
import 'dart:core';

final message_list = registerComponent(() => new SkydevMessageList());

class SkydevMessageList extends Component {
	render() {
		return				ul({'className': 'list-group'},
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
		state['messages'].add({'sender': props['current_user'], 'content': input.value, 'timestamp': new DateTime.now().toString()});
		setState({'messages': state['messages']});
		print(state['messages'].toString());
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
	props['chats'].map((chat) => chat_window({'recipient': chat["recipient"], 'current_user': props['current_user'], 'messages': chat["messages"]})).toList()
	])
	])
	]);
}
