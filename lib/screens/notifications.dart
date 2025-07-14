import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  final List<Map<String, String>> dummyNotifications = [
    {
      'title': 'Yeni yorum',
      'body': 'Gönderine birisi yorum yaptı.',
      'time': '5 dk önce',
    },

    {
      'title': 'Yeni mesaj',
      'body': 'Kullanıcıdan yeni bir mesaj aldın.',
      'time': '5 dk önce',
    },
    
  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'Bildirimler',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.white.withOpacity(0.1),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: dummyNotifications.length,
        separatorBuilder: (_, __) => const Divider(
          color: Colors.white24,
          thickness: 0.2,
        ),
        itemBuilder: (context, index) {
          final notification = dummyNotifications[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tileColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: Text(
              notification['title'] ?? '',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              notification['body'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              notification['time'] ?? '',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            onTap: () {
              // İleride ilgili sayfaya yönlendirme yapabilirsin.
            },
          );
        },
      ),
    );
  }
}
