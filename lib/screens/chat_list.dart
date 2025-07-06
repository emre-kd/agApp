import 'dart:async';
import 'dart:convert';
import 'package:agapp/constant.dart' show getConversations, baseNormalURL;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agapp/screens/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<dynamic>? conversations;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConversations(); // Initial fetch
  }



  Future<void> _fetchConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No token found. Please log in.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No token found. Please log in.'),
          backgroundColor: Colors.white70,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(getConversations),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversations = data['conversations'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          conversations = [];
          _isLoading = false;
          _errorMessage = 'Failed to load conversations.';
        });
      }
    } catch (e) {
      setState(() {
        conversations = [];
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.white70,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
        elevation: 1,
        shadowColor: Colors.grey[800],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _fetchConversations,
                      child: const Text(
                        'Tekrar dene',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : conversations!.isEmpty
              ? const Center(
                child: Text(
                  'Hiçbir mesaj bulunamadı',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.black,
                onRefresh: _fetchConversations,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: conversations!.length,
                  itemBuilder: (context, index) {
                    final convo = conversations![index];
                    return Padding(
                      padding: const EdgeInsets.only(
                      bottom: 
                      0
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[800],
                            backgroundImage:
                                convo['image'] != null
                                    ? NetworkImage(
                                      '$baseNormalURL/${convo['image']}',
                                    )
                                    : null,
                            child:
                                convo['image'] == null
                                    ? Text(
                                      convo['name']?[0] ?? '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                    : null,
                          ),
                          title: Text(
                            convo['name'] ?? 'Bilinmiyor',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            convo['last_message'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            convo['created_at'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => Chat(
                                      userId: convo['user_id'].toString(),
                                      userName: convo['name'],
                          
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
