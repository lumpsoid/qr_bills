part of 'scanner_bloc.dart';

sealed class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object> get props => [];
}

final class ScannerInitial extends ScannerState {}

final class ScannerLoading extends ScannerState {}

final class ScannerLoaded extends ScannerState {
  const ScannerLoaded({this.url = ''});

  final String url;

  @override
  List<Object> get props => [url];
}
