import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/common.dart';
import '../services/auth_provider.dart';
import '../services/nutrition_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;

  String _gender = 'male';
  String _activityLevel = 'moderatelyActive';
  bool _editing = false;

  static const _activityLabels = {
    'sedentary': 'Sedentary',
    'lightlyActive': 'Lightly Active',
    'moderatelyActive': 'Moderately Active',
    'veryActive': 'Very Active',
    'extraActive': 'Extra Active',
  };

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _ageCtrl =
        TextEditingController(text: profile?.age.toString() ?? '');
    _weightCtrl = TextEditingController(
        text: profile?.weightKg.toStringAsFixed(1) ?? '');
    _heightCtrl = TextEditingController(
        text: profile?.heightCm.toStringAsFixed(1) ?? '');
    if (profile != null) {
      _gender = profile.gender.name;
      _activityLevel = profile.activityLevel.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().updateProfile({
      'name': _nameCtrl.text.trim(),
      'age': int.parse(_ageCtrl.text.trim()),
      'weightKg': double.parse(_weightCtrl.text.trim()),
      'heightCm': double.parse(_heightCtrl.text.trim()),
      'gender': _gender,
      'activityLevel': _activityLevel,
    });

    if (!mounted) return;

    if (success) {
      final profile = context.read<AuthProvider>().profile!;
      context.read<NutritionProvider>().setTargets(profile);
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_editing)
            IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit profile',
                onPressed: () => setState(() => _editing = true))
          else ...[
            TextButton(
                onPressed: () => setState(() => _editing = false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: _save,
                child: const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ]
        ],
      ),
      body: Consumer2<AuthProvider, NutritionProvider>(
        builder: (context, auth, nutrition, _) {
          final profile = auth.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final bmr = NutritionCalculator.calculateBMR(profile);
          final tdee = NutritionCalculator.calculateTDEE(profile);
          final targets = NutritionCalculator.calculateTargets(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + name header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            const Color(0xFF4CAF50).withOpacity(0.15),
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 36,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(profile.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(profile.email,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Metrics cards
                Row(
                  children: [
                    _MetricCard(
                        label: 'BMR',
                        value: '${bmr.toStringAsFixed(0)} kcal'),
                    const SizedBox(width: 12),
                    _MetricCard(
                        label: 'TDEE',
                        value: '${tdee.toStringAsFixed(0)} kcal'),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daily Targets',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _TargetRow(
                            label: 'Calories',
                            value:
                                '${targets.calories.toStringAsFixed(0)} kcal'),
                        _TargetRow(
                            label: 'Protein',
                            value:
                                '${targets.protein.toStringAsFixed(1)} g'),
                        _TargetRow(
                            label: 'Carbs',
                            value:
                                '${targets.carbs.toStringAsFixed(1)} g'),
                        _TargetRow(
                            label: 'Fat',
                            value: '${targets.fat.toStringAsFixed(1)} g'),
                        _TargetRow(
                            label: 'Fiber',
                            value:
                                '${targets.fiber.toStringAsFixed(1)} g'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Editable form
                if (_editing)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Edit Profile',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Age',
                                  border: OutlineInputBorder()),
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                return n == null || n < 10 || n > 120
                                    ? 'Invalid'
                                    : null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _gender,
                              decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(
                                    value: 'male', child: Text('Male')),
                                DropdownMenuItem(
                                    value: 'female', child: Text('Female')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _gender = v!),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder()),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                return n == null || n <= 0 ? 'Invalid' : null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _heightCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                  labelText: 'Height (cm)',
                                  border: OutlineInputBorder()),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                return n == null || n <= 0 ? 'Invalid' : null;
                              },
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _activityLevel,
                          decoration: const InputDecoration(
                              labelText: 'Activity Level',
                              border: OutlineInputBorder()),
                          items: _activityLabels.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _activityLevel = v!),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) => ElevatedButton(
                            onPressed: auth.isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44)),
                            child: auth.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
}

class _TargetRow extends StatelessWidget {
  final String label;
  final String value;

  const _TargetRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
