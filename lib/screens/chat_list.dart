import 'package:agapp/screens/chat.dart';
import 'package:flutter/material.dart';

// Dummy user data
final List<Map<String, dynamic>> dummyUsers = [
  {'name': 'Alice', 'lastMessage': 'Hey, how are you?', 'time': '10:30 AM'},
  {'name': 'Bob', 'lastMessage': 'See you tomorrow!', 'time': 'Yesterday'},
  {'name': 'Charlie', 'lastMessage': 'Can you send the files?', 'time': '9:15 AM'},
  {'name': 'David', 'lastMessage': 'Thanks for the update.', 'time': 'Monday'},
];

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: dummyUsers.length,
        itemBuilder: (context, index) {
          final user = dummyUsers[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user['name'][0]),
            ),
            title: Text(user['name']),
            subtitle: Text(
              user['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              user['time'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat(userName: user['name']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}