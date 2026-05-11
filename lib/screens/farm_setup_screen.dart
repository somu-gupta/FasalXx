import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/delivery_address.dart';
import '../services/address_controller.dart';
import '../services/auth_controller.dart';
import '../theme/app_theme.dart';
import 'address_selection_screen.dart';
import 'auth_flow_screens.dart';
import 'main_screen.dart';

class FarmSetupScreen extends StatefulWidget {
  const FarmSetupScreen({super.key, this.returnToPreviousScreen = false});

  final bool returnToPreviousScreen;

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  final _farmName = TextEditingController();
  final _farmSize = TextEditingController();
  final _location = TextEditingController();
  final Set<String> _selectedCrops = {};
  final List<_CropOption> _customCrops = [];
  String _unit = 'Acre';
  bool _saving = false;
  bool _locating = false;

  static const _units = ['Acre', 'Bigha', 'Hectare'];
  static const _crops = [
    _CropOption('Wheat', Icons.grass_rounded),
    _CropOption('Rice', Icons.rice_bowl_outlined),
    _CropOption('Soybean', Icons.spa_outlined),
    _CropOption('Tomato', Icons.local_florist_outlined),
    _CropOption('Cotton', Icons.cloud_outlined),
    _CropOption('Maize', Icons.agriculture_outlined),
    _CropOption('Sugarcane', Icons.park_outlined),
    _CropOption('Potato', Icons.circle_outlined),
    _CropOption('Onion', Icons.radio_button_unchecked_rounded),
    _CropOption('Mustard', Icons.eco_outlined),
    _CropOption('Bajra', Icons.yard_outlined),
    _CropOption('Groundnut', Icons.nature_outlined),
  ];

  List<_CropOption> get _visibleCrops => [..._crops, ..._customCrops];

  bool get _canContinue {
    return _selectedCrops.isNotEmpty && !_saving;
  }

