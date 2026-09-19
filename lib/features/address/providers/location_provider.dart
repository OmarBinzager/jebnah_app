// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../common/models/place_details_model.dart';
import '../../../features/address/domain/models/address_model.dart';
import '../../../common/models/api_response_model.dart';
import '../../../common/models/response_model.dart';

import '../../../features/address/domain/reposotories/location_repo.dart';
import '../../../helper/api_checker_helper.dart';
import '../../../utill/app_constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/prediction_model.dart';

class LocationProvider with ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  final LocationRepo locationRepo;

  LocationProvider({
    required this.sharedPreferences,
    required this.locationRepo,
  });

  Position _position = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );
  Position _pickPosition = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );

  bool _loading = false;
  String? _address = '';
  String? _pickAddress = '';
  final String _currentAddressText = '';
  final List<Marker> _markers = <Marker>[];
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;
  List<AddressModel>? _addressList;
  List<String> _getAllAddressType = [];
  int _selectAddressIndex = 0;

  String? _pickedAddressLatitude;
  String? _pickedAddressLongitude;

  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String get currentAddressText => _currentAddressText;
  String? get address => _address;
  String? get pickAddress => _pickAddress;
  List<Marker> get markers => _markers;
  bool get buttonDisabled => _buttonDisabled;
  List<AddressModel>? get addressList => _addressList;
  List<String> get getAllAddressType => _getAllAddressType;
  int get selectAddressIndex => _selectAddressIndex;
  String? get pickedAddressLatitude => _pickedAddressLatitude;
  String? get pickedAddressLongitude => _pickedAddressLongitude;

  set setAddress(String? addressValue) => _address = addressValue;

  void setPickedAddressLatLon(
    String? lat,
    String? lon, {
    bool isUpdate = true,
  }) {
    _pickedAddressLatitude = lat;
    _pickedAddressLongitude = lon;
    if (isUpdate) {
      notifyListeners();
    }
  }

  GoogleMapController? mapController;
  CameraPosition? cameraPosition;
  bool isUpdateAddress = true;

  // for get current location
  void getCurrentLocation(
    BuildContext context,
    bool fromAddress, {
    GoogleMapController? mapController,
  }) async {
    _loading = true;
    notifyListeners();

    Position myPosition;
    try {
      Position newLocalData = await Geolocator.getCurrentPosition();
      myPosition = newLocalData;
    } catch (e) {
      myPosition = Position(
        latitude: double.parse('0'),
        longitude: double.parse('0'),
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    if (fromAddress) {
      _position = myPosition;
    } else {
      _pickPosition = myPosition;
    }

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(myPosition.latitude, myPosition.longitude),
            zoom: 17,
          ),
        ),
      );
    }
    // String _myPlaceMark;
    String getAddress = await getAddressFromGeocode(
      LatLng(myPosition.latitude, myPosition.longitude),
    );

    if (fromAddress) {
      _address = placeMarkToAddress(getAddress);
    }
    _loading = false;
    notifyListeners();
  }

  void updatePosition(
    CameraPosition? position,
    bool fromAddress,
    String? address, {
    bool forceNotify = true,
  }) async {
    if (_updateAddAddressData) {
      _loading = true;
      if (forceNotify) {
        notifyListeners();
      }

      try {
        if (fromAddress) {
          _position = Position(
            latitude: position!.target.latitude,
            longitude: position.target.longitude,
            timestamp: DateTime.now(),
            heading: 1,
            accuracy: 1,
            altitude: 1,
            speedAccuracy: 1,
            speed: 1,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        } else {
          _pickPosition = Position(
            latitude: position!.target.latitude,
            longitude: position.target.longitude,
            timestamp: DateTime.now(),
            heading: 1,
            accuracy: 1,
            altitude: 1,
            speedAccuracy: 1,
            speed: 1,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }

        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(
            LatLng(position.target.latitude, position.target.longitude),
          );
          fromAddress
              ? _address = addressFromGeocode
              : _pickAddress = addressFromGeocode;
          notifyListeners();
        } else {
          _changeAddress = true;
        }
      } catch (e) {
        debugPrint('error ==> $e');
        // تعيين عنوان افتراضي في حالة الخطأ
        if (fromAddress) {
          _address = 'Unable to get address';
        } else {
          _pickAddress = 'Unable to get address';
        }
      }
      _loading = false;

      if (forceNotify) {
        notifyListeners();
      }
    } else {
      _updateAddAddressData = true;
    }
  }

  // delete user address
  void deleteUserAddressByID(int? id, int index, Function callback) async {
    ApiResponseModel apiResponse = await locationRepo.removeAddressByID(id);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _addressList?.removeAt(index);
      callback(true, 'Deleted address successfully');
      notifyListeners();
    } else {
      callback(
        false,
        ApiCheckerHelper.getError(apiResponse).errors![0].message ?? '',
      );
    }
  }

  // user address

  Future<ResponseModel?> initAddressList() async {
    ResponseModel? responseModel;
    _addressList = null;
    ApiResponseModel apiResponse = await locationRepo.getAllAddress();
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _addressList = [];
      apiResponse.response!.data.forEach(
        (address) => _addressList!.add(AddressModel.fromJson(address)),
      );
      responseModel = ResponseModel(true, 'successful');
    } else {
      _addressList = [];
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
    return responseModel;
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _errorMessage = '';
  String? get errorMessage => _errorMessage;
  String? _addressStatusMessage = '';
  String? get addressStatusMessage => _addressStatusMessage;
  void updateAddressStatusMessage({String? message}) {
    _addressStatusMessage = message;
  }

  void onChangeErrorMessage({String? message}) {
    _errorMessage = message;
  }

  Future<ResponseModel> addAddress(
    AddressModel addressModel,
    BuildContext context,
  ) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;

    ApiResponseModel apiResponse = await locationRepo.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {
      responseModel = ResponseModel(
        false,
        ApiCheckerHelper.getError(apiResponse).errors?.first.message,
      );
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  // for address update screen
  Future<ResponseModel> updateAddress(
    BuildContext context, {
    required AddressModel addressModel,
    int? addressId,
  }) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;
    ApiResponseModel apiResponse = await locationRepo.updateAddress(
      addressModel,
      addressId,
    );
    _isLoading = false;
    ResponseModel responseModel;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {
      _errorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, errorMessage);
    }
    notifyListeners();
    return responseModel;
  }

  // for save user address Section
  Future<void> saveUserAddress({Placemark? address}) async {
    String userAddress = jsonEncode(address);
    try {
      await sharedPreferences!.setString(AppConstants.userAddress, userAddress);
    } catch (e) {
      rethrow;
    }
  }

  String getUserAddress() {
    return sharedPreferences!.getString(AppConstants.userAddress) ?? "";
  }

  // for Label Us

  void updateAddressIndex(int index, bool notify) {
    _selectAddressIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  initializeAllAddressType({BuildContext? context}) {
    if (_getAllAddressType.isEmpty) {
      _getAllAddressType = [];
      _getAllAddressType = locationRepo.getAllAddressType(context: context);
    }
  }

  Future<Position> setLocation(
    String? placeID,
    String? address,
    GoogleMapController? mapController,
  ) async {
    _loading = true;
    notifyListeners();
    PlaceDetailsModel detail;
    ApiResponseModel response = await locationRepo.getPlaceDetails(placeID);
    detail = PlaceDetailsModel.fromJson(response.response!.data);

    _pickPosition = Position(
      longitude: detail.location!.longitude!,
      latitude: detail.location!.latitude!,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );

    _position = Position(
      longitude: detail.location!.longitude!,
      latitude: detail.location!.latitude!,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );

    _pickAddress = address;
    _address = address;
    _changeAddress = false;

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              detail.location!.latitude!,
              detail.location!.longitude!,
            ),
            zoom: 16,
          ),
        ),
      );
    }
    _loading = false;
    notifyListeners();

    return _pickPosition;
  }

  void disableButton() {
    _buttonDisabled = true;
    notifyListeners();
  }

  void setAddAddressData(bool isUpdate) {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddAddressData = false;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    try {
      // المحاولة أولاً باستخدام الـ API الخاص بك
      ApiResponseModel response = await locationRepo.getAddressFromGeocode(
        latLng,
      );

      if (response.response != null && response.response!.statusCode == 200) {
        var data = response.response!.data;

        // محاولة استخراج العنوان من تنسيقات مختلفة
        String address = '';

        // تنسيق Google Maps API
        if (data is Map) {
          if (data.containsKey('results') && data['results'] != null) {
            var results = data['results'];
            if (results is List && results.isNotEmpty) {
              address = results[0]['formatted_address']?.toString() ?? '';
            }
          } else if (data.containsKey('address')) {
            address = data['address'].toString();
          } else if (data.containsKey('display_name')) {
            address = data['display_name'].toString();
          }
        }

        // إذا لم يتم العثور على عنوان من API، استخدم geocoding package
        if (address.isEmpty) {
          address = await _getAddressFromGeocodingPackage(latLng);
        }

        return address.isNotEmpty ? address : 'Unknown Location Found';
      } else {
        // إذا فشل API، استخدم geocoding package
        return await _getAddressFromGeocodingPackage(latLng);
      }
    } catch (e) {
      debugPrint('Error in getAddressFromGeocode: $e');
      // في حالة الخطأ، استخدم geocoding package
      return await _getAddressFromGeocodingPackage(latLng);
    }
  }

  // دالة مساعدة للحصول على العنوان من geocoding package
  Future<String> _getAddressFromGeocodingPackage(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];

        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        return addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Unknown Location';
      }
      return 'Unknown Location Found';
    } catch (e) {
      debugPrint('Error in geocoding: $e');
      return 'Unknown Location Found';
    }
  }

  Future<List<PredictionModel>> searchLocation(
    BuildContext context,
    String text,
  ) async {
    if (text.isNotEmpty) {
      try {
        ApiResponseModel response = await locationRepo.searchLocation(text);

        if (response.response?.statusCode == 200 &&
            response.response?.data != null) {
          _predictionList = [];

          // التحقق من وجود 'suggestions' وأنها ليست null
          var suggestions = response.response?.data['suggestions'];

          if (suggestions != null && suggestions is List) {
            suggestions.forEach(
              (prediction) =>
                  _predictionList.add(PredictionModel.fromJson(prediction)),
            );
          } else {
            // محاولة الحصول على البيانات من مفتاح آخر إذا كان الـ API مختلف
            var predictions =
                response.response?.data['predictions'] ??
                response.response?.data['results'] ??
                response.response?.data['data'];

            if (predictions != null && predictions is List) {
              predictions.forEach(
                (prediction) =>
                    _predictionList.add(PredictionModel.fromJson(prediction)),
              );
            } else {
              _predictionList = [];
            }
          }
        } else {
          _predictionList = [];
        }
      } catch (e) {
        debugPrint('Error in searchLocation: $e');
        _predictionList = [];
      }
    } else {
      _predictionList = [];
    }

    return _predictionList;
  }

  String placeMarkToAddress(String placeMark) {
    return placeMark;
  }

  Future<AddressModel?> getLastOrderedAddress() async {
    AddressModel? addressModel;
    ApiResponseModel apiResponse = await locationRepo.getLastOrderedAddress();
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200 &&
        apiResponse.response?.data.isNotEmpty) {
      addressModel = AddressModel.fromJson(apiResponse.response?.data);
    }
    return addressModel;
  }

  int? getAddressIndex(AddressModel address) {
    int? index;
    if (_addressList != null) {
      for (int i = 0; i < _addressList!.length; i++) {
        if (_addressList![i].id == address.id) {
          index = i;
          break;
        }
      }
    }
    return index;
  }
}
