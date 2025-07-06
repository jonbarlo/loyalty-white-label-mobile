import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/punch_cards/presentation/screens/punch_cards_screen.dart';
import '../../features/punch_cards/presentation/screens/punch_card_detail_screen.dart';
import '../../features/points/presentation/screens/points_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/business/presentation/screens/business_list_screen.dart';
import '../../features/business/presentation/screens/business_detail_screen.dart';
import '../../features/business/presentation/screens/business_form_screen.dart';
import '../../features/business/presentation/screens/business_test_screen.dart';
import '../../features/theme_editor/presentation/screens/theme_editor_screen.dart';
import '../../features/coupons/presentation/screens/admin_coupons_screen.dart';
import '../../features/coupons/presentation/screens/customer_coupons_screen.dart';
import '../../features/coupons/presentation/screens/coupon_form_screen.dart';
import '../providers/auth_provider.dart';
import '../../core/models/business.dart';
import '../../core/models/coupon.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router => GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register';
      final isBusinessRoute = state.matchedLocation.startsWith('/businesses');

      print('Router redirect - isAuthenticated: $isAuthenticated, location: ${state.matchedLocation}');

      if (!isAuthenticated && !isAuthRoute) {
        print('Redirecting to /login');
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        // Redirect to appropriate default route based on user role
        if (authProvider.isAdmin) {
          print('Admin user, redirecting to /businesses');
          return '/businesses';
        } else {
          print('Regular user, redirecting to /dashboard');
          return '/dashboard';
        }
      }

      // Redirect non-admin users away from business routes
      if (isAuthenticated && isBusinessRoute && !authProvider.isAdmin) {
        print('Non-admin user trying to access business route, redirecting to /dashboard');
        return '/dashboard';
      }

      // Redirect admin users away from user-only routes
      if (isAuthenticated && authProvider.isAdmin) {
        final userOnlyRoutes = ['/dashboard', '/punch-cards', '/points', '/rewards'];
        if (userOnlyRoutes.any((route) => state.matchedLocation.startsWith(route))) {
          print('Admin user trying to access user-only route, redirecting to /businesses');
          return '/businesses';
        }
      }

      print('No redirect needed');
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main app routes
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/punch-cards',
            name: 'punch-cards',
            builder: (context, state) => const PunchCardsScreen(),
          ),
          GoRoute(
            path: '/punch-cards/:id',
            name: 'punch-card-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return PunchCardDetailScreen(punchCardId: id);
            },
          ),
          GoRoute(
            path: '/points',
            name: 'points',
            builder: (context, state) => const PointsScreen(),
          ),
          GoRoute(
            path: '/rewards',
            name: 'rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/businesses',
            name: 'businesses',
            builder: (context, state) => const BusinessListScreen(),
          ),
          GoRoute(
            path: '/businesses/create',
            name: 'business-create',
            builder: (context, state) => const BusinessFormScreen(),
          ),
          GoRoute(
            path: '/businesses/test',
            name: 'business-test',
            builder: (context, state) => const BusinessTestScreen(),
          ),
          GoRoute(
            path: '/theme-editor',
            name: 'theme-editor',
            builder: (context, state) {
              final businessId = state.uri.queryParameters['businessId'];
              return ThemeEditorScreen(businessId: businessId);
            },
          ),
          GoRoute(
            path: '/businesses/:id/edit',
            name: 'business-edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BusinessFormScreen(businessId: id);
            },
          ),
          GoRoute(
            path: '/businesses/:id',
            name: 'business-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BusinessDetailScreen(businessId: id);
            },
          ),
          // Coupon routes
          GoRoute(
            path: '/coupons',
            name: 'admin-coupons',
            builder: (context, state) => const AdminCouponsScreen(),
          ),
          GoRoute(
            path: '/coupon-form',
            name: 'coupon-form',
            builder: (context, state) {
              final coupon = state.extra as Coupon?;
              return CouponFormScreen(coupon: coupon);
            },
          ),
          GoRoute(
            path: '/my-coupons',
            name: 'customer-coupons',
            builder: (context, state) => const CustomerCouponsScreen(),
          ),
        ],
      ),
    ],
  );
}

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  List<NavigationItem> get _navigationItems {
    final authProvider = context.read<AuthProvider>();
    final items = <NavigationItem>[];
    
    if (authProvider.isAdmin) {
      // For admin users: only show Business and Profile
      items.addAll([
        NavigationItem(
          icon: Icons.business,
          label: 'Businesses',
          route: '/businesses',
        ),
        NavigationItem(
          icon: Icons.person,
          label: 'Profile',
          route: '/profile',
        ),
      ]);
    } else {
      // For regular users: show Dashboard, Punch Cards, Points, Rewards, Coupons, and Profile
      items.addAll([
        NavigationItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          route: '/dashboard',
        ),
        NavigationItem(
          icon: Icons.card_giftcard,
          label: 'Punch Cards',
          route: '/punch-cards',
        ),
        NavigationItem(
          icon: Icons.stars,
          label: 'Points',
          route: '/points',
        ),
        NavigationItem(
          icon: Icons.redeem,
          label: 'Rewards',
          route: '/rewards',
        ),
        NavigationItem(
          icon: Icons.local_offer,
          label: 'Coupons',
          route: '/my-coupons',
        ),
        NavigationItem(
          icon: Icons.person,
          label: 'Profile',
          route: '/profile',
        ),
      ]);
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems = _navigationItems;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    debugPrint('[MainScaffold] build, scaffoldBackgroundColor: $scaffoldBg');
    
    // Determine current index based on current route
    final currentRoute = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    for (int i = 0; i < navigationItems.length; i++) {
      if (currentRoute.startsWith(navigationItems[i].route)) {
        currentIndex = i;
        break;
      }
    }
    
    // Update current index if it changed
    if (_currentIndex != currentIndex) {
      _currentIndex = currentIndex;
    }
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          context.go(navigationItems[index].route);
        },
        type: BottomNavigationBarType.fixed,
        items: navigationItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        )).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
} 