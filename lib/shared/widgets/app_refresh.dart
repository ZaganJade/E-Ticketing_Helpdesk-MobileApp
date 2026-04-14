import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// App Refresh Wrapper - Redesigned with shadcn_ui styling
/// A reusable refresh indicator component following AGENTS.md guidelines
class AppRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final Color? color;

  const AppRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor ??
          ShadTheme.of(context).colorScheme.card,
      color: color ?? ShadcnTheme.accent,
      displacement: 40,
      strokeWidth: 3,
      child: child,
    );
  }
}

/// App Pull To Refresh - Simple pull-to-refresh with scroll view
class AppPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final EdgeInsets? padding;

  const AppPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppRefreshWrapper(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// App Refresh List View - List view with pull-to-refresh
class AppRefreshListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final Widget? separator;
  final ScrollPhysics? physics;

  const AppRefreshListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.emptyWidget,
    this.padding,
    this.separator,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    if (items.isEmpty && !isLoading) {
      return AppRefreshWrapper(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: emptyWidget ?? _buildDefaultEmptyState(context),
            ),
          ],
        ),
      );
    }

    return AppRefreshWrapper(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: items.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) =>
            separator ?? SizedBox(height: isTablet ? 12 : 8),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _LoadMoreIndicator(
              isLoading: isLoading,
              onLoadMore: onLoadMore,
            );
          }
          return itemBuilder(context, items[index]);
        },
      ),
    );
  }

  Widget _buildDefaultEmptyState(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ShadcnTheme.muted.withValues(alpha: 0.8),
                  ShadcnTheme.muted.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: isTablet ? 48 : 40,
              color: ShadcnTheme.getMutedForeground(context),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Tidak ada data',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.foreground,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Tarik ke bawah untuk menyegarkan',
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: ShadcnTheme.getMutedForeground(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreIndicator extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const _LoadMoreIndicator({
    required this.isLoading,
    this.onLoadMore,
  });

  @override
  State<_LoadMoreIndicator> createState() => _LoadMoreIndicatorState();
}

class _LoadMoreIndicatorState extends State<_LoadMoreIndicator> {
  @override
  void initState() {
    super.initState();
    if (!widget.isLoading && widget.onLoadMore != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLoadMore!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return widget.isLoading
        ? Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            alignment: Alignment.center,
            child: SizedBox(
              width: isTablet ? 28 : 24,
              height: isTablet ? 28 : 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ShadcnTheme.accent),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

/// App Refresh Grid View - Grid view with pull-to-refresh
class AppRefreshGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onRefresh;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets? padding;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? emptyWidget;

  const AppRefreshGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.padding,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) {
      return AppRefreshWrapper(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: emptyWidget ?? const Center(child: Text('Tidak ada data')),
            ),
          ],
        ),
      );
    }

    return AppRefreshWrapper(
      onRefresh: onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _LoadMoreIndicator(
              isLoading: isLoading,
              onLoadMore: onLoadMore,
            );
          }
          return itemBuilder(context, items[index]);
        },
      ),
    );
  }
}
