import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/features/main_navigation/cubit/navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit({int initialIndex = 0})
    : super(NavigationState(currentIndex: initialIndex));

  void selectTab(int index) {
    if (index == state.currentIndex || index < 0 || index > 4) return;
    emit(NavigationState(currentIndex: index));
  }
}
