import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/business_provider.dart';
import 'core/providers/punch_card_provider.dart';
import 'core/providers/point_transaction_provider.dart';
import 'core/providers/reward_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/config/app_config.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/theme_service.dart';
import 'core/providers/theme_loader.dart';
import 'core/services/storage_test_service.dart';
import 'core/providers/business_image_provider.dart';
import 'core/services/business_image_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('[main.dart] Starting app initialization...');
  
  // Initialize environment variables
  await AppConfig.initialize();
  debugPrint('[main.dart] AppConfig initialized');
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  debugPrint('[main.dart] StorageService initialized');
  
  // Test SharedPreferences functionality
  await StorageTestService.testSharedPreferences();
  await StorageTestService.listAllKeys();
  
  final apiService = ApiService();
  debugPrint('[main.dart] ApiService initialized');
  
  debugPrint('[main.dart] Running app...');
  runApp(MyApp(
    storageService: storageService,
    apiService: apiService,
  ));
}

class MyApp extends StatefulWidget {
  final StorageService storageService;
  final ApiService apiService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.apiService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    debugPrint('[MyApp] initState called');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[MyApp] build called');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(widget.apiService, widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (context) => BusinessProvider(widget.apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => PunchCardProvider(widget.apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => PointTransactionProvider(widget.apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => RewardProvider(widget.apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(widget.apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(ThemeService(widget.apiService.dio)),
        ),
        ChangeNotifierProvider(
          create: (context) => BusinessImageProvider(BusinessImageService(widget.apiService.dio)),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          debugPrint('[MyApp] AuthProvider state - isAuthenticated: ${authProvider.isAuthenticated}, isLoading: ${authProvider.isLoading}');
          
          final router = AppRouter(authProvider).router;
          
          return ThemeLoader(
            businessId: '1',
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final dynamicBg = themeProvider.theme?.backgroundColor;
                debugPrint('[main.dart] dynamicBg: $dynamicBg');
                debugPrint('[main.dart] themeProvider.isLoading: ${themeProvider.isLoading}');
                debugPrint('[main.dart] themeProvider.hasError: ${themeProvider.hasError}');
                
                return MaterialApp.router(
                  title: AppConfig.appName,
                  theme: AppTheme.darkTheme.copyWith(
                    scaffoldBackgroundColor: dynamicBg ?? AppTheme.darkTheme.scaffoldBackgroundColor,
                  ),
                  darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeMode.dark,
                  routerConfig: router,
                  debugShowCheckedModeBanner: AppConfig.debugMode,
                  builder: (context, child) {
                    debugPrint('[MyApp] MaterialApp.router builder called');
                    return child ?? const SizedBox.shrink();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
} 