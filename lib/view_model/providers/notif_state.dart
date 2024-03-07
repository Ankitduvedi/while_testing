class NotificationsState {
  final List<String> notifications;
  final bool hasNewNotifications;

  NotificationsState({this.notifications = const [], this.hasNewNotifications = false});
}
