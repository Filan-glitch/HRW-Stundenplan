import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timetable/core/toast.dart';
import 'package:timetable/model/graphql/canteens/campus.dart';
import 'package:timetable/model/redux/actions.dart' as redux;
import 'package:timetable/model/redux/store.dart';
import 'package:timetable/service/storage.dart';

Future<void> getCanteenData() async {
  final String? cacheContent = await readMensaCache();
  final http.Response response;
  String responseBody = '';
  bool useCache = false;
  try {
    store.dispatch(redux.startTask());

    response = await http.post(
      Uri.parse('https://campusapp.hs-ruhrwest.de'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 11; SM-T720 Build/RP1A.200720.012; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/121.0.6167.144 Safari/537.36',
        'X-Requested-With': 'nrw.hrw.campusapp',
        'Sec-Ch-Ua-Platform': 'Android',
      },
      body: jsonEncode(
        {
          'operationName': 'Canteens',
          'variables': {
            'isoDates': [
              for (int i = 0; i < 14; i++)
                DateTime.now()
                    .add(Duration(days: i))
                    .toIso8601String()
                    .substring(0, 10)
            ]
          },
          'query': getCanteenDataQuery,
        },
      ),
    );

    if (response.statusCode != 200) {
      store.dispatch(redux.stopTask());
      if (cacheContent != null) {
        responseBody = cacheContent;
        useCache = true;
      } else {
        showErrorToast('Der Speiseplan konnten nicht geladen werden');
        store.dispatch(redux.setCanteenData([]));
        return;
      }
    } else {
      responseBody = response.body;
    }
  } catch (e) {
    store.dispatch(redux.stopTask());
    if (cacheContent != null) {
      responseBody = cacheContent;
      useCache = true;
    } else {
      showErrorToast('Der Speiseplan konnten nicht geladen werden');
      store.dispatch(redux.setCanteenData([]));
      return;
    }
  }

  if (!useCache) {
    await writeMensaCache(responseBody);
  }

  store.dispatch(redux.stopTask());

  final Map<String, dynamic> json = jsonDecode(responseBody);

  if (json['data'] != null && json['data']['campuses'] != null) {
    final List<Campus> campuses = [];
    json['data']['campuses'].forEach((v) {
      campuses.add(Campus(v));
    });

    store.dispatch(redux.setCanteenData(campuses));
  }
}

const String getCanteenDataQuery = r'''
query Canteens($campusIds: [Int], $canteenIds: [Int], $isoDates: [String]) {
    campuses(ids: $campusIds) {
      ... on Campus {
        canteens(ids: $canteenIds) {
          building {
            id
          name
          address {
              id
            street
            houseNumber
            postalCode
            city {
                id
              name
              __typename
            }
            url
            __typename
          }
          directions
          remarks
          url
          __typename
        }
        id
        menus(isoDates: $isoDates) {
            id
          isoDate
          maindishes {
              id
            name
            description
            allergens
            additives
            diet
            prices {
                id
              category
              value
              currency
              __typename
            }
            icon
            nutriscore
            category
            pictureUrl
            __typename
          }
          sidedishes {
              id
            name
            description
            allergens
            additives
            diet
            prices {
                id
              category
              value
              currency
              __typename
            }
            icon
            nutriscore
            category
            pictureUrl
            __typename
          }
          __typename
        }
        name
        generalInfoHtml
        openinghours {
            default {
              validFrom
            validTo
            monday {
                opens
              closes
              __typename
            }
            tuesday {
                opens
              closes
              __typename
            }
            wednesday {
                opens
              closes
              __typename
            }
            thursday {
                opens
              closes
              __typename
            }
            friday {
                opens
              closes
              __typename
            }
            saturday {
                opens
              closes
              __typename
            }
            sunday {
                opens
              closes
              __typename
            }
            __typename
          }
          exceptions {
              date
            times {
                opens
              closes
              __typename
            }
            __typename
          }
          __typename
        }
        order
        __typename
      }
      id
      name
      __typename
    }
    ... on BaseError {
        message
      __typename
    }
    ... on NetworkError {
        message
      __typename
    }
    ... on NotFoundError {
        message
      __typename
    }
    ... on UnknownError {
        message
      __typename
    }
    __typename
  }
}
''';
