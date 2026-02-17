import 'dart:io';
import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    final months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final weekday = weekdays[date.weekday % 7];
    
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    
    return '$month $day, $year\n$weekday • $displayHour:$minute $period';
  }

  Widget _buildImage(String imagePath) {
    // Check if the image is a URL or local file path
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateParts = _formatDate(entry.createdAt).split('\n');
    final dateLine = dateParts[0];
    final timeLine = dateParts[1];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF1F5F9)
              : const Color(0xFF334155),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and more button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLine,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF475569),
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  )
                else
                  Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF475569),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Content with optional image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text content
                Expanded(
                  child: Text(
                    entry.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          height: 1.5,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Image if available
                if (entry.hasImage)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFF334155),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImage(entry.imagePath!),
                    ),
                  ),
              ],
            ),
            
            // Tags if available
            if (entry.hasMood || entry.hasLocation)
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (entry.hasMood)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          entry.mood!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    if (entry.hasLocation)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          entry.location!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}