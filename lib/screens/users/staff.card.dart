import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/app_router.gr.dart';
import 'package:flutter/material.dart';

class StaffCard extends StatelessWidget {
  const StaffCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Center(
            child: SizedBox(width: 100, height: 100, child: CircleAvatar()),
          ),
          SizedBox(height: 20),
          Text(
            'Chiamaka Uzombachi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          SizedBox(height: 5),
          Text('Senior Software Engineer', style: TextStyle(fontSize: 10)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.router.push(ViewUser(id: ''));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text('View', style: TextStyle(fontSize: 10)),
                ),
              ),

              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text('Edit', style: TextStyle(fontSize: 10)),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(fontSize: 10, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
