import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securecapture/core/shared_data/models/image.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/shared_domain/managers/encryption/encryption_manager.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:securecapture/core/widgets/custom_app_bar.dart';
import 'package:securecapture/core/widgets/error_view.dart';
import 'package:securecapture/core/widgets/loading_widget.dart';
import 'package:securecapture/di/di.dart';
import 'package:securecapture/features/gallery/cubit/gallery_cubit.dart';
import 'package:securecapture/features/gallery/cubit/gallery_state.dart';
import 'package:securecapture/features/gallery/screens/image_view_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Gallery'),
      body: BlocProvider(
        create: (context) => GalleryCubit(
          authenticationManager: getIt<AuthenticationManager>(),
          imageRepository: getIt<ImageRepository>(),
          encryptionManager: getIt<EncryptionManager>(),
        )..init(),
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GalleryCubit, GalleryState>(
      listener: (context, state) {
        if (state.imageBytesToShow != null && state.isAuthenticated) {
          showDialog(
            context: context,
            builder: (context) => ImageViewScreen(imageBytes: state.imageBytesToShow!),
          );
        }
      },
      listenWhen: (previous, current) => previous.imageBytesToShow != current.imageBytesToShow,
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.isAuthenticated != current.isAuthenticated ||
          previous.images != current.images ||
          previous.error != current.error,
      builder: (context, state) {
        if (state.isLoading) {
          return const LoadingWidget();
        }
        if (state.error != null || !state.isAuthenticated) {
          return ErrorView(reloadCallback: () => context.read<GalleryCubit>().init(), message: state.error.toString());
        }

        if (state.images.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64),
                SizedBox(height: 16),
                Text('No images yet', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Take some photos to see them here'),
              ],
            ),
          );
        }

        return _ImageGrid(images: state.images);
      },
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<ImageModel> images;

  const _ImageGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => context.read<GalleryCubit>().showImage(images[index].id),
            child: _ImageTile(imageModel: images[index]),
          );
        },
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final ImageModel imageModel;

  const _ImageTile({required this.imageModel});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FutureBuilder<List<int>>(
        future: context.read<GalleryCubit>().getDecryptedThumbnailBytes(imageModel.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          if (snapshot.hasError) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error, color: Colors.red),
            );
          }

          if (snapshot.hasData) {
            return Image.memory(Uint8List.fromList(snapshot.data!), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
          }

          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      ),
    );
  }
}
