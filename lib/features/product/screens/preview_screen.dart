import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/custom_ink_well_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/dimensions.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> images;
  final int selectedIndex;
  const PreviewScreen({
    super.key,
    required this.images,
    required this.selectedIndex,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.selectedIndex;
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        backgroundColor: isDesktop ? Colors.transparent : Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (i) async {
                  setState(() {
                    _currentPage = i;
                  });
                },
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  String image =
                      '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.reviewImageUrl}/${widget.images[index]}';
                  return PhotoView(
                    backgroundDecoration: BoxDecoration(
                      color: isDesktop ? Colors.transparent : Colors.black,
                    ),
                    tightMode: true,
                    imageProvider: NetworkImage(
                      kIsWeb
                          ? '${AppConstants.baseUrl}/image-proxy?url=$image'
                          : image,
                    ),
                    // heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
                  );
                },
              ),

              Positioned(
                top: isDesktop ? 0 : 10,
                right: 0,
                child: isDesktop
                    ? InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).cardColor.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.clear,
                            size: Dimensions.paddingSizeLarge,
                          ),
                        ),
                      )
                    : IconButton(
                        splashRadius: 5,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear, color: Colors.white),
                      ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isPreviousPageExist()
                          ? isDesktop
                                ? Colors.white
                                : Colors.black
                          : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                  margin: EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  child: CustomInkWellWidget(
                    onTap: _previousPage,
                    radius: 50,
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Icon(
                      Icons.arrow_back_sharp,
                      color: _isPreviousPageExist()
                          ? isDesktop
                                ? Colors.white
                                : Colors.black
                          : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isNextPageExist()
                          ? isDesktop
                                ? Colors.white
                                : Colors.black
                          : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                  margin: EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: CustomInkWellWidget(
                    onTap: _nextPage,
                    radius: 50,
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _isNextPageExist()
                          ? isDesktop
                                ? Colors.white
                                : Colors.black
                          : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isNextPageExist() => _currentPage < widget.images.length - 1;

  bool _isPreviousPageExist() => _currentPage > 0;

  void _nextPage() {
    if (_isNextPageExist()) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_isPreviousPageExist()) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
