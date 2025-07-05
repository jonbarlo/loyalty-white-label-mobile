import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/global_theme_service.dart';
import 'package:provider/provider.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.getAllConfig();
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get dynamic background color from theme
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'Config');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[ConfigScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.brown, // Fallback to brown if no theme
          appBar: AppBar(
            title: const Text('Configuration'),
            // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: isLoading 
            ? const Center(
                child: Column(
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
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environment Variables',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: config.length,
                        itemBuilder: (context, index) {
                          final key = config.keys.elementAt(index);
                          final value = config[key];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                key,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                value.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: Icon(
                                _getIconForType(value),
                                color: _getColorForType(value, context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Note: These values are loaded from environment variables or default values.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  IconData _getIconForType(dynamic value) {
    if (value is bool) {
      return value ? Icons.check_circle : Icons.cancel;
    } else if (value is String && value.startsWith('http')) {
      return Icons.link;
    } else if (value is int) {
      return Icons.timer;
    } else {
      return Icons.info;
    }
  }

  Color _getColorForType(dynamic value, BuildContext context) {
    if (value is bool) {
      return value ? Colors.green : Colors.red;
    } else if (value is String && value.startsWith('http')) {
      return Colors.blue;
    } else if (value is int) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
} 