import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.darkSurface : AppColors.surface),
      color: color ?? AppColors.primary,
      displacement: 40,
      strokeWidth: 3,
      child: child,
    );
  }
}

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
      child: ListView.separated(
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: items.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) => separator ?? const SizedBox.shrink(),
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
    return widget.isLoading
        ? Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
