import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/punch_card_provider.dart';
import 'core/providers/point_transaction_provider.dart';
import 'core/providers/reward_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  final apiService = ApiService();
  
  runApp(MyApp(
    storageService: storageService,
    apiService: apiService,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(apiService, storageService),
        ),
        ChangeNotifierProvider(
          create: (context) => PunchCardProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => PointTransactionProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => RewardProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(apiService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = AppRouter(authProvider).router;
          
          return MaterialApp.router(
            title: 'Loyalty App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
} 