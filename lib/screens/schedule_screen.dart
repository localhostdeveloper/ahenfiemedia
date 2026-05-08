import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ahenfie_media/models/program.dart';



class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  // Helper method to show details when a program is clicked
  void _openDetails(BuildContext context, Program program) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(program.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Host: ${program.host}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
            const Divider(height: 32),
            Text(program.description, style: const TextStyle(fontSize: 16, height: 1.4)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      body: SafeArea(
        child: Column(
          children: [
            // Logo at the Top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/logo.png', height: 60), 
                ),
              ),
            ),

            // Live Stream from Cloud
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('programs')
                    .orderBy('time') // Ensure your 'time' strings allow sorting
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final program = Program.fromFirestore(docs[index]);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: program.isLive ? Colors.red : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => _openDetails(context, program),
                          contentPadding: const EdgeInsets.all(12),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(program.time, style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (program.isLive)
                                const Text("• LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          title: Text(program.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(program.host),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}