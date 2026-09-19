import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/chat/providers/chat_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../common/widgets/not_login_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../features/chat/widgets/message_bubble_widget.dart';
import '../../../features/chat/widgets/message_bubble_shimmer_widget.dart';

import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String userName;
  final String senderType;
  final String profileImage;
  final bool isAppBar;
  const ChatScreen({
    super.key,
    required this.orderId,
    this.isAppBar = false,
    required this.userName,
    required this.senderType,
    required this.profileImage,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputMessageController = TextEditingController();
  late bool _isLoggedIn;
  bool _isFirst = true;

  @override
  void initState() {
    super.initState();

    final ChatProvider chatProvider = Provider.of<ChatProvider>(
      context,
      listen: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!kIsWeb) {
        chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
    });

    _isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();

    if (_isLoggedIn) {
      if (_isFirst) {
        chatProvider.getMessages(1, widget.orderId, true, widget.senderType);
      } else {
        chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
        _isFirst = false;
      }

      Provider.of<ProfileProvider>(context, listen: false).getUserInfo(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    final bool isAdmin = widget.senderType == "admin";

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : ResponsiveHelper.isMobilePhone() && isAdmin && !widget.isAppBar
            ? null
            : AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).cardColor,
                  ),
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    if (!Navigator.canPop(context)) {
                      RouteHelper.getMainRoute(
                        action: RouteAction.pushNamedAndRemoveUntil,
                      );
                      splashProvider.setPageIndex(0);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  isAdmin
                      ? '${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommerceName}'
                      : widget.userName,
                  style: poppinsMedium.copyWith(
                    color: Theme.of(context).cardColor,
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).cardColor,
                        ),
                        color: Theme.of(context).cardColor,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CustomImageWidget(
                          fit: BoxFit.cover,
                          placeholder: isAdmin
                              ? Images.appLogo
                              : Images.profilePlaceholder,
                          image: isAdmin
                              ? ''
                              : '${splashProvider.baseUrls?.deliveryManImageUrl}/${widget.profileImage}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        body: _isLoggedIn
            ? Center(
                child: SizedBox(
                  width: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.webScreenWidth
                      : MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      ResponsiveHelper.isDesktop(context)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraLarge,
                              ),
                              child: Center(
                                child: Text(
                                  "chat".tr,
                                  style: poppinsSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),

                      Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          return chatProvider.messageList == null
                              ? Expanded(
                                  child: ListView.builder(
                                    reverse: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: 15,
                                    itemBuilder: (context, index) =>
                                        MessageBubbleShimmerWidget(
                                          isMe: index.isOdd,
                                        ),
                                  ),
                                )
                              : Expanded(
                                  child: ListView.builder(
                                    reverse: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: chatProvider.messageList!.length,
                                    itemBuilder: (context, index) {
                                      return MessageBubbleWidget(
                                        messages:
                                            chatProvider.messageList![index],
                                        isAdmin: isAdmin,
                                      );
                                    },
                                  ),
                                );
                        },
                      ),

                      Padding(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.isDesktop(context)
                              ? 0
                              : Dimensions.paddingSizeSmall,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSizeSmall,
                            ),
                          ),
                          child: Column(
                            children: [
                              Consumer<ChatProvider>(
                                builder: (context, chatProvider, _) {
                                  return (chatProvider.chatImage?.isNotEmpty ??
                                          false)
                                      ? SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount:
                                                chatProvider.chatImage!.length,
                                            itemBuilder: (BuildContext context, index) {
                                              return chatProvider
                                                      .chatImage!
                                                      .isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      20,
                                                                    ),
                                                                  ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius.all(
                                                                    Radius.circular(
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                    ),
                                                                  ),
                                                              child:
                                                                  ResponsiveHelper.isWeb()
                                                                  ? Image.network(
                                                                      chatProvider
                                                                          .chatImage![index]
                                                                          .path,
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image.file(
                                                                      File(
                                                                        chatProvider
                                                                            .chatImage![index]
                                                                            .path,
                                                                      ),
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: InkWell(
                                                              onTap: () =>
                                                                  chatProvider
                                                                      .removeImage(
                                                                        index,
                                                                      ),
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: const Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        4.0,
                                                                      ),
                                                                  child: Icon(
                                                                    Icons.clear,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox();
                                            },
                                          ),
                                        )
                                      : const SizedBox();
                                },
                              ),

                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Provider.of<ChatProvider>(
                                        context,
                                        listen: false,
                                      ).onPickImage(context, false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                      ),
                                      child: Image.asset(
                                        Images.image,
                                        width: 25,
                                        height: 25,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                    child: VerticalDivider(
                                      width: 0,
                                      thickness: 1,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeDefault,
                                  ),
                                  Expanded(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.sizeOf(context).height *
                                            0.2,
                                      ),
                                      child: TextField(
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(
                                            Dimensions.messageInputLength,
                                          ),
                                        ],
                                        controller: _inputMessageController,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        style: poppinsRegular,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          hintText: getTranslated(
                                            'type_here',
                                            context,
                                          ),
                                          hintStyle: poppinsRegular.copyWith(
                                            color: Theme.of(context).hintColor,
                                            fontSize: Dimensions.fontSizeLarge,
                                          ),
                                        ),
                                        onSubmitted: (String newText) {
                                          if (newText.trim().isNotEmpty &&
                                              !Provider.of<ChatProvider>(
                                                context,
                                                listen: false,
                                              ).isSendButtonActive) {
                                            Provider.of<ChatProvider>(
                                              context,
                                              listen: false,
                                            ).onChangeSendButtonActivity();
                                          } else if (newText.isEmpty &&
                                              Provider.of<ChatProvider>(
                                                context,
                                                listen: false,
                                              ).isSendButtonActive) {
                                            Provider.of<ChatProvider>(
                                              context,
                                              listen: false,
                                            ).onChangeSendButtonActivity();
                                          }
                                        },
                                        onChanged: (String newText) {
                                          if (newText.trim().isNotEmpty &&
                                              !Provider.of<ChatProvider>(
                                                context,
                                                listen: false,
                                              ).isSendButtonActive) {
                                            Provider.of<ChatProvider>(
                                              context,
                                              listen: false,
                                            ).onChangeSendButtonActivity();
                                          } else if (newText.isEmpty &&
                                              Provider.of<ChatProvider>(
                                                context,
                                                listen: false,
                                              ).isSendButtonActive) {
                                            Provider.of<ChatProvider>(
                                              context,
                                              listen: false,
                                            ).onChangeSendButtonActivity();
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () async {
                                      if (Provider.of<ChatProvider>(
                                        context,
                                        listen: false,
                                      ).isSendButtonActive) {
                                        Provider.of<ChatProvider>(
                                          context,
                                          listen: false,
                                        ).sendMessage(
                                          _inputMessageController.text,
                                          context,
                                          Provider.of<AuthProvider>(
                                            context,
                                            listen: false,
                                          ).getUserToken(),
                                          widget.orderId,
                                          widget.senderType,
                                        );
                                        _inputMessageController.clear();
                                        Provider.of<ChatProvider>(
                                          context,
                                          listen: false,
                                        ).onChangeSendButtonActivity();
                                      } else {
                                        showCustomSnackBarHelper(
                                          'write_somethings',
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                      ),
                                      child:
                                          Provider.of<ChatProvider>(
                                            context,
                                            listen: false,
                                          ).isLoading
                                          ? SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: CustomLoaderWidget(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                            )
                                          : Image.asset(
                                              Images.send,
                                              width: 25,
                                              height: 25,
                                              color:
                                                  Provider.of<ChatProvider>(
                                                    context,
                                                  ).isSendButtonActive
                                                  ? Theme.of(
                                                      context,
                                                    ).primaryColor
                                                  : Theme.of(context).hintColor,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (ResponsiveHelper.isDesktop(context)) ...[
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ],
                    ],
                  ),
                ),
              )
            : const NotLoggedInWidget(),
      ),
    );
  }
}
