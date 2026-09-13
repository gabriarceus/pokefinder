import 'package:equatable/equatable.dart';

class DetailGameVersionState extends Equatable {
  const DetailGameVersionState({
    this.selectedVersion = allVersions,
    this.availableVersions = const [],
  });

  static const String allVersions = 'all';

  final String selectedVersion;
  final List<String> availableVersions;

  bool get isAllVersions => selectedVersion == allVersions;

  DetailGameVersionState copyWith({
    String? selectedVersion,
    List<String>? availableVersions,
  }) {
    return DetailGameVersionState(
      selectedVersion: selectedVersion ?? this.selectedVersion,
      availableVersions: availableVersions ?? this.availableVersions,
    );
  }

  @override
  List<Object?> get props => [selectedVersion, availableVersions];
}
