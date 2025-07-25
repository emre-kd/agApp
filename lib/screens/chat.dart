// ignore_for_file: avoid_print
import 'package:agapp/screens/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../constant.dart';

class Message {
  final int id;
  final String text;
  final int senderId;
  final int receiverId;
  final int? communityId;
  final String createdAt;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    this.communityId,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      text: json['text'] ?? '',
      senderId:
          json['sender_id'] is String
              ? int.parse(json['sender_id'])
              : json['sender_id'],
      receiverId:
          json['receiver_id'] is String
              ? int.parse(json['receiver_id'])
              : json['receiver_id'],
      communityId: json['community_id'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class Chat extends StatefulWidget {
  final String userId;
  final String userName;

  const Chat({super.key, required this.userId, required this.userName});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  bool isLoading = false;
  bool isLoadingNew = false;
  int currentPage = 1;
  bool hasMore = true;
  final int perPage = 20;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    activeChatUserId = widget.userId; // Aktif kişi set edilir
    _fetchMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isLoading && !isLoadingNew) {
        _checkForNewMessages();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !isLoading &&
          hasMore) {
        _fetchMessages();
      }
    });
  }

  Future<void> _checkForNewMessages() async {
    if (isLoadingNew) return;

    setState(() {
      isLoadingNew = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        isLoadingNew = false;
      });
      return;
    }

    try {
      final url =
          '$indexMessage?receiver_id=${widget.userId}&page=1&per_page=$perPage';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> messageData = jsonData['data']['data'] ?? [];
        final newMessages =
            messageData.map((json) => Message.fromJson(json)).toList();

        final existingMessageIds = messages.map((m) => m.id).toSet();
        final uniqueNewMessages =
            newMessages
                .where((newMsg) => !existingMessageIds.contains(newMsg.id))
                .toList();

        if (uniqueNewMessages.isNotEmpty && mounted) {
          setState(() {
            messages.insertAll(0, uniqueNewMessages);
            isLoadingNew = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        } else {
          setState(() {
            isLoadingNew = false;
          });
        }
      } else {
        setState(() {
          isLoadingNew = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingNew = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final url =
          '$indexMessage?receiver_id=${widget.userId}&page=$currentPage&per_page=$perPage';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> messageData = jsonData['data']['data'] ?? [];
        final totalPages = jsonData['data']['last_page'] ?? 1;

        setState(() {
          messages.addAll(
            messageData.map((json) => Message.fromJson(json)).toList(),
          );
          currentPage++;
          hasMore = currentPage <= totalPages && messageData.isNotEmpty;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse(storeMessage),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': _controller.text,
          'receiver_id': widget.userId,
          'community_id': null,
        }),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          messages.insert(0, Message.fromJson(jsonData['data']));
          _controller.clear();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pollingTimer?.cancel();
    activeChatUserId = null; // Chat kapanınca null'a çek
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatList()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                messages.isEmpty && !isLoading
                    ? const Center(
                      child: Text(
                        'Henüz mesaj yok. Konuşmayı başlat!',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                        final message = messages[index];
                        final isSent =
                            message.senderId.toString() != widget.userId;
                        return Align(
                          alignment:
                              isSent
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isSent ? Colors.blueAccent : Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isSent
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  DateFormat(
                                    'HH:mm',
                                  ).format(DateTime.parse(message.createdAt).toLocal()),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 250,
                    decoration: InputDecoration(
                      hintText: 'Bir mesaj yaz...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chat ekranında aktif kişi ID'sini global olarak tutmak
String? activeChatUserId;
