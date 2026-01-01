import 'package:flutter/material.dart';

import '../model/task_model.dart';
// import your Task model file here
// import 'package:your_app/model/task.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          task.name,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title
                    Text(
                      task.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status + Project
                    Row(
                      children: [
                        const Icon(Icons.flag, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${task.status.toUpperCase()} • ${task.projectName}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Deadline
                    Row(
                      children: [
                        const Icon(Icons.event, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Deadline: ${task.deadline ?? '---'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Priority
                    Row(
                      children: [
                        const Icon(Icons.priority_high, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "Priority: ${task.priority}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Optional: if you have description field in Task model, show it here
            // Example:
            // if (task.description != null && task.description!.isNotEmpty) ...[
            //   const Text(
            //     "Description",
            //     style: TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            //   const SizedBox(height: 8),
            //   Text(task.description!),
            // ],
          ],
        ),
      ),
    );
  }
}
