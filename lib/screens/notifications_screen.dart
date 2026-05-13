import 'package:flutter/material.dart';

const _primaryGreen = Color(0xFF22C55E);
const _lightBackground = Color(0xFFF7FAF4);
const _darkBackground = Color(0xFF0F1A13);
const _ink = Color(0xFF17251A);

enum NotificationType { alert, success, info, market }

// Lightweight notification model used by the screen state and card widget.
class FasalNotification {
  const FasalNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  FasalNotification copyWith({bool? isRead}) {
    return FasalNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      time: time,
      isRead: isRead ?? this.isRead,
    );
  }
}

class DemoNotificationCenter extends ChangeNotifier {
  DemoNotificationCenter._();

  static final DemoNotificationCenter instance = DemoNotificationCenter._();

  int _nextId = 100;
  final List<FasalNotification> _notifications = [
    const FasalNotification(
      id: 1,
      type: NotificationType.alert,
      title: 'Pest Alert Nearby',
      message:
          'Locust movement has been reported near your village. Inspect crop leaves before evening.',
      time: '5 min ago',
      isRead: false,
    ),
    const FasalNotification(
      id: 2,
      type: NotificationType.success,
      title: 'Scan Report Ready',
      message:
          'Your tomato leaf scan is complete. Early blight risk is high with suggested treatment.',
      time: '18 min ago',
      isRead: false,
    ),
    const FasalNotification(
      id: 3,
      type: NotificationType.info,
      title: 'Irrigation Reminder',
      message:
          'Soil moisture is below the ideal range for Field A. Consider light irrigation today.',
      time: '1 hr ago',
      isRead: false,
    ),
    const FasalNotification(
      id: 4,
      type: NotificationType.market,
      title: 'Mandi Price Update',
      message:
          'Wheat prices increased in Bhopal mandi. Current estimate is Rs 2,350 per quintal.',
      time: '3 hrs ago',
      isRead: false,
    ),
  ];

  List<FasalNotification> get notifications =>
      List.unmodifiable(_notifications);

  void addOrderSuccess({
    required String orderId,
    required String amount,
    required String paymentMethod,
  }) {
    _add(
      NotificationType.success,
      'Order placed successfully',
      'Order $orderId paid via $paymentMethod for $amount. Delivery updates will appear here.',
    );
  }

  void addOrderFailure({
    required String reason,
    required String paymentMethod,
  }) {
    _add(
      NotificationType.alert,
      'Payment failed',
      '$paymentMethod payment failed: $reason. Your cart is safe, please retry.',
    );
  }

  void addOrderCancellation({required String orderId, required String reason}) {
    _add(
      NotificationType.alert,
      'Order cancelled',
      'Order $orderId was cancelled. Reason: $reason. Refund or reversal updates will appear here.',
    );
  }

