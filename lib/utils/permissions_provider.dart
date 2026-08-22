import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/owner_service.dart';

class PermissionsState {
  final String role;
  final Map<String, bool> permissions; // e.g. {'bookings.view': true, ...}
  final double commissionRate;
  final String commissionType;
  final double commissionFixed;
  final bool isLoading;
  final String? error;

  const PermissionsState({
    this.role = 'guest',
    this.permissions = const {},
    this.commissionRate = 0,
    this.commissionType = 'percentage',
    this.commissionFixed = 0,
    this.isLoading = false,
    this.error,
  });

  bool can(String resource, String action) => permissions['$resource.$action'] == true;

  PermissionsState copyWith({
    String? role,
    Map<String, bool>? permissions,
    double? commissionRate,
    String? commissionType,
    double? commissionFixed,
    bool? isLoading,
    String? error,
  }) {
    return PermissionsState(
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionType: commissionType ?? this.commissionType,
      commissionFixed: commissionFixed ?? this.commissionFixed,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PermissionsNotifier extends StateNotifier<PermissionsState> {
  PermissionsNotifier() : super(const PermissionsState());

  final OwnerService _service = OwnerService();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getMyPermissions();
      final rawPerms = (data['permissions'] as Map?)?.cast<String, dynamic>() ?? {};
      final perms = rawPerms.map((k, v) => MapEntry(k, v == true));

      state = PermissionsState(
        role: data['role']?.toString() ?? 'guest',
        permissions: perms,
        commissionRate: double.tryParse(data['commission_rate']?.toString() ?? '0') ?? 0,
        commissionType: data['commission_type']?.toString() ?? 'percentage',
        commissionFixed: double.tryParse(data['commission_fixed']?.toString() ?? '0') ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = const PermissionsState();
  }
}

final permissionsProvider = StateNotifierProvider<PermissionsNotifier, PermissionsState>(
  (ref) => PermissionsNotifier(),
);
