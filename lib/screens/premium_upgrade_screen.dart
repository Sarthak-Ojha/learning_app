import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../providers/user_provider_simple.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  bool _isProcessing = false;

  Future<void> _processStripePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Create a PaymentIntent on the Stripe server (Hackathon serverless approach)
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer YOUR_STRIPE_SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'amount=999&currency=usd&automatic_payment_methods[enabled]=true',
      );

      final paymentIntentData = jsonDecode(response.body);

      if (paymentIntentData['error'] != null) {
        throw Exception(paymentIntentData['error']['message']);
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'GyanYatra',
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6772E5),
            ),
          ),
        ),
      );

      // 3. Display Payment Sheet and wait for user
      await Stripe.instance.presentPaymentSheet();

      // 4. Payment was successful, give user premium access
      if (!mounted) return;
      await Provider.of<UserProviderSimple>(context, listen: false).upgradeToPremium();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful! Premium features unlocked.'),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context); // Go back to map

    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Cancelled / Failed: ${e.error.localizedMessage}'))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Upgrade to Premium', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.verified, size: 64, color: Color(0xFF6772E5)),
                const SizedBox(height: 16),
                const Text(
                  'Lifetime Access',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF32325D)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unlock all classes, levels, and mini-games to accelerate learning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF525F7F)),
                ),
                const SizedBox(height: 32),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F9FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE6EBF1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.payment, color: Color(0xFF6772E5)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Checkout via Stripe Official Portal',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF32325D)),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                _isProcessing
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF6772E5)))
                    : ElevatedButton(
                        onPressed: _processStripePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6772E5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Pay \$9.99 with Stripe',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 14, color: Color(0xFFAAB7C4)),
                    SizedBox(width: 4),
                    Text(
                      'Secured by Stripe Checkout',
                      style: TextStyle(color: Color(0xFFAAB7C4), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
