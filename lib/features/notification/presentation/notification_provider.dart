import 'package:flutter/foundation.dart';
import '../data/notification_remote_datasource.dart';
import '../../../core/errors/failures.dart';

class NotificationItem {
  final int id;
  final String judul;
  final String pesan;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      isRead: json['isRead'] == true || json['is_read'] == true || json['isRead'] == 1 || json['is_read'] == 1,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Menentukan icon berdasarkan keyword pada judul
  String get iconType {
    final lower = judul.toLowerCase();
    if (lower.contains('pengingat')) return 'warning';
    if (lower.contains('pengawasan')) return 'clock';
    return 'info';
  }

  /// Waktu relatif (e.g. "5 menit lalu", "kemarin")
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }
}

class NotificationProvider extends ChangeNotifier {
  final NotificationRemoteDatasource _datasource;

  NotificationProvider({NotificationRemoteDatasource? datasource})
      : _datasource = datasource ?? NotificationRemoteDatasource();

  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch semua notifikasi
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _datasource.fetchNotifications();
      _notifications = data
          .map<NotificationItem>((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on Failure catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal memuat notifikasi.';
      debugPrint('NotificationError: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch jumlah unread saja (untuk badge count)
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _datasource.fetchUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('UnreadCountError: $e');
    }
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<void> markRead(int notifId) async {
    try {
      await _datasource.markAsRead(notifId);
      // Update state lokal
      final idx = _notifications.indexWhere((n) => n.id == notifId);
      if (idx != -1 && !_notifications[idx].isRead) {
        _notifications[idx] = NotificationItem(
          id: _notifications[idx].id,
          judul: _notifications[idx].judul,
          pesan: _notifications[idx].pesan,
          isRead: true,
          createdAt: _notifications[idx].createdAt,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, 9999);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('MarkReadError: $e');
    }
  }

  /// Tandai SEMUA notifikasi sebagai sudah dibaca
  Future<void> markAllRead() async {
    try {
      await _datasource.markAllAsRead();
      _notifications = _notifications.map((n) => NotificationItem(
        id: n.id,
        judul: n.judul,
        pesan: n.pesan,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('MarkAllReadError: $e');
    }
  }
}
