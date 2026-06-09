import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:common/common.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Map from dateStr to DailyLog
  final Map<String, DailyLog> _logs = {};
  bool _isLoading = false;
  String? _error;
  String? _expandedDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    final now = DateTime.now();

    try {
      // Fetch the last 14 days
      for (int i = 0; i < 14; i++) {
        final date = now.subtract(Duration(days: i));
        final log = await api.getDailyLog(date);
        final key = _dateStr(date);
        _logs[key] = log;
      }
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final sortedDates = _logs.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadHistory,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, i) {
                      final dateStr = sortedDates[i];
                      final log = _logs[dateStr]!;
                      final date = DateTime.parse(dateStr);
                      final isToday = dateStr == _dateStr(DateTime.now());
                      final isExpanded = _expandedDate == dateStr;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isToday
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade300,
                                child: Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                      color: isToday
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                isToday
                                    ? 'Today'
                                    : DateFormat('EEEE, MMM d').format(date),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: log.entries.isEmpty
                                  ? const Text('No entries',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12))
                                  : Text(
                                      '${log.entries.length} item${log.entries.length == 1 ? '' : 's'}  ·  '
                                      '${log.totals.calories.toStringAsFixed(0)} kcal  ·  '
                                      'P ${log.totals.protein.toStringAsFixed(1)}g',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                              trailing: log.entries.isEmpty
                                  ? null
                                  : Icon(isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more),
                              onTap: log.entries.isEmpty
                                  ? null
                                  : () => setState(() =>
                                      _expandedDate =
                                          isExpanded ? null : dateStr),
                            ),
                            if (isExpanded)
                              ListView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(
                                    left: 16, right: 8, bottom: 8),
                                itemCount: log.entries.length,
                                itemBuilder: (context, j) {
                                  final entry = log.entries[j];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 3),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle,
                                            size: 6,
                                            color: Color(0xFF4CAF50)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${entry.foodName} — ${entry.grams.toStringAsFixed(0)}g',
                                            style: const TextStyle(
                                                fontSize: 13),
                                          ),
                                        ),
                                        Text(
                                          '${entry.nutrients.calories.toStringAsFixed(0)} kcal',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
