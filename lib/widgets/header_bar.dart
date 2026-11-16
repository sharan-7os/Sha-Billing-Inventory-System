import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class HeaderBar extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;

  const HeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dateFormat = DateFormat('EEE, dd MMM yyyy • hh:mm:ss a');

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Screen Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Low Stock Alert Banner if any
          if (state.lowStockProducts.isNotEmpty) ...[
            InkWell(
              onTap: () => state.setViewIndex(2), // jump to inventory
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.lowStockProducts.length} Items Low Stock',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Live Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(_currentTime),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),

          if (widget.actions != null) ...[
            const SizedBox(width: 16),
            ...widget.actions!,
          ],
        ],
      ),
    );
  }
}

