import 'package:flutter/material.dart';

class ProfileData {
  const ProfileData({
    required this.name,
    required this.phone,
    required this.village,
    required this.district,
    required this.state,
    required this.totalLand,
    required this.cropTypes,
    required this.activeCrops,
  });

  factory ProfileData.demo() {
    return const ProfileData(
      name: 'Ramesh Patel',
      phone: '+91 98765 43210',
      village: 'Sehore',
      district: 'Sehore',
      state: 'Madhya Pradesh',
      totalLand: '7.5',
      cropTypes: 'Wheat, Soyabean',
      activeCrops: '2',
    );
  }

  final String name;
  final String phone;
  final String village;
  final String district;
  final String state;
  final String totalLand;
  final String cropTypes;
  final String activeCrops;

  String get location {
    final parts = [
      if (village.trim().isNotEmpty) village.trim(),
      if (state.trim().isNotEmpty) state.trim(),
    ];
    return parts.isEmpty ? 'Location not added' : parts.join(', ');
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
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFFF7FAF4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 176),
        children: [
          _FarmerProfileCard(
            profile: _profile,
            onEdit: _openEditProfile,
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            language: _language,
            voiceAssistant: _voiceAssistant,
            notifications: _notifications,
            darkMode: _darkMode,
            onLanguageChanged: (value) {
              if (value != null) {
                setState(() => _language = value);
              }
            },
            onVoiceChanged: (value) => setState(() => _voiceAssistant = value),
            onNotificationsChanged: (value) => setState(() => _notifications = value),
            onDarkModeChanged: (value) => setState(() => _darkMode = value),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Farm Information',
            subtitle: 'Land, crops, and basic farm data',
            rows: [
              _ProfileRow(icon: Icons.landscape_outlined, label: 'Land Size', value: '${_profile.totalLand} acres'),
              _ProfileRow(icon: Icons.grass_outlined, label: 'Crop Types', value: _profile.cropTypes),
              _ProfileRow(icon: Icons.map_outlined, label: 'Farm Data', value: '${_profile.activeCrops} fields active'),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Help & Support',
            subtitle: 'Support within 2-3 taps',
            rows: [
              _ProfileRow(icon: Icons.help_outline_rounded, label: 'Help Center', value: 'Guides'),
              _ProfileRow(icon: Icons.support_agent_rounded, label: 'Contact Support', value: 'Call / Chat'),
              _ProfileRow(icon: Icons.quiz_outlined, label: 'FAQ', value: 'Questions'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout action coming soon.')),
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
    final updated = await Navigator.of(context).push<ProfileData>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
    );

    if (updated == null || !mounted) return;
    setState(() => _profile = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
  }
}

class _FarmerProfileCard extends StatelessWidget {
  const _FarmerProfileCard({required this.profile, required this.onEdit});

  final ProfileData profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
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
                  border: Border.all(color: const Color(0xFFD6EED2), width: 1.5),
                ),
                child: const Icon(Icons.person_rounded, color: Color(0xFF16823A), size: 40),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Color(0xFF17251A),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF667366)),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.location,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF667366), fontWeight: FontWeight.w700),
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
              Expanded(child: _StatTile(label: 'Total Land', value: profile.totalLand, unit: 'acres')),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Active Crops', value: profile.activeCrops, unit: 'crops')),
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
      backgroundColor: const Color(0xFFF7FAF4),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFFF7FAF4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -8)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          border: Border.all(color: const Color(0xFFD6EED2), width: 1.5),
                        ),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF16823A), size: 48),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: const Color(0xFF16823A),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Photo update coming soon.')),
                              );
                            },
                            child: const SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _EditField(controller: _name, label: 'Full Name', icon: Icons.person_outline_rounded),
                _EditField(controller: _phone, label: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
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
                _EditField(controller: _village, label: 'Village / City', icon: Icons.home_work_outlined),
                _EditField(controller: _district, label: 'District', icon: Icons.location_city_outlined),
                _EditField(controller: _state, label: 'State', icon: Icons.map_outlined),
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
                  subtitle: 'Simple farm information for better recommendations',
                ),
                const SizedBox(height: 14),
                _EditField(controller: _land, label: 'Total Land (acres)', icon: Icons.landscape_outlined, keyboardType: TextInputType.number),
                _EditField(controller: _crops, label: 'Crop Types', icon: Icons.grass_outlined),
                _EditField(controller: _activeCrops, label: 'Active Crops', icon: Icons.eco_outlined, keyboardType: TextInputType.number),
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
        phone: _phone.text.trim(),
        village: _village.text.trim(),
        district: _district.text.trim(),
        state: _state.text.trim(),
        totalLand: _land.text.trim().isEmpty ? '0' : _land.text.trim(),
        cropTypes: _crops.text.trim().isEmpty ? 'Not added' : _crops.text.trim(),
        activeCrops: _activeCrops.text.trim().isEmpty ? '0' : _activeCrops.text.trim(),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF16823A)),
          filled: true,
          fillColor: const Color(0xFFF7FAF4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE3EDE1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF16823A), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF607062), fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF14532D),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(color: Color(0xFF607062), fontWeight: FontWeight.w800),
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
      trailing: Switch(
        value: value,
        activeColor: const Color(0xFF16823A),
        onChanged: onChanged,
      ),
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
                  style: const TextStyle(
                    color: Color(0xFF17251A),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6A766A), fontWeight: FontWeight.w600),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF17251A), fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF6A766A), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _IconBox(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF17251A),
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
                  style: const TextStyle(color: Color(0xFF6A766A), fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A968A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF1F8EF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: const Color(0xFF14532D)),
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
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8EF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: const Color(0xFF16823A), size: 24),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
