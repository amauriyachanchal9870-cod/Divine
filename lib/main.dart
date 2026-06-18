import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Routes/my_routes.dart';
import 'package:divine_foundation/Utilities/app_string.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background Notification Received: ${message.notification?.title}");}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey = 'pk_test_51S5fp6Czvo41TV2vWNffi4LiPGT0OtV0WeKapCuMURiNZPvcfqWpOGyVExOWw7NQxRYcKEJJZpQaxai6LUhpcCq9001qzO1bH4';
  // await Stripe.instance.applySettings();

  try {
    await Firebase.initializeApp(
      // TODO: When running on a specific platform without config files (google-services.json or GoogleService-Info.plist),
      // you can provide the options manually here. Otherwise, ensure the config files are present.
      // options: FirebaseOptions(
      //   apiKey: "AIzaSyCT1ApvAtTVkIPkrpfVggUGN_IpPbSEps0",
      //   appId: "1:642740048789:ios:24421ddcff19bdce19dc9c",
      //   messagingSenderId: "642740048789",
      //   projectId: "openstatus-44592",
      // ),
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("Firebase initialization failed: $e");
    print("Please ensure you have added google-services.json (Android) or GoogleService-Info.plist (iOS)");
    print("Alternatively, run 'flutterfire configure' to generate firebase_options.dart");
  }

  await Hive.initFlutter();
  await Hive.openBox('login');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Divine Foundation',
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // home: const SplashScreen(),
      initialRoute: "/",
      getPages: MyRouters.route,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}

