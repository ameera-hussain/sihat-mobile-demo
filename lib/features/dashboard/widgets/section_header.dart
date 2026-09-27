import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final String? seeAllRoute;
  const SectionHeader({
    super.key,
    required this.title,
    required this.showSeeAll,
    this.seeAllRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        if (showSeeAll)
          GestureDetector(
            onTap: () => context.go(seeAllRoute ?? '/vitals'),
            child: Text(
              'See All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}