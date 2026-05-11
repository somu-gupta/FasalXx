import 'package:flutter/material.dart';

import '../screens/farm_setup_screen.dart';
import '../screens/main_screen.dart';
import '../services/auth_controller.dart';

const _darkGreen = Color(0xFF2E7D32);
const _mediumGreen = Color(0xFF5C8D57);
const _softGreen = Color(0xFFA5D6A7);
const _lightGreen = Color(0xFFE8F5E9);
const _fieldFill = Color(0xFFFBFDF8);
const _ink = Color(0xFF17251A);
const _muted = Color(0xFF667366);

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key, required this.auth});

  final AuthController auth;

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1900), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    final next = widget.auth.isAuthenticated
        ? widget.auth.hasCompletedFarmSetup
              ? const MainScreen()
              : const FarmSetupScreen()
        : widget.auth.hasSelectedLanguage
        ? const LoginScreen()
        : const LanguageSelectionScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) =>
            FadeTransition(opacity: animation, child: next),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: ((value - 0.9) / 0.1).clamp(0, 1),
                    child: Transform.scale(scale: value, child: child),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BrandLogo(size: 104, iconSize: 54),
                    SizedBox(height: 26),
                    Text(
                      'FasalX',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Smart Farming, Simplified',
                      style: TextStyle(
                        color: _mediumGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 92,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: _darkGreen,
                ),
              ),
            ),
            const Positioned(
              bottom: 34,
              child: Text(
                'Powered by AI for Farmers',
                style: TextStyle(
                  color: Color(0xCC667366),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthSectionTitle(
            title: 'Choose Your Language',
            subtitle:
                'FasalX will use this language across your farming tools.',
          ),
          const SizedBox(height: 22),
          DropdownButtonFormField<String>(
            initialValue: _language,
            borderRadius: BorderRadius.circular(8),
            dropdownColor: Colors.white,
            menuMaxHeight: 260,
            iconEnabledColor: _darkGreen,
            iconDisabledColor: _darkGreen,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
            decoration: _inputDecoration(
              label: 'Language',
              icon: Icons.translate_rounded,
            ),
            items: const [
              DropdownMenuItem(
                value: 'English',
                child: Text(
                  'English',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'Hindi',
                child: Text(
                  'Hindi',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _language = value);
            },
          ),
          const SizedBox(height: 24),
          _PrimaryAuthButton(
            label: 'Continue',
            onPressed: () async {
              await AuthController.instance.setLanguage(_language);
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _email.text.trim().isNotEmpty &&
        _password.text.isNotEmpty &&
        _emailError == null &&
        _passwordError == null &&
        !_loading;
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthSectionTitle(
            title: 'Login',
            subtitle: 'Use your registered email to continue.',
          ),
          const SizedBox(height: 22),
          _AuthTextField(
            controller: _email,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (_) => _validateLogin(),
          ),
          const SizedBox(height: 14),
          _AuthTextField(
            controller: _password,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: !_showPassword,
            errorText: _passwordError,
            onChanged: (_) => _validateLogin(),
            suffix: IconButton(
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _darkGreen,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password reset demo will be connected with Firebase later.',
                    ),
                  ),
                );
              },
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 8),
          _PrimaryAuthButton(
            label: 'Login',
            loading: _loading,
            onPressed: _canSubmit ? _login : null,
          ),
          const SizedBox(height: 18),
          _AuthSwitchText(
            leading: "Don't have an account? ",
            action: 'Sign up',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
            },
          ),
        ],
      ),
    );
  }

  void _validateLogin() {
    final email = _email.text.trim();
    setState(() {
      _emailError =
          email.isEmpty || RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
          ? null
          : 'Invalid email';
      _passwordError = _password.text.isEmpty || _password.text.length >= 6
          ? null
          : 'Password must be at least 6 characters';
    });
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final result = await AuthController.instance.login(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message!)));
      return;
    }
    final next = AuthController.instance.hasCompletedFarmSetup
        ? const MainScreen()
        : const FarmSetupScreen();
    Navigator.of(
      context,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => next), (_) => false);
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _state;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _city.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _name.text.trim().isNotEmpty &&
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim()) &&
        _city.text.trim().isNotEmpty &&
        _state != null &&
        _password.text.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(_password.text) &&
        RegExp(r'\d').hasMatch(_password.text) &&
        _password.text == _confirmPassword.text &&
        !_loading;
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthSectionTitle(
            title: 'Sign up',
            subtitle: 'Add a few details so FasalX can guide you better.',
          ),
          const SizedBox(height: 22),
          _AuthTextField(
            controller: _name,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: _email,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText:
                _email.text.isEmpty ||
                    RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(_email.text.trim())
                ? null
                : 'Enter a valid email',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: _city,
            label: 'City',
            icon: Icons.location_city_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _StatePickerField(
            value: _state,
            onSelected: (value) => setState(() => _state = value),
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: _password,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: !_showPassword,
            errorText: _password.text.isEmpty || _password.text.length >= 8
                ? null
                : 'Use 8+ characters with letters and numbers',
            onChanged: (_) => setState(() {}),
            suffix: IconButton(
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: _confirmPassword,
            label: 'Confirm Password',
            icon: Icons.verified_user_outlined,
            obscureText: !_showConfirmPassword,
            errorText:
                _confirmPassword.text.isEmpty ||
                    _confirmPassword.text == _password.text
                ? null
                : 'Passwords do not match',
            onChanged: (_) => setState(() {}),
            suffix: IconButton(
              tooltip: _showConfirmPassword ? 'Hide password' : 'Show password',
              onPressed: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
              icon: Icon(
                _showConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _PrimaryAuthButton(
            label: 'Sign Up',
            loading: _loading,
            onPressed: _isValid ? _signUp : null,
          ),
          const SizedBox(height: 18),
          _AuthSwitchText(
            leading: 'Already have an account? ',
            action: 'Login',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() => _loading = true);
    final result = await AuthController.instance.signUp(
      name: _name.text,
      email: _email.text,
      city: _city.text,
      state: _state!,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message!)));
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const FarmSetupScreen()),
      (_) => false,
    );
  }
}

