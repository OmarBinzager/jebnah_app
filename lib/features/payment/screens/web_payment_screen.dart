import 'dart:convert';
import '../../../common/models/place_order_model.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WebPaymentScreen extends StatefulWidget {
  final String? token;
  const WebPaymentScreen({super.key, this.token});

  @override
  State<WebPaymentScreen> createState() => _WebPaymentScreenState();
}

class _WebPaymentScreenState extends State<WebPaymentScreen> {
  Future<void> getValue() async {
    if (html.window.location.href.contains('success')) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      String placeOrderString = utf8.decode(
        base64Url.decode(orderProvider.getPlaceOrder()!.replaceAll(' ', '+')),
      );
      String tokenString = utf8.decode(
        base64Url.decode(widget.token!.replaceAll(' ', '+')),
      );
      String paymentMethod = tokenString.substring(
        0,
        tokenString.indexOf('&&'),
      );
      String transactionReference = tokenString.substring(
        tokenString.indexOf('&&') + '&&'.length,
        tokenString.length,
      );

      PlaceOrderModel placeOrderBody =
          PlaceOrderModel.fromJson(jsonDecode(placeOrderString)).copyWith(
            paymentMethod: paymentMethod.replaceAll('payment_method=', ''),
            transactionReference: transactionReference
                .replaceRange(
                  0,
                  transactionReference.indexOf('transaction_reference='),
                  '',
                )
                .replaceAll('transaction_reference=', ''),
          );
      orderProvider.placeOrder(placeOrderBody, _callback);
    } else {
      RouteHelper.getOrderSuccessRoute(
        '0',
        'field',
        action: RouteAction.pushReplacement,
      );
    }
  }

  void _callback(bool isSuccess, String message, String orderID) async {
    Provider.of<CartProvider>(context, listen: false).clearCartList();
    Provider.of<OrderProvider>(context, listen: false).clearPlaceOrder();
    Provider.of<OrderProvider>(context, listen: false).stopLoader();
    if (isSuccess) {
      RouteHelper.getOrderSuccessRoute(
        orderID,
        'success',
        action: RouteAction.pushReplacement,
      );
    } else {
      showCustomSnackBarHelper(message);
    }
  }

  @override
  void initState() {
    super.initState();
    getValue();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: Center(
          child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
