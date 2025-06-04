import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/di/app_module.dart';
import '../../../../data/models/book.dart';
import '../../../../data/models/user.dart' as app_user;
import '../../../../data/models/user_role.dart';
import '../../../widgets/glassmorphic_container.dart';

// Providers
// Using authServiceProvider from app_module.dart

final currentUserProvider = StreamProvider<app_user.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser.map((user) => user as app_user.User?);
});

final usersStreamProvider = StreamProvider<List<app_user.User>>((ref) {
  final database = FirebaseDatabase.instance;
  final usersRef = database.ref().child('users');
  
  return usersRef.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return [];
    
    return data.entries.map((entry) {
      final userData = Map<String, dynamic>.from(entry.value as Map);
      userData['id'] = entry.key;
      return app_user.User.fromJson(userData);
    }).toList();
  });
});

final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  final database = FirebaseDatabase.instance;
  final booksRef = database.ref().child('books');
  
  return booksRef.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return [];
    
    return data.entries.map((entry) {
      final bookData = Map<String, dynamic>.from(entry.value as Map);
      bookData['id'] = entry.key;
      return Book.fromJson(bookData);
    }).toList();
  });
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null || !currentUser.isAdmin) {
          return Scaffold(
            body: Center(
              child: Text(
                'Access Denied',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authService.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context, currentUser),
                const SizedBox(height: 24),
                _buildQuickStats(context, ref),
                const SizedBox(height: 24),
                _buildUserManagement(context, ref),
                const SizedBox(height: 24),
                _buildBookManagement(context, ref),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.go('/books/add');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Book'),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, app_user.User user) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassmorphicContainer(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primary,
              child: Text(
                user.name[0].toUpperCase(),
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${user.name}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin Dashboard',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);
    final booksAsync = ref.watch(booksStreamProvider);

    return usersAsync.when(
      data: (users) => booksAsync.when(
        data: (books) {
          final totalUsers = users.length;
          final activeUsers = users.where((u) => u.isActive).length;
          final totalBooks = books.length;
          final availableBooks = books.where((b) => b.status == 'available').length;

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                'Total Users',
                totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Active Users',
                activeUsers.toString(),
                Icons.person,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Total Books',
                totalBooks.toString(),
                Icons.book,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Available Books',
                availableBooks.toString(),
                Icons.menu_book,
                Colors.purple,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildUserManagement(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);

    return usersAsync.when(
      data: (users) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(context, ref, user);
            },
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildBookManagement(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);

    return booksAsync.when(
      data: (books) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/books/${book.id}'),
                ),
              );
            },
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, app_user.User user) {
    final authService = ref.watch(authServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive ? colorScheme.primary : colorScheme.error,
          child: Text(
            user.name[0].toUpperCase(),
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
                color: user.isActive ? colorScheme.error : colorScheme.primary,
              ),
              onPressed: () async {
                if (user.isActive) {
                  await authService.deactivateUser(user.id);
                } else {
                  await authService.activateUser(user.id);
                }
              },
            ),
            IconButton(
              icon: Icon(
                user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: user.isAdmin ? colorScheme.primary : colorScheme.onSurface,
              ),
              onPressed: () async {
                await authService.changeUserRole(
                  user.id,
                  user.isAdmin ? UserRole.user : UserRole.admin,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 