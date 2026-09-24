import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rburger/cubit/branch_selector_state.dart';
import 'package:rburger/services/data/branch_data.dart';

class BranchSelectorCubit extends Cubit<BranchSelectorState> {
  BranchSelectorCubit()
    : super(
        BranchSelectorState(
          selectedBranch: branches.isNotEmpty ? branches.first.nameEn : 'Sohag',
        ),
      );

  void changeBranch(String newBranch) {
    emit(BranchSelectorState(selectedBranch: newBranch));
  }

  // CHANGED: Match branch by ID instead of text name so language switching never breaks selection state
  void switchLanguage(bool isArabic) {
    if (branches.isEmpty) return;

    final currentBranchObj = branches.firstWhere(
      (b) =>
          b.nameEn == state.selectedBranch || b.nameAr == state.selectedBranch,
      orElse: () => branches.first,
    );

    emit(
      BranchSelectorState(
        selectedBranch: isArabic
            ? currentBranchObj.nameAr
            : currentBranchObj.nameEn,
      ),
    );
  }
}
