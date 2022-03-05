import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShareLocationSheet extends StatefulWidget {
  @override
  _ShareLocationSheetState createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  List<AtContact> selectedContacts = [];
  Uint8List imageData;
  bool isLoading;
  String selectedOption;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: EdgeInsets.all(25),
      child: ListView(
        children: [
          CustomAppBar(
            centerTitle: false,
            title: TextStrings.shareLocation,
            action: PopButton(label: TextStrings.cancel),
          ),
          SizedBox(
            height: 25,
          ),
          Text(TextStrings.shareWith, style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          CustomInputField(
            width: SizeConfig().screenWidth * 0.95,
            height: 50.toFont,
            isReadOnly: true,
            hintText: TextStrings.searchAtsignFromContact,
            icon: Icons.contacts_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupContactView(
                    asSelectionScreen: true,
                    showGroups: true,
                    showContacts: true,
                    selectedList: (s) {
                      setState(() {
                        if (s.isEmpty) {
                          selectedContacts = [];
                        } else {
                          selectedContacts = [];
                          s.forEach((_groupElement) {
                            // for contacts
                            if (_groupElement.contact != null) {
                              var _containsContact = false;

                              // to prevent one contact from getting added again
                              selectedContacts.forEach((_contact) {
                                if (_groupElement.contact.atSign ==
                                    _contact.atSign) {
                                  _containsContact = true;
                                }
                              });

                              if (!_containsContact) {
                                selectedContacts.add(_groupElement.contact);
                              }
                            } else if (_groupElement.group != null) {
                              // for groups
                              _groupElement.group.members.forEach((element) {
                                var _containsContact = false;

                                // to prevent one contact from getting added again
                                selectedContacts.forEach((_contact) {
                                  if (element.atSign == _contact.atSign) {
                                    _containsContact = true;
                                  }
                                });

                                if (!_containsContact) {
                                  selectedContacts.add(element);
                                }
                              });
                            }
                          });
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
          (selectedContacts.isNotEmpty)
              ? (OverlappingContacts(
                  selectedContacts,
                  onRemove: (_index) {
                    setState(() {
                      selectedContacts.removeAt(_index);
                    });
                  },
                ))
              : SizedBox(),
          SizedBox(height: 25),
          Text(
            TextStrings.duration,
            style: CustomTextStyles().greyLabel14,
          ),
          SizedBox(height: 10),
          Container(
            color: AllColors().INPUT_GREY_BACKGROUND,
            width: SizeConfig().screenWidth * 0.95,
            height: 50.toFont,
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: DropdownButton(
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down),
              underline: SizedBox(),
              elevation: 0,
              dropdownColor: AllColors().INPUT_GREY_BACKGROUND,
              value: selectedOption,
              hint: Text(TextStrings.selectDuration,
                  style: TextStyle(
                      color: AllColors().LIGHT_GREY_LABEL,
                      fontSize: 15.toFont)),
              style:
                  TextStyle(color: AllColors().DARK_GREY, fontSize: 13.toFont),
              items: [
                TextStrings.selectDuration,
                TextStrings.k30mins,
                TextStrings.k2hours,
                TextStrings.k24hours,
                TextStrings.untilTurnedOff
              ].map((String option) {
                return DropdownMenuItem<String>(
                  value: option == TextStrings.selectDuration ? null : option,
                  child:
                      // option == 'Select Duration'
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Text(option,
                      //               style: TextStyle(
                      //                   color: AllColors().LIGHT_GREY_LABEL,
                      //                   fontSize: 15.toFont)),
                      //           Icon(Icons.keyboard_arrow_up)
                      //         ],
                      //       )
                      //     :
                      Text(option,
                          style: TextStyle(
                              color: AllColors().DARK_GREY,
                              fontSize: 13.toFont)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
          ),
          // Expanded(child: SizedBox()),
          TextButton(
              onPressed: () async {
                final _picker = ImagePicker();
                // Pick an image
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);

                imageData = await image.readAsBytes();
                //sendFile(selectedContacts[0].atSign, image.path);
              },
              child: Text('Pick Image')),
          SizedBox(
            height: 100,
          ),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    onTap: onShareTap,
                    bgColor: Theme.of(context).primaryColor,
                    width: 164,
                    height: 48,
                    child: Text(TextStrings.share,
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 16.toFont)),
                  ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, Object>> sendFile(String atSign, String filePath) async {
    if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    print('Sending file => $atSign $filePath');
    var response = {'status': false, 'msg': ''};

    var result = await BackendService.getInstance()
        .atClientServiceInstance
        .atClientManager
        .atClient
        .stream(atSign, filePath);
    print('sendfile result => $result');
    if (result.status.toString() == 'AtStreamStatus.COMPLETE') {
      response['status'] = true;
      response['msg'] = 'completed';
      return response;
    } else if (result.status.toString() == 'AtStreamStatus.NO_ACK') {
      response['status'] = false;
      response['msg'] = 'no_ack';
      return response;
    } else {
      response['status'] = false;
      response['msg'] = 'unknown';
      return response;
    }
  }

  // ignore: always_declare_return_types
  onShareTap() async {
    if (selectedContacts == null) {
      CustomToast().show(TextStrings.selectAContact, context, isError: true);
      return;
    }
    if (selectedOption == null) {
      CustomToast().show(TextStrings.selectTime, context, isError: true);
      return;
    }

    var minutes = (selectedOption == '30 mins'
        ? 30
        : (selectedOption == '2 hours'
            ? (2 * 60)
            : (selectedOption == '24 hours' ? (24 * 60) : null)));
    setState(() {
      isLoading = true;
    });

    var result;
    if (selectedContacts.length > 1) {
      await SharingLocationService()
          .sendShareLocationToGroup(selectedContacts, minutes: minutes);
    } else {
      if (imageData != null) {
        result = await sendSharePhotoLocationNotification(
            selectedContacts[0].atSign, minutes, imageData);
      } else {
        result = await sendShareLocationNotification(
            selectedContacts[0].atSign, minutes);
      }
    }

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast()
          .show(TextStrings.shareLocationRequestSent, context, isSuccess: true);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast()
          .show(TextStrings.somethingWentWrong, context, isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }
}
