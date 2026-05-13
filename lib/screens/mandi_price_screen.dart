import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/backend_repositories.dart';
import 'notifications_screen.dart';
import '../theme/app_theme.dart';

class MandiPriceScreen extends StatefulWidget {
  const MandiPriceScreen({super.key, this.onBack, this.onOpenAiAdvice});

  final VoidCallback? onBack;
  final VoidCallback? onOpenAiAdvice;

  @override
  State<MandiPriceScreen> createState() => _MandiPriceScreenState();
}

class _MandiPriceScreenState extends State<MandiPriceScreen> {
  final _backend = DemoMandiBackend.instance;
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _refreshing = false;

  static const _filters = [
    'All',
    'Grains',
    'Vegetables',
    'Fruits',
    'Pulses',
    'Oil Seeds',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MandiCropPrice> get _filteredPrices {
    final query = _searchController.text.trim().toLowerCase();
    return _backend.prices.where((price) {
      final matchesFilter =
          _selectedFilter == 'All' || price.category == _selectedFilter;
      final matchesQuery =
          query.isEmpty ||
          price.crop.toLowerCase().contains(query) ||
          price.mandi.toLowerCase().contains(query) ||
          price.category.toLowerCase().contains(query) ||
          price.location.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await _backend.refresh();
    if (!mounted) return;
    setState(() => _refreshing = false);
    _snack('Latest mandi prices refreshed.');
  }

  void _back() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(duration: const Duration(milliseconds: 2500), content: Text(message)));
  }

  Future<void> _openSellCropScreen() async {
    final submitted = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const SellCropScreen()));
    if (submitted == true && mounted) {
      _snack('Sell crop request submitted to nearby mandis.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _backend,
        builder: (context, _) {
          final prices = _filteredPrices;
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 116),
                    sliver: SliverList.list(
                      children: [
                        _MandiHeader(
                          refreshing: _refreshing,
                          selectedLocation: _backend.selectedLocation,
                          onBack: _back,
                          onRefresh: _refresh,
                          onNotify: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                          onLocation: () => _showLocationSheet(),
                        ),
                        const SizedBox(height: 16),
                        _SearchAndFilters(
                          controller: _searchController,
                          filters: _filters,
                          selectedFilter: _selectedFilter,
                          onSearchChanged: (_) => setState(() {}),
                          onFilterChanged: (filter) =>
                              setState(() => _selectedFilter = filter),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Market Rates',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: fx.textStrong,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                    ),
                              ),
                            ),
                            Text(
                              '${prices.length} crops',
                              style: TextStyle(
                                color: fx.textMuted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (final price in prices) ...[
                          _MandiPriceCard(
                            price: price,
                            onFavorite: () {
                              _backend.toggleFavorite(price.id);
                              _snack(
                                price.favorite
                                    ? '${price.crop} removed from favorites.'
                                    : '${price.crop} added to favorites.',
                              );
                            },
                            onAlert: () {
                              _backend.toggleAlert(price.id);
                              DemoNotificationCenter.instance
                                  .addMandiPriceAlert(
                                    crop: price.crop,
                                    mandi: price.mandi,
                                    price: 'Rs ${price.modalPrice} per quintal',
                                    enabled: price.alertEnabled,
                                  );
                              showNotificationSnackBar(
                                context,
                                price.alertEnabled
                                    ? 'You will be notified when ${price.crop} price increases.'
                                    : 'Alert disabled for ${price.crop}.',
                              );
                            },
                            onCompare: () => _showCompareSheet(price),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 6),
                        _TrendAnalyticsCard(trend: _backend.trend),
                        const SizedBox(height: 22),
                        Text(
                          'Quick Actions',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: fx.textStrong,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _MandiQuickActions(
                          onSellCrop: _openSellCropScreen,
                          onFindBestMandi: () => _showBestMandiSheet(),
                          onDownloadReport: () =>
                              _snack('Mandi report downloaded successfully.'),
                          onAiAdvice:
                              widget.onOpenAiAdvice ??
                              () => _showAiAdviceSheet(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLocationSheet() {
    final fx = context.fx;
    final addressController = TextEditingController(
      text: _backend.selectedLocation,
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: fx.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        var detecting = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> useCurrentLocation() async {
              setSheetState(() => detecting = true);
              final address = await _backend.detectCurrentAddress();
              setSheetState(() {
                addressController.text = address;
                detecting = false;
              });
            }

            void saveAddress() {
              final address = addressController.text.trim();
              if (address.isEmpty) return;
              _backend.setLocation(address);
              Navigator.of(context).pop();
              _snack('Market address updated.');
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                6,
                20,
                24 +
                    MediaQuery.of(context).padding.bottom +
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Market Address',
                    style: TextStyle(
                      color: fx.textStrong,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use your current location or enter an address to find nearby mandi prices.',
                    style: TextStyle(color: fx.textMuted, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: detecting ? null : useCurrentLocation,
                    icon: detecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                    label: Text(
                      detecting
                          ? 'Detecting Location...'
                          : 'Use Current Location',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: addressController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Address / village / city',
                      hintText: 'House, area, city, state',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    onSubmitted: (_) => saveAddress(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Suggested nearby addresses',
                    style: TextStyle(
                      color: fx.textStrong,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final address in DemoMandiBackend.suggestedAddresses)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: fx.selectedFill,
                        child: Icon(
                          Icons.near_me_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(address),
                      trailing: address == _backend.selectedLocation
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        _backend.setLocation(address);
                        Navigator.of(context).pop();
                      },
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: saveAddress,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Save Address'),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(addressController.dispose);
  }

  void _showCompareSheet(MandiCropPrice price) {
    final fx = context.fx;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: fx.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          6,
          20,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compare ${price.crop}',
              style: TextStyle(
                color: fx.textStrong,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _CompareRow(mandi: 'Bhopal Mandi', price: price.modalPrice),
            _CompareRow(mandi: 'Indore Mandi', price: price.modalPrice + 90),
            _CompareRow(mandi: 'Sehore Mandi', price: price.modalPrice - 65),
          ],
        ),
      ),
    );
  }

  void _showBestMandiSheet() {
    final fx = context.fx;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: fx.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          6,
          20,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Best Nearby Mandis',
              style: TextStyle(
                color: fx.textStrong,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _NearbyMandiTile(name: 'Sehore Mandi', distance: '8.4 km'),
            const _NearbyMandiTile(name: 'Bhopal Mandi', distance: '28 km'),
            const _NearbyMandiTile(name: 'Indore Mandi', distance: '162 km'),
          ],
        ),
      ),
    );
  }

  void _showAiAdviceSheet() {
    final fx = context.fx;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: fx.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          6,
          20,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: fx.selectedFill,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'AI Market Advice',
              style: TextStyle(
                color: fx.textStrong,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wheat and soybean prices are firm today. If transport is available, compare Sehore and Bhopal before selling.',
              style: TextStyle(color: fx.textMuted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class SellCropScreen extends StatefulWidget {
  const SellCropScreen({super.key});

  @override
  State<SellCropScreen> createState() => _SellCropScreenState();
}

class _SellCropScreenState extends State<SellCropScreen> {
  final _backend = DemoMandiBackend.instance;
  final _quantityController = TextEditingController(text: '25');
  final _expectedPriceController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  late String _crop = _backend.prices.first.crop;
  late String _mandi = _backend.prices.first.mandi;
  String _unit = 'Quintal';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final first = _backend.prices.first;
    _expectedPriceController.text = first.modalPrice.toString();
    _addressController.text = _backend.selectedLocation;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _expectedPriceController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final address = await _backend.detectCurrentAddress();
    if (!mounted) return;
    setState(() => _addressController.text = address);
  }

  Future<void> _submit() async {
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final price = int.tryParse(_expectedPriceController.text.trim()) ?? 0;
    final address = _addressController.text.trim();
    if (quantity <= 0 || price <= 0 || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(milliseconds: 2500),
          content: Text('Add quantity, expected price, and pickup address.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    await _backend.submitSellRequest(
      SellCropRequest(
        crop: _crop,
        mandi: _mandi,
        quantity: quantity,
        unit: _unit,
        expectedPrice: price,
        pickupAddress: address,
        notes: _notesController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final crops = _backend.prices.map((price) => price.crop).toSet().toList();
    final mandis = _backend.prices.map((price) => price.mandi).toSet().toList();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Sell Crop',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: fx.surface,
          border: Border(top: BorderSide(color: fx.border)),
          boxShadow: _softShadow(context),
        ),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sell_outlined),
          label: Text(_submitting ? 'Submitting...' : 'Submit Sell Request'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: fx.selectedFill,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withAlpha(42),
              ),
              boxShadow: _softShadow(context),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: fx.surface,
                  child: Icon(
                    Icons.storefront_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create a crop sale request. Nearby mandis will receive your expected price and pickup details.',
                    style: TextStyle(
                      color: fx.textStrong,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SellFormCard(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _crop,
                  decoration: const InputDecoration(
                    labelText: 'Crop',
                    prefixIcon: Icon(Icons.eco_outlined),
                  ),
                  items: [
                    for (final crop in crops)
                      DropdownMenuItem(value: crop, child: Text(crop)),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    final price = _backend.prices.firstWhere(
                      (item) => item.crop == value,
                    );
                    setState(() {
                      _crop = value;
                      _expectedPriceController.text = price.modalPrice
                          .toString();
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _mandi,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Mandi',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  items: [
                    for (final mandi in mandis)
                      DropdownMenuItem(value: mandi, child: Text(mandi)),
                  ],
                  onChanged: (value) =>
                      setState(() => _mandi = value ?? _mandi),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: Icon(Icons.scale_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 128,
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Quintal',
                            child: Text('Quintal'),
                          ),
                          DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                          DropdownMenuItem(value: 'Ton', child: Text('Ton')),
                        ],
                        onChanged: (value) =>
                            setState(() => _unit = value ?? _unit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _expectedPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expected Price',
                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                    suffixText: '/ quintal',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Pickup Address',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: IconButton(
                      tooltip: 'Use current location',
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText:
                        'Quality, harvest date, transport availability...',
                    prefixIcon: Icon(Icons.notes_outlined),
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

class _SellFormCard extends StatelessWidget {
  const _SellFormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fx.border),
        boxShadow: _softShadow(context),
      ),
      child: child,
    );
  }
}

class _MandiHeader extends StatelessWidget {
  const _MandiHeader({
    required this.refreshing,
    required this.selectedLocation,
    required this.onBack,
    required this.onRefresh,
    required this.onNotify,
    required this.onLocation,
  });

  final bool refreshing;
  final String selectedLocation;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onNotify;
  final VoidCallback onLocation;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _HeaderButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mandi Prices',
                    style: TextStyle(
                      color: fx.textStrong,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live Market Rates',
                    style: TextStyle(
                      color: fx.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
              onTap: onNotify,
            ),
            const SizedBox(width: 8),
            _HeaderButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
              spinning: refreshing,
              onTap: onRefresh,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Material(
          color: fx.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: fx.border),
                boxShadow: _softShadow(context),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedLocation,
                      style: TextStyle(
                        color: fx.textStrong,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: fx.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.spinning = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final child = Icon(icon, color: fx.textStrong);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: fx.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: spinning
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      builder: (context, value, child) => Transform.rotate(
                        angle: math.pi * 2 * value,
                        child: child,
                      ),
                      child: child,
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.filters,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search crops, mandi, category...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: fx.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: fx.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: fx.border),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final filter in filters) ...[
                ChoiceChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  selectedColor: fx.selectedFill,
                  labelStyle: TextStyle(
                    color: selectedFilter == filter
                        ? Theme.of(context).colorScheme.primary
                        : fx.textMuted,
                    fontWeight: FontWeight.w900,
                  ),
                  side: BorderSide(
                    color: selectedFilter == filter
                        ? Theme.of(context).colorScheme.primary
                        : fx.border,
                  ),
                  onSelected: (_) => onFilterChanged(filter),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MandiPriceCard extends StatelessWidget {
  const _MandiPriceCard({
    required this.price,
    required this.onFavorite,
    required this.onAlert,
    required this.onCompare,
  });

  final MandiCropPrice price;
  final VoidCallback onFavorite;
  final VoidCallback onAlert;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final trendColor = price.trendPercent >= 0 ? fx.success : fx.danger;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fx.border),
        boxShadow: _softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: price.color.withAlpha(28),
                child: Icon(price.icon, color: price.color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            price.crop,
                            style: TextStyle(
                              color: fx.textStrong,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Favorite',
                          visualDensity: VisualDensity.compact,
                          onPressed: onFavorite,
                          icon: Icon(
                            price.favorite
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: price.favorite
                                ? Theme.of(context).colorScheme.primary
                                : fx.textMuted,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Price alert',
                          visualDensity: VisualDensity.compact,
                          onPressed: onAlert,
                          icon: Icon(
                            price.alertEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: price.alertEnabled
                                ? fx.warning
                                : fx.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MiniTag(label: price.category, color: price.color),
                        _MiniTag(label: price.grade, color: fx.info),
                        _MiniTag(
                          label: price.recommendation,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: fx.textMuted, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${price.mandi}, ${price.location}',
                  style: TextStyle(
                    color: fx.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                price.distance,
                style: TextStyle(
                  color: fx.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Arrival: ${price.arrival}',
            style: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 420;
              final children = [
                _PriceMetric(label: 'Min', value: price.minPrice),
                _PriceMetric(label: 'Max', value: price.maxPrice),
                _PriceMetric(label: 'Modal', value: price.modalPrice),
              ];
              if (narrow) {
                return Column(
                  children: [
                    Row(children: children.take(2).toList()),
                    const SizedBox(height: 8),
                    Row(children: [children.last]),
                  ],
                );
              }
              return Row(children: children);
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: trendColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      price.trendPercent >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: trendColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${price.trendPercent.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Sparkline(values: price.sparkline, color: trendColor),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: onCompare,
                icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                label: const Text('Compare'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            price.updated,
            style: TextStyle(
              color: fx.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceMetric extends StatelessWidget {
  const _PriceMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fx.fieldFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: fx.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs $value',
              style: TextStyle(
                color: fx.textStrong,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '/ quintal',
              style: TextStyle(
                color: fx.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).abs() < 1 ? 1 : maxValue - minValue;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minValue) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _TrendAnalyticsCard extends StatelessWidget {
  const _TrendAnalyticsCard({required this.trend});

  final List<MandiTrendPoint> trend;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fx.border),
        boxShadow: _softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Trend Analytics',
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Weekly market movement',
            style: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 230,
            width: double.infinity,
            child: CustomPaint(
              painter: _MandiTrendPainter(
                trend: trend,
                lineColor: Theme.of(context).colorScheme.primary,
                gridColor: fx.border,
                textColor: fx.textMuted,
                strongTextColor: fx.textStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MandiTrendPainter extends CustomPainter {
  const _MandiTrendPainter({
    required this.trend,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.strongTextColor,
  });

  final List<MandiTrendPoint> trend;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final Color strongTextColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 12.0;
    const top = 22.0;
    const bottom = 34.0;
    final chart = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );
    final minValue = trend.map((e) => e.price).reduce(math.min) - 80;
    final maxValue = trend.map((e) => e.price).reduce(math.max) + 80;
    final range = maxValue - minValue;

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }

    final points = <Offset>[];
    for (var i = 0; i < trend.length; i++) {
      final x = chart.left + chart.width * i / (trend.length - 1);
      final y =
          chart.bottom - ((trend[i].price - minValue) / range) * chart.height;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final mid = Offset((current.dx + next.dx) / 2, current.dy);
      linePath.quadraticBezierTo(mid.dx, mid.dy, next.dx, next.dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withAlpha(54), lineColor.withAlpha(0)],
        ).createShader(chart),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, Paint()..color = lineColor);
      canvas.drawCircle(
        points[i],
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        'Rs ${trend[i].price}',
        points[i] - const Offset(0, 21),
        strongTextColor,
        10,
        FontWeight.w900,
        center: true,
      );
      _drawText(
        canvas,
        trend[i].label,
        Offset(points[i].dx, chart.bottom + 18),
        textColor,
        10,
        FontWeight.w700,
        center: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
    FontWeight weight, {
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center ? offset - Offset(painter.width / 2, 0) : offset,
    );
  }

  @override
  bool shouldRepaint(covariant _MandiTrendPainter oldDelegate) {
    return oldDelegate.trend != trend || oldDelegate.lineColor != lineColor;
  }
}

class _MandiQuickActions extends StatelessWidget {
  const _MandiQuickActions({
    required this.onSellCrop,
    required this.onFindBestMandi,
    required this.onDownloadReport,
    required this.onAiAdvice,
  });

  final VoidCallback onSellCrop;
  final VoidCallback onFindBestMandi;
  final VoidCallback onDownloadReport;
  final VoidCallback onAiAdvice;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = constraints.maxWidth >= 720 ? 2.6 : 1.55;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: ratio,
          children: [
            _QuickActionCard(
              icon: Icons.sell_outlined,
              title: 'Sell Crop',
              color: fx.success,
              background: fx.successContainer,
              onTap: onSellCrop,
            ),
            _QuickActionCard(
              icon: Icons.location_searching_rounded,
              title: 'Find Best Mandi',
              color: fx.warning,
              background: fx.warningContainer,
              onTap: onFindBestMandi,
            ),
            _QuickActionCard(
              icon: Icons.download_rounded,
              title: 'Download Report',
              color: fx.info,
              background: fx.infoContainer,
              onTap: onDownloadReport,
            ),
            _QuickActionCard(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Market Advice',
              color: Theme.of(context).colorScheme.primary,
              background: fx.selectedFill,
              onTap: onAiAdvice,
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.97 : 1,
      child: Material(
        color: fx.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: fx.border),
              boxShadow: _softShadow(context),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: widget.background,
                  child: Icon(widget.icon, color: widget.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: fx.textStrong,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
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

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.mandi, required this.price});

  final String mandi;
  final int price;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: context.fx.selectedFill,
        child: Icon(
          Icons.storefront_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(mandi),
      trailing: Text(
        'Rs $price',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _NearbyMandiTile extends StatelessWidget {
  const _NearbyMandiTile({required this.name, required this.distance});

  final String name;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: context.fx.selectedFill,
        child: Icon(
          Icons.near_me_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(name),
      subtitle: Text(distance),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}

class DemoMandiBackend extends ChangeNotifier {
  DemoMandiBackend._();

  static final DemoMandiBackend instance = DemoMandiBackend._();

  static const suggestedAddresses = [
    'Village Kolar Road, Bhopal, Madhya Pradesh',
    'Near Sehore Mandi, Sehore, Madhya Pradesh',
    'Sanwer Road, Indore, Madhya Pradesh',
  ];

  String selectedLocation = suggestedAddresses.first;
  int _tick = 0;
  final _agronomyRepository = const AgronomyRepository();
  final List<SellCropRequest> _sellRequests = [];

  late final List<MandiCropPrice> _prices = [
    MandiCropPrice(
      id: 'wheat',
      crop: 'Wheat',
      category: 'Grains',
      grade: 'FAQ Grade',
      mandi: 'Bhopal Mandi',
      location: 'Madhya Pradesh',
      arrival: '240 quintal',
      minPrice: 2220,
      maxPrice: 2380,
      modalPrice: 2300,
      trendPercent: 2.4,
      updated: 'Updated 5 mins ago',
      recommendation: 'Good time to sell',
      distance: '28 km',
      icon: Icons.grass_rounded,
      color: const Color(0xFF10B981),
      sparkline: const [2180, 2210, 2240, 2260, 2300],
    ),
    MandiCropPrice(
      id: 'rice',
      crop: 'Rice',
      category: 'Grains',
      grade: 'Grade A',
      mandi: 'Sehore Mandi',
      location: 'Madhya Pradesh',
      arrival: '180 quintal',
      minPrice: 2050,
      maxPrice: 2180,
      modalPrice: 2110,
      trendPercent: -1.2,
      updated: 'Updated 12 mins ago',
      recommendation: 'Hold for better rate',
      distance: '8.4 km',
      icon: Icons.rice_bowl_outlined,
      color: const Color(0xFF3B82F6),
      sparkline: const [2180, 2160, 2140, 2120, 2110],
    ),
    MandiCropPrice(
      id: 'tomato',
      crop: 'Tomato',
      category: 'Vegetables',
      grade: 'Fresh',
      mandi: 'Indore Mandi',
      location: 'Madhya Pradesh',
      arrival: '95 quintal',
      minPrice: 1320,
      maxPrice: 1680,
      modalPrice: 1580,
      trendPercent: 4.8,
      updated: 'Updated 8 mins ago',
      recommendation: 'Prices expected to rise tomorrow',
      distance: '162 km',
      icon: Icons.local_florist_outlined,
      color: const Color(0xFFF97316),
      sparkline: const [1400, 1440, 1510, 1550, 1580],
    ),
    MandiCropPrice(
      id: 'soybean',
      crop: 'Soybean',
      category: 'Oil Seeds',
      grade: 'Clean',
      mandi: 'Bhopal Mandi',
      location: 'Madhya Pradesh',
      arrival: '320 quintal',
      minPrice: 4380,
      maxPrice: 4620,
      modalPrice: 4500,
      trendPercent: 3.1,
      updated: 'Updated 3 mins ago',
      recommendation: 'Good time to sell',
      distance: '28 km',
      icon: Icons.spa_outlined,
      color: const Color(0xFF10B981),
      sparkline: const [4310, 4380, 4410, 4470, 4500],
    ),
    MandiCropPrice(
      id: 'gram',
      crop: 'Gram',
      category: 'Pulses',
      grade: 'Bold',
      mandi: 'Sehore Mandi',
      location: 'Madhya Pradesh',
      arrival: '130 quintal',
      minPrice: 5150,
      maxPrice: 5380,
      modalPrice: 5280,
      trendPercent: 1.7,
      updated: 'Updated 18 mins ago',
      recommendation: 'Compare nearby mandis',
      distance: '8.4 km',
      icon: Icons.eco_outlined,
      color: const Color(0xFF059669),
      sparkline: const [5100, 5140, 5200, 5240, 5280],
    ),
  ];

  List<MandiCropPrice> get prices => List.unmodifiable(_prices);
  List<SellCropRequest> get sellRequests => List.unmodifiable(_sellRequests);

  List<MandiTrendPoint> get trend => [
    MandiTrendPoint('Last Week', 2180 + _tick),
    MandiTrendPoint('Yesterday', 2250 + _tick),
    MandiTrendPoint('Today', 2300 + _tick),
  ];

  void setLocation(String location) {
    selectedLocation = location;
    notifyListeners();
  }

  Future<String> detectCurrentAddress() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return 'Current Location: Farm Road, Sehore, Madhya Pradesh';
  }

  Future<void> submitSellRequest(SellCropRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _sellRequests.insert(0, request);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final item = _prices.firstWhere((price) => price.id == id);
    item.favorite = !item.favorite;
    notifyListeners();
  }

  void toggleAlert(String id) {
    final item = _prices.firstWhere((price) => price.id == id);
    item.alertEnabled = !item.alertEnabled;
    notifyListeners();
  }

  void enableMandiPriceNotifications() {
    final price = _prices.first;
    DemoNotificationCenter.instance.addMandiPriceAlert(
      crop: price.crop,
      mandi: price.mandi,
      price: 'Rs ${price.modalPrice} per quintal',
      enabled: true,
    );
  }

  Future<void> refresh() async {
    try {
      final data = await _agronomyRepository.mandiPrices();
      final parsed = _parseMandiPrices(data);
      if (parsed.isNotEmpty) {
        _prices
          ..clear()
          ..addAll(parsed);
        notifyListeners();
        return;
      }
    } catch (_) {
      // Demo data remains available when the backend is not running locally.
    }

    await Future<void>.delayed(const Duration(milliseconds: 650));
    _tick += 12;
    for (final price in _prices) {
      price.modalPrice += price.trendPercent >= 0 ? 6 : -4;
      price.updated = 'Updated just now';
    }
    notifyListeners();
  }

  List<MandiCropPrice> _parseMandiPrices(dynamic data) {
    final records = data is List
        ? data
        : data is Map && data['records'] is List
        ? data['records'] as List
        : data is Map && data['data'] is List
        ? data['data'] as List
        : data is Map && data['commodities'] is List
        ? data['commodities'] as List
        : const [];

    return [
      for (final item in records)
        if (item is Map)
          MandiCropPrice(
            id:
                item['id']?.toString() ??
                '${item['commodity'] ?? item['crop'] ?? 'crop'}-${item['market'] ?? item['mandi'] ?? 'market'}',
            crop:
                item['commodity']?.toString() ??
                item['crop']?.toString() ??
                'Crop',
            category: item['category']?.toString() ?? 'All',
            grade: item['grade']?.toString() ?? 'FAQ Grade',
            mandi:
                item['market']?.toString() ??
                item['mandi']?.toString() ??
                'Nearby Mandi',
            location: item['state']?.toString() ?? item['location']?.toString() ?? '',
            arrival: item['arrival']?.toString() ?? 'Live arrival',
            minPrice: _asInt(item['min_price'] ?? item['minPrice']),
            maxPrice: _asInt(item['max_price'] ?? item['maxPrice']),
            modalPrice: _asInt(item['modal_price'] ?? item['modalPrice']),
            trendPercent: _asDouble(item['trend_percent'] ?? item['trendPercent']),
            updated: 'Updated just now',
            recommendation: item['recommendation']?.toString() ?? 'Compare nearby mandis',
            distance: item['distance']?.toString() ?? '',
            icon: Icons.eco_outlined,
            color: const Color(0xFF10B981),
            sparkline: const [0, 1, 2, 3, 4],
          ),
    ];
  }

  int _asInt(Object? value) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class MandiCropPrice {
  MandiCropPrice({
    required this.id,
    required this.crop,
    required this.category,
    required this.grade,
    required this.mandi,
    required this.location,
    required this.arrival,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.trendPercent,
    required this.updated,
    required this.recommendation,
    required this.distance,
    required this.icon,
    required this.color,
    required this.sparkline,
    this.favorite = false,
    this.alertEnabled = false,
  });

  final String id;
  final String crop;
  final String category;
  final String grade;
  final String mandi;
  final String location;
  final String arrival;
  final int minPrice;
  final int maxPrice;
  int modalPrice;
  final double trendPercent;
  String updated;
  final String recommendation;
  final String distance;
  final IconData icon;
  final Color color;
  final List<double> sparkline;
  bool favorite;
  bool alertEnabled;
}

class MandiTrendPoint {
  const MandiTrendPoint(this.label, this.price);

  final String label;
  final int price;
}

class SellCropRequest {
  const SellCropRequest({
    required this.crop,
    required this.mandi,
    required this.quantity,
    required this.unit,
    required this.expectedPrice,
    required this.pickupAddress,
    required this.notes,
  });

  final String crop;
  final String mandi;
  final double quantity;
  final String unit;
  final int expectedPrice;
  final String pickupAddress;
  final String notes;
}

List<BoxShadow> _softShadow(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withAlpha(isDark ? 70 : 18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