class _StatePickerField extends StatelessWidget {
  const _StatePickerField({required this.value, required this.onSelected});

  final String? value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Select state',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            builder: (_) => const _StateSearchSheet(),
          );
          if (selected != null) onSelected(selected);
        },
        child: InputDecorator(
          decoration: _inputDecoration(
            label: 'Select State',
            icon: Icons.map_outlined,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? 'Select State',
                  style: TextStyle(
                    color: value == null ? _muted : _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: _darkGreen),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateSearchSheet extends StatefulWidget {
  const _StateSearchSheet();

  @override
  State<_StateSearchSheet> createState() => _StateSearchSheetState();
}

class _StateSearchSheetState extends State<_StateSearchSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final states = indianStates
        .where((state) => state.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
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
              const Text(
                'Select State',
                style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: _search,
                label: 'Search state',
                icon: Icons.search_rounded,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: states.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final state = states[index];
                    return ListTile(
                      tileColor: Colors.white,
                      selectedTileColor: Colors.white,
                      minVerticalPadding: 12,
                      title: Text(
                        state,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(state),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthShell extends StatelessWidget {
  const _AuthShell({
    required this.child,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  final Widget child;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: keyboardDismissBehavior,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: _FadeScaleIn(child: _AuthCard(child: child)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthSectionTitle extends StatelessWidget {
  const _AuthSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF4F5E52),
            height: 1.4,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 470),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCE8D9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x102E7D32),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.size, required this.iconSize});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      scale: 1,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _lightGreen,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F2E7D32),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: _softGreen.withAlpha(130), width: 1.4),
        ),
        child: Icon(Icons.eco_rounded, color: _darkGreen, size: iconSize),
      ),
    );
  }
}

class _FadeScaleIn extends StatelessWidget {
  const _FadeScaleIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: ((value - 0.96) / 0.04).clamp(0, 1),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      cursorColor: _darkGreen,
      style: const TextStyle(
        color: _ink,
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
      ),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        errorText: errorText,
        suffix: suffix,
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  String? errorText,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    prefixIcon: Icon(icon, color: _darkGreen),
    suffixIcon: suffix,
    labelStyle: const TextStyle(
      color: Color(0xFF445247),
      fontWeight: FontWeight.w800,
    ),
    floatingLabelStyle: const TextStyle(
      color: _darkGreen,
      fontWeight: FontWeight.w900,
    ),
    errorStyle: const TextStyle(fontWeight: FontWeight.w700),
    filled: true,
    fillColor: _fieldFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFC7D8C5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFC7D8C5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _darkGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE53935)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.8),
    ),
  );
}

class _PrimaryAuthButton extends StatefulWidget {
  const _PrimaryAuthButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<_PrimaryAuthButton> createState() => _PrimaryAuthButtonState();
}

class _PrimaryAuthButtonState extends State<_PrimaryAuthButton> {
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
          height: 54,
          child: FilledButton(
            onPressed: widget.loading ? null : widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: _darkGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD6DED2),
              disabledForegroundColor: const Color(0xFF8C9A8D),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AuthSwitchText extends StatelessWidget {
  const _AuthSwitchText({
    required this.leading,
    required this.action,
    required this.onTap,
  });

  final String leading;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          leading,
          style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            child: Text(
              action,
              style: const TextStyle(
                color: _darkGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const indianStates = [
  'Andaman and Nicobar Islands',
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chandigarh',
  'Chhattisgarh',
  'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jammu and Kashmir',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Ladakh',
  'Lakshadweep',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Puducherry',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];
