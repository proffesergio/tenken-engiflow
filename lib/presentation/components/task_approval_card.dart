import 'package:flutter/material.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';

class TaskApprovalCard extends StatefulWidget {
  final Task task;
  final Function(String) onApprove;
  final Function(String) onReject;
  
  const TaskApprovalCard({
    super.key,
    required this.task,
    required this.onApprove,
    required this.onReject,
  });
  
  @override
  State<TaskApprovalCard> createState() => _TaskApprovalCardState();
}

class _TaskApprovalCardState extends State<TaskApprovalCard> {
  bool _isExpanded = false;
  final _commentsController = TextEditingController();
  final _rejectReasonController = TextEditingController();
  
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            _isExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(widget.task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: _getPriorityColor(widget.task.priority),
                  ),
                ),
                title: Text(
                  widget.task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Due: ${widget.task.dueDate.toLocal().toString().substring(0, 10)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Chip(
                  label: Text(
                    widget.task.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getPriorityColor(widget.task.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: _getPriorityColor(widget.task.priority).withOpacity(0.1),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.task.description),
                  const SizedBox(height: 16),
                  Text(
                    'Assigned To: User ID ${widget.task.assignedTo}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentsController,
                    decoration: const InputDecoration(
                      labelText: 'Approval Comments (Optional)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onApprove(_commentsController.text);
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Reject Task'),
                                content: TextFormField(
                                  controller: _rejectReasonController,
                                  decoration: const InputDecoration(
                                    labelText: 'Rejection Reason',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      widget.onReject(_rejectReasonController.text);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Reject'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isExpanded: _isExpanded,
          ),
        ],
      ),
    );
  }
}