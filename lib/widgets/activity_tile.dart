import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/theme.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(bool?)? onCompleted;

  const ActivityTile({
    Key? key,
    required this.activity,
    required this.onTap,
    required this.onDelete,
    this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.activityColor(activity.category ?? 'other');

    return Dismissible(
      key: Key(activity.id),
      onDismissed: (_) => onDelete(),
      background: Container(
        color: AppTheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppTheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                decoration: activity.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (activity.priority > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${activity.priority}★',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (activity.startTime != null)
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  activity.startTime!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          if (activity.category != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  activity.category!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: activity.completed,
                  onChanged: onCompleted,
                  activeColor: color,
                  checkColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
