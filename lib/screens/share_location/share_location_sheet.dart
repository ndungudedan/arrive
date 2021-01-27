import 'package:at_contact/at_contact.dart';
import 'package:atsign_contacts/screens/contacts_screen.dart';
import 'package:atsign_contacts_group/widgets/custom_toast.dart';
import 'package:atsign_events/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/services/notification_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_common/services/size_config.dart';
import 'package:provider/provider.dart';
import 'package:atsign_events/models/hybrid_notifiation_model.dart';

class ShareLocationSheet extends StatefulWidget {
  @override
  _ShareLocationSheetState createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  AtContact selectedContact;
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.5,
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomAppBar(
            centerTitle: false,
            title: 'Share Location',
            action: PopButton(label: 'Cancel'),
          ),
          SizedBox(
            height: 25,
          ),
          Text('Share with', style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          CustomInputField(
            width: 330.toWidth,
            height: 50,
            //isReadOnly: true,
            hintText: 'Type @sign or search from contact',
            icon: Icons.contacts_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactsScreen(
                    asSelectionScreen: true,
                    context: context,
                    selectedList: (selectedList) {
                      print(selectedList);
                      setState(() {
                        selectedContact = selectedList[0];
                      });
                    },
                  ),
                ),
              );
            },
          ),
          (selectedContact != null)
              ? (OverlappingContacts(selectedList: [selectedContact]))
              : SizedBox(),
          SizedBox(height: 25),
          Text(
            'Duration',
            style: CustomTextStyles().greyLabel14,
          ),
          SizedBox(height: 10),
          CustomInputField(
              width: 330,
              height: 50,
              hintText: 'Select Duration',
              icon: Icons.keyboard_arrow_down),
          Expanded(child: SizedBox()),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    child: Text('Share',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor)),
                    onTap: onShareTap,
                    bgColor: Theme.of(context).primaryColor,
                    width: 164,
                    height: 48,
                  ),
          ),
        ],
      ),
    );
  }

  onShareTap() async {
    setState(() {
      isLoading = true;
    });

    var result = await LocationSharingService()
        .sendShareLocationEvent(selectedContact.atSign, false);

    if (result[0] == true) {
      CustomToast().show('Share Location Request sent', context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      providerCallback<HybridProvider>(NavService.navKey.currentContext,
          task: (provider) => provider.addNewEvent(HybridNotificationModel(
              NotificationType.Location,
              locationNotificationModel: result[1])),
          taskName: (provider) => provider.HYBRID_ADD_EVENT,
          showLoader: false,
          onSuccess: (provider) {});
    } else {
      CustomToast().show('some thing went wrong , try again.', context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
