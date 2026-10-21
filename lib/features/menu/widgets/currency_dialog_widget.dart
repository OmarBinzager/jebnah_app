import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/models/currency_model.dart';
import '../../../common/providers/currency_provider.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';

class CurrencyDialogWidget extends StatefulWidget {
  const CurrencyDialogWidget({super.key});

  @override
  State<CurrencyDialogWidget> createState() => _CurrencyDialogWidgetState();
}

class _CurrencyDialogWidgetState extends State<CurrencyDialogWidget> {
  CurrencyModel? _tempSelected;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CurrencyProvider>(context, listen: false);
    _tempSelected = provider.selectedCurrency;
  }

  String _getCurrencyName(BuildContext context, CurrencyModel currency) {
    final code = currency.currencyCode?.toUpperCase();
    if (code == 'YER') {
      return getTranslated('yemeni_rial', context);
    } else if (code == 'SAR') {
      return getTranslated('saudi_riyal', context);
    } else if (code == 'USD') {
      return getTranslated('us_dollar', context);
    }
    return currency.country ?? currency.currencyCode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Consumer<CurrencyProvider>(
          builder: (context, currencyProvider, child) {
            final currencyList = currencyProvider.currencyList;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated('select_currency', context),
                            style: poppinsBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getTranslated('preferred_currency_hint', context),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      if (_tempSelected?.currencyCode != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _tempSelected!.currencyCode!,
                            style: poppinsBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                const Divider(height: 1),
                
                Flexible(
                  child: currencyList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                          child: Center(
                            child: Text(
                              getTranslated('no_currency_found', context),
                              style: poppinsRegular,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: currencyList.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (context, index) {
                            final currency = currencyList[index];
                            final isSelected = _tempSelected?.currencyCode?.toUpperCase() == currency.currencyCode?.toUpperCase();

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _tempSelected = currency;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                                            : Theme.of(context).hintColor.withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        currency.currencySymbol ?? '',
                                        style: poppinsBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                currency.currencyCode ?? '',
                                                style: poppinsBold.copyWith(
                                                  fontSize: Dimensions.fontSizeDefault,
                                                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                              if (currency.isBase == true) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    getTranslated('base_currency', context),
                                                    style: poppinsMedium.copyWith(
                                                      fontSize: 10,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            _getCurrencyName(context, currency),
                                            style: poppinsRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.4),
                                          width: isSelected ? 6.5 : 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            getTranslated('cancel', context),
                            style: poppinsRegular.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_tempSelected != null) {
                              currencyProvider.setCurrency(_tempSelected!);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            getTranslated('ok', context),
                            style: poppinsBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
