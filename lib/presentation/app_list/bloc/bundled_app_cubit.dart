import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bundled_app_state.dart';

class BundledAppCubit extends Cubit<BundledAppState> {
  BundledAppCubit() : super(BundledAppInitial());
}
