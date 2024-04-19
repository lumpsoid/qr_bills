import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_tab_state.dart';

class AddPageCubit extends Cubit<AddPageState> {
  AddPageCubit() : super(const AddPageState());

  void setTab(AddTab tab) => state.copyWith(tab: tab);
}
