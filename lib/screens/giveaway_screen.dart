import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';

class GiveawayScreen extends StatefulWidget {
  final String winnerUserId;
  const GiveawayScreen({required this.winnerUserId, Key? key}) : super(key: key);

  @override
  _GiveawayScreenState createState() => _GiveawayScreenState();
}

class _GiveawayScreenState extends State<GiveawayScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  void submitWinnerDetails() async {
    String message = "🔥 *RS7_esport Giveaway Winner Detail* 🔥\n\n"
                     "👤 Name: ${_name.text}\n"
                     "📞 Phone: ${_phone.text}\n"
                     "📍 Address: ${_address.text}\n"
                     "🆔 Winner ID: ${widget.winnerUserId}";

    String whatsappUrl = "https://wa.me/918858509091?text=${Uri.encodeComponent(message)}";
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Claim Rewards"), backgroundColor: RS7Theme.primaryRed),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("🎉 Congratulations! You have won the Giveaway! Fill details to dispatch your prize:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(controller: _name, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: "Phone Number")),
            TextField(controller: _address, maxLines: 3, decoration: const InputDecoration(labelText: "Shipping Address")),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
              onPressed: submitWinnerDetails,
              child: const Text("Submit to WhatsApp Verification"),
            )
          ],
        ),
      ),
    );
  }
}
