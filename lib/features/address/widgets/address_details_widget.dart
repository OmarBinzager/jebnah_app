import 'package:flutter/material.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../features/address/domain/models/address_model.dart';
import '../../../features/auth/widgets/country_code_picker_widget.dart';

class AddressDetailsWidget extends StatelessWidget {
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController florNumberController;
  final TextEditingController cityController;
  final TextEditingController districtController;
  final TextEditingController streetNameController;

  final FocusNode nameNode;
  final FocusNode numberNode;
  final FocusNode addressNode;
  final FocusNode stateNode;
  final FocusNode houseNode;
  final FocusNode florNode;
  final FocusNode cityNode;
  final FocusNode districtNode;
  final FocusNode streetNameNode;

  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  final String countryCode;
  final Function(String) onValueChange;

  const AddressDetailsWidget({
    super.key,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.streetNumberController,
    required this.houseNumberController,
    required this.florNumberController,
    required this.cityController,
    required this.districtController,
    required this.streetNameController,
    required this.nameNode,
    required this.numberNode,
    required this.addressNode,
    required this.stateNode,
    required this.houseNode,
    required this.florNode,
    required this.cityNode,
    required this.districtNode,
    required this.streetNameNode,
    required this.isEnableUpdate,
    required this.fromCheckout,
    this.address,
    required this.countryCode,
    required this.onValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // حقل اسم الشخص المسؤول عن الاتصال
        TextFormField(
          controller: contactPersonNameController,
          focusNode: nameNode,
          decoration: InputDecoration(
            hintText: getTranslated('contact_person_name', context),
            labelText: getTranslated('contact_person_name', context),
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // حقل رقم الهاتف مع كود الدولة
        Row(
          children: [
            CountryCodePickerWidget(
              initialSelection: countryCode,
              onChanged: (code) {
                onValueChange(code.code!);
              },
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: TextFormField(
                controller: contactPersonNumberController,
                focusNode: numberNode,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: getTranslated('phone_number', context),
                  labelText: getTranslated('phone_number', context),
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSizeDefault,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // حقل المدينة
        TextFormField(
          controller: cityController,
          focusNode: cityNode,
          decoration: InputDecoration(
            hintText: getTranslated('city', context),
            labelText: getTranslated('city', context),
            prefixIcon: const Icon(Icons.location_city),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // حقل المنطقة
        TextFormField(
          controller: districtController,
          focusNode: districtNode,
          decoration: InputDecoration(
            hintText: getTranslated('district', context),
            labelText: getTranslated('district', context),
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // حقل اسم الشارع
        TextFormField(
          controller: streetNameController,
          focusNode: streetNameNode,
          decoration: InputDecoration(
            hintText: getTranslated('street_name', context),
            labelText: getTranslated('street_name', context),
            prefixIcon: const Icon(Icons.signpost),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // حقول إضافية (رقم الشارع، المنزل، الطابق)
        // للشاشات الكبيرة عرضها في صف واحد
        if (ResponsiveHelper.isDesktop(context))
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: streetNumberController,
                  focusNode: stateNode,
                  decoration: InputDecoration(
                    hintText: getTranslated('street_number', context),
                    labelText: getTranslated('street_number', context),
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeDefault,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: TextFormField(
                  controller: houseNumberController,
                  focusNode: houseNode,
                  decoration: InputDecoration(
                    hintText: getTranslated('house_number', context),
                    labelText: getTranslated('house_number', context),
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeDefault,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: TextFormField(
                  controller: florNumberController,
                  focusNode: florNode,
                  decoration: InputDecoration(
                    hintText: getTranslated('floor_number', context),
                    labelText: getTranslated('floor_number', context),
                    prefixIcon: const Icon(Icons.flood_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeDefault,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          // للشاشات الصغيرة عرضها في عمود
          Column(
            children: [
              TextFormField(
                controller: streetNumberController,
                focusNode: stateNode,
                decoration: InputDecoration(
                  hintText: getTranslated('street_number', context),
                  labelText: getTranslated('street_number', context),
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSizeDefault,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              TextFormField(
                controller: houseNumberController,
                focusNode: houseNode,
                decoration: InputDecoration(
                  hintText: getTranslated('house_number', context),
                  labelText: getTranslated('house_number', context),
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSizeDefault,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              TextFormField(
                controller: florNumberController,
                focusNode: florNode,
                decoration: InputDecoration(
                  hintText: getTranslated('floor_number', context),
                  labelText: getTranslated('floor_number', context),
                  prefixIcon: const Icon(Icons.flood_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSizeDefault,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
