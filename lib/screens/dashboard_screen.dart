import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/image_3.png', height: 40), // Branded Header Icon
        backgroundColor: RS7Theme.background,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('matches').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var match = snapshot.data!.docs[index];
              List joinedUsers = match['joinedUserIds'] ?? [];
              bool isJoined = joinedUsers.contains(currentUid);

              return Card(
                color: RS7Theme.surface,
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(match['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Map: ${match['map']}"),
                          Text("Prize Pool: ₹${match['prizePool']}"),
                          Text("Per Kill: ₹${match['perKill']}"),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      
                      // Dynamic Secret Data Component Panel
                      if (isJoined) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.black38,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("🔒 ROOM INFORMATION (Reveals 15m before start)", style: TextStyle(color: RS7Theme.primaryRed, fontWeight: FontWeight.bold)),
                              Text("Room ID: ${match['roomId'] ?? 'WAITING...'}", style: const TextStyle(fontSize: 16, color: Colors.green)),
                              Text("Password: ${match['roomPassword'] ?? 'WAITING...'}", style: const TextStyle(fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        )
                      ] else ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: RS7Theme.primaryRed),
                          onPressed: () => _joinMatchLogic(match.id, match['entryFee'], currentUid, joinedUsers),
                          child: Text("Join Match (Fee: ₹${match['entryFee']})"),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _joinMatchLogic(String matchId, dynamic fee, String uid, List joined) async {
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').document(uid);
    DocumentReference matchRef = FirebaseFirestore.instance.collection('matches').document(matchId);

    var userSnap = await userRef.get();
    double currentBalance = userSnap['walletBalance'] ?? 0.0;

    if(currentBalance >= fee) {
      await userRef.updateData({'walletBalance': currentBalance - fee});
      joined.add(uid);
      await matchRef.updateData({'joinedUserIds': joined});
    }
  }
}
