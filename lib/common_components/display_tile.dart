import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_location_flutter/common_components/contacts_initial.dart';
import 'package:atsign_location_app/screens/contacts/add_contact.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_common_flutter/services/size_config.dart';

class DisplayTile extends StatefulWidget {
  final String title, semiTitle, subTitle, atsignCreator, invitedBy;
  final int number;
  final Widget action;
  final bool showName, showRetry;
  final Function onRetryTapped;
  DisplayTile(
      {Key key,
      @required this.title,
      this.atsignCreator,
      @required this.subTitle,
      this.semiTitle,
      this.invitedBy,
      this.number,
      this.showName = false,
      this.action,
      this.showRetry = false,
      this.onRetryTapped})
      : super(key: key);

  @override
  _DisplayTileState createState() => _DisplayTileState();
}

class _DisplayTileState extends State<DisplayTile> {
  Uint8List image;
  AtContact contact;
  AtContactsImpl atContact;
  String name;
  @override
  void initState() {
    super.initState();
    getEventCreator();
  }

  // ignore: always_declare_return_types
  getEventCreator() async {
    var contact = await getAtSignDetails(widget.atsignCreator);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        if (mounted) {
          setState(() {
            image = Uint8List.fromList(intList);
            if (widget.showName) name = contact.tags['name'].toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 15, 10.5),
      child: Row(
        children: [
          GestureDetector(
            onTap: ((widget.atsignCreator != null) &&
                    (widget.atsignCreator !=
                        AtClientManager.getInstance()
                            .atClient
                            .getCurrentAtSign()) &&
                    (ContactService().contactList.indexWhere((element) =>
                            element.atSign == widget.atsignCreator) ==
                        -1))
                ? () async {
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AddContact(
                          atSignName: widget.atsignCreator,
                          image: image,
                          name: name,
                          onSuccessCallback: () {
                            setState(() {});
                          },
                        );
                      },
                    );
                  }
                : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                (image != null)
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(30.toFont)),
                        child: Image.memory(
                          image,
                          width: 50.toFont,
                          height: 50.toFont,
                          fit: BoxFit.fill,
                        ),
                      )
                    : widget.atsignCreator != null
                        ? ContactInitial(initials: widget.atsignCreator)
                        : SizedBox(),
                widget.number != null
                    ? Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          alignment: Alignment.center,
                          height: 28.toFont,
                          width: 28.toFont,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0.toFont),
                              color: AllColors().BLUE),
                          child: Text(
                            '+${widget.number}',
                            style: CustomTextStyles().black10,
                          ),
                        ),
                      )
                    : SizedBox(),
                ((widget.atsignCreator != null) &&
                        (widget.atsignCreator !=
                            AtClientManager.getInstance()
                                .atClient
                                .getCurrentAtSign()) &&
                        (ContactService().contactList.indexWhere((element) =>
                                element.atSign == widget.atsignCreator) ==
                            -1))
                    ? Positioned(
                        right: -5,
                        top: -10,
                        child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(Icons.person_add)))
                    : SizedBox()
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Column(
                mainAxisAlignment: (widget.subTitle == null)
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? widget.title,
                    style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline3.color,
                        fontSize: 14.toFont),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  widget.semiTitle != null
                      ? Text(
                          widget.semiTitle,
                          style: (widget.semiTitle == TextStrings.actionRequired ||
                                      widget.semiTitle == TextStrings.requestDeclined ) ||
                                  (widget.semiTitle == TextStrings.cancelled ||
                                      (widget.semiTitle == TextStrings.requestRejected))
                              ? CustomTextStyles().orange12
                              : CustomTextStyles().darkGrey12,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 3,
                  ),
                  (widget.subTitle != null)
                      ? Text(
                          widget.subTitle,
                          style: CustomTextStyles().darkGrey12,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox(),
                  widget.invitedBy != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(widget.invitedBy,
                              style: CustomTextStyles().grey14),
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
          widget.showRetry
              ? InkWell(
                  onTap: widget.onRetryTapped,
                  child: Text(
                    TextStrings.retry,
                    style: TextStyle(
                        color: AllColors().ORANGE, fontSize: 14.toFont),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : SizedBox(),
          widget.action ?? SizedBox(),
        ],
      ),
    );
  }
}