  @override
  void dispose() {
    _farmName.dispose();
    _farmSize.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Back',
                    onPressed: _handleBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Setup Your First Farm',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: fx.textStrong,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Help us personalize insights for your farm',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: fx.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SetupCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Farm Name'),
                        const SizedBox(height: 8),
                        _SetupTextField(
                          controller: _farmName,
                          hint: 'Field A, Green Farm, North Farm',
                          icon: Icons.eco_outlined,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel('Farm Size'),
                        const SizedBox(height: 8),
                        _FarmSizeRow(
                          sizeController: _farmSize,
                          unit: _unit,
                          units: _units,
                          onSizeChanged: (_) => setState(() {}),
                          onUnitChanged: (value) =>
                              setState(() => _unit = value ?? _unit),
                        ),
                        const SizedBox(height: 22),
                        _FieldLabel('Farm Location'),
                        const SizedBox(height: 5),
                        Text(
                          'Optional: add a location for more local farm insights.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: fx.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _locating ? null : _useCurrentLocation,
                          icon: _locating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded),
                          label: Text(
                            _locating
                                ? 'Detecting Location...'
                                : 'Use Current Location',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: _selectOnMap,
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Select on Map'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        if (_location.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _LocationPreview(location: _location.text),
                        ],
                        const SizedBox(height: 24),
                        _FieldLabel('Select Crops'),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = width >= 700
                                ? 4
                                : width >= 480
                                ? 3
                                : 2;
                            return GridView.builder(
                              itemCount: _visibleCrops.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.98,
                                  ),
                              itemBuilder: (context, index) {
                                final crop = _visibleCrops[index];
                                final selected = _selectedCrops.contains(
                                  crop.name,
                                );
                                return _CropCard(
                                  crop: crop,
                                  selected: selected,
                                  onTap: () => _toggleCrop(crop.name),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _AddCustomCropButton(onTap: _addCustomCrop),
                        const SizedBox(height: 26),
                        FilledButton(
                          onPressed: _canContinue ? _continue : null,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            disabledBackgroundColor: fx.fieldFill,
                            disabledForegroundColor: fx.textMuted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _saving
                                ? const SizedBox(
                                    key: ValueKey('saving'),
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                    ),
                                  )
                                : const Text(
                                    'Continue',
                                    key: ValueKey('continue'),
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton(
                            onPressed: _saving ? null : _skip,
                            child: const Text('Skip for now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCrop(String crop) {
    setState(() {
      if (!_selectedCrops.add(crop)) _selectedCrops.remove(crop);
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final draft = await context
          .read<AddressController>()
          .detectCurrentLocation();
      if (!mounted) return;
      setState(() => _location.text = _formatAddressDraft(draft));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location added for this farm.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _selectOnMap() async {
    final draft = await Navigator.of(context).push<AddressDraft>(
      MaterialPageRoute(builder: (_) => const MapLocationPickerScreen()),
    );
    if (draft == null || !mounted) return;
    setState(() => _location.text = _formatAddressDraft(draft));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Map location saved for this farm.')),
    );
  }

  Future<void> _addCustomCrop() async {
    final controller = TextEditingController();
    final crop = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Crop'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter crop name',
              prefixIcon: Icon(Icons.add_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (crop == null || crop.isEmpty) return;
    final normalizedCrop = _titleCase(crop);
    final exists = _visibleCrops.any(
      (item) => item.name.toLowerCase() == normalizedCrop.toLowerCase(),
    );
    setState(() {
      if (!exists) {
        _customCrops.add(
          _CropOption(normalizedCrop, Icons.add_circle_outline_rounded),
        );
      }
      _selectedCrops.add(normalizedCrop);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$normalizedCrop added to selected crops.')),
    );
  }

  String _formatAddressDraft(AddressDraft draft) {
    final address = [
      draft.house,
      draft.area,
      draft.city,
      draft.state,
      draft.pincode,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    if (address.isNotEmpty) return address;
    final lat = draft.latitude;
    final lng = draft.longitude;
    if (lat != null && lng != null) {
      return 'Lat ${lat.toStringAsFixed(5)}, Lng ${lng.toStringAsFixed(5)}';
    }
    return 'Farm location selected';
  }

  String _titleCase(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          if (part.length == 1) return part.toUpperCase();
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _continue() async {
    if (!_canContinue) return;
    setState(() => _saving = true);
    final sortedCrops = _selectedCrops.toList()..sort();
    await AuthController.instance.updateFarmProfile(
      FarmProfile(
        name: _farmName.text.trim().isEmpty
            ? 'My First Farm'
            : _farmName.text.trim(),
        size: _farmSize.text.trim().isEmpty
            ? 'Not added'
            : _farmSize.text.trim(),
        unit: _unit,
        location: _location.text.trim(),
        crops: sortedCrops,
        isSetupComplete: true,
      ),
    );
    if (!mounted) return;
    _finishSetup();
  }

  Future<void> _skip() async {
    setState(() => _saving = true);
    await AuthController.instance.updateFarmProfile(
      const FarmProfile.empty().copyWith(isSetupComplete: true),
    );
    if (!mounted) return;
    _finishSetup();
  }

  void _handleBack() {
    final canReturn = Navigator.of(context).canPop();
    if ((widget.returnToPreviousScreen ||
            AuthController.instance.currentUser != null) &&
        canReturn) {
      Navigator.of(context).pop();
      return;
    }
    _goToLogin();
  }

  void _finishSetup() {
    if (widget.returnToPreviousScreen) {
      Navigator.of(context).pop();
      return;
    }
    _goToDashboard();
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: fx.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 70 : 18),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: context.fx.textStrong,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SetupTextField extends StatelessWidget {
  const _SetupTextField({
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: context.fx.textStrong,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}

class _FarmSizeRow extends StatelessWidget {
  const _FarmSizeRow({
    required this.sizeController,
    required this.unit,
    required this.units,
    required this.onSizeChanged,
    required this.onUnitChanged,
  });

  final TextEditingController sizeController;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<String?> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 420;
        final sizeField = _SetupTextField(
          controller: sizeController,
          hint: '0.0',
          icon: Icons.landscape_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onSizeChanged,
        );
        final unitField = DropdownButtonFormField<String>(
          initialValue: unit,
          items: units
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onUnitChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.straighten_rounded),
          ),
          borderRadius: BorderRadius.circular(18),
        );

        if (stack) {
          return Column(
            children: [sizeField, const SizedBox(height: 10), unitField],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: sizeField),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: unitField),
          ],
        );
      },
    );
  }
}

class _LocationPreview extends StatelessWidget {
  const _LocationPreview({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.fx.selectedFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fx.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location,
              style: TextStyle(
                color: context.fx.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.crop,
    required this.selected,
    required this.onTap,
  });

  final _CropOption crop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      label: crop.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          scale: selected ? 1.025 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? fx.selectedFill : fx.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? scheme.primary : fx.border,
                width: selected ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 45 : 12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primary.withAlpha(isDark ? 44 : 24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(crop.icon, color: scheme.primary, size: 24),
                ),
                const Spacer(),
                Text(
                  crop.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? scheme.primary : fx.textStrong,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: scheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Selected',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
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

class _AddCustomCropButton extends StatelessWidget {
  const _AddCustomCropButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '+ Add Custom Crop',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
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

class _CropOption {
  const _CropOption(this.name, this.icon);

  final String name;
  final IconData icon;
}
