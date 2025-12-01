import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alert.dart';
import '../data/models/outage.dart';

// Mock data for development - replace with Firebase in production
final alertsProvider = StateNotifierProvider<AlertsNotifier, List<Alert>>((ref) {
  return AlertsNotifier();
});

class AlertsNotifier extends StateNotifier<List<Alert>> {
  AlertsNotifier() : super([]);

  void addAlert(Alert alert) {
    state = [alert, ...state];
  }

  void markAsRead(String alertId) {
    state = state.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(isRead: true);
      }
      return alert;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((alert) => alert.copyWith(isRead: true)).toList();
  }

  void clearAlerts() {
    state = [];
  }

  int get unreadCount => state.where((a) => !a.isRead).length;
}

// Outages provider
final outagesProvider = StateNotifierProvider<OutagesNotifier, List<Outage>>((ref) {
  return OutagesNotifier();
});

class OutagesNotifier extends StateNotifier<List<Outage>> {
  OutagesNotifier() : super([]);

  void setOutages(List<Outage> outages) {
    state = outages;
  }

  void addOutage(Outage outage) {
    state = [outage, ...state];
  }

  void updateOutage(Outage updatedOutage) {
    state = state.map((outage) {
      if (outage.id == updatedOutage.id) {
        return updatedOutage;
      }
      return outage;
    }).toList();
  }

  List<Outage> get activeOutages =>
      state.where((o) => o.status == OutageStatus.active).toList();
}

// Unread alert count provider
final unreadAlertCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider);
  return alerts.where((a) => !a.isRead).length;
});

// Active outages count provider
final activeOutagesCountProvider = Provider<int>((ref) {
  final outages = ref.watch(outagesProvider);
  return outages.where((o) => o.status == OutageStatus.active).length;
});
