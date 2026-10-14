import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileModel>().profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context
        .read<ProfileModel>()
        .update(name: _nameCtrl.text, bio: _bioCtrl.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редагування профілю')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Ім'я",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? "Мінімум 2 символи"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Про себе',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Зберегти')),
            ],
          ),
        ),
      ),
    );
  }
}
