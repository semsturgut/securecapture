import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securecapture/core/shared_data/services/database/database_service.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/features/dashboard/cubit/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required this.authenticationManager, required this.databaseService}) : super(const DashboardState());

  final AuthenticationManager authenticationManager;
  final DatabaseService databaseService;

  @override
  Future<void> close() {
    // Properly dispose resources
    authenticationManager.dispose();
    databaseService.close();
    return super.close();
  }
}
