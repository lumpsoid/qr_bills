part of 'add_tab_cubit.dart';

enum AddTab { form, qr }

final class AddPageState extends Equatable {
  const AddPageState({this.tab = AddTab.qr});

  final AddTab tab;

  @override
  List<Object> get props => [tab];

  AddPageState copyWith({AddTab? tab}) {
    return AddPageState(tab: tab ?? this.tab);
  }
}
