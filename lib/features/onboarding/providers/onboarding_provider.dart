import 'package:flutter/material.dart';
import '../../../common/models/api_response_model.dart';
import '../../../features/onboarding/domain/models/onboarding_model.dart';
import '../../../features/onboarding/domain/reposotories/onboarding_repo.dart';

class OnBoardingProvider with ChangeNotifier {
  final OnBoardingRepo? onboardingRepo;
  OnBoardingProvider({required this.onboardingRepo});

  final List<OnBoardingModel> _onBoardingList = [];
  List<OnBoardingModel> get onBoardingList => _onBoardingList;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void getBoardingList(BuildContext context) async {
    ApiResponseModel apiResponse = await onboardingRepo!.getOnBoardingList(
      context,
    );
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _onBoardingList.clear();
      _onBoardingList.addAll(apiResponse.response!.data);
      notifyListeners();
    }
  }
}
