import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/profile_model.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Запуск завантаження після першого кадру; read - бо це не build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final email = context.read<AuthModel>().email;
      if (email != null) context.read<ProfileModel>().load(email);
    });
  }

  void _logout() {
    context.read<ProfileModel>().clear();
    context.read<AuthModel>().logout();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: HomeScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Головна'),
        actions: [
          IconButton(
            tooltip: 'Вийти',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: const _ProfileBody(),
    );
  }
}

/// select: перебудова лише при зміні стану (loading / error / data).
class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    debugPrint('build: ProfileBody');
    final status = context.select<ProfileModel, ProfileStatus>(
      (m) => m.status,
    );
    return switch (status) {
      ProfileStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      ProfileStatus.error => const _ErrorView(),
      ProfileStatus.data => const _ProfileView(),
    };
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    final message = context.select<ProfileModel, String?>((m) => m.error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message ?? 'Помилка', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<ProfileModel>().retry(),
              child: const Text('Повторити'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Greeting(),
          const SizedBox(height: 16),
          const _LoggedInAs(),
          const SizedBox(height: 8),
          const _Details(),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
            child: const Text('Редагувати профіль'),
          ),
        ],
      ),
    );
  }
}

/// select: залежить лише від імені.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    debugPrint('build: Greeting');
    final name = context.select<ProfileModel, String>(
      (m) => m.profile?.name ?? '',
    );
    return Text(
      'Привіт, $name!',
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}

/// Consumer: невеликий листковий віджет, якому потрібна вся AuthModel.
class _LoggedInAs extends StatelessWidget {
  const _LoggedInAs();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (context, auth, _) {
        debugPrint('build: LoggedInAs');
        return Text('Ви увійшли як ${auth.email ?? ''}');
      },
    );
  }
}

/// watch: листковий віджет залежить від усього профілю (email + біо).
class _Details extends StatelessWidget {
  const _Details();

  @override
  Widget build(BuildContext context) {
    debugPrint('build: Details');
    final profile = context.watch<ProfileModel>().profile;
    if (profile == null) return const SizedBox.shrink();
    return Text('Про себе: ${profile.bio}');
  }
}
