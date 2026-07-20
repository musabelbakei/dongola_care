import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'utils/app_constants.dart';

void main() {
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appNameAr,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        scaffoldBackgroundColor: AppColors.scaffold,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 3,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.primaryLight,
          labelStyle: TextStyle(color: AppColors.primaryDark),
          side: BorderSide.none,
        ),
      ),
      home: const HomeScreen(),
      // إصلاح طلب #7: هذا الخط أصلاً كان false، فعلامة DEBUG التي تظهر
      // أعلى الشاشة الرئيسية ليست من هنا، بل هي شارة "Debug" التي يضيفها
      // Flutter تلقائياً عند التشغيل بوضع Debug (flutter run العادي) —
      // راجع الملاحظة المرفقة بعد الملفات لطريقة إخفائها نهائياً عبر بناء
      // نسخة Release الحقيقية.
      debugShowCheckedModeBanner: false,
    );
  }
}
