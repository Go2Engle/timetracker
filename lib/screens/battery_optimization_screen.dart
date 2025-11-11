import 'package:flutter/material.dart';
import '../services/battery_optimization_service.dart';

/// Screen that checks battery optimization status and guides users to
/// disable it for reliable background timer operation.
class BatteryOptimizationScreen extends StatefulWidget {
  const BatteryOptimizationScreen({super.key});

  @override
  State<BatteryOptimizationScreen> createState() =>
      _BatteryOptimizationScreenState();
}

class _BatteryOptimizationScreenState extends State<BatteryOptimizationScreen>
    with WidgetsBindingObserver {
  bool _isOptimizationDisabled = true;
  bool _isLoading = true;
  bool _isPlatformSupported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBatteryOptimization();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh status when returning from settings
    if (state == AppLifecycleState.resumed) {
      _checkBatteryOptimization();
    }
  }

  Future<void> _checkBatteryOptimization() async {
    setState(() {
      _isLoading = true;
    });

    final isPlatformSupported =
        BatteryOptimizationService.isPlatformSupported();
    final isDisabled =
        await BatteryOptimizationService.checkBatteryOptimizationStatus();

    setState(() {
      _isPlatformSupported = isPlatformSupported;
      _isOptimizationDisabled = isDisabled;
      _isLoading = false;
    });
  }

  Future<void> _openSettings() async {
    try {
      await BatteryOptimizationService.requestBatteryOptimizationExemption();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battery Optimization')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isPlatformSupported
          ? _buildNotApplicable()
          : _buildStatusCard(),
    );
  }

  Widget _buildNotApplicable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Not Applicable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Battery optimization settings are only applicable on Android devices. '
              'This feature is not needed on your current platform.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isOptimized = !_isOptimizationDisabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          Card(
            color: isOptimized ? Colors.orange.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    isOptimized
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    size: 64,
                    color: isOptimized
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isOptimized
                        ? 'Battery Optimization: Enabled'
                        : 'Battery Optimization: Disabled',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isOptimized
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOptimized ? 'Action Required' : 'Configured Correctly',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isOptimized
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Explanation Section
          Text(
            'Why This Matters',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            isOptimized
                ? 'Battery optimization can cause timers to pause or stop when the app is in the background, '
                      'leading to inaccurate time tracking. For the best experience, we recommend disabling '
                      'battery optimization for TimeTracker.'
                : 'Battery optimization is disabled for TimeTracker, which ensures your timers continue '
                      'running accurately even when the app is in the background or your screen is locked.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // How It Works Section
          Text(
            'How Background Timers Work',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'TimeTracker uses a foreground service to keep timers running in the background. '
            'However, Android\'s battery optimization can still restrict background execution. '
            'Disabling optimization ensures reliable timer operation.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Action Button (only show if optimization is enabled)
          if (isOptimized) ...[
            ElevatedButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Fix'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the button above to open battery settings. '
              'Look for TimeTracker and set it to "Don\'t optimize" or "Not optimized".',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
