import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_queue_service.dart';
import '../services/connectivity_service.dart';
import '../utils/app_theme.dart';

/// Widget that shows sync status in the app bar
class SyncStatusIndicator extends StatelessWidget {
  final bool showLabel;
  final double iconSize;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = false,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<SyncQueueService, ConnectivityService>(
      builder: (context, syncQueue, connectivity, _) {
        return GestureDetector(
          onTap: () => _showSyncDetails(context, syncQueue, connectivity),
          child: _buildIndicator(context, syncQueue, connectivity),
        );
      },
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    SyncQueueService syncQueue,
    ConnectivityService connectivity,
  ) {
    final isOffline = connectivity.isOffline;
    final state = syncQueue.state;
    final pendingCount = syncQueue.pendingCount;
    final failedCount = syncQueue.failedCount;

    IconData icon;
    Color color;
    String? badgeText;

    if (isOffline) {
      icon = Icons.cloud_off;
      color = AppColors.warning;
    } else {
      switch (state) {
        case SyncState.syncing:
          icon = Icons.cloud_sync;
          color = AppColors.categoryTransport; // Blue
        case SyncState.synced:
          icon = Icons.cloud_done;
          color = AppColors.success;
        case SyncState.error:
          icon = Icons.cloud_off;
          color = AppColors.error;
          badgeText = failedCount.toString();
        case SyncState.idle:
          if (pendingCount > 0) {
            icon = Icons.cloud_upload;
            color = AppColors.warning;
            badgeText = pendingCount.toString();
          } else {
            icon = Icons.cloud_done;
            color = AppColors.success;
          }
      }
    }

    Widget iconWidget = state == SyncState.syncing
        ? _buildSyncingIcon(color)
        : Icon(icon, color: color, size: iconSize);

    if (badgeText != null) {
      iconWidget = Badge(
        label: Text(
          badgeText,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        child: iconWidget,
      );
    }

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          Text(
            _getStatusLabel(state, isOffline, pendingCount),
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      );
    }

    return iconWidget;
  }

  Widget _buildSyncingIcon(Color color) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: iconSize - 4,
            height: iconSize - 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Icon(Icons.cloud, color: color, size: iconSize - 8),
        ],
      ),
    );
  }

  String _getStatusLabel(SyncState state, bool isOffline, int pendingCount) {
    if (isOffline) return 'Offline';

    switch (state) {
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.synced:
        return 'Synced';
      case SyncState.error:
        return 'Sync failed';
      case SyncState.idle:
        if (pendingCount > 0) {
          return '$pendingCount pending';
        }
        return 'Synced';
    }
  }

  void _showSyncDetails(
    BuildContext context,
    SyncQueueService syncQueue,
    ConnectivityService connectivity,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SyncDetailsSheet(
        syncQueue: syncQueue,
        connectivity: connectivity,
      ),
    );
  }
}

class _SyncDetailsSheet extends StatelessWidget {
  final SyncQueueService syncQueue;
  final ConnectivityService connectivity;

  const _SyncDetailsSheet({
    required this.syncQueue,
    required this.connectivity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                connectivity.isOffline ? Icons.cloud_off : Icons.cloud,
                color: connectivity.isOffline
                    ? AppColors.warning
                    : AppColors.categoryTransport,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Sync Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Connection status
          _buildStatusRow(
            context,
            'Connection',
            connectivity.isOnline ? 'Online' : 'Offline',
            connectivity.isOnline ? AppColors.success : AppColors.warning,
            connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
            textSecondary,
          ),
          const SizedBox(height: 16),

          // Sync status
          _buildStatusRow(
            context,
            'Sync State',
            _getSyncStateText(syncQueue.state),
            _getSyncStateColor(syncQueue.state),
            _getSyncStateIcon(syncQueue.state),
            textSecondary,
          ),
          const SizedBox(height: 16),

          // Pending items
          _buildStatusRow(
            context,
            'Pending Changes',
            '${syncQueue.pendingCount} items',
            syncQueue.pendingCount > 0
                ? AppColors.warning
                : textSecondary,
            Icons.upload,
            textSecondary,
          ),
          const SizedBox(height: 16),

          // Failed items
          if (syncQueue.failedCount > 0) ...[
            _buildStatusRow(
              context,
              'Failed Items',
              '${syncQueue.failedCount} items',
              AppColors.error,
              Icons.error_outline,
              textSecondary,
            ),
            const SizedBox(height: 16),
          ],

          // Last error
          if (syncQueue.lastError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      syncQueue.lastError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          const Divider(),
          const SizedBox(height: 16),

          // Force sync button
          if (connectivity.isOnline && syncQueue.pendingCount > 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncQueue.isSyncing ? null : () => syncQueue.processQueue(),
                icon: const Icon(Icons.sync),
                label: Text(syncQueue.isSyncing ? 'Syncing...' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

          // Retry failed button
          if (connectivity.isOnline && syncQueue.failedCount > 0) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: syncQueue.isSyncing ? null : () => syncQueue.forceSync(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Failed Items'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
    Color labelColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getSyncStateText(SyncState state) {
    switch (state) {
      case SyncState.idle:
        return 'Idle';
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.synced:
        return 'Up to date';
      case SyncState.error:
        return 'Error';
    }
  }

  Color _getSyncStateColor(SyncState state) {
    switch (state) {
      case SyncState.idle:
        return AppColors.grey500;
      case SyncState.syncing:
        return AppColors.categoryTransport;
      case SyncState.synced:
        return AppColors.success;
      case SyncState.error:
        return AppColors.error;
    }
  }

  IconData _getSyncStateIcon(SyncState state) {
    switch (state) {
      case SyncState.idle:
        return Icons.hourglass_empty;
      case SyncState.syncing:
        return Icons.sync;
      case SyncState.synced:
        return Icons.check_circle;
      case SyncState.error:
        return Icons.error;
    }
  }
}

/// Offline banner widget to show at the top of screens
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        if (connectivity.isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: AppColors.warning,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'You\'re offline. Changes will sync when connected.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
