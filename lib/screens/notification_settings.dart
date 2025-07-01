import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _allNotifications = true;
  bool _chatNotifications = true;
  bool _likeNotifications = true;
  bool _commentNotifications = true;
  bool _newUserNotifications = true;

  // Function to handle toggling "All" switch
  void _toggleAllNotifications(bool value) {
    setState(() {
      _allNotifications = value;
      _chatNotifications = value;
      _likeNotifications = value;
      _commentNotifications = value;
      _newUserNotifications = value;
    });
  }

  // Helper method to build each switch tile with improved UI
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
        activeTrackColor: Colors.blue[200],
        inactiveThumbColor: Colors.grey[600],
        inactiveTrackColor: Colors.grey[850],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Bildirim Ayarları',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Bildirimlerinizi özelleştirin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // All Notifications
            _buildSwitchTile(
              title: 'Tüm Bildirimler',
              subtitle: 'Tüm bildirim türlerini aç/kapat',
              value: _allNotifications,
              onChanged: _toggleAllNotifications,
            ),
            const SizedBox(height: 8),
            // Chat Notifications
            _buildSwitchTile(
              title: 'Sohbet',
              subtitle: 'Size meesaj gelirse bildirim alın',
              value: _chatNotifications,
              onChanged: (value) {
                setState(() {
                  _chatNotifications = value;
                  _allNotifications = _chatNotifications &&
                      _likeNotifications &&
                      _commentNotifications &&
                      _newUserNotifications;
                });
              },
            ),
            // Like Notifications
            _buildSwitchTile(
              title: 'Beğeni',
              subtitle: 'Postunuza beğeni gelirse bildirim alın',
              value: _likeNotifications,
              onChanged: (value) {
                setState(() {
                  _likeNotifications = value;
                  _allNotifications = _chatNotifications &&
                      _likeNotifications &&
                      _commentNotifications &&
                      _newUserNotifications;
                });
              },
            ),
            // Comment Notifications
            _buildSwitchTile(
              title: 'Yorum',
              subtitle: 'Postunuza yorum gelirse bildirim alın',
              value: _commentNotifications,
              onChanged: (value) {
                setState(() {
                  _commentNotifications = value;
                  _allNotifications = _chatNotifications &&
                      _likeNotifications &&
                      _commentNotifications &&
                      _newUserNotifications;
                });
              },
            ),
            // New User Notifications
            _buildSwitchTile(
              title: 'Yeni Kullanıcı',
              subtitle: 'Topluluğa yeni kullanıcı kayıt olunca bildirim alın',
              value: _newUserNotifications,
              onChanged: (value) {
                setState(() {
                  _newUserNotifications = value;
                  _allNotifications = _chatNotifications &&
                      _likeNotifications &&
                      _commentNotifications &&
                      _newUserNotifications;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}