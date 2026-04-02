import 'package:flutter/material.dart';
import '../models/poll.dart';
import '../services/poll_service.dart';
import '../utils/helpers.dart';

class PollCard extends StatefulWidget {
  final Poll poll;

  const PollCard({super.key, required this.poll});

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  final PollService _pollService = PollService();
  bool _hasVoted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfVoted();
  }

  Future<void> _checkIfVoted() async {
    final voted = await _pollService.hasUserVoted(widget.poll.id);
    if (mounted) {
      setState(() {
        _hasVoted = voted;
        _isLoading = false;
      });
    }
  }

  Future<void> _vote(int optionIndex) async {
    setState(() => _isLoading = true);

    final error = await _pollService.vote(widget.poll.id, optionIndex);

    if (error != null && mounted) {
      Helpers.showSnackBar(context, error, isError: true);
      setState(() => _isLoading = false);
    } else if (mounted) {
      setState(() {
        _hasVoted = true;
        _isLoading = false;
      });
      Helpers.showSnackBar(context, 'Vote recorded! 🎉');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.poll, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Daily Poll',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Spacer(),
                if (widget.poll.isExpired)
                  Chip(
                    label: const Text('Ended', style: TextStyle(fontSize: 12)),
                    backgroundColor: Colors.red.shade100,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Question
            Text(
              widget.poll.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Options
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ...widget.poll.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final percentage = option.getPercentage(widget.poll.totalVotes);

                return _buildOption(
                  option: option,
                  index: index,
                  percentage: percentage,
                  hasVoted: _hasVoted,
                );
              }),

            const SizedBox(height: 12),

            // Footer
            Text(
              '${widget.poll.totalVotes} ${widget.poll.totalVotes == 1 ? 'vote' : 'votes'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required PollOption option,
    required int index,
    required double percentage,
    required bool hasVoted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: hasVoted || widget.poll.isExpired
            ? null
            : () => _vote(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasVoted ? Colors.deepPurple : Colors.grey.shade300,
              width: hasVoted ? 2 : 1,
            ),
            color: hasVoted
                ? Colors.deepPurple.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Stack(
            children: [
              // Progress bar
              if (hasVoted)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

              // Option text and percentage
              Row(
                children: [
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontWeight: hasVoted ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (hasVoted)
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}