import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemeLoader extends StatefulWidget {
  final Widget child;
  final String businessId;

  const ThemeLoader({Key? key, required this.child, required this.businessId}) : super(key: key);

  @override
  State<ThemeLoader> createState() => _ThemeLoaderState();
}

class _ThemeLoaderState extends State<ThemeLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[ThemeLoader] Calling ThemeProvider.loadTheme("${widget.businessId}")');
      Provider.of<ThemeProvider>(context, listen: false).loadTheme(widget.businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 