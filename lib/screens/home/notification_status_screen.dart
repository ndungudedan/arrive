import 'package:at_client/at_client.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

import '../../utils/constants/text_strings.dart';
import '../../utils/constants/text_styles.dart';

class NotificationStatusScreen extends StatefulWidget {
  @override
  State<NotificationStatusScreen> createState() =>
      _NotificationStatusScreenState();
}

class _NotificationStatusScreenState extends State<NotificationStatusScreen> {
  String _currentAtsign;
  final storyController = StoryController();

  @override
  void initState() {
    _currentAtsign = AtClientManager.getInstance().atClient.getCurrentAtSign();

    super.initState();
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
        key: UniqueKey(),
        builder: (context, locationProvider, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  )),
              title: Row(
                children: [
                  ContactInitial(initials: _currentAtsign),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    _currentAtsign ?? TextStrings.atSign,
                    style: CustomTextStyles().white15,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            body: StoryView(
              onStoryShow: (s) {
                print('Showing a story');
              },
              onComplete: () {
                print('Completed a cycle');
                Navigator.pop(context);
              },
              progressPosition: ProgressPosition.top,
              repeat: false,
              controller: storyController,
              storyItems: List.generate(
                  locationProvider.allLocationNotifications.length, (index) {
                return StoryItem.pageProviderImage(MemoryImage(
                  locationProvider.allLocationNotifications
                      .elementAt(index)
                      .locationKeyModel
                      .locationNotificationModel
                      .imageData,
                ));
              }),
            ),
          );
        });
  }
}
