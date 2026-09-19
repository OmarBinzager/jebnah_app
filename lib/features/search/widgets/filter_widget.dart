import 'package:flutter/material.dart';

import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../providers/search_provider.dart';

class FilterWidget extends StatefulWidget {
  final String? query;

  const FilterWidget({super.key, this.query});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<SearchProvider>(
      context,
      listen: false,
    ).setLowerAndUpperValue(null, null, isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 600 : 700,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          final isNotEqualValue =
              (searchProvider.lowerValue ??
                  (searchProvider.searchProductModel?.minPrice ?? 0)) >
              (searchProvider.upperValue ??
                  (searchProvider.searchProductModel?.maxPrice ?? 0));

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // عدد الفلاتر النشطة
                    if (searchProvider.activeFiltersCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeSmall,
                          ),
                        ),
                        child: Text(
                          '${searchProvider.activeFiltersCount} ${getTranslated('filters_active', context)}',
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                    const Spacer(),

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        getTranslated('filter', context),
                        textAlign: TextAlign.center,
                        style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                    ),

                    const Spacer(),

                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // ========== 1. فلتر السعر ==========
                Text(getTranslated('price', context), style: poppinsMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                FlutterSlider(
                  values: [
                    searchProvider.lowerValue ??
                        (searchProvider.searchProductModel?.minPrice ?? 0),
                    (searchProvider.upperValue ??
                        (searchProvider.searchProductModel?.maxPrice ?? 0) +
                            (isNotEqualValue ? 0 : 1)),
                  ],
                  rangeSlider: true,
                  max:
                      (searchProvider.searchProductModel?.maxPrice ?? 0) +
                      (isNotEqualValue ? 0 : 1),
                  min: searchProvider.searchProductModel?.minPrice ?? 0,
                  handlerHeight: 25,
                  handlerWidth: 25,
                  trackBar: FlutterSliderTrackBar(
                    activeTrackBar: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    activeTrackBarHeight: 6,
                  ),
                  handler: FlutterSliderHandler(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(),
                  ),
                  rightHandler: FlutterSliderHandler(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(),
                  ),
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    searchProvider.setLowerAndUpperValue(
                      lowerValue,
                      upperValue,
                    );
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // ========== 2. فلتر الألوان ==========
                if (searchProvider.availableFilters['colors'] != null &&
                    (searchProvider.availableFilters['colors'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('colors', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['colors'] as List)
                                .map((color) {
                                  String colorName = color['name'] ?? '';
                                  int colorCount = color['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedColors
                                      .contains(colorName);

                                  return FilterChip(
                                    label: Text('$colorName ($colorCount)'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleColor(colorName);
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),
                // ========== فلتر الفئات (Categories) ==========
                // يوضع بعد فلتر الألوان وقبل فلتر الموديلات
                if (searchProvider.availableFilters['categories'] != null &&
                    (searchProvider.availableFilters['categories'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('categories', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['categories']
                                    as List)
                                .map((category) {
                                  String categoryName = category['name'] ?? '';
                                  String categoryId = (category['id'] ?? '')
                                      .toString();
                                  int categoryCount = category['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedCategories
                                      .contains(categoryId);

                                  return FilterChip(
                                    label: Text(
                                      '$categoryName ($categoryCount)',
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleCategory(categoryId);
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),
                // ========== 3. فلتر الموديلات ==========
                if (searchProvider.availableFilters['models'] != null &&
                    (searchProvider.availableFilters['models'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('models', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['models'] as List)
                                .map((model) {
                                  String modelName = model['name'] ?? '';
                                  int modelCount = model['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedModels
                                      .contains(modelName);

                                  return FilterChip(
                                    label: Text('$modelName ($modelCount)'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleModel(modelName);
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),

                // ========== 4. فلتر بلدان الصنع ==========
                if (searchProvider.availableFilters['countries'] != null &&
                    (searchProvider.availableFilters['countries'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('countries', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['countries']
                                    as List)
                                .map((country) {
                                  String countryName = country['name'] ?? '';
                                  int countryCount = country['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedCountries
                                      .contains(countryName);

                                  return FilterChip(
                                    label: Text('$countryName ($countryCount)'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleCountry(countryName);
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),

                // ========== 5. فلتر السعات ==========
                if (searchProvider.availableFilters['capacities'] != null &&
                    (searchProvider.availableFilters['capacities'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('capacities', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['capacities']
                                    as List)
                                .map((capacity) {
                                  String capacityName = capacity['name'] ?? '';
                                  int capacityCount = capacity['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedCapacities
                                      .contains(capacityName);

                                  return FilterChip(
                                    label: Text(
                                      '$capacityName ($capacityCount)',
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleCapacity(
                                        capacityName,
                                      );
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),

                // ========== 6. فلتر البراندات ==========
                // في FilterWidget، تعديل جزء البراندات
                if (searchProvider.availableFilters['brands'] != null &&
                    (searchProvider.availableFilters['brands'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('brands', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['brands'] as List)
                                .map((brand) {
                                  String brandName = brand['name'] ?? '';
                                  String brandId = (brand['id'] ?? '')
                                      .toString(); // استخدام id
                                  int brandCount = brand['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedBrands
                                      .contains(brandId);

                                  return FilterChip(
                                    label: Text('$brandName ($brandCount)'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleBrand(
                                        brandId,
                                      ); // تمرير id
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),

                // تعديل جزء الفئات
                if (searchProvider.availableFilters['categories'] != null &&
                    (searchProvider.availableFilters['categories'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('categories', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['categories']
                                    as List)
                                .map((category) {
                                  String categoryName = category['name'] ?? '';
                                  String categoryId = (category['id'] ?? '')
                                      .toString(); // استخدام id
                                  int categoryCount = category['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedCategories
                                      .contains(categoryId);

                                  return FilterChip(
                                    label: Text(
                                      '$categoryName ($categoryCount)',
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleCategory(
                                        categoryId,
                                      ); // تمرير id
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),

                // ========== فلتر البائعين (Sellers) ==========
                if (searchProvider.availableFilters['sellers'] != null &&
                    (searchProvider.availableFilters['sellers'] as List)
                        .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('sellers', context),
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Wrap(
                        spacing: Dimensions.paddingSizeSmall,
                        runSpacing: Dimensions.paddingSizeSmall,
                        children:
                            (searchProvider.availableFilters['sellers'] as List)
                                .map((seller) {
                                  String sellerName = seller['name'] ?? '';
                                  String sellerId = (seller['id'] ?? '')
                                      .toString();
                                  int sellerCount = seller['count'] ?? 0;
                                  bool isSelected = searchProvider
                                      .selectedSellers
                                      .contains(sellerId);

                                  return FilterChip(
                                    label: Text('$sellerName ($sellerCount)'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      searchProvider.toggleSeller(sellerId);
                                    },
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    labelStyle: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),
                // ========== 7. فلتر الترتيب ==========
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text(getTranslated('sort_by', context), style: poppinsMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                ListView.builder(
                  itemCount: searchProvider.allSortBy.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => searchProvider.setFilterValue(
                      searchProvider.allSortBy[index],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    searchProvider.selectedFilter ==
                                        searchProvider.allSortBy[index]
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(
                                        context,
                                      ).hintColor.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                            child:
                                searchProvider.selectedFilter ==
                                    searchProvider.allSortBy[index]
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Text(
                            getTranslated(
                              '${searchProvider.allSortBy[index]}',
                              context,
                            ),
                            style: poppinsRegular.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ========== أزرار الإجراءات ==========
                Row(
                  children: [
                    // زر إعادة التعيين
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeTen,
                          ),
                          border: Border.all(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        child: CustomButtonWidget(
                          backgroundColor: Theme.of(context).cardColor,
                          textColor: Theme.of(context).disabledColor,
                          buttonText: getTranslated('reset', context),
                          onPressed: () {
                            searchProvider.resetAllFilters();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    // زر التطبيق
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: CustomButtonWidget(
                          buttonText: getTranslated('apply', context),
                          onPressed: () {
                            searchProvider.searchWithCurrentFilters(
                              offset: 1,
                              query: widget.query ?? '',
                              isUpdate: true,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          );
        },
      ),
    );
  }
}
