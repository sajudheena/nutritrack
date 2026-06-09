import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/common.dart';
import '../services/nutrition_provider.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchCtrl = TextEditingController();
  List<FoodItem> _results = FoodDatabase.items;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchCtrl.text.trim();
    setState(() {
      _results =
          query.isEmpty ? FoodDatabase.items : FoodDatabase.search(query);
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAddDialog(FoodItem item) async {
    final gramsCtrl = TextEditingController(text: '100');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category: ${item.category}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Per 100g: ${item.calories.toStringAsFixed(0)} kcal  '
                '· P ${item.protein.toStringAsFixed(1)}g  '
                '· C ${item.carbs.toStringAsFixed(1)}g  '
                '· F ${item.fat.toStringAsFixed(1)}g',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: gramsCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Amount (grams)',
                  border: OutlineInputBorder(),
                  suffixText: 'g',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter grams';
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Add to Log'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final grams = double.parse(gramsCtrl.text.trim());
      final success = await context.read<NutritionProvider>().addEntry(
            foodItemId: item.id,
            grams: grams,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${item.name} (${grams.toStringAsFixed(0)}g) added to log'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final error =
            context.read<NutritionProvider>().error ?? 'Failed to add entry';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Foods'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by food name or category...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_results.length} results',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final item = _results[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _categoryColor(item.category)
                        .withOpacity(0.15),
                    child: Icon(
                      _categoryIcon(item.category),
                      color: _categoryColor(item.category),
                      size: 20,
                    ),
                  ),
                  title: Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    '${item.category}  ·  ${item.calories.toStringAsFixed(0)} kcal/100g',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.add_circle_outline,
                      color: Color(0xFF4CAF50)),
                  onTap: () => _showAddDialog(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Grains':
        return Colors.amber.shade700;
      case 'Dairy':
        return Colors.blue.shade400;
      case 'Meat & Fish':
        return Colors.red.shade400;
      case 'Vegetables':
        return Colors.green.shade600;
      case 'Fruits':
        return Colors.orange.shade500;
      case 'Legumes':
        return Colors.brown.shade400;
      case 'Nuts & Seeds':
        return Colors.brown.shade600;
      case 'Snacks':
        return Colors.purple.shade400;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Grains':
        return Icons.grain;
      case 'Dairy':
        return Icons.local_drink_outlined;
      case 'Meat & Fish':
        return Icons.set_meal_outlined;
      case 'Vegetables':
        return Icons.eco_outlined;
      case 'Fruits':
        return Icons.apple_outlined;
      case 'Legumes':
        return Icons.spa_outlined;
      case 'Nuts & Seeds':
        return Icons.scatter_plot_outlined;
      case 'Snacks':
        return Icons.cookie_outlined;
      default:
        return Icons.food_bank_outlined;
    }
  }
}
