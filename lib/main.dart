import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // set the publishable key for Stripe - this is mandatory
  Stripe.publishableKey =
      'pk_test_51MUrVLSAa0c1p3HXktfOFQz8its4jPwsqDeJu6Bi8daM5ABS8UNY6dvKEvUvNKE9Ug9sAzgQoL1FhblccFTHJryM00rMV4JcJR';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Paypal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Paypal Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('10', 'INR');

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'mukesh'))
          .then((value) {});

      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  Future createPaymentIntent(String amount, String currency) async {
    final calculatedAmount = (int.parse(amount)) * 100;
    try {
      Map<String, dynamic> body = {
        'amount': '$calculatedAmount',
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51MUrVLSAa0c1p3HXhE6N7smkngtn6Bkl9b4V4dsBjIav0XPRDkYcwqlVAXnwrMxISGkWzBc6c7qFVJchbnOZZRcq00NXf5MmMY',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      print('pamentIntentresoponse ====> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print(err.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Text('Payment Successful'),
                    ],
                  )
                ]),
              ));

      paymentIntent = null;
    } on StripeException catch (err) {
      print('Error is : =======> $err');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text('Cancelled'),
              ));
    } catch (e) {
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => UsePaypal(
                                sandboxMode: true,
                                clientId:
                                    "AaleUMWGT-0Hs-RC03RpoqLBlqAFt0r4hiu6xRq8cSBkMjS4UdFAzU4QW7g79yr_I7WzAaU2-nchp4TX",
                                secretKey:
                                    "EEfKwKdBItvM6UxrultpM9vLPFfQxXGhIFDxuAGnV-r_lvrNlXUlur63-DT3aRZrJdvjxNrYntb5pxf8",
                                returnURL: "https://samplesite.com/return",
                                cancelURL: "https://samplesite.com/cancel",
                                transactions: const [
                                  {
                                    "amount": {
                                      "total": '10.12',
                                      "currency": "USD",
                                      "details": {
                                        "subtotal": '10.12',
                                        "shipping": '0',
                                        "shipping_discount": 0
                                      }
                                    },
                                    "description":
                                        "The payment transaction description.",
                                    // "payment_options": {
                                    //   "allowed_payment_method":
                                    //       "INSTANT_FUNDING_SOURCE"
                                    // },
                                    "item_list": {
                                      "items": [
                                        {
                                          "name": "A demo product",
                                          "quantity": 1,
                                          "price": '10.12',
                                          "currency": "USD"
                                        }
                                      ],

                                      // shipping address is not required though
                                      "shipping_address": {
                                        "recipient_name": "Jane Foster",
                                        "line1": "Travis County",
                                        "line2": "",
                                        "city": "Austin",
                                        "country_code": "US",
                                        "postal_code": "73301",
                                        "phone": "+00000000",
                                        "state": "Texas"
                                      },
                                    }
                                  }
                                ],
                                note:
                                    "Contact us for any questions on your order.",
                                onSuccess: (Map params) async {
                                  print("onSuccess: $params");
                                },
                                onError: (error) {
                                  print("onError: $error");
                                },
                                onCancel: (params) {
                                  print('cancelled: $params');
                                }),
                          ),
                        )
                      },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.paypal_outlined),
                      Text('Pay with Paypal')
                    ],
                  )),
              TextButton(
                  onPressed: () async {
                    await makePayment();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_outlined),
                      Text('Pay with Stripe')
                    ],
                  )),
            ],
          ),
        ));
  }
}
