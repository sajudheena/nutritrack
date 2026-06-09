import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/services/api_service.dart';
import 'src/services/auth_provider.dart';
import 'src/services/nutrition_provider.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/register_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/food_search_screen.dart';
import 'src/screens/profile_screen.dart';
import 'src/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  runApp(NutriTrackApp(apiService: apiService));
}

class NutriTrackApp extends StatelessWidget {
  final ApiService apiService;

  const NutriTrackApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Expose ApiService directly so screens can access it (e.g., history)
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(api: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => NutritionProvider(api: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'NutriTrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4CAF50),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const _AuthGate(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/food-search': (_) => const FoodSearchScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/history': (_) => const HistoryScreen(),
        },
      ),
    );
  }
}

/// Checks stored auth state and routes to home or login.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.loadFromStorage();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      final nutrition = context.read<NutritionProvider>();
      nutrition.setTargets(auth.profile!);
      await nutrition.loadDailyLog(DateTime.now());
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco, size: 56, color: Color(0xFF4CAF50)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ],
          ),
        ),
      );
    }
    return const LoginScreen();
  }
}
