import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/auth_flow_screens.dart';
import '../services/auth_controller.dart';
import '../services/theme_controller.dart';
import '../services/image_input_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';
import 'farm_setup_screen.dart';

class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.farmName,
    required this.farmLocation,
    required this.village,
    required this.district,
    required this.state,
    required this.totalLand,
    required this.cropTypes,
    required this.activeCrops,
    this.profileImage,
  });

  factory ProfileData.demo() {
    return const ProfileData(
      name: 'Ramesh Patel',
      email: 'ramesh@fasalx.demo',
      phone: '+91 98765 43210',
      farmName: 'Green Farm',
      farmLocation: 'Sehore Road, Madhya Pradesh',
      village: 'Sehore',
      district: 'Sehore',
      state: 'Madhya Pradesh',
      totalLand: '7.5',
      cropTypes: 'Wheat, Soyabean',
      activeCrops: '2',
    );
  }

  final String name;
  final String email;
  final String phone;
  final String farmName;
  final String farmLocation;
  final String village;
  final String district;
  final String state;
  final String totalLand;
  final String cropTypes;
  final String activeCrops;
  final SelectedImage? profileImage;

  String get location {
    final parts = [
      if (village.trim().isNotEmpty) village.trim(),
      if (state.trim().isNotEmpty) state.trim(),
    ];
    return parts.isEmpty ? 'Location not added' : parts.join(', ');
  }

  factory ProfileData.fromUser(AppUser user) {
    final farm = user.farm;
    return ProfileData(
      name: user.name,
      email: user.email,
      phone: user.email,
      farmName: farm.name.isEmpty ? 'First Farm' : farm.name,
      farmLocation: farm.location.isEmpty ? 'Not added' : farm.location,
      village: user.city,
      district: user.city,
      state: user.state,
      totalLand: farm.size.isEmpty ? '0' : '${farm.size} ${farm.unit}',
      cropTypes: farm.crops.isEmpty ? 'Not added' : farm.crops.join(', '),
      activeCrops: farm.crops.length.toString(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileData _profile = ProfileData.demo();
  String _language = 'Hindi';
  bool _voiceAssistant = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = context.watch<ThemeController>();
    final user = auth.currentUser;
    final displayProfile = user == null ? _profile : ProfileData.fromUser(user);
    final language = auth.selectedLanguage ?? _language;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const FasalXHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 176),
        children: [
          Text(
            'Profile',
            style: TextStyle(
              color: context.fx.textStrong,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _FarmerProfileCard(profile: displayProfile, onEdit: _openEditProfile),
          const SizedBox(height: 16),
          _SettingsCard(
            language: language,
            voiceAssistant: _voiceAssistant,
            notifications: _notifications,
            darkMode: theme.isDark,
            onLanguageChanged: (value) {
              if (value != null) {
                setState(() => _language = value);
                AuthController.instance.setLanguage(value);
              }
            },
            onVoiceChanged: (value) => setState(() => _voiceAssistant = value),
            onNotificationsChanged: (value) =>
                setState(() => _notifications = value),
            onDarkModeChanged: (value) =>
                ThemeController.instance.setDarkTheme(value),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Farm Information',
            subtitle: 'Land, crops, and basic farm data',
            rows: [
              _ProfileRow(
                icon: Icons.eco_outlined,
                label: 'Farm Name',
                value: displayProfile.farmName,
                onTap: _openFarmSetup,
              ),
              _ProfileRow(
                icon: Icons.landscape_outlined,
                label: 'Farm Size',
                value: displayProfile.totalLand,
                onTap: _openFarmSetup,
              ),
              _ProfileRow(
                icon: Icons.grass_outlined,
                label: 'Crop Types',
                value: displayProfile.cropTypes,
                onTap: _openFarmSetup,
              ),
              _ProfileRow(
                icon: Icons.location_on_outlined,
                label: 'Farm Location',
                value: displayProfile.farmLocation,
                onTap: _openFarmSetup,
              ),
              _ProfileRow(
                icon: Icons.map_outlined,
                label: 'Farm Data',
                value: '${displayProfile.activeCrops} crops active',
                onTap: _openFarmSetup,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Help & Support',
            subtitle: 'Support within 2-3 taps',
            rows: [
              _ProfileRow(
                icon: Icons.help_outline_rounded,
                label: 'Help Center',
                value: 'Guides',
              ),
              _ProfileRow(
                icon: Icons.support_agent_rounded,
                label: 'Contact Support',
                value: 'Call / Chat',
              ),
              _ProfileRow(
                icon: Icons.quiz_outlined,
                label: 'FAQ',
                value: 'Questions',
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () async {
                await AuthController.instance.logout();
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final user = AuthController.instance.currentUser;
    final profile = user == null ? _profile : ProfileData.fromUser(user);
    final updated = await Navigator.of(context).push<ProfileData>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
    );

    if (updated == null || !mounted) return;
    setState(() => _profile = updated);
    if (user != null) {
      await AuthController.instance.updateProfile(
        AppUser(
          name: updated.name,
          email: user.email,
          city: updated.village,
          state: updated.state,
          farm: user.farm,
        ),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
  }

  void _openFarmSetup() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FarmSetupScreen()));
  }
}

class _FarmerProfileCard extends StatelessWidget {
  const _FarmerProfileCard({required this.profile, required this.onEdit});

  final ProfileData profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _SoftCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7E8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD6EED2),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: profile.profileImage == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF16823A),
                        size: 40,
                      )
                    : Image.memory(
                        profile.profileImage!.bytes,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: fx.textMuted,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.location,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fx.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _IconAction(
                icon: Icons.edit_outlined,
                tooltip: 'Edit profile',
                onTap: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Total Land',
                  value: profile.totalLand,
                  unit: 'acres',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Active Crops',
                  value: profile.activeCrops,
                  unit: 'crops',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final ProfileData profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _village;
  late final TextEditingController _district;
  late final TextEditingController _state;
  late final TextEditingController _land;
  late final TextEditingController _crops;
  late final TextEditingController _activeCrops;
  SelectedImage? _profileImage;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _phone = TextEditingController(text: widget.profile.phone);
    _village = TextEditingController(text: widget.profile.village);
    _district = TextEditingController(text: widget.profile.district);
    _state = TextEditingController(text: widget.profile.state);
    _land = TextEditingController(text: widget.profile.totalLand);
    _crops = TextEditingController(text: widget.profile.cropTypes);
    _activeCrops = TextEditingController(text: widget.profile.activeCrops);
    _profileImage = widget.profile.profileImage;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _village.dispose();
    _district.dispose();
    _state.dispose();
    _land.dispose();
    _crops.dispose();
    _activeCrops.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: context.fx.surface,
          border: Border(top: BorderSide(color: context.fx.border)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Row(
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16823A),
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
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'Personal Details',
                  subtitle: 'Keep your name and contact updated',
                ),
                const SizedBox(height: 14),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7E8),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFD6EED2),
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _profileImage == null
                            ? const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF16823A),
                                size: 48,
                              )
                            : Image.memory(
                                _profileImage!.bytes,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: const Color(0xFF16823A),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickProfileImage,
                            child: const SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _EditField(
                  controller: _name,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                _EditField(
                  controller: _phone,
                  label: 'Gmail',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'Location',
                  subtitle: 'Used for local mandi, weather, and schemes',
                ),
                const SizedBox(height: 14),
                _EditField(
                  controller: _village,
                  label: 'Village / City',
                  icon: Icons.home_work_outlined,
                ),
                _EditField(
                  controller: _district,
                  label: 'District',
                  icon: Icons.location_city_outlined,
                ),
                _EditField(
                  controller: _state,
                  label: 'State',
                  icon: Icons.map_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'Farm Details',
                  subtitle:
                      'Simple farm information for better recommendations',
                ),
                const SizedBox(height: 14),
                _EditField(
                  controller: _land,
                  label: 'Total Land (acres)',
                  icon: Icons.landscape_outlined,
                  keyboardType: TextInputType.number,
                ),
                _EditField(
                  controller: _crops,
                  label: 'Crop Types',
                  icon: Icons.grass_outlined,
                ),
                _EditField(
                  controller: _activeCrops,
                  label: 'Active Crops',
                  icon: Icons.eco_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter farmer name.')),
      );
      return;
    }

    Navigator.of(context).pop(
      ProfileData(
        name: _name.text.trim(),
        email: widget.profile.email,
        phone: _phone.text.trim(),
        farmName: widget.profile.farmName,
        farmLocation: widget.profile.farmLocation,
        village: _village.text.trim(),
        district: _district.text.trim(),
        state: _state.text.trim(),
        totalLand: _land.text.trim().isEmpty ? '0' : _land.text.trim(),
        cropTypes: _crops.text.trim().isEmpty
            ? 'Not added'
            : _crops.text.trim(),
        activeCrops: _activeCrops.text.trim().isEmpty
            ? '0'
            : _activeCrops.text.trim(),
        profileImage: _profileImage,
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final image = await pickDeviceImage();
      if (!mounted) return;

      if (image == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected.')));
        return;
      }

      setState(() => _profileImage = image);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo selected. Tap Save to apply.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gallery could not be opened. Please try again.'),
        ),
      );
    }
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        cursorColor: Theme.of(context).colorScheme.primary,
        style: TextStyle(
          color: fx.textStrong,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          labelStyle: TextStyle(
            color: fx.textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          floatingLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
          hintStyle: TextStyle(
            color: fx.textMuted,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: fx.fieldFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: fx.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: fx.border, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final normalizedValue = value.toLowerCase();
    final normalizedUnit = unit.toLowerCase();
    final singularUnit = normalizedUnit.endsWith('s')
        ? normalizedUnit.substring(0, normalizedUnit.length - 1)
        : normalizedUnit;
    final shouldShowUnit =
        !normalizedValue.contains(normalizedUnit) &&
        !normalizedValue.contains(singularUnit);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (shouldShowUnit) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      unit,
                      style: TextStyle(
                        color: fx.textMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.language,
    required this.voiceAssistant,
    required this.notifications,
    required this.darkMode,
    required this.onLanguageChanged,
    required this.onVoiceChanged,
    required this.onNotificationsChanged,
    required this.onDarkModeChanged,
  });

  final String language;
  final bool voiceAssistant;
  final bool notifications;
  final bool darkMode;
  final ValueChanged<String?> onLanguageChanged;
  final ValueChanged<bool> onVoiceChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Account & App Settings',
            subtitle: 'Simple controls for daily use',
          ),
          const SizedBox(height: 12),
          _SettingShell(
            icon: Icons.translate_rounded,
            title: 'Language',
            subtitle: 'Hindi default, English available',
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: language,
                borderRadius: BorderRadius.circular(16),
                items: const [
                  DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                ],
                onChanged: onLanguageChanged,
              ),
            ),
          ),
          _SwitchSetting(
            icon: Icons.record_voice_over_outlined,
            title: 'Voice Assistant',
            subtitle: voiceAssistant ? 'ON - Hindi voice help' : 'OFF',
            value: voiceAssistant,
            onChanged: onVoiceChanged,
          ),
          _SwitchSetting(
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            subtitle: notifications ? 'Crop alerts enabled' : 'Alerts disabled',
            value: notifications,
            onChanged: onNotificationsChanged,
          ),
          _SwitchSetting(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: darkMode ? 'Dark theme enabled' : 'Light theme active',
            value: darkMode,
            onChanged: onDarkModeChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _SettingShell extends StatelessWidget {
  const _SettingShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fx.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  final String title;
  final String subtitle;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: fx.textStrong,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _IconBox(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: fx.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: fx.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: fx.fieldFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: fx.fieldFill,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fx.surface,
        border: Border.all(color: fx.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
