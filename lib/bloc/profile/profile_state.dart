part of 'profile_bloc.dart';

@immutable
sealed class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {
  final String? cachedName;
  final Uint8List? cachedImage;

  const ProfileLoading({this.cachedName, this.cachedImage});

  @override
  List<Object?> get props => [cachedName, cachedImage];
}

final class ProfileReady extends ProfileState {
  final String name;
  final Uint8List? image;
  final bool isUpdatingImage;
  final bool isUpdatingName;

  const ProfileReady({
    required this.name,
    this.image,
    this.isUpdatingImage = false,
    this.isUpdatingName = false,
  });

  ProfileReady copyWith({
    String? name,
    Uint8List? image,
    bool? isUpdatingImage,
    bool? isUpdatingName,
  }) {
    return ProfileReady(
      name: name ?? this.name,
      image: image ?? this.image,
      isUpdatingImage: isUpdatingImage ?? this.isUpdatingImage,
      isUpdatingName: isUpdatingName ?? this.isUpdatingName,
    );
  }

  @override
  List<Object?> get props => [name, image, isUpdatingImage, isUpdatingName];
}

final class ProfileError extends ProfileState {
  final String message;
  final ProfileState previousState;

  const ProfileError(this.message, this.previousState);

  @override
  List<Object?> get props => [message, previousState];
}