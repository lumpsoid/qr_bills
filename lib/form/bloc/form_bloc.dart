import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  FormBloc() : super(FormInitial()) {
    on<FormEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
