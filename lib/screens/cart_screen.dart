import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/delivery_address.dart';
import '../screens/address_selection_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../services/address_controller.dart';
import '../services/cart_controller.dart';
import '../theme/app_theme.dart';

const _mainGreen = Color(0xFF0F9D6C);
const _lightGreen = Color(0xFFE8F7EF);
const _darkText = Color(0xFF1B1B1B);
const _secondaryText = Color(0xFF6B7280);
const _cartBorder = Color(0xFFE5E7EB);

String _money(int value) => '\u20B9$value';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.watch(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _CartTopBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Cart',
                  style: TextStyle(
                    color: context.fx.textStrong,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Continue Shopping'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _DeliveryAddressCard(),
          const SizedBox(height: 14),
          _CartItemsCard(cart: cart),
          const SizedBox(height: 14),
          _CouponCard(cart: cart),
          const SizedBox(height: 14),
          _BillSummaryCard(cart: cart),
          const SizedBox(height: 18),
          _CheckoutButton(
            enabled: !cart.isEmpty,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'UPI';
  bool _placingOrder = false;
  DemoCoupon? _appliedCoupon;
  int _couponDiscount = 0;
  final _upiController = TextEditingController(text: 'farmer@upi');
  final _cardController = TextEditingController(text: '4242 4242 4242 4242');
  final _cvvController = TextEditingController(text: '123');

  @override
  void dispose() {
    _upiController.dispose();
    _cardController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.watch(context);
    final address = context.watch<AddressController>().activeAddress;
    _refreshCoupon(cart);
    final payableAmount = max(0, cart.grandTotal - _couponDiscount);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _CartTopBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    color: _darkText,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Cart'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CheckoutAddressCard(address: address, onEdit: _openAddressSelector),
          const SizedBox(height: 14),
          _PaymentMethodCard(
            selected: _paymentMethod,
            amount: payableAmount,
            upiController: _upiController,
            cardController: _cardController,
            cvvController: _cvvController,
            onChanged: (value) {
              setState(() => _paymentMethod = value);
              _refreshCoupon(cart);
            },
          ),
          const SizedBox(height: 14),
          _CheckoutCouponCard(
            coupon: _appliedCoupon,
            discount: _couponDiscount,
            onApply: () => _openCouponSheet(cart),
            onRemove: _appliedCoupon == null
                ? null
                : () => setState(() {
                    _appliedCoupon = null;
                    _couponDiscount = 0;
                  }),
          ),
          const SizedBox(height: 14),
          _OrderSummaryCard(
            cart: cart,
            coupon: _appliedCoupon,
            couponDiscount: _couponDiscount,
          ),
          const SizedBox(height: 14),
          const _FarmerTrustCard(),
          const SizedBox(height: 18),
          _PlaceOrderButton(
            loading: _placingOrder,
            onTap: cart.isEmpty || address == null
                ? null
                : () => _placeOrder(cart, payableAmount),
          ),
        ],
      ),
    );
  }

  void _openAddressSelector() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddressSelectionScreen()));
  }

  Future<void> _placeOrder(CartController cart, int payableAmount) async {
    setState(() => _placingOrder = true);
    final result = await DemoCheckoutBackend.instance.placeOrder(
      amount: payableAmount,
      paymentMethod: _paymentMethod,
      upiId: _upiController.text.trim(),
      cardNumber: _cardController.text.trim(),
      cvv: _cvvController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _placingOrder = false);

    if (!result.success) {
      DemoNotificationCenter.instance.addOrderFailure(
        reason: result.message,
        paymentMethod: _paymentMethod,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderFailureScreen(
            reason: result.message,
            paymentMethod: _paymentMethod,
          ),
        ),
      );
      return;
    }

    DemoOrderHistoryStore.instance.add(
      DemoOrderRecord.fromCart(
        orderId: result.orderId!,
        amount: payableAmount,
        paymentMethod: _paymentMethod,
        couponCode: _appliedCoupon?.code,
        lines: cart.items,
      ),
    );
    cart.clear();
    DemoNotificationCenter.instance.addOrderSuccess(
      orderId: result.orderId!,
      amount: _money(payableAmount),
      paymentMethod: _paymentMethod,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          orderId: result.orderId!,
          amount: payableAmount,
          paymentMethod: _paymentMethod,
          couponCode: _appliedCoupon?.code,
        ),
      ),
    );
  }

  Future<void> _openCouponSheet(CartController cart) async {
    final coupon = await showModalBottomSheet<DemoCoupon>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _CouponSheet(cart: cart, paymentMethod: _paymentMethod),
    );
    if (coupon == null || !mounted) return;
    final discount = DemoCheckoutBackend.instance.discountFor(
      coupon,
      cart,
      _paymentMethod,
    );
    if (discount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DemoCheckoutBackend.instance.couponMessage(
              coupon,
              cart,
              _paymentMethod,
            ),
          ),
        ),
      );
      return;
    }
    setState(() {
      _appliedCoupon = coupon;
      _couponDiscount = discount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${coupon.code} applied. You saved ${_money(discount)}.'),
      ),
    );
  }

  void _refreshCoupon(CartController cart) {
    final coupon = _appliedCoupon;
    if (coupon == null) return;
    final discount = DemoCheckoutBackend.instance.discountFor(
      coupon,
      cart,
      _paymentMethod,
    );
    if (discount != _couponDiscount) {
      _couponDiscount = discount;
    }
  }
}

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.couponCode,
  });

  final String orderId;
  final int amount;
  final String paymentMethod;
  final String? couponCode;

  @override
  Widget build(BuildContext context) {
    final deliveryDate = DateTime.now().add(const Duration(days: 4));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _CartTopBar(),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.75, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: _lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _mainGreen,
                  size: 58,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Order Placed Successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _darkText,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Order ID: $orderId\nEstimated delivery: ${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}\nPayment: $paymentMethod confirmed for ${_money(amount)}${couponCode == null ? '' : '\nCoupon applied: $couponCode'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _PrimaryWideButton(
              label: 'Track Order',
              icon: Icons.local_shipping_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      orderId: orderId,
                      amount: amount,
                      paymentMethod: paymentMethod,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderFailureScreen extends StatelessWidget {
  const OrderFailureScreen({
    super.key,
    required this.reason,
    required this.paymentMethod,
  });

  final String reason;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _CartTopBar(),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.75, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFFE53935),
                  size: 58,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Payment Failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _darkText,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$paymentMethod could not be completed.\n$reason\nYour cart is safe. Try another method or retry.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _PrimaryWideButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('View Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
  });

  final String orderId;
  final int amount;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final tracking = DemoCheckoutBackend.instance.trackingForOrder(
      orderId: orderId,
      amount: amount,
      paymentMethod: paymentMethod,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _CartTopBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Track Order',
                  style: TextStyle(
                    color: _darkText,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TrackingHeroCard(tracking: tracking),
          const SizedBox(height: 14),
          _TrackingProgressCard(tracking: tracking),
          const SizedBox(height: 14),
          _ShipmentDetailsCard(tracking: tracking),
          const SizedBox(height: 14),
          _TrackingTimelineCard(events: tracking.events),
          const SizedBox(height: 14),
          _TrackingActionCard(tracking: tracking),
        ],
      ),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = DemoOrderHistoryStore.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _CartTopBar(),
      body: AnimatedBuilder(
        animation: history,
        builder: (context, _) {
          final orders = history.orders;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Order History',
                      style: TextStyle(
                        color: _darkText,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _OrderHistoryHero(totalOrders: orders.length),
              const SizedBox(height: 14),
              if (orders.isEmpty)
                const _EmptyOrderHistory()
              else
                for (final order in orders) ...[
                  _OrderHistoryCard(order: order),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _OrderHistoryHero extends StatelessWidget {
  const _OrderHistoryHero({required this.totalOrders});

  final int totalOrders;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      color: const Color(0xFFEFFAF4),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: _mainGreen,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your farm purchases',
                  style: TextStyle(
                    color: _darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalOrders == 1
                      ? '1 order ready for tracking and reorder.'
                      : '$totalOrders orders ready for tracking and reorder.',
                  style: const TextStyle(
                    color: _secondaryText,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrderHistory extends StatelessWidget {
  const _EmptyOrderHistory();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: _lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: _mainGreen,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No orders yet',
            style: TextStyle(
              color: _darkText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your completed store orders will appear here with tracking details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Start Shopping'),
            style: FilledButton.styleFrom(
              backgroundColor: _mainGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order});

  final DemoOrderRecord order;

  @override
  Widget build(BuildContext context) {
    final preview = order.itemPreview;

    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: order.statusColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(order.statusIcon, color: order.statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderId,
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.statusLabel} - ${order.dateLabel}',
                      style: const TextStyle(
                        color: _secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _HistoryStatusPill(order: order),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _darkText,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_money(order.amount)} - ${order.paymentMethod}',
                  style: const TextStyle(
                    color: _mainGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${order.totalItems} items',
                style: const TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (order.isCancelled) ...[
            const SizedBox(height: 12),
            _CancelledOrderNotice(order: order),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reorder(context, order),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: const Text('Reorder'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _mainGreen,
                    side: const BorderSide(color: _mainGreen),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: order.isCancelled
                      ? null
                      : () => _track(context, order),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Track'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _mainGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: _secondaryText,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: order.canCancel
                  ? () => _cancelOrder(context, order)
                  : null,
              icon: Icon(
                order.isCancelled
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
              ),
              label: Text(
                order.isCancelled ? 'Order Cancelled' : 'Cancel Order',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                disabledForegroundColor: _secondaryText,
                side: BorderSide(
                  color: order.isCancelled
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFFFCA5A5),
                ),
                backgroundColor: order.isCancelled
                    ? const Color(0xFFF9FAFB)
                    : const Color(0xFFFFF7F7),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _track(BuildContext context, DemoOrderRecord order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(
          orderId: order.orderId,
          amount: order.amount,
          paymentMethod: order.paymentMethod,
        ),
      ),
    );
  }

  void _reorder(BuildContext context, DemoOrderRecord order) {
    final cart = CartScope.read(context);
    for (final line in order.lines) {
      for (var index = 0; index < line.quantity; index++) {
        cart.add(line.product);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${order.totalItems} items added to cart from ${order.orderId}.',
        ),
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context, DemoOrderRecord order) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CancelOrderSheet(order: order),
    );
    if (reason == null || !context.mounted) return;

    DemoOrderHistoryStore.instance.cancelOrder(order.orderId, reason);
    DemoNotificationCenter.instance.addOrderCancellation(
      orderId: order.orderId,
      reason: reason,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order.orderId} cancelled. Notification added.'),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
        ),
      ),
    );
  }
}

class _CancelledOrderNotice extends StatelessWidget {
  const _CancelledOrderNotice({required this.order});

  final DemoOrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cancelled${order.cancelReason == null ? '' : ': ${order.cancelReason}'}',
              style: const TextStyle(
                color: Color(0xFF7F1D1D),
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CancelOrderSheet extends StatefulWidget {
  const CancelOrderSheet({super.key, required this.order});

  final DemoOrderRecord order;

  @override
  State<CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<CancelOrderSheet> {
  String _selectedReason = _cancelReasons.first;

  static const _cancelReasons = [
    'Ordered by mistake',
    'Need to change address',
    'Found a better price',
    'Delivery will be too late',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 30,
              offset: Offset(0, -12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E2D4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cancel order?',
                        style: TextStyle(
                          color: _darkText,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.order.orderId,
                        style: const TextStyle(
                          color: _secondaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFCFA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _cartBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, color: _mainGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_money(widget.order.amount)} - ${widget.order.itemPreview}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _darkText,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reason for cancellation',
              style: TextStyle(color: _darkText, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final reason in _cancelReasons) ...[
              _CancelReasonTile(
                reason: reason,
                selected: _selectedReason == reason,
                onTap: () => setState(() => _selectedReason = reason),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Keep Order'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(_selectedReason),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Confirm Cancel'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelReasonTile extends StatelessWidget {
  const _CancelReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final String reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF1F2) : const Color(0xFFFAFCFA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFFDC2626) : _cartBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? const Color(0xFFDC2626) : _secondaryText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reason,
                  style: TextStyle(
                    color: selected ? const Color(0xFF7F1D1D) : _darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryStatusPill extends StatelessWidget {
  const _HistoryStatusPill({required this.order});

  final DemoOrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: order.statusColor.withAlpha(22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          color: order.statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TrackingHeroCard extends StatelessWidget {
  const _TrackingHeroCard({required this.tracking});

  final DemoOrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      color: const Color(0xFFEFFAF4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  tracking.currentStep.icon,
                  color: _mainGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tracking.currentStep.title,
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tracking.currentStep.detail,
                      style: const TextStyle(
                        color: _secondaryText,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: tracking.progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(_mainGreen),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TrackingMetric(
                  label: 'Arriving',
                  value: tracking.etaLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TrackingMetric(
                  label: 'Order ID',
                  value: tracking.orderId,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackingMetric extends StatelessWidget {
  const _TrackingMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingProgressCard extends StatelessWidget {
  const _TrackingProgressCard({required this.tracking});

  final DemoOrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Status',
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < tracking.steps.length; index++)
            _TrackingStepRow(
              step: tracking.steps[index],
              isLast: index == tracking.steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TrackingStepRow extends StatelessWidget {
  const _TrackingStepRow({required this.step, required this.isLast});

  final DemoTrackingStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = step.completed ? _mainGreen : const Color(0xFFCBD5E1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: step.completed ? _lightGreen : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(
                  step.completed ? Icons.check_rounded : step.icon,
                  color: color,
                  size: 19,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: color.withAlpha(step.completed ? 160 : 80),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: step.completed ? _darkText : _secondaryText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.timeLabel,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.detail,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentDetailsCard extends StatelessWidget {
  const _ShipmentDetailsCard({required this.tracking});

  final DemoOrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipment Details',
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _TrackingInfoRow(
            icon: Icons.local_shipping_outlined,
            label: 'Courier',
            value: tracking.courier,
          ),
          _TrackingInfoRow(
            icon: Icons.confirmation_number_outlined,
            label: 'AWB',
            value: tracking.awb,
          ),
          _TrackingInfoRow(
            icon: Icons.payments_outlined,
            label: 'Payment',
            value: '${tracking.paymentMethod} - ${_money(tracking.amount)}',
          ),
          _TrackingInfoRow(
            icon: Icons.warehouse_outlined,
            label: 'Fulfilled by',
            value: tracking.fulfillmentCenter,
          ),
        ],
      ),
    );
  }
}

class _TrackingInfoRow extends StatelessWidget {
  const _TrackingInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, color: _mainGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _secondaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _darkText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingTimelineCard extends StatelessWidget {
  const _TrackingTimelineCard({required this.events});

  final List<DemoTrackingEvent> events;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Updates',
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final event in events) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.radio_button_checked_rounded,
                    color: _mainGreen,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        event.subtitle,
                        style: const TextStyle(
                          color: _secondaryText,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        event.timeLabel,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (event != events.last) const Divider(height: 22),
          ],
        ],
      ),
    );
  }
}

class _TrackingActionCard extends StatelessWidget {
  const _TrackingActionCard({required this.tracking});

  final DemoOrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      color: const Color(0xFFFFFBEB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need help?',
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tracking.supportMessage,
            style: const TextStyle(
              color: Color(0xFF5F5132),
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demo support ticket created for this order.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text('Support'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Demo tracking refreshed for ${tracking.orderId}.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _mainGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _CartTopBar();

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final cart = CartScope.watch(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        height: preferredSize.height + topPadding,
        padding: EdgeInsets.fromLTRB(18, topPadding + 10, 18, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.eco_rounded, color: _mainGreen, size: 28),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'FasalX',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _TopIconButton(
              icon: Icons.history_rounded,
              tooltip: 'Order history',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            _TopIconButton(
              icon: Icons.shopping_cart_outlined,
              tooltip: 'Cart',
              badge: cart.totalItems,
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            const SizedBox(width: 8),
            _TopIconButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _TopIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF1F6EF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: _darkText, size: 26),
                if (badge > 0)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.4),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard();

  @override
  Widget build(BuildContext context) {
    final address = context.watch<AddressController>().activeAddress;

    return _SoftCard(
      color: _lightGreen,
      child: Row(
        children: [
          const _CircleIcon(icon: Icons.location_on_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVERING TO',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address?.shortLine ?? 'Select delivery address',
                  style: const TextStyle(
                    color: _darkText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddressSelectionScreen(),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _CartItemsCard extends StatelessWidget {
  const _CartItemsCard({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${cart.totalItems})',
            style: const TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: Text('Your cart is empty')),
            )
          else
            for (final line in cart.items) ...[
              _CartLineTile(line: line),
              if (line != cart.items.last) const Divider(height: 24),
            ],
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.watch(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: line.product.color.withAlpha(24),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(line.product.icon, color: line.product.color, size: 34),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.product.name,
                style: const TextStyle(
                  color: _darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                line.product.quantityLabel,
                style: const TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _money(line.product.price),
                style: const TextStyle(
                  color: _mainGreen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _QuantityStepper(
          quantity: line.quantity,
          onMinus: line.quantity <= 1
              ? null
              : () => cart.decrement(line.product.id),
          onPlus: () => cart.increment(line.product.id),
        ),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final coupon = await showModalBottomSheet<DemoCoupon>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            builder: (_) => _CouponSheet(cart: cart),
          );
          if (coupon == null || !context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${coupon.code} is available. Apply it on the checkout screen.',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_offer_outlined, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Apply Coupon',
                  style: TextStyle(
                    color: _darkText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillSummaryCard extends StatelessWidget {
  const _BillSummaryCard({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Summary',
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _BillRow(label: 'Item Total', value: _money(cart.subtotal)),
          _BillRow(label: 'Taxes (GST 5%)', value: _money(cart.gst)),
          _BillRow(
            label: 'Delivery Fee',
            value: cart.deliveryFee == 0 ? 'Free' : _money(cart.deliveryFee),
            valueColor: cart.deliveryFee == 0 ? _mainGreen : _darkText,
          ),
          if (cart.discount > 0)
            _BillRow(
              label: 'Discount/Subsidy',
              value: '- ${_money(cart.discount)}',
              valueColor: _mainGreen,
            ),
          const Divider(height: 24),
          _BillRow(
            label: 'Grand Total',
            value: _money(cart.grandTotal),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _CheckoutCouponCard extends StatelessWidget {
  const _CheckoutCouponCard({
    required this.coupon,
    required this.discount,
    required this.onApply,
    required this.onRemove,
  });

  final DemoCoupon? coupon;
  final int discount;
  final VoidCallback onApply;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final applied = coupon != null && discount > 0;

    return _SoftCard(
      color: applied ? _lightGreen : Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: applied ? Colors.white : const Color(0xFFEFF6FF),
            child: Icon(
              applied
                  ? Icons.check_circle_outline_rounded
                  : Icons.local_offer_outlined,
              color: applied ? _mainGreen : const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applied ? '${coupon!.code} applied' : 'Apply Coupon',
                  style: const TextStyle(
                    color: _darkText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  applied
                      ? 'You saved ${_money(discount)} on this order'
                      : 'View bank offers and farm coupons',
                  style: const TextStyle(
                    color: _secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (applied)
            IconButton(
              tooltip: 'Remove coupon',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded),
            )
          else
            TextButton(onPressed: onApply, child: const Text('Apply')),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.cart,
    this.coupon,
    this.couponDiscount = 0,
  });

  final CartController cart;
  final DemoCoupon? coupon;
  final int couponDiscount;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _BillRow(label: 'Subtotal amount', value: _money(cart.subtotal)),
          _BillRow(
            label: 'Delivery charges',
            value: cart.deliveryFee == 0 ? 'Free' : _money(cart.deliveryFee),
            valueColor: _mainGreen,
          ),
          _BillRow(
            label: 'Discount/Subsidy',
            value: cart.discount == 0
                ? 'No active subsidy'
                : '- ${_money(cart.discount)}',
            valueColor: _mainGreen,
          ),
          if (coupon != null && couponDiscount > 0)
            _BillRow(
              label: 'Coupon ${coupon!.code}',
              value: '- ${_money(couponDiscount)}',
              valueColor: _mainGreen,
            ),
          const Divider(height: 24),
          _BillRow(
            label: 'Final payable amount',
            value: _money(max(0, cart.grandTotal - couponDiscount)),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PrimaryWideButton(
      label: 'Proceed to Checkout',
      icon: Icons.arrow_forward_rounded,
      onTap: enabled ? onTap : null,
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _PrimaryWideButton(
      label: loading ? 'Placing Order...' : 'Place Order',
      icon: Icons.lock_rounded,
      onTap: loading ? null : onTap,
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selected,
    required this.amount,
    required this.upiController,
    required this.cardController,
    required this.cvvController,
    required this.onChanged,
  });

  final String selected;
  final int amount;
  final TextEditingController upiController;
  final TextEditingController cardController;
  final TextEditingController cvvController;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const methods = [
      (
        'UPI',
        Icons.account_balance_wallet_outlined,
        'GPay, PhonePe, Paytm',
        'Fast and secure payment',
      ),
      (
        'Card',
        Icons.credit_card_rounded,
        'Credit / Debit Card',
        'Visa, Mastercard, RuPay',
      ),
      (
        'Cash on Delivery',
        Icons.payments_outlined,
        'Pay when product arrives',
        'Available up to Rs 2,000',
      ),
    ];

    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const _PaymentHint(),
          const SizedBox(height: 12),
          for (final method in methods) ...[
            _PaymentOption(
              title: method.$1,
              subtitle: method.$3,
              badge: method.$4,
              icon: method.$2,
              selected: selected == method.$1,
              onTap: () => onChanged(method.$1),
            ),
            if (selected == method.$1) ...[
              const SizedBox(height: 8),
              _PaymentDetailsFields(
                selected: selected,
                amount: amount,
                upiController: upiController,
                cardController: cardController,
                cvvController: cvvController,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PaymentHint extends StatelessWidget {
  const _PaymentHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Choose a payment method to complete your order. Cash on Delivery is available for eligible orders up to Rs 2,000.',
              style: TextStyle(
                color: Color(0xFF315279),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? _lightGreen : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? _mainGreen : _cartBorder,
          width: 1.4,
        ),
      ),
      child: RadioListTile<String>(
        value: title,
        groupValue: selected ? title : null,
        onChanged: (_) => onTap(),
        activeColor: _mainGreen,
        secondary: Icon(icon, color: selected ? _mainGreen : _secondaryText),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('$subtitle\n$badge'),
        isThreeLine: true,
      ),
    );
  }
}

class _PaymentDetailsFields extends StatelessWidget {
  const _PaymentDetailsFields({
    required this.selected,
    required this.amount,
    required this.upiController,
    required this.cardController,
    required this.cvvController,
  });

  final String selected;
  final int amount;
  final TextEditingController upiController;
  final TextEditingController cardController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    if (selected == 'UPI') {
      return _InlinePaymentBox(
        children: [
          TextField(
            controller: upiController,
            decoration: _fieldDecoration(
              context,
              'UPI ID',
              Icons.alternate_email_rounded,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          const Text(
            'A UPI collect request will be sent for approval.',
            style: TextStyle(color: _secondaryText),
          ),
        ],
      );
    }

    if (selected == 'Card') {
      return _InlinePaymentBox(
        children: [
          TextField(
            controller: cardController,
            decoration: _fieldDecoration(
              context,
              'Card Number',
              Icons.credit_card_rounded,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cvvController,
            decoration: _fieldDecoration(
              context,
              'CVV',
              Icons.lock_outline_rounded,
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
          ),
        ],
      );
    }

    if (selected == 'Cash on Delivery') {
      final available = amount <= 2000;
      return _InlinePaymentBox(
        color: available ? _lightGreen : const Color(0xFFFFE4E6),
        children: [
          Row(
            children: [
              Icon(
                available
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: available ? _mainGreen : const Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  available
                      ? 'COD is available for this order.'
                      : 'COD is not available above Rs 2,000.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  InputDecoration _fieldDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final fx = context.fx;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: fx.fieldFill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: fx.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }
}

class _InlinePaymentBox extends StatelessWidget {
  const _InlinePaymentBox({
    required this.children,
    this.color = const Color(0xFFFAFCFA),
  });

  final List<Widget> children;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? fx.fieldFill
            : color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fx.border),
      ),
      child: Column(children: children),
    );
  }
}

class _CheckoutAddressCard extends StatelessWidget {
  const _CheckoutAddressCard({required this.address, required this.onEdit});

  final DeliveryAddress? address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CircleIcon(icon: Icons.location_on_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address?.fullName ?? 'Select delivery address',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  address?.fullAddress ??
                      'Add GPS or manual address before checkout',
                  style: const TextStyle(color: _secondaryText),
                ),
                const SizedBox(height: 4),
                if (address != null)
                  Text(
                    address!.mobileNumber,
                    style: const TextStyle(color: _secondaryText),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit address',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_location_alt_outlined),
          ),
        ],
      ),
    );
  }
}

class _FarmerTrustCard extends StatelessWidget {
  const _FarmerTrustCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      color: const Color(0xFFFFFBEB),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farmer-friendly details',
            style: TextStyle(color: _darkText, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text('Subsidy savings applied when eligible'),
          Text('Estimated delivery: 3-5 days'),
          Text('Free delivery on orders above Rs 500'),
          Text('Limited stock warning shown before dispatch'),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded, size: 18),
            color: Theme.of(context).colorScheme.primary,
            visualDensity: VisualDensity.compact,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded, size: 18),
            color: Theme.of(context).colorScheme.primary,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: bold ? fx.textStrong : fx.textMuted,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? fx.textStrong,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
              fontSize: bold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryWideButton extends StatefulWidget {
  const _PrimaryWideButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_PrimaryWideButton> createState() => _PrimaryWideButtonState();
}

class _PrimaryWideButtonState extends State<_PrimaryWideButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: widget.onTap,
            style: FilledButton.styleFrom(
              backgroundColor: _mainGreen,
              foregroundColor: Colors.white,
              shadowColor: _mainGreen.withAlpha(90),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: Icon(widget.icon),
            label: Text(
              widget.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child, this.color = Colors.white});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final effectiveColor = Theme.of(context).brightness == Brightness.dark
        ? (color == Colors.white || color == const Color(0xFFFAFCFA)
              ? fx.surface
              : color.withAlpha(55))
        : color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: fx.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return CircleAvatar(
      backgroundColor: fx.selectedFill,
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class DemoCheckoutBackend {
  DemoCheckoutBackend._();

  static final DemoCheckoutBackend instance = DemoCheckoutBackend._();

  final List<DemoCoupon> coupons = const [
    DemoCoupon(
      code: 'FASAL150',
      title: 'Flat Rs 150 off on farm orders above Rs 2,000',
      minOrder: 2000,
      flatDiscount: 150,
    ),
    DemoCoupon(
      code: 'KISAN10',
      title: '10% off up to Rs 100 on orders above Rs 500',
      minOrder: 500,
      percent: 10,
      maxDiscount: 100,
    ),
    DemoCoupon(
      code: 'UPI100',
      title: 'Rs 100 cashback-style discount on UPI payments',
      minOrder: 999,
      flatDiscount: 100,
      paymentMethod: 'UPI',
    ),
    DemoCoupon(
      code: 'SEED50',
      title: 'Rs 50 off for small basket checkout',
      minOrder: 250,
      flatDiscount: 50,
    ),
  ];

  DemoCoupon? couponByCode(String code) {
    for (final coupon in coupons) {
      if (coupon.code == code.toUpperCase()) return coupon;
    }
    return null;
  }

  int discountFor(
    DemoCoupon coupon,
    CartController cart,
    String paymentMethod,
  ) {
    if (cart.subtotal < coupon.minOrder) return 0;
    if (coupon.paymentMethod != null && coupon.paymentMethod != paymentMethod) {
      return 0;
    }
    final percentDiscount = coupon.percent == null
        ? 0
        : (cart.subtotal * coupon.percent! / 100).floor();
    final rawDiscount =
        coupon.flatDiscount ??
        min(percentDiscount, coupon.maxDiscount ?? percentDiscount);
    return min(rawDiscount, cart.grandTotal);
  }

  String couponMessage(
    DemoCoupon coupon,
    CartController cart,
    String paymentMethod,
  ) {
    if (cart.subtotal < coupon.minOrder) {
      return 'Add items worth ${_money(coupon.minOrder - cart.subtotal)} more to use ${coupon.code}.';
    }
    if (coupon.paymentMethod != null && coupon.paymentMethod != paymentMethod) {
      return '${coupon.code} is valid only on ${coupon.paymentMethod} payments.';
    }
    return '${coupon.code} can be applied.';
  }

  DemoOrderTracking trackingForOrder({
    required String orderId,
    required int amount,
    required String paymentMethod,
  }) {
    final seed = _numericSeed('$orderId$amount$paymentMethod');
    final currentIndex = min(3, seed % 4);
    final now = DateTime.now();
    final placedAt = now.subtract(Duration(hours: 7 + seed % 9));
    final courier = _couriers[seed % _couriers.length];
    final hub = _hubs[seed % _hubs.length];
    final eta = now.add(Duration(days: 1 + seed % 4));
    final steps = <DemoTrackingStep>[
      DemoTrackingStep(
        title: 'Order Confirmed',
        detail: 'Payment verified and order queued at FasalX store.',
        timeLabel: _formatTrackingTime(placedAt),
        icon: Icons.receipt_long_outlined,
        completed: currentIndex >= 0,
      ),
      DemoTrackingStep(
        title: 'Packed',
        detail: 'Items packed with invoice and farmer-safe handling labels.',
        timeLabel: currentIndex >= 1
            ? _formatTrackingTime(placedAt.add(const Duration(hours: 3)))
            : 'Expected today',
        icon: Icons.inventory_2_outlined,
        completed: currentIndex >= 1,
      ),
      DemoTrackingStep(
        title: 'Shipped',
        detail: '$courier picked up the package from $hub.',
        timeLabel: currentIndex >= 2
            ? _formatTrackingTime(placedAt.add(const Duration(hours: 8)))
            : 'Expected in 24 hours',
        icon: Icons.local_shipping_outlined,
        completed: currentIndex >= 2,
      ),
      DemoTrackingStep(
        title: 'Out for Delivery',
        detail: 'Delivery partner will call before reaching your address.',
        timeLabel: currentIndex >= 3
            ? 'Today, before 7 PM'
            : 'Expected ${_formatShortDate(eta)}',
        icon: Icons.delivery_dining_outlined,
        completed: currentIndex >= 3,
      ),
      DemoTrackingStep(
        title: 'Delivered',
        detail: 'OTP handover and bill confirmation will complete the order.',
        timeLabel: 'By ${_formatShortDate(eta)}',
        icon: Icons.home_outlined,
        completed: false,
      ),
    ];

    return DemoOrderTracking(
      orderId: orderId,
      amount: amount,
      paymentMethod: paymentMethod,
      courier: courier,
      awb: 'FXAWB${seed + 420091}',
      fulfillmentCenter: hub,
      etaLabel: currentIndex >= 3 ? 'Today by 7 PM' : _formatShortDate(eta),
      progress: (currentIndex + 1) / steps.length,
      currentStep: steps[currentIndex],
      steps: steps,
      events: _eventsFor(
        courier: courier,
        hub: hub,
        placedAt: placedAt,
        currentIndex: currentIndex,
      ),
      supportMessage: currentIndex >= 3
          ? 'Keep your phone reachable. The delivery partner can ask for OTP during handover.'
          : 'Tracking is generated by demo backend rules from order ID, amount, and payment method.',
    );
  }

  int _numericSeed(String orderId) {
    final digits = orderId.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(digits) ??
        orderId.codeUnits.fold(0, (sum, value) => sum + value);
  }

  List<DemoTrackingEvent> _eventsFor({
    required String courier,
    required String hub,
    required DateTime placedAt,
    required int currentIndex,
  }) {
    final events = <DemoTrackingEvent>[
      DemoTrackingEvent(
        title: 'Order confirmed',
        subtitle: 'FasalX received the order and started seller processing.',
        timeLabel: _formatTrackingTime(placedAt),
      ),
    ];
    if (currentIndex >= 1) {
      events.insert(
        0,
        DemoTrackingEvent(
          title: 'Package packed',
          subtitle: 'Invoice generated and items checked for dispatch.',
          timeLabel: _formatTrackingTime(
            placedAt.add(const Duration(hours: 3)),
          ),
        ),
      );
    }
    if (currentIndex >= 2) {
      events.insert(
        0,
        DemoTrackingEvent(
          title: 'Package shipped',
          subtitle: '$courier picked up your order from $hub.',
          timeLabel: _formatTrackingTime(
            placedAt.add(const Duration(hours: 8)),
          ),
        ),
      );
    }
    if (currentIndex >= 3) {
      events.insert(
        0,
        const DemoTrackingEvent(
          title: 'Out for delivery',
          subtitle: 'Delivery partner is carrying your package.',
          timeLabel: 'Today, 9:20 AM',
        ),
      );
    }
    return events;
  }

  static const _couriers = [
    'FasalX Express',
    'AgriKart Logistics',
    'RuralShip',
    'Kisan Delivery',
  ];

  static const _hubs = [
    'Bhopal Fulfillment Hub',
    'Indore Agri Warehouse',
    'Sehore Partner Store',
    'Nagpur Regional Hub',
  ];

  Future<CheckoutResult> placeOrder({
    required int amount,
    required String paymentMethod,
    required String upiId,
    required String cardNumber,
    required String cvv,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1050));

    if (paymentMethod == 'UPI') {
      if (!upiId.contains('@')) {
        return const CheckoutResult.failure('Enter a valid UPI ID.');
      }
      if (upiId.toLowerCase().contains('fail')) {
        return const CheckoutResult.failure(
          'UPI app declined this demo collect request.',
        );
      }
    }

    if (paymentMethod == 'Card') {
      final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 12) {
        return const CheckoutResult.failure('Enter a valid demo card number.');
      }
      if (cvv.length < 3) {
        return const CheckoutResult.failure('Enter a valid CVV.');
      }
      if (cvv == '000') {
        return const CheckoutResult.failure(
          'Bank declined this demo card transaction.',
        );
      }
    }

    if (paymentMethod == 'Cash on Delivery' && amount > 2000) {
      return const CheckoutResult.failure(
        'Cash on Delivery is available only up to Rs 2,000.',
      );
    }

    return CheckoutResult.success('FX${100000 + Random().nextInt(899999)}');
  }
}

class DemoOrderHistoryStore extends ChangeNotifier {
  DemoOrderHistoryStore._() {
    final now = DateTime.now();
    _orders.addAll([
      DemoOrderRecord(
        orderId: 'FX284931',
        amount: 1778,
        paymentMethod: 'UPI',
        couponCode: 'KISAN10',
        placedAt: now.subtract(const Duration(days: 2, hours: 4)),
        status: DemoOrderStatus.shipped,
        lines: const [
          CartLine(product: _demoWheatSeeds, quantity: 1),
          CartLine(product: _demoDapFertilizer, quantity: 1),
        ],
      ),
      DemoOrderRecord(
        orderId: 'FX193482',
        amount: 420,
        paymentMethod: 'Cash on Delivery',
        placedAt: now.subtract(const Duration(days: 9)),
        status: DemoOrderStatus.delivered,
        lines: const [CartLine(product: _demoNeemPesticide, quantity: 1)],
      ),
    ]);
  }

  static final DemoOrderHistoryStore instance = DemoOrderHistoryStore._();

  final List<DemoOrderRecord> _orders = [];

  List<DemoOrderRecord> get orders => List.unmodifiable(_orders);

  void add(DemoOrderRecord order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void cancelOrder(String orderId, String reason) {
    final index = _orders.indexWhere((order) => order.orderId == orderId);
    if (index == -1) return;
    _orders[index] = _orders[index].cancelled(reason);
    notifyListeners();
  }
}

enum DemoOrderStatus { confirmed, shipped, delivered, cancelled }

class DemoOrderRecord {
  const DemoOrderRecord({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.placedAt,
    required this.status,
    required this.lines,
    this.couponCode,
    this.cancelReason,
    this.cancelledAt,
  });

  factory DemoOrderRecord.fromCart({
    required String orderId,
    required int amount,
    required String paymentMethod,
    required List<CartLine> lines,
    String? couponCode,
  }) {
    return DemoOrderRecord(
      orderId: orderId,
      amount: amount,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      placedAt: DateTime.now(),
      status: DemoOrderStatus.confirmed,
      lines: List.unmodifiable(lines),
    );
  }

  final String orderId;
  final int amount;
  final String paymentMethod;
  final DateTime placedAt;
  final DemoOrderStatus status;
  final List<CartLine> lines;
  final String? couponCode;
  final String? cancelReason;
  final DateTime? cancelledAt;

  int get totalItems => lines.fold(0, (sum, line) => sum + line.quantity);

  bool get canCancel => status != DemoOrderStatus.cancelled;

  bool get isCancelled => status == DemoOrderStatus.cancelled;

  String get itemPreview {
    if (lines.isEmpty) return 'Store order';
    return lines
        .map((line) => '${line.product.name} x${line.quantity}')
        .join(', ');
  }

  String get dateLabel => _formatShortDate(placedAt);

  String get statusLabel {
    switch (status) {
      case DemoOrderStatus.confirmed:
        return 'Confirmed';
      case DemoOrderStatus.shipped:
        return 'Shipped';
      case DemoOrderStatus.delivered:
        return 'Delivered';
      case DemoOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case DemoOrderStatus.confirmed:
        return Icons.receipt_long_outlined;
      case DemoOrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case DemoOrderStatus.delivered:
        return Icons.check_circle_outline_rounded;
      case DemoOrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color get statusColor {
    switch (status) {
      case DemoOrderStatus.confirmed:
        return const Color(0xFF2563EB);
      case DemoOrderStatus.shipped:
        return const Color(0xFFF59E0B);
      case DemoOrderStatus.delivered:
        return _mainGreen;
      case DemoOrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  DemoOrderRecord cancelled(String reason) {
    return DemoOrderRecord(
      orderId: orderId,
      amount: amount,
      paymentMethod: paymentMethod,
      placedAt: placedAt,
      status: DemoOrderStatus.cancelled,
      lines: lines,
      couponCode: couponCode,
      cancelReason: reason,
      cancelledAt: DateTime.now(),
    );
  }
}

const _demoWheatSeeds = CartProduct(
  id: 1,
  name: 'Hybrid Wheat Seeds',
  quantityLabel: '10 kg',
  price: 1250,
  iconCodePoint: 0xe2c1,
  colorValue: 0xFF16823A,
  category: 'Seeds',
);

const _demoDapFertilizer = CartProduct(
  id: 2,
  name: 'DAP Fertilizer',
  quantityLabel: '45 kg',
  price: 1350,
  iconCodePoint: 0xe4f4,
  colorValue: 0xFF2563EB,
  category: 'Fertilizers',
);

const _demoNeemPesticide = CartProduct(
  id: 3,
  name: 'Neem Pesticide',
  quantityLabel: '1 litre',
  price: 420,
  iconCodePoint: 0xe1e6,
  colorValue: 0xFFF59E0B,
  category: 'Pesticides',
);

class DemoCoupon {
  const DemoCoupon({
    required this.code,
    required this.title,
    required this.minOrder,
    this.flatDiscount,
    this.percent,
    this.maxDiscount,
    this.paymentMethod,
  });

  final String code;
  final String title;
  final int minOrder;
  final int? flatDiscount;
  final int? percent;
  final int? maxDiscount;
  final String? paymentMethod;
}

class DemoOrderTracking {
  const DemoOrderTracking({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.courier,
    required this.awb,
    required this.fulfillmentCenter,
    required this.etaLabel,
    required this.progress,
    required this.currentStep,
    required this.steps,
    required this.events,
    required this.supportMessage,
  });

  final String orderId;
  final int amount;
  final String paymentMethod;
  final String courier;
  final String awb;
  final String fulfillmentCenter;
  final String etaLabel;
  final double progress;
  final DemoTrackingStep currentStep;
  final List<DemoTrackingStep> steps;
  final List<DemoTrackingEvent> events;
  final String supportMessage;
}

class DemoTrackingStep {
  const DemoTrackingStep({
    required this.title,
    required this.detail,
    required this.timeLabel,
    required this.icon,
    required this.completed,
  });

  final String title;
  final String detail;
  final String timeLabel;
  final IconData icon;
  final bool completed;
}

class DemoTrackingEvent {
  const DemoTrackingEvent({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
}

String _formatTrackingTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '${_formatShortDate(value)}, $hour:$minute $suffix';
}

String _formatShortDate(DateTime value) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(value.year, value.month, value.day);
  if (date == today) return 'Today';
  if (date == today.add(const Duration(days: 1))) return 'Tomorrow';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]}';
}

class CheckoutResult {
  const CheckoutResult._({
    required this.success,
    required this.message,
    this.orderId,
  });

  const CheckoutResult.success(String orderId)
    : this._(success: true, message: 'Payment successful', orderId: orderId);

  const CheckoutResult.failure(String message)
    : this._(success: false, message: message);

  final bool success;
  final String message;
  final String? orderId;
}

class _CouponSheet extends StatefulWidget {
  const _CouponSheet({required this.cart, this.paymentMethod = 'UPI'});

  final CartController cart;
  final String paymentMethod;

  @override
  State<_CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<_CouponSheet> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backend = DemoCheckoutBackend.instance;
    final offers = backend.coupons;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Offers & Coupons',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFCFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _cartBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _applyTypedCode,
                  style: FilledButton.styleFrom(
                    backgroundColor: _mainGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(92, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Best offers for you',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: offers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final coupon = offers[index];
                  final discount = backend.discountFor(
                    coupon,
                    widget.cart,
                    widget.paymentMethod,
                  );
                  final available = discount > 0;

                  return _CouponOfferTile(
                    coupon: coupon,
                    discount: discount,
                    available: available,
                    message: backend.couponMessage(
                      coupon,
                      widget.cart,
                      widget.paymentMethod,
                    ),
                    onApply: () => Navigator.of(context).pop(coupon),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyTypedCode() {
    final code = _codeController.text.trim().toUpperCase();
    final coupon = DemoCheckoutBackend.instance.couponByCode(code);
    if (coupon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid coupon code. Try FASAL150, KISAN10 or UPI100.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(coupon);
  }
}

class _CouponOfferTile extends StatelessWidget {
  const _CouponOfferTile({
    required this.coupon,
    required this.discount,
    required this.available,
    required this.message,
    required this.onApply,
  });

  final DemoCoupon coupon;
  final int discount;
  final bool available;
  final String message;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: available ? _lightGreen : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: available ? _mainGreen : _cartBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              available
                  ? Icons.local_offer_rounded
                  : Icons.lock_outline_rounded,
              color: available ? _mainGreen : _secondaryText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  coupon.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  available ? 'Save ${_money(discount)} now' : message,
                  style: TextStyle(
                    color: available ? _mainGreen : _secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: available ? onApply : null,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
