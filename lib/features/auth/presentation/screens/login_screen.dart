import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/global_theme_service.dart';
import '../../../../core/providers/business_image_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/business.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load business image for current business ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessImageProvider>().loadBusinessImage(int.parse(AppConfig.currentBusinessId));
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('[LoginScreen] Error during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get dynamic background color from theme
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'Login');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[LoginScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.blue, // Fallback to blue if no theme
          appBar: AppBar(
            title: Text(
              'Login',
              style: TextStyle(
                color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: GlobalThemeService.getAppBarColor(context) ?? Colors.transparent,
            foregroundColor: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
            elevation: GlobalThemeService.getElevation(context) ?? 0,
          ),
          body: SafeArea(
            child: Center(
              child: isLoading 
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading theme...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo and Title
                          Consumer<BusinessImageProvider>(
                            builder: (context, businessImageProvider, child) {
                              final imageUrl = businessImageProvider.getBusinessImage(int.parse(AppConfig.currentBusinessId));
                              final isLoading = businessImageProvider.isLoading(int.parse(AppConfig.currentBusinessId));
                              
                              if (isLoading) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                                  width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              }
                              
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                return Container(
                                  height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                                  width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1), // Semi-transparent background
                                    borderRadius: BorderRadius.circular(
                                      GlobalThemeService.getBorderRadius(context) ?? 12,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      GlobalThemeService.getBorderRadius(context) ?? 12,
                                    ),
                                    child: Image.network(
                                      '${imageUrl}?business=${AppConfig.currentBusinessId}',
                                      height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                                      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                                      fit: BoxFit.contain, // Show full image in container
                                      errorBuilder: (context, error, stackTrace) {
                                        debugPrint('[LoginScreen] Error loading business image: $error');
                                        return _buildFallbackIcon();
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                                                              return SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                                        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      );
                                      },
                                    ),
                                  ),
                                );
                              }
                              
                              return _buildFallbackIcon();
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                              fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your loyalty account',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return ElevatedButton(
                                onPressed: (authProvider.isLoading || _isLoading) ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: GlobalThemeService.getDefaultPadding(context) ?? 24,
                                    vertical: GlobalThemeService.getDefaultPadding(context) ?? 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      GlobalThemeService.getBorderRadius(context) ?? 8,
                                    ),
                                  ),
                                ),
                                child: (authProvider.isLoading || _isLoading)
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                                  fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                style: TextButton.styleFrom(
                                  foregroundColor: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackIcon() {
    // Use a default business logo when API call fails
    return Container(
      height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
      decoration: BoxDecoration(
        color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      child: Icon(
        Icons.business,
        size: 60, // Increased icon size for larger container
        color: Colors.white,
      ),
    );
  }
} 