import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/histogram_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _monthlyGoal = 20.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadGoal();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      await context.read<StatsProvider>().loadStats(uid);
      await context.read<AudioProvider>().loadCategories();
      await context.read<FavoritesProvider>().loadFavorites(uid);
    }
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _monthlyGoal = prefs.getDouble(AppConstants.monthlyGoalKey) ??
            AppConstants.defaultMonthlyGoalHours;
      });
    }
  }

  Future<void> _saveGoal(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.monthlyGoalKey, hours);
    if (mounted) setState(() => _monthlyGoal = hours);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 20, bottom: 10),
                title: Consumer<AuthProvider>(
                  builder: (_, auth, __) => Text(
                    'Hey, ${auth.currentUser?.firstName ?? "there"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmText,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppTheme.dimText),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatRow(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildTopTracksSection(),
                  const SizedBox(height: 20),
                  _buildMonthlyStatsCard(),
                  const SizedBox(height: 20),
                  _buildMonthlyGoalCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    return Consumer<StatsProvider>(
      builder: (_, stats, __) {
        final h = stats.stats.totalListeningTime.inHours;
        final m = stats.stats.totalListeningTime.inMinutes.remainder(60);
        final currentMonth =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
        final monthlyDuration =
            stats.stats.monthlyListening[currentMonth] ?? Duration.zero;
        final totalHours = monthlyDuration.inMinutes / 60;

        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.gold, AppTheme.goldLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.access_time_rounded,
                          color: AppTheme.darkBg, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                color: AppTheme.dimText, fontSize: 10)),
                        Text('${h}h ${m}m',
                            style: const TextStyle(
                                color: AppTheme.warmText,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.amber.withOpacity(0.15),
                      ),
                      child: const Icon(Icons.trending_up_rounded,
                          color: AppTheme.amber, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Month',
                            style: TextStyle(
                                color: AppTheme.dimText, fontSize: 10)),
                        Text('${totalHours.toStringAsFixed(1)}h',
                            style: const TextStyle(
                                color: AppTheme.warmText,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _QuickTile(
            icon: Icons.play_circle_rounded,
            label: 'Listen',
            sub: 'Choose a Surah',
            gradient: const [AppTheme.gold, AppTheme.goldLight],
            onTap: () {
              context.read<AudioProvider>().selectCategory(0);
              Navigator.of(context).pushNamed(AppRoutes.player);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _QuickTile(
            icon: Icons.favorite_rounded,
            label: 'Favs',
            sub: 'Saved',
            gradient: const [Color(0xFFF43F5E), Color(0xFFE11D48)], // Modern rose
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.favorites),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _QuickTile(
            icon: Icons.edit_rounded,
            label: 'Goal',
            sub: 'Set target',
            gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)], // Modern indigo
            onTap: _editGoal,
          ),
        ),
      ],
    );
  }

  Widget _buildTopTracksSection() {
    return Consumer<StatsProvider>(
      builder: (_, stats, __) {
        final tracks = stats.stats.topTracks;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                children: [
                  const Text(
                    'TOP SURAHS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.dimText,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (tracks.isNotEmpty)
                    Text('${tracks.length} total',
                        style: const TextStyle(
                            color: AppTheme.dimText, fontSize: 10)),
                ],
              ),
            ),
            if (tracks.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: const Text(
                  'Start listening to see your top Surahs',
                  style: TextStyle(color: AppTheme.dimText, fontSize: 13),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tracks.length.clamp(0, 8),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    final track = tracks[i];
                    return Container(
                      width: 140,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.gold.withOpacity(0.15),
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                          color: AppTheme.gold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.play_circle_fill_rounded,
                                  color: AppTheme.gold, size: 18),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            track.trackTitle,
                            style: const TextStyle(
                                color: AppTheme.warmText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text('${track.playCount} plays',
                              style: const TextStyle(
                                  color: AppTheme.dimText, fontSize: 10)),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppTheme.gold, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Monthly Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: Consumer<StatsProvider>(
              builder: (_, stats, __) =>
                  HistogramChart(monthlyData: stats.stats.monthlyListening),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyGoalCard() {
    return Consumer<StatsProvider>(
      builder: (_, stats, __) {
        final auth = context.read<AuthProvider>();
        final uid = auth.currentUser?.uid ?? '';
        final progress = stats.getMonthlyProgress(uid, _monthlyGoal);
        final pct = (progress * 100).round();
        final currentMonth =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
        final monthlyDuration =
            stats.stats.monthlyListening[currentMonth] ?? Duration.zero;
        final totalHours = monthlyDuration.inMinutes / 60;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surface1,
                AppTheme.gold.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gold.withOpacity(0.15)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.flag_rounded,
                        color: AppTheme.amber, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Monthly Goal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmText,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _editGoal,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.gold.withOpacity(0.1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 10, color: AppTheme.gold),
                          SizedBox(width: 3),
                          Text('Edit',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppTheme.surface2,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${totalHours.toStringAsFixed(1)}h / ${_monthlyGoal.toStringAsFixed(0)}h',
                      style: const TextStyle(
                          color: AppTheme.dimText, fontSize: 11)),
                  Text('$pct%',
                      style: const TextStyle(
                          color: AppTheme.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editGoal() async {
    final controller =
        TextEditingController(text: _monthlyGoal.toStringAsFixed(0));
    final newGoal = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: const Text(
          'Monthly Listening Goal',
          style: TextStyle(
            color: AppTheme.warmText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppTheme.warmText),
          decoration: const InputDecoration(
            labelText: 'Hours per month',
            suffixText: 'h',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v > 0) Navigator.of(ctx).pop(v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newGoal != null) await _saveGoal(newGoal);
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.darkBg, size: 22),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.darkBg,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                color: AppTheme.darkBg.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
