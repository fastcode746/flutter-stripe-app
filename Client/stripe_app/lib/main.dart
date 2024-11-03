// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_app/services/helper_functions.dart';
import 'package:stripe_app/widgets/subscribe_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'].toString();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Stripe App',
      home: StripePaymentScreen(),
    );
  }
}

class StripePaymentScreen extends StatefulWidget {
  const StripePaymentScreen({
    super.key,
  });

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  bool status = false;
  @override
  void initState() {
    super.initState();
    getSubscriptionStatus();
  }

  Future<void> getSubscriptionStatus() async {
    await HelperFunctions.getSubscriptionStatus().then((value) {
      if (value != null) {
        setState(() {
          status = value;
        });
      }
    });
  }

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter-Stripe-Payment'),
      ),
      body: Center(
          child: status
              ? SubscribeButton(
                  title: "Unsubscribe",
                  onPress: () async {
                    await HelperFunctions.saveSubscriptionStatus(false);
                    setState(() {
                      status = false;
                    });
                  })
              : SubscribeButton(
                  title: "Subscribe for 15\$/month",
                  onPress: () async {
                    await makePayment();
                  })),
    );
  }

  Future<void> makePayment() async {
    try {
      // Create payment intent data
      paymentIntent = await createPaymentIntent('20', 'USD');
      // initialise the payment sheet setup
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Client secret key from payment data
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
              // Currency and country code is accourding to India
              testEnv: true,
              currencyCode: "USD",
              merchantCountryCode: "US"),
          // Merchant Name
          merchantDisplayName: 'FastCode Developers',
          // return URl if you want to add
          // returnURL: 'flutterstripe://redirect',
        ),
      );
      // Display payment sheet
      displayPaymentSheet();
    } catch (e) {
      if (kDebugMode) {
        print("exception $e");
      }

      if (e is StripeConfigException) {
        if (kDebugMode) {
          print("Stripe exception ${e.message}");
        }
      } else {
        if (kDebugMode) {
          print("exception $e");
        }
      }
    }
  }

  displayPaymentSheet() async {
    try {
      // "Display payment sheet";
      await Stripe.instance.presentPaymentSheet();
      // Show when payment is done
      // Displaying snackbar for it
      await HelperFunctions.saveSubscriptionStatus(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      setState(() {
        status = true;
      });
      paymentIntent = null;
    } on StripeException catch (e) {
      // If any error comes during payment
      // so payment will be cancelled
      if (kDebugMode) {
        print('Error: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" Payment Cancelled")),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error in displaying");
      }
      if (kDebugMode) {
        print('$e');
      }
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((int.parse(amount)) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey = dotenv.env['STRIPE_SECRET_KEY'];
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      if (kDebugMode) {
        print('Payment Intent Body: ${response.body.toString()}');
      }
      return jsonDecode(response.body.toString());
    } catch (err) {
      if (kDebugMode) {
        print('Error charging user: ${err.toString()}');
      }
    }
  }
}
