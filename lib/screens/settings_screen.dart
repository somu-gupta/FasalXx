import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/theme_controller.dart';
import '../theme/app_theme.dart';

const _green = Color(0xFF22C55E);
const _deepGreen = Color(0xFF14532D);
const _ink = Color(0xFF17251A);
const _muted = Color(0xFF667366);

enum _VerificationMethod { otp, link }

enum _LocationAccess { denied, allowed, limited }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';
  bool _dataSaver = false;
  bool _pushNotifications = true;
  bool _smsAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const _SettingsHeader(title: 'Settings'),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'App Preferences',
              children: [
                _SettingTile(
                  icon: Icons.translate_rounded,
                  title: 'Language Selector',
                  subtitle: 'Choose your preferred language',
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _language,
                      borderRadius: BorderRadius.circular(16),
                      items: const [
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: '\u0939\u093F\u0928\u094D\u0926\u0940',
                          child: Text('\u0939\u093F\u0928\u094D\u0926\u0940'),
                        ),
                        DropdownMenuItem(
                          value: '\u092E\u0930\u093E\u0920\u0940',
                          child: Text('\u092E\u0930\u093E\u0920\u0940'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _language = value);
                      },
                    ),
                  ),
                ),
                _SettingTile(
                  icon: Icons.network_check_rounded,
                  title: 'Data Saver Mode',
                  subtitle: 'Optimize app for slow rural networks',
                  trailing: Switch(
                    value: _dataSaver,
                    onChanged: (value) => setState(() => _dataSaver = value),
                  ),
                ),
                _SettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Theme',
                  subtitle: 'Tap to switch between light and dark mode',
                  trailing: Consumer<ThemeController>(
                    builder: (context, theme, _) {
                      return _ThemeModeButton(
                        isDark: theme.isDark,
                        loading: theme.isChanging,
                        onTap: () => theme.toggle(),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Notifications & Alerts',
              children: [
                _SettingTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Weather and market updates',
                  trailing: Switch(
                    value: _pushNotifications,
                    onChanged: (value) =>
                        setState(() => _pushNotifications = value),
                  ),
                ),
                _SettingTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS Alerts',
                  subtitle: 'Critical alerts without internet',
                  trailing: Switch(
                    value: _smsAlerts,
                    onChanged: (value) => setState(() => _smsAlerts = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Account & Security',
              children: [
                _NavigationTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Verify identity and update credentials',
                  onTap: () => _push(context, const ChangePasswordScreen()),
                ),
                _NavigationTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy & Data',
                  subtitle: 'Manage data usage and privacy settings',
                  onTap: () => _push(context, const PrivacyDataScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _email = TextEditingController(text: 'suresh.farmer@gmail.com');
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  _VerificationMethod _method = _VerificationMethod.otp;
  bool _loading = false;
  bool _verificationSent = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const _SettingsHeader(title: 'Change Password'),
            const SizedBox(height: 20),
            _ElevatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF7E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        color: _deepGreen,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To change your password, we will send a verification link or OTP to your registered email address.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: _MutedPill(label: _maskEmail(_email.text))),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() => _emailError = null),
                    decoration: _inputDecoration(
                      context,
                      'Registered email',
                      Icons.alternate_email_rounded,
                      errorText: _emailError,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _VerificationSelector(
                    method: _method,
                    onChanged: (method) => setState(() => _method = method),
                  ),
                  const SizedBox(height: 16),
                  _PressableButton(
                    label: _loading ? 'Sending...' : 'Send Verification',
                    icon: Icons.send_rounded,
                    onTap: _loading ? null : _sendVerification,
                  ),
                  if (_verificationSent) ...[
                    const SizedBox(height: 22),
                    _PasswordResetForm(
                      newPassword: _newPassword,
                      confirmPassword: _confirmPassword,
                      passwordError: _passwordError,
                      showNewPassword: _showNewPassword,
                      showConfirmPassword: _showConfirmPassword,
                      onToggleNew: () {
                        setState(() => _showNewPassword = !_showNewPassword);
                      },
                      onToggleConfirm: () {
                        setState(
                          () => _showConfirmPassword = !_showConfirmPassword,
                        );
                      },
                      onChanged: () => setState(() => _passwordError = null),
                      onSubmit: _updatePassword,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendVerification() async {
    final email = _email.text.trim();
    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _verificationSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification sent successfully')),
    );
  }

  void _updatePassword() {
    final password = _newPassword.text;
    if (!_isStrongPassword(password)) {
      setState(() => _passwordError = 'Password does not meet requirements');
      return;
    }
    if (password != _confirmPassword.text) {
      setState(() => _passwordError = 'Passwords do not match');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully')),
    );
    Navigator.of(context).pop();
  }
}

class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _shareAiData = false;
  bool _preciseLocation = false;
  bool _exporting = false;
  _LocationAccess _locationAccess = _LocationAccess.denied;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const _SettingsHeader(title: 'Privacy & Data'),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Data Sharing Preferences',
              children: [
                _SettingTile(
                  icon: Icons.psychology_alt_outlined,
                  title: 'Share with AI Models',
                  subtitle:
                      'Help us improve crop disease detection algorithms anonymously.',
                  trailing: Switch(
                    value: _shareAiData,
                    onChanged: (value) {
                      setState(() => _shareAiData = value);
                      _snack('AI data sharing preference updated');
                    },
                  ),
                ),
                _SettingTile(
                  icon: Icons.location_on_outlined,
                  title: 'Precise Location',
                  subtitle:
                      'Required for accurate localized weather and mandi prices.\nStatus: ${_locationAccess.label}',
                  trailing: Switch(
                    value: _preciseLocation,
                    onChanged: _toggleLocation,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Your Data',
              children: [
                _ActionTile(
                  icon: Icons.cloud_download_outlined,
                  title: 'Download My Data',
                  subtitle: _exporting
                      ? 'Preparing profile, farm records, crop history, schemes, and alerts...'
                      : 'Export profile, farm records, crop history, schemes, and preferences',
                  trailing: _exporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: _exporting ? null : _downloadData,
                ),
                _DangerTile(onTap: _confirmDeleteAccount),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Legal',
              children: [
                _NavigationTile(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read how FasalX protects your data',
                  onTap: () => _push(const PrivacyPolicyScreen()),
                ),
                _NavigationTile(
                  icon: Icons.article_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Service terms for using FasalX',
                  onTap: () => _push(const TermsConditionsScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _toggleLocation(bool enabled) {
    if (!enabled) {
      setState(() {
        _preciseLocation = false;
        _locationAccess = _LocationAccess.denied;
      });
      _snack('Location access disabled');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allow precise location?'),
        content: const Text(
          'FasalX uses location for weather, mandi prices, and local schemes.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _preciseLocation = false;
                _locationAccess = _LocationAccess.denied;
              });
              _snack('Location permission denied');
            },
            child: const Text('Deny'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _preciseLocation = true;
                _locationAccess = _LocationAccess.allowed;
              });
              _snack('Location permission allowed');
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadData() async {
    setState(() => _exporting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _exporting = false);
    _snack('Your data export is ready');
  }

  void _confirmDeleteAccount() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete Account',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deleting your account permanently removes all farm records and saved schemes.',
                style: TextStyle(
                  color: _muted,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: _inputDecoration(
                  context,
                  'Enter password or OTP',
                  Icons.lock_outline_rounded,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _snack(
                          'Final confirmation required before account deletion',
                        );
                      },
                      child: const Text('Confirm Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Privacy Policy',
      heading: 'FasalX Privacy Policy',
      dateLabel: 'Effective Date: May 1, 2026',
      accentTitle: false,
      sections: const [
        LegalSection(
          title: '1. Data We Collect',
          body:
              'We collect crop types, field coordinates, IoT sensor locations, disease detection images, government scheme registration details, and basic profile information to provide farming recommendations and account services.',
        ),
        LegalSection(
          title: '2. AI & Machine Learning Processing',
          body:
              'Crop images may be processed using secure AI models for disease detection workflows. Anonymous training consent is controlled through the Share with AI Models setting. We use privacy-safe image handling, secure AI processing pipelines, and do not share images without authorization.',
        ),
        LegalSection(
          title: '3. Location Services',
          body:
              'Precise location is used for weather forecasting, mandi prices, and region-specific schemes. Location access is permission based and data is not sold to advertisers.',
        ),
        LegalSection(
          title: '4. Data Security',
          body:
              'FasalX follows AES-256 encryption principles, secure cloud storage practices, encrypted transmission, role-based access control, and industry-standard security practices.',
        ),
        LegalSection(
          title: '5. User Rights',
          body:
              'You can download your data, delete your account, manage permissions, withdraw consent, and contact support for privacy-related requests.',
        ),
      ],
    );
  }
}

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Terms & Conditions',
      heading: 'Terms of Service',
      dateLabel: 'Last Updated: May 2026',
      accentTitle: true,
      sections: const [
        LegalSection(
          title: '1. Acceptance of Terms',
          body:
              'By accessing and using the FasalX application, users agree to these terms. If users disagree, they should discontinue usage. These terms apply to AI diagnostics, IoT syncing, weather services, and marketplace features.',
        ),
        LegalSection(
          title: '2. Medical & Agricultural Advice Disclaimer',
          body:
              'AI crop diagnosis is assistive technology only and does not replace certified agronomists or agricultural officers. Users should validate recommendations before implementation.',
        ),
        LegalSection(
          title: '3. E-commerce & Store Purchases',
          body:
              'Seeds, fertilizers, and farming tools are sold through verified vendors. Delivery timelines may vary in rural regions due to weather and logistics. Refund and replacement policies may vary by vendor.',
        ),
        LegalSection(
          title: '4. SIH 2026 Compliance',
          body:
              'The platform supports secure agricultural digitization initiatives, digital public infrastructure standards, data localization, and security compliance practices.',
        ),
        LegalSection(
          title: '5. User Responsibilities',
          body:
              'Users must submit accurate information, protect account access, use AI recommendations responsibly, and avoid fraudulent or harmful platform misuse.',
        ),
        LegalSection(
          title: '6. Account Suspension & Termination',
          body:
              'Fraudulent activities or platform rule violations may result in suspension or termination. Data handling after deletion follows privacy and retention rules.',
        ),
        LegalSection(
          title: '7. Limitation of Liability',
          body:
              'FasalX is not liable for service interruptions, weather inaccuracies, third-party vendor actions, or connectivity issues in rural areas.',
        ),
        LegalSection(
          title: '8. Contact & Support',
          body:
              'For help, contact support@fasalx.example or visit the in-app help center for escalation support.',
        ),
      ],
      showAcceptButton: true,
    );
  }
}

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.heading,
    required this.dateLabel,
    required this.sections,
    required this.accentTitle,
    this.showAcceptButton = false,
  });

  final String title;
  final String heading;
  final String dateLabel;
  final List<LegalSection> sections;
  final bool accentTitle;
  final bool showAcceptButton;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  final _search = TextEditingController();
  final _scrollController = ScrollController();
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = List<bool>.filled(widget.sections.length, true);
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<LegalSection> get _visibleSections {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return widget.sections;
    return widget.sections
        .where(
          (section) =>
              section.title.toLowerCase().contains(query) ||
              section.body.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleSections;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  _SettingsHeader(title: widget.title),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      context,
                      'Search inside document',
                      Icons.search_rounded,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _ElevatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            widget.heading,
                            style: TextStyle(
                              color: widget.accentTitle ? _deepGreen : _ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.dateLabel,
                            style: const TextStyle(
                              color: _muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Divider(height: 28),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < widget.sections.length; i++)
                                ActionChip(
                                  label: Text('${i + 1}'),
                                  onPressed: () {
                                    _scrollController.animateTo(
                                      120.0 + (i * 150),
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeOutCubic,
                                    );
                                  },
                                ),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.share_outlined,
                                  size: 17,
                                ),
                                label: const Text('Share'),
                                onPressed: () =>
                                    _snack('Share option coming soon'),
                              ),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 17,
                                ),
                                label: const Text('PDF'),
                                onPressed: () =>
                                    _snack('PDF download coming soon'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (visible.isEmpty)
                            const Text('No matching sections found.')
                          else
                            for (final section in visible)
                              _LegalSectionTile(
                                section: section,
                                expanded:
                                    _expanded[widget.sections.indexOf(section)],
                                onToggle: () {
                                  final index = widget.sections.indexOf(
                                    section,
                                  );
                                  setState(
                                    () => _expanded[index] = !_expanded[index],
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                    if (widget.showAcceptButton) ...[
                      const SizedBox(height: 14),
                      _PressableButton(
                        label: 'Accept & Continue',
                        icon: Icons.check_circle_outline_rounded,
                        onTap: () => _snack('Terms accepted'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class LegalSection {
  const LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

class _LegalSectionTile extends StatelessWidget {
  const _LegalSectionTile({
    required this.section,
    required this.expanded,
    required this.onToggle,
  });

  final LegalSection section;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: const Color(0xFFFAFCF7),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SelectableText(
                      section.body,
                      style: const TextStyle(
                        color: Color(0xFF4F5E50),
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordResetForm extends StatelessWidget {
  const _PasswordResetForm({
    required this.newPassword,
    required this.confirmPassword,
    required this.passwordError,
    required this.showNewPassword,
    required this.showConfirmPassword,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController newPassword;
  final TextEditingController confirmPassword;
  final String? passwordError;
  final bool showNewPassword;
  final bool showConfirmPassword;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength(newPassword.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create New Password',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: newPassword,
          obscureText: !showNewPassword,
          onChanged: (_) => onChanged(),
          decoration: _passwordDecoration(
            context,
            'New Password',
            showNewPassword,
            onToggleNew,
            errorText: passwordError,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: strength,
          minHeight: 8,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: const Color(0xFFE5EDE0),
          valueColor: AlwaysStoppedAnimation<Color>(
            strength < 0.5 ? Colors.orange : _green,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Requirements: 8+ characters, 1 uppercase, 1 number, 1 special character',
          style: TextStyle(
            color: _muted,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPassword,
          obscureText: !showConfirmPassword,
          onChanged: (_) => onChanged(),
          decoration: _passwordDecoration(
            context,
            'Confirm Password',
            showConfirmPassword,
            onToggleConfirm,
          ),
        ),
        const SizedBox(height: 16),
        _PressableButton(
          label: 'Update Password',
          icon: Icons.lock_reset_rounded,
          onTap: onSubmit,
        ),
      ],
    );
  }
}

class _VerificationSelector extends StatelessWidget {
  const _VerificationSelector({required this.method, required this.onChanged});

  final _VerificationMethod method;
  final ValueChanged<_VerificationMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Send OTP',
              selected: method == _VerificationMethod.otp,
              onTap: () => onChanged(_VerificationMethod.otp),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Send Verification Link',
              selected: method == _VerificationMethod.link,
              onTap: () => onChanged(_VerificationMethod.link),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? _deepGreen : _muted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton.filledTonal(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: fx.textStrong,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Semantics(
      container: true,
      label: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: fx.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          _ElevatedCard(
            padding: EdgeInsets.zero,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
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
    return _TileShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ActionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
      onTap: onTap,
    );
  }
}

class _ThemeModeButton extends StatefulWidget {
  const _ThemeModeButton({
    required this.isDark,
    required this.loading,
    required this.onTap,
  });

  final bool isDark;
  final bool loading;
  final VoidCallback onTap;

  @override
  State<_ThemeModeButton> createState() => _ThemeModeButtonState();
}

class _ThemeModeButtonState extends State<_ThemeModeButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final background = isDark
        ? const Color(0xFF111827)
        : const Color(0xFF2E7D32);
    final borderColor = isDark ? const Color(0xFF22C55E) : Colors.transparent;
    final shadowColor = isDark
        ? const Color(0x5522C55E)
        : const Color(0x3D2E7D32);

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.97 : (_hovered ? 1.02 : 1),
      child: Semantics(
        button: true,
        toggled: isDark,
        label: isDark ? 'Dark theme on' : 'Light theme on',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.loading ? null : widget.onTap,
            onHover: (value) => setState(() => _hovered = value),
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 54,
              constraints: const BoxConstraints(minWidth: 128, maxWidth: 176),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: isDark ? 1.3 : 0),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: isDark ? 18 : 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.loading
                          ? 'Applying'
                          : isDark
                          ? 'Dark'
                          : 'Light',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
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
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: _TileShell(
          icon: icon,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  const _DangerTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: fx.dangerContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fx.danger.withAlpha(90)),
      ),
      child: _ActionTile(
        icon: Icons.delete_outline_rounded,
        title: 'Delete Account',
        subtitle: 'Permanently remove farm records and saved schemes',
        trailing: Icon(Icons.chevron_right_rounded, color: fx.danger),
        onTap: onTap,
      ),
    );
  }
}

class _TileShell extends StatelessWidget {
  const _TileShell({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBadge(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 15.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: fx.textMuted,
                    height: 1.3,
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

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
    );
  }
}

class _ElevatedCard extends StatelessWidget {
  const _ElevatedCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: fx.border),
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

class _MutedPill extends StatelessWidget {
  const _MutedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: fx.fieldFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PressableButton extends StatefulWidget {
  const _PressableButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 110),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: widget.onTap,
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            icon: Icon(widget.icon),
            label: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context,
  String label,
  IconData icon, {
  String? errorText,
}) {
  final fx = context.fx;
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
    filled: true,
    fillColor: fx.fieldFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: fx.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.5,
      ),
    ),
  );
}

InputDecoration _passwordDecoration(
  BuildContext context,
  String label,
  bool visible,
  VoidCallback onToggle, {
  String? errorText,
}) {
  return _inputDecoration(
    context,
    label,
    Icons.lock_outline_rounded,
    errorText: errorText,
  ).copyWith(
    suffixIcon: IconButton(
      tooltip: visible ? 'Hide password' : 'Show password',
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
      onPressed: onToggle,
    ),
  );
}

bool _isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

bool _isStrongPassword(String value) {
  return value.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(value) &&
      RegExp(r'[0-9]').hasMatch(value) &&
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
}

double _passwordStrength(String value) {
  var score = 0;
  if (value.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(value)) score++;
  if (RegExp(r'[0-9]').hasMatch(value)) score++;
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) score++;
  return score / 4;
}

String _maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2 || parts.first.length < 2) return 'su******@gmail.com';
  return '${parts.first.substring(0, 2)}******@${parts.last}';
}

extension on _LocationAccess {
  String get label {
    switch (this) {
      case _LocationAccess.denied:
        return 'Denied';
      case _LocationAccess.allowed:
        return 'Allowed';
      case _LocationAccess.limited:
        return 'Limited Access';
    }
  }
}
