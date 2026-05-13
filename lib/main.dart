import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth_flow_screens.dart';
import 'screens/main_screen.dart';
import 'services/address_controller.dart';
import 'services/address_repository.dart';
import 'services/auth_controller.dart';
import 'services/cart_controller.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await CartController.instance.load();
  await AuthController.instance.load();
  await ThemeController.instance.load();
  final addressController = AddressController(AddressRepository());
  await addressController.load();
  runApp(
    FasalXApp(
      addressController: addressController,
      authController: AuthController.instance,
      themeController: ThemeController.instance,
    ),
  );
}

class FasalXApp extends StatelessWidget {
  const FasalXApp({
    super.key,
    required this.addressController,
    required this.authController,
    required this.themeController,
  });

  final AddressController addressController;
  final AuthController authController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: addressController),
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: CartScope(
        controller: CartController.instance,
        child: Consumer2<AuthController, ThemeController>(
          builder: (context, auth, theme, _) {
            return MaterialApp(
              title: 'FasalX',
              debugShowCheckedModeBanner: false,
              locale: Locale(auth.selectedLanguage == 'Hindi' ? 'hi' : 'en'),
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: theme.themeMode,
              themeAnimationDuration: const Duration(milliseconds: 320),
              themeAnimationCurve: Curves.easeInOutCubic,
              home: AppEntryScreen(auth: auth),
              routes: {'/dashboard': (_) => const MainScreen()},
            );
          },
        ),
      ),
    );
  }
}
