import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _matchIdController = TextEditingController();
  final _roomIdController = TextEditingController();
  final _roomPassController = TextEditingController();

  Future<void> updateRoomCredentials() async {
    await FirebaseFirestore.instance.collection('matches').doc(_matchIdController.text.trim()).update({
      'roomId': _roomIdController.text.trim(),
      'roomPassword': _roomPassController.text.trim(),
    });
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Credentials Broadcasted Successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RS7 Admin Console"), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Broadcast Custom Room Coordinates", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RS7Theme.primaryRed)),
            const SizedBox(height: 10),
            TextField(controller: _matchIdController, decoration: const InputDecoration(labelText: "Target Match Document ID")),
            TextField(controller: _roomIdController, decoration: const InputDecoration(labelText: "New Room ID")),
            TextField(controller: _roomPassController, decoration: const InputDecoration(labelText: "New Room Password")),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: RS7Theme.ElectricBlue),
              onPressed: updateRoomCredentials,
              child: const Text("Push live Room Details (Updates Joined Users Only)"),
            ),
            const SizedBox(height: 30),
            const Text("Incoming Deposits Management Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              height: 250,
              color: RS7Theme.surface,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('deposits').where('status', isEqualTo: 'pending').snapshots(),
                builder: (context, snap) {
                  if(!snap.hasData) return const LinearProgressIndicator();
                  return ListView.builder(
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, idx) {
                      var dep = snap.data!.docs[idx];
                      return ListTile(
                        title: Text("Ref/UTR: ${dep['utr']}"),
                        subtitle: Text("Amount: ₹${dep['amount']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _approveDeposit(dep.id, dep['userId'], dep['amount'])),
                            IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _rejectDeposit(dep.id)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _approveDeposit(String id, String uid, dynamic amount) async {
    var uRef = FirebaseFirestore.instance.collection('users').doc(uid);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      var snapshot = await transaction.get(uRef);
      double current = snapshot['walletBalance'] ?? 0.0;
      transaction.update(uRef, {'walletBalance': current + amount});
      transaction.update(FirebaseFirestore.instance.collection('deposits').doc(id), {'status': 'approved'});
    });
  }

  void _rejectDeposit(String id) {
     FirebaseFirestore.instance.collection('deposits').doc(id).update({'status': 'rejected'});
  }
}
