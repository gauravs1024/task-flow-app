import '../../../../core/data/mock_data_source.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final MockDataSource _dataSource = MockDataSource();

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await _dataSource.simulateNetwork();

    final userNotifs = _dataSource.notifications
        .where((n) => n['user_id'] == userId)
        .map((n) => NotificationModel.fromJson(n))
        .toList();

    // Sort by created date descending (newest first)
    userNotifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userNotifs;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _dataSource.simulateNetwork();

    final index = _dataSource.notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _dataSource.notifications[index]['read'] = true;
    }
  }
}
