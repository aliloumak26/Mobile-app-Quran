import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/track_model.dart';
import '../../models/playlist_category.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int? _selectedCategoryIndex;

  void _openSearch(BuildContext context) {
    showSearch(context: context, delegate: _TrackSearchDelegate(context, this));
  }

  void _showCategoryTracks(int index) {
    setState(() => _selectedCategoryIndex = index);
  }

  void _backToCategories() {
    setState(() => _selectedCategoryIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player',
                          style: TextStyle(
                            color: AppTheme.warmText,
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Listen to the Holy Quran',
                          style: TextStyle(
                            color: AppTheme.dimText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.search_rounded,
                    onTap: () => _openSearch(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Library content ──
            Expanded(
              child: _buildLibraryTab(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Library Tab ──
  Widget _buildLibraryTab() {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        if (audio.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.gold),
          );
        }
        if (audio.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.gold.withOpacity(0.08),
                  ),
                  child: const Icon(Icons.library_music_rounded,
                      size: 48, color: AppTheme.dimText),
                ),
                const SizedBox(height: 16),
                const Text('No playlists available',
                    style: TextStyle(
                        color: AppTheme.warmText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Content will appear here once loaded',
                    style: TextStyle(color: AppTheme.dimText, fontSize: 13)),
              ],
            ),
          );
        }

        if (_selectedCategoryIndex != null) {
          return _buildCategoryTracks(context, audio);
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: audio.categories.length,
          itemBuilder: (context, index) {
            final category = audio.categories[index];
            // Alternate accent colors for categories
            final accentColors = [
              AppTheme.gold,
              const Color(0xFF6366F1),
              const Color(0xFF10B981),
              const Color(0xFFF43F5E),
              const Color(0xFFF59E0B),
            ];
            final accent = accentColors[index % accentColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showCategoryTracks(index),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: accent.withOpacity(0.08),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: AppTheme.surface1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accent.withOpacity(0.15),
                                  accent.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: accent,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    color: AppTheme.warmText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${category.tracks.length} tracks',
                                  style: const TextStyle(
                                      color: AppTheme.dimText, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: accent,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Category Tracks ──
  Widget _buildCategoryTracks(BuildContext context, AudioProvider audio) {
    final cat = audio.categories[_selectedCategoryIndex!];
    audio.selectCategory(_selectedCategoryIndex!);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppTheme.warmText, size: 18),
                ),
                onPressed: _backToCategories,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: const TextStyle(
                        color: AppTheme.warmText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${cat.tracks.length} tracks',
                      style:
                          const TextStyle(color: AppTheme.dimText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Tracks
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: cat.tracks.length,
            itemBuilder: (context, index) {
              final track = cat.tracks[index];
              final isCurrent = index == audio.currentIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => audio.playTrack(index),
                    borderRadius: BorderRadius.circular(14),
                    splashColor: AppTheme.gold.withOpacity(0.08),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.gold.withOpacity(0.08)
                            : AppTheme.surface1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? AppTheme.gold.withOpacity(0.3)
                              : AppTheme.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Track number / playing indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: isCurrent
                                  ? const LinearGradient(
                                      colors: [AppTheme.gold, AppTheme.goldLight],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isCurrent
                                  ? null
                                  : AppTheme.gold.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isCurrent
                                  ? const Icon(Icons.equalizer_rounded,
                                      color: AppTheme.darkBg, size: 18)
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: AppTheme.dimText,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              track.title,
                              style: TextStyle(
                                color: isCurrent
                                    ? AppTheme.gold
                                    : AppTheme.warmText,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Favorite button
                          GestureDetector(
                            onTap: () async {
                              final auth = context.read<AuthProvider>();
                              final uid = auth.currentUser?.uid;
                              if (uid != null) {
                                final favs = context.read<FavoritesProvider>();
                                final isFav =
                                    await favs.isFavorite(uid, track.id);
                                if (isFav) {
                                  await favs.removeFavorite(uid, track.id);
                                } else {
                                  await favs.addFavorite(uid, track);
                                }
                              }
                            },
                            child: Consumer<FavoritesProvider>(
                              builder: (_, favs, __) {
                                final isFav = favs.isFavoriteLocal(track.id);
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isFav
                                        ? const Color(0xFFF43F5E)
                                            .withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFav
                                        ? const Color(0xFFF43F5E)
                                        : AppTheme.dimText,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isCurrent
                                ? Icons.play_circle_fill_rounded
                                : Icons.play_circle_outline_rounded,
                            color: isCurrent ? AppTheme.gold : AppTheme.dimText,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}

// ── Search icon button in header ──
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Icon(icon, color: AppTheme.dimText, size: 22),
      ),
    );
  }
}

// ── Two-Phase Search Delegate ──
// Phase 1: Search reciters only
// Phase 2: After selecting a reciter, search surahs (tracks) within that reciter
class _TrackSearchDelegate extends SearchDelegate<String?> {
  final BuildContext context;
  final _PlayerScreenState playerState;

  // Phase tracking: null = reciter search, non-null = track search within reciter
  PlaylistCategory? _selectedReciter;
  int _selectedReciterIndex = 0;

  _TrackSearchDelegate(this.context, this.playerState);

  @override
  String get searchFieldLabel =>
      _selectedReciter != null ? 'Search surahs…' : 'Search reciters…';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: AppTheme.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.darkBg,
        iconTheme: IconThemeData(color: AppTheme.warmText),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppTheme.dimText),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppTheme.warmText),
        bodyMedium: TextStyle(color: AppTheme.warmText),
        bodySmall: TextStyle(color: AppTheme.dimText),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: AppTheme.dimText),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.warmText),
      onPressed: () {
        // If in phase 2, go back to phase 1 instead of closing
        if (_selectedReciter != null) {
          _selectedReciter = null;
          _selectedReciterIndex = 0;
          query = '';
          showSuggestions(context);
        } else {
          close(context, null);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchBody(context);

  Widget _buildSearchBody(BuildContext context) {
    if (_selectedReciter != null) {
      return _buildTrackSearch(context);
    }
    return _buildReciterSearch(context);
  }

  // ── Phase 1: Reciter Search ──
  Widget _buildReciterSearch(BuildContext context) {
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final queryLower = query.toLowerCase().trim();

    final reciters = <PlaylistCategory>[];
    for (final cat in audio.categories) {
      if (queryLower.isEmpty || cat.name.toLowerCase().contains(queryLower)) {
        reciters.add(cat);
      }
    }

    if (query.isEmpty) {
      return Column(
        children: [
          // Hint banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gold.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.gold.withOpacity(0.7), size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Select a reciter first, then search surahs',
                      style: TextStyle(color: AppTheme.dimText, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Show all reciters
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: reciters.length,
              itemBuilder: (_, i) => _buildReciterTile(
                  audio, reciters[i], audio.categories.indexOf(reciters[i])),
            ),
          ),
        ],
      );
    }

    if (reciters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withOpacity(0.08),
              ),
              child: const Icon(Icons.person_off_rounded,
                  size: 40, color: AppTheme.dimText),
            ),
            const SizedBox(height: 16),
            const Text('No reciters found',
                style: TextStyle(color: AppTheme.dimText, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: reciters.length,
      itemBuilder: (_, i) => _buildReciterTile(
          audio, reciters[i], audio.categories.indexOf(reciters[i])),
    );
  }

  Widget _buildReciterTile(
      AudioProvider audio, PlaylistCategory cat, int catIndex) {
    final accentColors = [
      AppTheme.gold,
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF43F5E),
      const Color(0xFFF59E0B),
    ];
    final accent = accentColors[catIndex % accentColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: accent.withOpacity(0.08),
          onTap: () {
            // Move to phase 2: track search within this reciter
            _selectedReciter = cat;
            _selectedReciterIndex = catIndex;
            query = '';
            showSuggestions(context);
          },
          child: Ink(
            decoration: BoxDecoration(
              color: AppTheme.surface1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withOpacity(0.15),
                        accent.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_rounded, color: accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name,
                          style: const TextStyle(
                              color: AppTheme.warmText,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('${cat.tracks.length} surahs',
                          style: const TextStyle(
                              color: AppTheme.dimText, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      color: accent, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Phase 2: Track (Surah) Search within selected reciter ──
  Widget _buildTrackSearch(BuildContext context) {
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final reciter = _selectedReciter!;
    final queryLower = query.toLowerCase().trim();

    final tracks = <_TrackSearchItem>[];
    for (int i = 0; i < reciter.tracks.length; i++) {
      final track = reciter.tracks[i];
      if (queryLower.isEmpty || track.title.toLowerCase().contains(queryLower)) {
        tracks.add(_TrackSearchItem(track: track, indexInCategory: i));
      }
    }

    return Column(
      children: [
        // Breadcrumb: shows selected reciter with back action
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: GestureDetector(
            onTap: () {
              _selectedReciter = null;
              _selectedReciterIndex = 0;
              query = '';
              showSuggestions(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_rounded,
                      color: AppTheme.gold, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      reciter.name,
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppTheme.gold, size: 14),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Track list
        if (tracks.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6366F1).withOpacity(0.08),
                    ),
                    child: const Icon(Icons.music_off_rounded,
                        size: 40, color: AppTheme.dimText),
                  ),
                  const SizedBox(height: 16),
                  const Text('No surahs found',
                      style: TextStyle(color: AppTheme.dimText, fontSize: 15)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: tracks.length,
              itemBuilder: (_, i) {
                final item = tracks[i];
                final track = item.track;
                const accent = Color(0xFF6366F1);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      splashColor: accent.withOpacity(0.08),
                      onTap: () {
                        audio.selectCategory(_selectedReciterIndex);
                        audio.playTrack(item.indexInCategory);
                        close(context, null);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppTheme.surface1,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.indexInCategory + 1}',
                                  style: const TextStyle(
                                    color: AppTheme.dimText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                track.title,
                                style: const TextStyle(
                                  color: AppTheme.warmText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Favorite button
                            GestureDetector(
                              onTap: () async {
                                final auth = Provider.of<AuthProvider>(context, listen: false);
                                final uid = auth.currentUser?.uid;
                                if (uid != null) {
                                  final favs = Provider.of<FavoritesProvider>(context, listen: false);
                                  final isFav = await favs.isFavorite(uid, track.id);
                                  if (isFav) {
                                    await favs.removeFavorite(uid, track.id);
                                  } else {
                                    await favs.addFavorite(uid, track);
                                  }
                                }
                              },
                              child: Consumer<FavoritesProvider>(
                                builder: (_, favs, __) {
                                  final isFav = favs.isFavoriteLocal(track.id);
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isFav
                                          ? const Color(0xFFF43F5E).withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isFav
                                          ? const Color(0xFFF43F5E)
                                          : AppTheme.dimText,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.play_circle_fill_rounded,
                                color: accent, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TrackSearchItem {
  final TrackModel track;
  final int indexInCategory;

  _TrackSearchItem({required this.track, required this.indexInCategory});
}
