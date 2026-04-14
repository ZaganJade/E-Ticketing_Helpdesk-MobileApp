import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../cubits/tiket_cubit.dart';
import '../widgets/tiket_card.dart';

/// Tiket List Page - Redesigned with shadcn_ui
/// Displays list of tickets with filtering and search capabilities
class TiketListPage extends StatefulWidget {
  const TiketListPage({super.key});

  @override
  State<TiketListPage> createState() => _TiketListPageState();
}

class _TiketListPageState extends State<TiketListPage> {
  late final TiketCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _currentSearch = '';

  final List<Map<String, String>> _filters = [
    {'value': 'semua', 'label': 'Semua'},
    {'value': 'TERBUKA', 'label': 'Terbuka'},
    {'value': 'DIPROSES', 'label': 'Diproses'},
    {'value': 'SELESAI', 'label': 'Selesai'},
  ];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TiketCubit>();
    _cubit.loadTiketList();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMoreTiket(search: _currentSearch.isEmpty ? null : _currentSearch);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _currentSearch = _searchController.text;
    });
  }

  void _onSearchSubmitted() {
    _cubit.loadTiketList(
      filter: _cubit.state is TiketListLoaded
          ? (_cubit.state as TiketListLoaded).currentFilter
          : 'semua',
      search: _currentSearch.isEmpty ? null : _currentSearch,
      refresh: true,
    );
  }

  void _onFilterChanged(String filter) {
    _cubit.changeFilter(filter, search: _currentSearch.isEmpty ? null : _currentSearch);
  }

  void _navigateToDetail(String tiketId) {
    context.push('/tiket/$tiketId');
  }

  void _navigateToCreate() {
    context.push('/tiket/create').then((created) {
      if (created == true) {
        _cubit.refresh();
        _showSuccessSnackBar('Tiket berhasil dibuat');
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ShadcnTheme.statusDone,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Daftar Tiket',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: _showSearchDialog,
              child: const Icon(Icons.search, size: 24),
            ),
          ],
        ),
        body: BlocBuilder<TiketCubit, TiketState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                // Filter chips
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = state is TiketListLoaded &&
                            state.currentFilter == filter['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            label: filter['label']!,
                            isSelected: isSelected,
                            onTap: () => _onFilterChanged(filter['value']!),
                            isTablet: isTablet,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(state, isTablet),
                ),
              ],
            );
          },
        ),
        floatingActionButton: ShadButton(
          onPressed: _navigateToCreate,
          child: const Icon(Icons.add, size: 24),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ShadcnTheme.accent.withValues(alpha: 0.2),
                    ShadcnTheme.accent.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ShadcnTheme.accent
                : (isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? ShadcnTheme.accent
                : ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TiketState state, bool isTablet) {
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    if (state is TiketLoading) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: 5,
        itemBuilder: (context, index) => const TiketCardSkeleton(),
      );
    }

    if (state is TiketError) {
      return _buildErrorState(isTablet, horizontalPadding);
    }

    if (state is TiketListLoaded) {
      if (state.tiketList.isEmpty) {
        return _buildEmptyState(isTablet, horizontalPadding);
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _cubit.refresh(search: _currentSearch.isEmpty ? null : _currentSearch);
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: state.tiketList.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.tiketList.length) {
              return state.isLoadingMore
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 24 : 16),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }

            final tiket = state.tiketList[index];
            return TiketCard(
              tiket: tiket,
              onTap: () => _navigateToDetail(tiket.id),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(bool isTablet, double horizontalPadding) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: EdgeInsets.all(horizontalPadding),
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        decoration: BoxDecoration(
          color: isDark ? ShadcnTheme.darkMuted : ShadcnTheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ShadcnTheme.accent.withValues(alpha: 0.15),
                    ShadcnTheme.accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: isTablet ? 56 : 48,
                color: ShadcnTheme.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada tiket',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Buat tiket baru untuk memulai',
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            ShadButton(
              onPressed: _navigateToCreate,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 8),
                  Text('Buat Tiket'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isTablet, double horizontalPadding) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(horizontalPadding),
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        decoration: BoxDecoration(
          color: ShadcnTheme.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ShadcnTheme.destructive.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 56 : 48,
              color: ShadcnTheme.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat tiket',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: ShadcnTheme.destructive,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Terjadi kesalahan saat memuat data',
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            ShadButton.outline(
              onPressed: () => _cubit.refresh(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Cari Tiket'),
        description: const Text('Cari berdasarkan judul atau deskripsi'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pop(context);
              _onSearchSubmitted();
            },
            child: const Text('Cari'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadInput(
              controller: _searchController,
              placeholder: const Text('Ketik kata kunci...'),
              autofocus: true,
              onSubmitted: (_) {
                Navigator.pop(context);
                _onSearchSubmitted();
              },
            ),
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear, size: 16),
                      SizedBox(width: 4),
                      Text('Bersihkan'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
