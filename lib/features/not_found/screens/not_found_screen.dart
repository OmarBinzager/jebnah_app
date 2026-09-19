import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: WebAppBarWidget(),
              )
            : null,
        body: SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      !ResponsiveHelper.isDesktop(context) && height < 600
                      ? height
                      : height - 400,
                ),
                child: Center(
                  child: TweenAnimationBuilder(
                    curve: Curves.bounceOut,
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 12.0, end: 30.0),
                    builder:
                        (BuildContext context, dynamic value, Widget? child) {
                          return Text(
                            getTranslated('page_not_found', context),
                            style: poppinsBold,
                          );
                        },
                  ),
                ),
              ),

              const FooterWebWidget(footerType: FooterType.nonSliver),
            ],
          ),
        ),
      ),
    );
  }
}
