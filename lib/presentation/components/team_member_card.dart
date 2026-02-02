import 'package:flutter/material.dart';

class TeamMemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onAssignTask;
  final VoidCallback onViewDetails;
  final VoidCallback onEvaluate;
  
  const TeamMemberCard({
    super.key,
    required this.member,
    required this.onAssignTask,
    required this.onViewDetails,
    required this.onEvaluate,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF37474F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            member['displayName'] ?? 'Unknown',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            member['department'] ?? 'Engineering',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.add_task, size: 20),
                onPressed: onAssignTask,
                tooltip: 'Assign Task',
                color: const Color(0xFF37474F),
              ),
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: onViewDetails,
                tooltip: 'View Details',
                color: Colors.blue,
              ),
              IconButton(
                icon: const Icon(Icons.assessment, size: 20),
                onPressed: onEvaluate,
                tooltip: 'Evaluate',
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}