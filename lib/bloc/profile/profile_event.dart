part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {}

final class ProfileImageUpdateRequested extends ProfileEvent {
  final Uint8List imageData;

  const ProfileImageUpdateRequested(this.imageData);

  @override
  List<Object?> get props => [imageData];
}

final class ProfileNameUpdateRequested extends ProfileEvent {
  final String newName;

  const ProfileNameUpdateRequested(this.newName);

  @override
  List<Object?> get props => [newName];
}
