import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable shimmer animation wrapper that sweeps a gradient across child widgets.
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      (bounds.width * 2) * (slidePercent - 0.5),
      0.0,
      0.0,
    );
  }
}

/// A basic rectangular or rounded skeleton placeholder block.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}

/// Skeleton loading placeholder for Project List Screen
class ProjectListSkeleton extends StatelessWidget {
  const ProjectListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 160.w, height: 20.h, borderRadius: 6),
                      SkeletonBox(width: 24.w, height: 24.h, borderRadius: 12),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SkeletonBox(width: double.infinity, height: 14.h, borderRadius: 4),
                  SizedBox(height: 6.h),
                  SkeletonBox(width: 220.w, height: 14.h, borderRadius: 4),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 70.w, height: 22.h, borderRadius: 12),
                      SkeletonBox(width: 80.w, height: 14.h, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton loading placeholder for Task List Screen
class TaskListSkeleton extends StatelessWidget {
  final int count;
  const TaskListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: count,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 180.w, height: 16.h, borderRadius: 4),
                        SizedBox(height: 8.h),
                        SkeletonBox(width: 100.w, height: 12.h, borderRadius: 4),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SkeletonBox(width: 60.w, height: 20.h, borderRadius: 8),
                      SizedBox(height: 6.h),
                      SkeletonBox(width: 40.w, height: 12.h, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton loading placeholder for Project Detail Screen
class ProjectDetailSkeleton extends StatelessWidget {
  const ProjectDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Project Summary Card Skeleton
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 80.w, height: 24.h, borderRadius: 8),
                      SkeletonBox(width: 70.w, height: 14.h, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SkeletonBox(width: double.infinity, height: 14.h, borderRadius: 4),
                  SizedBox(height: 6.h),
                  SkeletonBox(width: 240.w, height: 14.h, borderRadius: 4),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Metrics Header Skeleton
          SkeletonBox(width: 140.w, height: 18.h, borderRadius: 4),
          SizedBox(height: 12.h),

          // 4 Metric cards
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: index == 0 || index == 3 ? 0 : 4.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      SkeletonBox(width: 20.w, height: 20.h, borderRadius: 4),
                      SizedBox(height: 6.h),
                      SkeletonBox(width: 32.w, height: 10.h, borderRadius: 4),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 28.h),

          // Tasks Header Skeleton
          SkeletonBox(width: 100.w, height: 18.h, borderRadius: 4),
          SizedBox(height: 12.h),

          // Task Item Skeletons
          ...List.generate(3, (index) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 160.w, height: 15.h, borderRadius: 4),
                        SizedBox(height: 6.h),
                        SkeletonBox(width: 90.w, height: 11.h, borderRadius: 4),
                      ],
                    ),
                    SkeletonBox(width: 55.w, height: 20.h, borderRadius: 8),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

/// Skeleton loading placeholder for Notification Inbox Screen
class NotificationListSkeleton extends StatelessWidget {
  const NotificationListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: EdgeInsets.all(16.r),
        itemCount: 6,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 12.w, height: 12.h, borderRadius: 6),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: double.infinity, height: 14.h, borderRadius: 4),
                        SizedBox(height: 6.h),
                        SkeletonBox(width: 180.w, height: 14.h, borderRadius: 4),
                        SizedBox(height: 8.h),
                        SkeletonBox(width: 70.w, height: 11.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton loading placeholder for Forms
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 100.w, height: 14.h, borderRadius: 4),
            SizedBox(height: 8.h),
            SkeletonBox(width: double.infinity, height: 48.h, borderRadius: 12),
            SizedBox(height: 20.h),
            SkeletonBox(width: 120.w, height: 14.h, borderRadius: 4),
            SizedBox(height: 8.h),
            SkeletonBox(width: double.infinity, height: 100.h, borderRadius: 12),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 70.w, height: 14.h, borderRadius: 4),
                      SizedBox(height: 8.h),
                      SkeletonBox(width: double.infinity, height: 48.h, borderRadius: 12),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 70.w, height: 14.h, borderRadius: 4),
                      SizedBox(height: 8.h),
                      SkeletonBox(width: double.infinity, height: 48.h, borderRadius: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SkeletonBox(width: 90.w, height: 14.h, borderRadius: 4),
            SizedBox(height: 8.h),
            SkeletonBox(width: double.infinity, height: 48.h, borderRadius: 12),
            SizedBox(height: 32.h),
            SkeletonBox(width: double.infinity, height: 50.h, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
