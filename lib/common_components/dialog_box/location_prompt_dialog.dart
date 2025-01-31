import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_button.dart';

Future<void> locationPromptDialog(
    {String text,
    String yesText,
    String noText,
    @required bool isShareLocationData,
    @required bool isRequestLocationData,
    bool onlyText = false,
    LocationNotificationModel locationNotificationModel}) {
  var value = showDialog<void>(
    context: NavService.navKey.currentContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LocationPrompt(
          text: text,
          yesText: yesText,
          noText: noText,
          onlyText: onlyText,
          isShareLocationData: isShareLocationData,
          isRequestLocationData: isRequestLocationData,
          locationNotificationModel: locationNotificationModel);
    },
  );
  return value;
}

class LocationPrompt extends StatefulWidget {
  final String text, yesText, noText;
  final bool isShareLocationData, isRequestLocationData, onlyText;
  final LocationNotificationModel locationNotificationModel;

  LocationPrompt(
      {this.text,
      this.yesText,
      this.noText,
      this.onlyText = false,
      @required this.isShareLocationData,
      @required this.isRequestLocationData,
      this.locationNotificationModel});

  @override
  _LocationPromptState createState() => _LocationPromptState();
}

class _LocationPromptState extends State<LocationPrompt> {
  bool loading;

  @override
  void initState() {
    loading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig().screenWidth * 0.8,
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 20),
        content: SingleChildScrollView(
          child: Container(
            child: widget.onlyText
                ? Column(
                    children: [
                      Text(
                        widget.text ?? '...',
                        style: CustomTextStyles().grey16,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        onTap: () => Navigator.of(context).pop(),
                        bgColor: Theme.of(context).primaryColor,
                        width: 70.toWidth,
                        height: 48.toHeight,
                        child: Text(
                          TextStrings.okay,
                          style: TextStyle(
                              fontSize: 15.toFont,
                              color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                      )
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Text(
                        widget.text ??
                            TextStrings.locationPromptDialogDescription,
                        style: CustomTextStyles().grey16,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      loading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : CustomButton(
                              onTap: () async {
                                setState(() {
                                  loading = true;
                                });

                                if (widget.isShareLocationData) {
                                  // await updateShareLocation();
                                } else if (widget.isRequestLocationData) {
                                  // await updateRequestLocation();
                                } else {
                                  await Provider.of<LocationProvider>(context,
                                          listen: false)
                                      .updateLocationSharingKey(true);
                                }

                                if (mounted) {
                                  setState(() {
                                    loading = false;
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                              bgColor: Theme.of(context).primaryColor,
                              width: 164.toWidth,
                              height: 48.toHeight,
                              child: Text(
                                widget.yesText ?? TextStrings.yesTurnItOn,
                                style: TextStyle(
                                    fontSize: 15.toFont,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                              ),
                            ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          if (widget.isShareLocationData) {
                            // CustomToast().show('Update cancelled', context);
                          } else if (widget.isRequestLocationData) {
                            // CustomToast().show('Prompt cancelled', context);
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.noText ?? TextStrings.no,
                          style: CustomTextStyles().black14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // updateShareLocation() async {
  //   var update = await LocationSharingService()
  //       .updateWithShareLocationAcknowledge(widget.locationNotificationModel,
  //           rePrompt: widget.locationNotificationModel.rePrompt);

  //   if (update is bool) {
  //     CustomToast().show('Share Location Request sent', context);
  //   } else {
  //     CustomToast()
  //         .show('Something went wrong!  ${update.toString()}', context);
  //   }
  // }

  // updateRequestLocation() async {
  //   var update = await RequestLocationService()
  //       .updateWithRequestLocationAcknowledge(widget.locationNotificationModel,
  //           rePrompt: widget.locationNotificationModel.rePrompt);

  //   if (update is bool) {
  //     CustomToast().show('Prompted again', context);
  //   } else {
  //     CustomToast().show('Something went wrong! ${update.toString()}', context);
  //   }
  // }
}
