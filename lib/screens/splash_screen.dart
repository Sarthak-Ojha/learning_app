import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider_simple.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Safety fallback: always go somewhere after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _navigated) return;
      _navigated = true;
      Navigator.of(context).pushReplacementNamed('/auth');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    if (_navigated) return;
    final userProvider = Provider.of<UserProviderSimple>(context, listen: true);
    // Once auth resolves (not loading and authenticated), navigate immediately
    if (!userProvider.isLoading && userProvider.isAuthenticated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF81D4FA),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 400,
                  height: 400,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
