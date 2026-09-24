// lib/screens/payment_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

/// Returns true/false/null (null = user backed out / inconclusive).
/// Treat this as a hint only — confirm the real status via your backend after.
class PaymentWebviewScreen extends StatefulWidget {
  final String redirectUrl;
  const PaymentWebviewScreen({super.key, required this.redirectUrl});

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            // Adjust these matches to whatever "return URL" pattern your
            // backend configures with Paymob (success/failure query params).
            if (url.contains('success=true')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            if (url.contains('success=false')) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('payment.complete_payment'.tr())),
      body: WebViewWidget(controller: _controller),
    );
  }
}
