import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/track_model.dart';

class AudioPlayerWidget extends StatelessWidget {
  final TrackModel track;
  final Duration position;
  final Duration? duration;
  final bool isPlaying;
  final bool isRepeat;
  final bool isShuffled;
  final VoidCallback onPlayPause;
  final Function(Duration) onSeek;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleRepeat;
  final VoidCallback onToggleShuffle;
  final double progress;

  const AudioPlayerWidget({
    super.key,
    required this.track,
    required this.position,
    this.duration,
    required this.isPlaying,
    required this.isRepeat,
    required this.isShuffled,
    required this.onPlayPause,
    required this.onSeek,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleRepeat,
    required this.onToggleShuffle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surface1,
            AppTheme.surface2.withOpacity(0.95),
          ],
        ),
        border: const Border(
          top: BorderSide(color: AppTheme.cardBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Track info row ──
              Row(
                children: [
                  // Album art placeholder
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gold.withOpacity(0.2),
                          AppTheme.gold.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isPlaying
                            ? Icons.equalizer_rounded
                            : Icons.music_note_rounded,
                        key: ValueKey(isPlaying),
                        color: AppTheme.gold,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.warmText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.category ?? '',
                          style: const TextStyle(
                            color: AppTheme.dimText,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Progress bar ──
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: AppTheme.gold,
                      inactiveTrackColor: AppTheme.cardBorder.withOpacity(0.5),
                      thumbColor: AppTheme.gold,
                      overlayColor: AppTheme.gold.withOpacity(0.12),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        if (duration != null) {
                          onSeek(Duration(
                            milliseconds:
                                (value * duration!.inMilliseconds).round(),
                          ));
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: AppTheme.dimText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          duration != null
                              ? _formatDuration(duration!)
                              : '--:--',
                          style: const TextStyle(
                            color: AppTheme.dimText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ── Controls ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  _ControlButton(
                    icon: Icons.shuffle_rounded,
                    isActive: isShuffled,
                    onPressed: onToggleShuffle,
                    size: 22,
                  ),
                  // Previous
                  _ControlButton(
                    icon: Icons.skip_previous_rounded,
                    onPressed: onPrevious,
                    size: 30,
                    color: AppTheme.warmText,
                  ),
                  // Play / Pause (main)
                  GestureDetector(
                    onTap: onPlayPause,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.gold, AppTheme.goldLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey(isPlaying),
                          color: AppTheme.darkBg,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // Next
                  _ControlButton(
                    icon: Icons.skip_next_rounded,
                    onPressed: onNext,
                    size: 30,
                    color: AppTheme.warmText,
                  ),
                  // Repeat
                  _ControlButton(
                    icon: isRepeat ? Icons.repeat_on_rounded : Icons.repeat_rounded,
                    isActive: isRepeat,
                    onPressed: onToggleRepeat,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isActive;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.size = 24,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color ?? (isActive ? AppTheme.gold : AppTheme.dimText),
          size: size,
        ),
      ),
    );
  }
}
