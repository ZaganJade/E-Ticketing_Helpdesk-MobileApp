import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../cubits/tiket_cubit.dart';
import '../widgets/tiket_card.dart';
import '../../../core/theme/app_border_radius.dart';

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
        AppSnackbar.success(context, 'Tiket berhasil dibuat');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Daftar Tiket',
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _showSearchBottomSheet();
              },
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.default_,
                    vertical: AppSpacing.sm,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = state is TiketListLoaded &&
                            state.currentFilter == filter['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(filter['label']!),
                            selected: isSelected,
                            onSelected: (_) => _onFilterChanged(filter['value']!),
                            selectedColor: AppColors.primary.withOpacity(0.1),
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.badgeRadius,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(TiketState state) {
    if (state is TiketLoading) {
      return const ListSkeleton(itemCount: 5);
    }

    if (state is TiketError) {
      return ErrorState.server(
        onRetry: () => _cubit.refresh(),
      );
    }

    if (state is TiketListLoaded) {
      if (state.tiketList.isEmpty) {
        return EmptyState.tickets(
          actionLabel: 'Buat Tiket',
          onAction: _navigateToCreate,
        );
      }

      return AppRefreshWrapper(
        onRefresh: () => _cubit.refresh(search: _currentSearch.isEmpty ? null : _currentSearch),
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSpacing.default_),
          itemCount: state.tiketList.length + (state.hasMore ? 1 : 0),
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.default_),
          itemBuilder: (context, index) {
            if (index == state.tiketList.length) {
              return state.isLoadingMore
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.default_),
                        child: CircularProgressIndicator(),
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

  void _showSearchBottomSheet() {
    AppModal.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cari judul atau deskripsi...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) {
              Navigator.pop(context);
              _onSearchSubmitted();
            },
          ),
          const SizedBox(height: AppSpacing.default_),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Batal',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.default_),
              Expanded(
                child: AppButton(
                  label: 'Cari',
                  onPressed: () {
                    Navigator.pop(context);
                    _onSearchSubmitted();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
