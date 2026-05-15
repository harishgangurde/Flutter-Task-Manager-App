import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import 'app_theme.dart';

class QuoteCard extends StatelessWidget {
  final QuoteModel? quote;
  final bool isLoading;
  final VoidCallback onRefresh;

  const QuoteCard({
    super.key,
    this.quote,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: Colors.white70,
                size: 22,
              ),

              const SizedBox(width: 8),

              const Text(
                'Daily Motivation',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (isLoading)
            _LoadingQuote()
          else if (quote != null) ...[
            Text(
              '"${quote!.quote}"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${quote!.author}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else
            const Text(
              'Could not load quote. Tap refresh to try again.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _LoadingQuote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerBar(double.infinity),
        const SizedBox(height: 8),
        _shimmerBar(double.infinity),
        const SizedBox(height: 8),
        _shimmerBar(160),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerRight, child: _shimmerBar(100)),
      ],
    );
  }

  Widget _shimmerBar(double width) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
