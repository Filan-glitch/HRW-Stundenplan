import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'price.dart';

enum Diet {
  FISH,
  VEGAN,
  VEGETARIAN,
  POULTRY,
  BEEF,
  PIG,
}

class Meal {
  String? id;
  String? name;
  String? category;
  String? description;
  List<Price>? prices;
  String? pictureUrl;
  String? nutriscore;
  List<Diet>? diets;
  List<String>? additives;
  List<String>? allergens;

  static String additiveToString(String additive) {
    switch (additive) {
      case 'PHOSPHATE':
        return 'Phosphate';
      case 'ANTIOXIDANT':
        return 'Antioxidantien';
      case 'PRESERVATIVE':
        return 'Konservierungsstoffe';
      case 'SWEETENER':
        return 'Süßungsmittel';
      case 'FOOD_DYE':
        return 'Farbstoffe';
      case 'WAXED':
        return 'Gewachst';
      case 'BLACKENED':
        return 'Geschwärzt';
      case 'SULPHURATED':
        return 'Schwefel';
      default:
        FirebaseCrashlytics.instance.recordError(
          Exception('Unknown additive: $additive'),
          StackTrace.current,
        );
        return additive.toLowerCase();
    }
  }

  static String allergeneToString(String allergene) {
    switch (allergene) {
      case 'WHEAT':
        return 'Weizen';
      case 'FISH':
        return 'Fisch';
      case 'MILK':
        return 'Milch';
      case 'BARLEY':
        return 'Gerste';
      case 'SOYBEAN':
        return 'Sojabohnen';
      case 'CELERY':
        return 'Sellerie';
      case 'EGGS':
        return 'Eier';
      case 'MUSTARD':
        return 'Senf';
      case 'SULFURDIOXIDE':
        return 'Schwefeldioxid und Sulfite';
      case 'CRUSTACEANS':
        return 'Krebstiere';
      case 'WALNUTS':
        return 'Walnüsse';
      case 'OAT':
        return 'Hafer';
      case 'SESAMESEEDS':
        return 'Sesamsamen';
      case 'ALMONDS':
        return 'Mandeln';
      case 'PISTACHIOS':
        return 'Pistazien';
      case 'PEANUT':
        return 'Erdnüsse';
      case 'CASHEWS':
        return 'Cashewnüsse';
      case 'SPELT':
        return 'Dinkel';
      default:
        FirebaseCrashlytics.instance.recordError(
          Exception('Unknown allergene: $allergene'),
          StackTrace.current,
        );
        return allergene.toLowerCase();
    }
  }

  Meal(Map<String, dynamic> json) {
    id = json['id'];
    name = (json['name'] as String).replaceAll('&quot;', '\"');
    category = json['category'];
    description = json['description'];
    if (json['prices'] != null) {
      prices = [];
      json['prices'].forEach((v) {
        prices!.add(Price(v));
      });
    }
    pictureUrl = json['pictureUrl'];
    nutriscore = json['nutriscore'];
    if (json['additives'] != null) {
      additives = [];
      json['additives'].forEach((v) {
        additives!.add(v);
      });
    }
    if (json['allergens'] != null) {
      allergens = [];
      json['allergens'].forEach((v) {
        allergens!.add(v);
      });
    }

    if (json['diet'] != null) {
      diets = [];
      json['diet'].forEach((v) {
        switch (v) {
          case 'FISH':
            diets!.add(Diet.FISH);
            break;
          case 'VEGAN':
            diets!.add(Diet.VEGAN);
            break;
          case 'VEGETARIAN':
            diets!.add(Diet.VEGETARIAN);
            break;
          case 'POULTRY':
            diets!.add(Diet.POULTRY);
            break;
          case 'BEEF':
            diets!.add(Diet.BEEF);
            break;
          case 'PIG':
            diets!.add(Diet.PIG);
            break;
        }
      });
    }
  }
}
