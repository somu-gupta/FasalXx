import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/delivery_address.dart';
import '../services/address_controller.dart';

const _mainGreen = Color(0xFF0F9D6C);
const _lightGreen = Color(0xFFE8F7EF);
const _accentGreen = Color(0xFF22C55E);
const _border = Color(0xFFE5E7EB);
const _darkText = Color(0xFF17211C);
const _mutedText = Color(0xFF647067);

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddressController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Select Delivery Address',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _CurrentLocationCard(
              loading: controller.loadingLocation,
              onTap: () => _useCurrentLocation(controller),
            ),
            const SizedBox(height: 16),
            _SearchAddressField(
              controller: _searchController,
              suggestions: controller.suggestions,
              onChanged: (value) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 360), () {
                  controller.searchPlaces(value);
                });
              },
              onSuggestionTap: (suggestion) =>
                  _selectSuggestion(controller, suggestion),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Saved Addresses',
                    style: TextStyle(
                      color: _darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openAddressSheet(),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (controller.addresses.isEmpty)
              _EmptyAddressCard(onTap: () => _openAddressSheet())
            else
              for (final address in controller.addresses) ...[
                _SavedAddressCard(
                  address: address,
                  active: controller.activeAddress?.id == address.id,
                  onDeliver: () async {
                    await controller.selectDeliveryAddress(address.id);
                    if (!mounted) return;
                    Navigator.of(context).pop(address);
                  },
                  onEdit: () => _openAddressSheet(address: address),
                  onDelete: () => _confirmDelete(controller, address),
                  onMakeDefault: () => controller.makeDefault(address.id),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation(AddressController controller) async {
    try {
      final draft = await controller.detectCurrentLocation();
      if (!mounted) return;
      _openAddressSheet(draft: draft);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(duration: const Duration(milliseconds: 2500), content: Text('$error')));
    }
  }

  Future<void> _selectSuggestion(
    AddressController controller,
    PlaceSuggestion suggestion,
  ) async {
    final draft = await controller.selectSuggestion(suggestion);
    if (!mounted || draft == null) return;
    _searchController.clear();
    _openAddressSheet(draft: draft);
  }

  Future<void> _openAddressSheet({
    DeliveryAddress? address,
    AddressDraft? draft,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressFormSheet(address: address, draft: draft),
    );
  }

  Future<void> _confirmDelete(
    AddressController controller,
    DeliveryAddress address,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text(address.fullAddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await controller.deleteAddress(address.id);
    }
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _lightGreen,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _mainGreen.withAlpha(35), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F9D6C),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: _mainGreen,
                        ),
                      )
                    : const Icon(
                        Icons.my_location_rounded,
                        color: _mainGreen,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loading
                          ? 'Detecting your location...'
                          : 'Use Current Location',
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Automatically detect your address',
                      style: TextStyle(
                        color: _mutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _mainGreen),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchAddressField extends StatelessWidget {
  const _SearchAddressField({
    required this.controller,
    required this.suggestions,
    required this.onChanged,
    required this.onSuggestionTap,
  });

  final TextEditingController controller;
  final List<PlaceSuggestion> suggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<PlaceSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 18,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search area, street, village or pincode',
              prefixIcon: Icon(Icons.search_rounded),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: suggestions.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 18,
                        offset: Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (final suggestion in suggestions)
                        ListTile(
                          leading: const Icon(
                            Icons.place_outlined,
                            color: _mainGreen,
                          ),
                          title: Text(
                            suggestion.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: suggestion.subtitle.isEmpty
                              ? null
                              : Text(suggestion.subtitle),
                          onTap: () => onSuggestionTap(suggestion),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _SavedAddressCard extends StatelessWidget {
  const _SavedAddressCard({
    required this.address,
    required this.active,
    required this.onDeliver,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
  });

  final DeliveryAddress address;
  final bool active;
  final VoidCallback onDeliver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: active ? _lightGreen : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: active ? _mainGreen : _border, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AddressTypeIcon(type: address.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          address.typeLabel,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (address.isDefault) const _DefaultBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(color: _mutedText, height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${address.fullName}  |  ${address.mobileNumber}',
                      style: const TextStyle(
                        color: _darkText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Edit address',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete address',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onDeliver,
                  style: FilledButton.styleFrom(
                    backgroundColor: _mainGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Deliver Here'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: address.isDefault ? null : onMakeDefault,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(116, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Default'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet({this.address, this.draft});

  final DeliveryAddress? address;
  final AddressDraft? draft;

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _house;
  late final TextEditingController _area;
  late final TextEditingController _landmark;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  late AddressType _type;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    final draft = widget.draft;
    _name = TextEditingController(text: address?.fullName ?? '');
    _mobile = TextEditingController(text: address?.mobileNumber ?? '');
    _house = TextEditingController(text: address?.house ?? draft?.house ?? '');
    _area = TextEditingController(text: address?.area ?? draft?.area ?? '');
    _landmark = TextEditingController(
      text: address?.landmark ?? draft?.landmark ?? '',
    );
    _city = TextEditingController(text: address?.city ?? draft?.city ?? '');
    _state = TextEditingController(text: address?.state ?? draft?.state ?? '');
    _pincode = TextEditingController(
      text: address?.pincode ?? draft?.pincode ?? '',
    );
    _type = address?.type ?? AddressType.home;
    _latitude = address?.latitude ?? draft?.latitude;
    _longitude = address?.longitude ?? draft?.longitude;
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _house.dispose();
    _area.dispose();
    _landmark.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.address == null
                          ? 'Add New Address'
                          : 'Edit Address',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Pick on map',
                    onPressed: _openMapPicker,
                    icon: const Icon(Icons.map_outlined, color: _mainGreen),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  children: [
                    _FormField(
                      controller: _name,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    _FormField(
                      controller: _mobile,
                      label: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _validateMobile,
                    ),
                    _FormField(
                      controller: _house,
                      label: 'House No / Farm Name',
                      icon: Icons.home_work_outlined,
                    ),
                    _FormField(
                      controller: _area,
                      label: 'Street / Area',
                      icon: Icons.route_outlined,
                    ),
                    _FormField(
                      controller: _landmark,
                      label: 'Landmark',
                      icon: Icons.flag_outlined,
                      required: false,
                    ),
                    _FormField(
                      controller: _city,
                      label: 'Village / City',
                      icon: Icons.location_city_outlined,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            controller: _state,
                            label: 'State',
                            icon: Icons.map_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FormField(
                            controller: _pincode,
                            label: 'Pincode',
                            icon: Icons.pin_drop_outlined,
                            keyboardType: TextInputType.number,
                            validator: _validatePincode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Address Type',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<AddressType>(
                      segments: const [
                        ButtonSegment(
                          value: AddressType.home,
                          icon: Icon(Icons.home_outlined),
                          label: Text('Home'),
                        ),
                        ButtonSegment(
                          value: AddressType.farm,
                          icon: Icon(Icons.agriculture_outlined),
                          label: Text('Farm'),
                        ),
                        ButtonSegment(
                          value: AddressType.office,
                          icon: Icon(Icons.business_outlined),
                          label: Text('Office'),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (value) =>
                          setState(() => _type = value.first),
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: _lightGreen,
                        selectedForegroundColor: _mainGreen,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: _mainGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save Address'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateMobile(String? value) {
    final text = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (text.length < 10) return 'Enter valid mobile';
    return null;
  }

  String? _validatePincode(String? value) {
    final text = value?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(text)) return 'Enter 6 digit pincode';
    return null;
  }

  Future<void> _openMapPicker() async {
    final draft = await Navigator.of(context).push<AddressDraft>(
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    if (draft == null || !mounted) return;
    _applyDraft(draft);
  }

  void _applyDraft(AddressDraft draft) {
    setState(() {
      _house.text = draft.house;
      _area.text = draft.area;
      _landmark.text = draft.landmark;
      _city.text = draft.city;
      _state.text = draft.state;
      _pincode.text = draft.pincode;
      _latitude = draft.latitude;
      _longitude = draft.longitude;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<AddressController>();
    final original = widget.address;
    final address = DeliveryAddress(
      id: original?.id ?? 'addr-${DateTime.now().microsecondsSinceEpoch}',
      fullName: _name.text.trim(),
      mobileNumber: _mobile.text.trim(),
      house: _house.text.trim(),
      area: _area.text.trim(),
      landmark: _landmark.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      pincode: _pincode.text.trim(),
      type: _type,
      isDefault: original?.isDefault ?? controller.addresses.isEmpty,
      latitude: _latitude,
      longitude: _longitude,
    );
    await controller.upsertAddress(address);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late LatLng _pin;
  Timer? _reverseDebounce;
  AddressDraft? _draft;
  String _preview = 'Move the pin to update address';
  bool _loading = false;

  bool get _mapsSupported {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _pin = LatLng(
      widget.initialLatitude ?? 23.2599,
      widget.initialLongitude ?? 77.4126,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAddress());
  }

  @override
  void dispose() {
    _reverseDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pick Location',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (_mapsSupported)
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _pin, zoom: 16),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId('delivery-pin'),
                  position: _pin,
                  draggable: true,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  onDragEnd: _movePin,
                ),
              },
              onTap: _movePin,
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Google Maps location picker is available on Android and iOS devices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    _loading ? 'Updating address...' : _preview,
                    style: const TextStyle(
                      color: _darkText,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: _mainGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Confirm Location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _movePin(LatLng position) {
    setState(() {
      _pin = position;
      _preview = 'Updating address from map pin...';
    });
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(
      const Duration(milliseconds: 420),
      _refreshAddress,
    );
  }

  Future<void> _refreshAddress() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final draft = await context.read<AddressController>().reverseGeocode(
        _pin.latitude,
        _pin.longitude,
      );
      if (!mounted) return;
      setState(() {
        _draft = draft;
        _preview = [
          draft.house,
          draft.area,
          draft.city,
          draft.state,
          draft.pincode,
        ].where((part) => part.trim().isNotEmpty).join(', ');
        if (_preview.isEmpty) {
          _preview = 'Address found from selected coordinates';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _draft = AddressDraft(
          latitude: _pin.latitude,
          longitude: _pin.longitude,
        );
        _preview = 'Selected coordinates will be saved with this address';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    final draft =
        _draft ??
        AddressDraft(latitude: _pin.latitude, longitude: _pin.longitude);
    Navigator.of(context).pop(draft);
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.required = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            validator ??
            (required
                ? (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null
                : null),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFFAFCFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _mainGreen, width: 1.6),
          ),
        ),
      ),
    );
  }
}

class _AddressTypeIcon extends StatelessWidget {
  const _AddressTypeIcon({required this.type});

  final AddressType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      AddressType.home => Icons.home_outlined,
      AddressType.farm => Icons.agriculture_outlined,
      AddressType.office => Icons.business_outlined,
    };
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: _lightGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: _mainGreen),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _accentGreen.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          color: _mainGreen,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyAddressCard extends StatelessWidget {
  const _EmptyAddressCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_location_alt_outlined,
            color: _mainGreen,
            size: 38,
          ),
          const SizedBox(height: 10),
          const Text(
            'No saved addresses yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(backgroundColor: _mainGreen),
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}
