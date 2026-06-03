import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/theme.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({Key? key}) : super(key: key);
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  final _utrController = TextEditingController();
  final String upiId = "mishrashivam5740@oksbi";

  Future<void> initiateUPIPayment() async {
    final String amount = _amountController.text.trim();
    if(amount.isEmpty) return;

    // Direct standard Intent URI string mapping
    final String upiUrl = "upi://pay?pa=$upiId&pn=RS7_esport&cu=INR&am=$amount";
    
    if (await canLaunchUrl(Uri.parse(upiUrl))) {
      await launchUrl(Uri.parse(upiUrl));
    } else {
      // Fallback if browser/platform blocks direct intent execution
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open automatic UPI apps. Please copy UPI ID manually."))
      );
    }
  }

  Future<void> submitReceipt() async {
    if(_utrController.text.isEmpty || _amountController.text.isEmpty) return;
    
    await FirebaseFirestore.instance.collection('deposits').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'amount': double.parse(_amountController.text.trim()),
      'utr': _utrController.text.trim(),
      'screenshotUrl': 'placeholder_or_firebase_storage_url',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deposit requested submitted for Admin review!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Wallet Cash"), backgroundColor: RS7Theme.surface),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter Amount (INR)", prefixText: "₹ "),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
              onPressed: initiateUPIPayment,
              child: const Text("Pay Now (Automatic UPI Apps Open)"),
            ),
            const Divider(height: 40, color: Colors.grey),
            TextField(
              controller: _utrController,
              decoration: const InputDecoration(labelText: "Enter 12-Digit Ref/UTR Number"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: RS7Theme.primaryRed, minimumSize: const Size(double.infinity, 50)),
              onPressed: submitReceipt,
              child: const Text("Submit Verification Details"),
            )
          ],
        ),
      ),
    );
  }
}