  void addMandiPriceAlert({
    required String crop,
    required String mandi,
    required String price,
    required bool enabled,
  }) {
    _add(
      NotificationType.market,
      enabled ? '$crop price alert enabled' : '$crop price alert disabled',
      enabled
          ? 'You will be notified from $mandi when $crop moves above $price.'
          : 'Mandi notifications for $crop from $mandi have been turned off.',
    );
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void markAsRead(int id) {
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].id == id) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        notifyListeners();
        return;
      }
    }
  }

  FasalNotification removeAt(int index) {
    final removed = _notifications.removeAt(index);
    notifyListeners();
    return removed;
  }

  void restoreAt(int index, FasalNotification notification) {
    final restoreIndex = index.clamp(0, _notifications.length).toInt();
    _notifications.insert(restoreIndex, notification);
    notifyListeners();
  }

  void _add(NotificationType type, String title, String message) {
    _notifications.insert(
      0,
      FasalNotification(
        id: _nextId++,
        type: type,
        title: title,
        message: message,
        time: 'Just now',
        isRead: false,
      ),
    );
    notifyListeners();
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _center = DemoNotificationCenter.instance;

  List<FasalNotification> get _notifications => _center.notifications;

  int get _unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  @override
  void initState() {
    super.initState();
    _center.addListener(_refresh);
  }

  @override
  void dispose() {
    _center.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _markAllAsRead() {
    _center.markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  void _openNotification(FasalNotification notification) {
    _center.markAsRead(notification.id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(notification.title)));
  }

  void _deleteNotification(int index) {
    final removedNotification = _center.removeAt(index);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Notification removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              _center.restoreAt(index, removedNotification);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? _darkBackground : _lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? const Color(0xFF132016) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          children: [
            _LeafMark(),
            SizedBox(width: 10),
            Text(
              'FasalX',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      _BackButton(onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : _ink,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        '${_notifications.length} Updates',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF607062),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _unreadCount == 0 ? null : _markAllAsRead,
                        child: const Text('Mark all as read'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              // Swap to a friendly empty state after the last notification is deleted.
              child: _notifications.isEmpty
                  ? const EmptyNotificationsState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NotificationCard(
                            notification: notification,
                            onTap: () => _openNotification(notification),
                            onDelete: () => _deleteNotification(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(scale: value, child: child),
          );
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17251A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF26382B) : const Color(0xFFE4EDE0),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : const Color(0x10000000),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF203426)
                      : const Color(0xFFF1F6EF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: _primaryGreen,
                  size: 46,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'All caught up!',
                style: TextStyle(
                  color: isDark ? Colors.white : _ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No new notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF8A968A),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final FasalNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _NotificationTypeMeta.fromType(notification.type);
    final opacity = notification.isRead ? 0.64 : 1.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: opacity,
      child: Material(
        color: isDark ? const Color(0xFF17251A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.fromLTRB(15, 15, 46, 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: notification.isRead
                        ? (isDark
                              ? const Color(0xFF26382B)
                              : const Color(0xFFE4EDE0))
                        : _primaryGreen,
                    width: notification.isRead ? 1 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : const Color(0x12000000),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TypeIcon(meta: meta),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : _ink,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (!notification.isRead) ...[
                                const SizedBox(width: 8),
                                const _UnreadDot(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF607062),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            notification.time,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF8A968A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _DeleteNotificationButton(onDelete: onDelete),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteNotificationButton extends StatefulWidget {
  const _DeleteNotificationButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  State<_DeleteNotificationButton> createState() =>
      _DeleteNotificationButtonState();
}

class _DeleteNotificationButtonState extends State<_DeleteNotificationButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isHovered || _isPressed;

    return SizedBox(
      width: 34,
      height: 34,
      child: Tooltip(
        message: 'Remove notification',
        child: Material(
          color: isActive ? const Color(0xFFFFE4E6) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onHover: (value) => setState(() => _isHovered = value),
            onHighlightChanged: (value) => setState(() => _isPressed = value),
            onTap: widget.onDelete,
            child: Icon(
              Icons.close_rounded,
              size: 19,
              color: isActive
                  ? const Color(0xFFE53935)
                  : const Color(0xFF8A968A),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTypeMeta {
  const _NotificationTypeMeta({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  // Central mapping for notification icon/color treatment.
  factory _NotificationTypeMeta.fromType(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return const _NotificationTypeMeta(
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFE53935),
          backgroundColor: Color(0xFFFFE4E6),
        );
      case NotificationType.success:
        return const _NotificationTypeMeta(
          icon: Icons.check_circle_outline_rounded,
          color: _primaryGreen,
          backgroundColor: Color(0xFFEAF7E8),
        );
      case NotificationType.info:
        return const _NotificationTypeMeta(
          icon: Icons.info_outline_rounded,
          color: Color(0xFF2563EB),
          backgroundColor: Color(0xFFE8F1FF),
        );
      case NotificationType.market:
        return const _NotificationTypeMeta(
          icon: Icons.trending_up_rounded,
          color: Color(0xFFF59E0B),
          backgroundColor: Color(0xFFFFF4CC),
        );
    }
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.meta});

  final _NotificationTypeMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: meta.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(meta.icon, color: meta.color, size: 26),
    );
  }
}

class _LeafMark extends StatelessWidget {
  const _LeafMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD6EED2)),
      ),
      child: const Icon(Icons.eco_rounded, color: _primaryGreen, size: 26),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: IconButton.filledTonal(
        tooltip: 'Back',
        onPressed: onTap,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 5),
      decoration: const BoxDecoration(
        color: _primaryGreen,
        shape: BoxShape.circle,
      ),
    );
  }
}
