import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.bgDark, AppColors.cardBgDark]
                : [AppColors.bgLight, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Logo Icon
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                size: 80.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            // Title Text
            Text(
              'TaskFlow',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Lightweight Project Management',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                  ),
            ),
            SizedBox(height: 60.h),
            // Sleek Loading Indicator
            SizedBox(
              width: 40.w,
              height: 4.h,
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
