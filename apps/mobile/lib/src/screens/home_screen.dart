import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../services/nutrition_provider.dart';
import '../widgets/nutrient_progress_bar.dart';
import '../widgets/food_log_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadDailyLog(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _DashboardTab(),
          _HistoryTabPlaceholder(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) {
          if (i == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/profile');
          } else {
            setState(() => _navIndex = i);
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history),
              label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/food-search'),
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NutritionProvider>(
      builder: (context, auth, nutrition, _) {
        final profile = auth.profile;
        final log = nutrition.dailyLog;
        final targets = nutrition.targets;
        final today = DateFormat('EEEE, MMM d').format(DateTime.now());

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              snap: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${profile?.name.split(' ').first ?? 'there'}!',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(today,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            ),
            if (nutrition.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              // Nutrient progress section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Progress',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (targets != null && log != null) ...[
                            NutrientProgressBar(
                              label: 'Calories',
                              current: log.totals.calories,
                              target: targets.calories,
                              unit: 'kcal',
                            ),
                            NutrientProgressBar(
                              label: 'Protein',
                              current: log.totals.protein,
                              target: targets.protein,
                            ),
                            NutrientProgressBar(
                              label: 'Carbs',
                              current: log.totals.carbs,
                              target: targets.carbs,
                            ),
                            NutrientProgressBar(
                              label: 'Fat',
                              current: log.totals.fat,
                              target: targets.fat,
                            ),
                            NutrientProgressBar(
                              label: 'Fiber',
                              current: log.totals.fiber,
                              target: targets.fiber,
                            ),
                          ] else
                            const Text(
                                'Set up your profile to see targets.',
                                style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Log entries
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Food Log  (${log?.entries.length ?? 0} entries)',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (log == null || log.entries.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No food logged yet.\nTap + Add Food to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final entry = log.entries[i];
                      return FoodLogTile(
                        entry: entry,
                        onDelete: () => _deleteEntryFromContext(context, entry.id),
                      );
                    },
                    childCount: log.entries.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        );
      },
    );
  }

  Future<void> _deleteEntryFromContext(
      BuildContext context, String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry'),
        content: const Text('Remove this food entry from your log?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  Text('Delete', style: TextStyle(color: Colors.red.shade600))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<NutritionProvider>().removeEntry(entryId);
    }
  }
}

// Placeholder so IndexedStack doesn't complain — actual history uses routing
class _HistoryTabPlaceholder extends StatelessWidget {
  const _HistoryTabPlaceholder();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
