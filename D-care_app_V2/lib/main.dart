// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/chatbot/presentation/chat_screen.dart';
import 'features/insight/presentation/insight_screen.dart';
import 'features/health_profile/presentation/health_input_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: DCareApp()));
}

final mainShellKey = GlobalKey<_MainShellState>();

class DCareApp extends StatelessWidget {
  const DCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.bgSecondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textSecondary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.bgPrimary,
          indicatorColor: AppColors.bgSecondary,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final sel = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              color: sel ? AppColors.accent : AppColors.textTertiary,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          hintStyle: const TextStyle(
              color: AppColors.textTertiary, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// 메인 탭 쉘
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 1; // 챗봇 기본값

  void navigateTo(int index) {
    setState(() => _index = index);
  }

  // IndexedStack으로 탭 상태 유지
  final _screens = const [
    DashboardScreen(),  // Tab 0: 대시보드
    ChatScreen(),       // Tab 1: 챗봇 (LLM)
    InsightScreen(),    // Tab 2: 인사이트 (ML)
    HealthInputScreen(),// Tab 3: 건강정보
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5))),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined,
                  color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.dashboard,
                  color: AppColors.accent),
              label: '대시보드',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline,
                  color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.chat_bubble,
                  color: AppColors.accent),
              label: '챗봇',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined,
                  color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.insights,
                  color: AppColors.accent),
              label: '인사이트',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline,
                  color: AppColors.textTertiary),
              selectedIcon: Icon(Icons.person,
                  color: AppColors.accent),
              label: '건강정보',
            ),
          ],
        ),
      ),
    );
  }
}
