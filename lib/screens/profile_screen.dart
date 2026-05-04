import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
          const _FarmerProfileCard(),
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
          const _SectionCard(
            title: 'Farm Information',
            subtitle: 'Land, crops, and basic farm data',
            rows: [
              _ProfileRow(icon: Icons.landscape_outlined, label: 'Land Size', value: '7.5 acres'),
              _ProfileRow(icon: Icons.grass_outlined, label: 'Crop Types', value: 'Wheat, Soyabean'),
              _ProfileRow(icon: Icons.map_outlined, label: 'Farm Data', value: '2 fields active'),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Financial & Bank Details',
            subtitle: 'For marketplace and future payments',
            rows: [
              _ProfileRow(icon: Icons.account_balance_outlined, label: 'Bank Account', value: 'Linked'),
              _ProfileRow(icon: Icons.payments_outlined, label: 'UPI / Payments', value: 'Ready'),
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
}

class _FarmerProfileCard extends StatelessWidget {
  const _FarmerProfileCard();

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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ramesh Patel',
                      style: TextStyle(
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
                            'Sehore, Madhya Pradesh',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Color(0xFF667366), fontWeight: FontWeight.w700),
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile edit screen coming soon.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: _StatTile(label: 'Total Land', value: '7.5', unit: 'acres')),
              SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Active Crops', value: '2', unit: 'crops')),
            ],
          ),
        ],
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
