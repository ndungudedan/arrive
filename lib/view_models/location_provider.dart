import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/services/event_location_share.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:atsign_location_app/common_components/dialog_box/location_prompt_dialog.dart';
import 'package:atsign_location_app/data_services/hive/hive_db.dart';
import 'package:atsign_location_app/models/event_and_location.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:atsign_location_app/view_models/base_model.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart'
    as newKeyLocationmodel;
import 'package:flutter/material.dart';
import 'package:at_location_flutter/service/send_location_notification.dart'
    as PackageSendLocationNotification;

class LocationProvider extends BaseModel {
  LocationProvider();
  List<EventAndLocationHybrid> allNotifications = [];
  List<newKeyLocationmodel.KeyLocationModel> allLocationNotifications = [];
  List<EventKeyLocationModel> allEventNotifications = [];
  final HiveDataProvider _hiveDataProvider = HiveDataProvider();
  bool isSharing = false;
  // ignore: non_constant_identifier_names
  String GET_ALL_NOTIFICATIONS = 'get_all_notifications';

  void init(AtClientImpl atClient, String activeAtSign,
      GlobalKey<NavigatorState> navKey) {
    initialiseLocationSharing();
    initialiseEventService(atClient, navKey,
        mapKey: MixedConstants.MAP_KEY,
        apiKey: MixedConstants.API_KEY,
        rootDomain: MixedConstants.ROOT_DOMAIN,
        streamAlternative: updateEvents,
        initLocation: false);

    /// If we initialise location before events then it will take values from events location package
    initializeLocationService(
      atClient, activeAtSign, navKey,
      mapKey: MixedConstants.MAP_KEY,
      apiKey: MixedConstants.API_KEY,
      // getAtValue: LocationNotificationListener().getAtValue
      showDialogBox: true,
      streamAlternative: notificationUpdate,
    );

    SendLocationNotification().setLocationPrompt(() async {
      await locationPromptDialog(
        isShareLocationData: false,
        isRequestLocationData: false,
      );
    });
    EventLocationShare().setLocationPrompt(() async {
      await locationPromptDialog(
        isShareLocationData: false,
        isRequestLocationData: false,
      );
    });

    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }

  // ignore: always_declare_return_types
  notificationUpdate(List<newKeyLocationmodel.KeyLocationModel> list) {
    print('notificationUpdate');

    allLocationNotifications = list;
    updateAllNotification(locationsList: allLocationNotifications);

    // setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }

  updateEvents(List<EventKeyLocationModel> list) {
    print('notificationUpdate');

    allEventNotifications = list;
    updateAllNotification(eventsList: allEventNotifications);

    // setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }

  updateAllNotification(
      {List<newKeyLocationmodel.KeyLocationModel> locationsList,
      List<EventKeyLocationModel> eventsList}) {
    allNotifications = [];

    if (locationsList != null) {
      locationsList.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.LocationModel,
            locationKeyModel: element);

        allNotifications.add(_obj);
      });
    } else {
      allLocationNotifications.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.LocationModel,
            locationKeyModel: element);

        allNotifications.add(_obj);
      });
    }

    if (eventsList != null) {
      eventsList.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.EventModel,
            eventKeyModel: element);

        allNotifications.add(_obj);
      });
    } else {
      allEventNotifications.forEach((element) {
        var _obj = EventAndLocationHybrid(NotificationModelType.EventModel,
            eventKeyModel: element);

        allNotifications.add(_obj);
      });
    }

    setStatus(GET_ALL_NOTIFICATIONS, Status.Done);
  }

  Future<void> initialiseLocationSharing() async {
    isSharing = await getShareLocation();
    PackageSendLocationNotification.SendLocationNotification()
        .setMasterSwitchState(isSharing);
    EventLocationShare().setMasterSwitchState(isSharing);
    notifyListeners();
  }

  Future<void> updateShareLocation(bool value) async {
    await _hiveDataProvider.insertData(
      'Sharing',
      {'isSharing': value.toString()},
    );

    isSharing = value;

    PackageSendLocationNotification.SendLocationNotification()
        .setMasterSwitchState(value);
    EventLocationShare().setMasterSwitchState(value);

    notifyListeners();
  }

  Future<bool> getShareLocation() async {
    var data = await _hiveDataProvider.readData('Sharing');
    return (data['isSharing'] == 'true') ? true : false;
  }
}
