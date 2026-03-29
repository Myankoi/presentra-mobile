import '../../../core/network/api_client.dart';
import '../../../core/constants/api_config.dart';

class NotificationRemoteDatasource {
  final ApiClient _client;

  NotificationRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient();

  /// Ambil semua notifikasi milik user yang sedang login
  Future<List<dynamic>> fetchNotifications() async {
    final json = await _client.get(ApiConfig.notifications);
    return json['data'] as List<dynamic>? ?? [];
  }

  /// Ambil jumlah notifikasi yang belum dibaca
  Future<int> fetchUnreadCount() async {
    final json = await _client.get(ApiConfig.notificationsUnreadCount);
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return data['count'] ?? 0;
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<void> markAsRead(int notifId) async {
    await _client.put(ApiConfig.notificationRead(notifId));
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    await _client.put(ApiConfig.notificationsMarkAllRead);
  }
}
