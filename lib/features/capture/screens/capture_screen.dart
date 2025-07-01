import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securecapture/core/widgets/custom_app_bar.dart';
import 'package:securecapture/core/widgets/button.dart';
import 'package:securecapture/core/widgets/error_view.dart';
import 'package:securecapture/core/widgets/loading_widget.dart';
import 'package:securecapture/di/di.dart';
import 'package:securecapture/features/capture/cubit/capture_cubit.dart';
import 'package:securecapture/features/capture/cubit/capture_state.dart';
import 'package:securecapture/core/shared_domain/services/permission_service.dart';
import 'package:securecapture/features/capture/domain/services/camera_service.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CaptureCubit(permissionService: getIt<PermissionService>(), cameraService: getIt<CameraService>())..init(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Capture'),
      extendBodyBehindAppBar: true,
      body: BlocConsumer<CaptureCubit, CaptureState>(
        listener: (context, state) {
          if (state is PermissionDenied) {
            _showPermissionDeniedDialog(context);
          }
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const LoadingWidget(),
            error: (error) => ErrorView(reloadCallback: () => context.read<CaptureCubit>().init(), message: error.declaration),
            granted: (cameraController) => _GrantedView(cameraController: cameraController),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Permission denied'),
          actions: [
            TextButton(
              onPressed: () {
                context.read<CaptureCubit>().openSettings();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Open settings'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}

class _GrantedView extends StatelessWidget {
  final CameraController cameraController;
  const _GrantedView({required this.cameraController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: cameraController.value.previewSize?.height ?? 0,
          height: cameraController.value.previewSize?.width ?? 0,
          child: CameraPreview(cameraController),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 16,
              children: [
                Button(icon: Icons.image, onTap: () {}),
                Expanded(
                  child: Button(text: 'Take picture', icon: Icons.camera_alt, onTap: () => context.read<CaptureCubit>().takePicture()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
