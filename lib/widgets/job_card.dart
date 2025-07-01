import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({Key? key, required this.job, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: AppTextStyles.headline1),
              const SizedBox(height: 4),
              Text(job.company, style: AppTextStyles.subtitle1),
              const SizedBox(height: 8),
              Text(job.location, style: AppTextStyles.bodyText1),
              if (job.salary != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${job.salary?.toStringAsFixed(0)} ₸ / месяц',
                    style: AppTextStyles.bodyText1.copyWith(color: AppColors.primaryLight),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
