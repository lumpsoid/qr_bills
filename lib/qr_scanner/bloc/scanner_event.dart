part of 'scanner_bloc.dart';

sealed class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object> get props => [];
}

final class ScannerQrScanned extends ScannerEvent {
  final String url;

  const ScannerQrScanned({required this.url});

  @override
  List<Object> get props => [url];
}
