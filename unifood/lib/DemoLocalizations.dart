// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';


// #docregion Demo
class DemoLocalizations {
  DemoLocalizations(this.locale);

  final Locale locale;

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations)!;
  }


  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'title': 'Hello World',
      "groceryList": "Grocery List",
      "grocery": "Groceries",
      "quantity": "Quantity",
      "summary": "Summary",
      "totalNutrition": "Total Nutrition",
      "calories": "Calories",
      "fat": "Fat",
      "protein": "Protein",
      "carbs": "Carbs",
      "search": "Search",
      "servings": "serving(s)",
      "map": "Map",
      "mapSearch": "Search Grocery Stores (include city name)",
      "reviews": "Reviews",

      "finishTitle": "Purchase complete?",
      "finishDescription": "Are you done with your purchase and would like to remove the selected items from the list?",
      "yes": "Yes",

      "pantry": "Pantry",
      "pantryPage": "My Pantry",

      "profile": "Profile",
      "userProfile": "User Profile",
      "emailVerifiedFalse": "Email is not verified",
      "dismiss": "Dismiss",
      "sendEmailVer": "Send verification email",
      "signInMethods": "Sign-in methods",
      "moreSignIn": "Enable more sign-in methods",
      "signOut": "Sign Out",
      "deleteAccount": "Delete account",

      "deleteWarning": "Select which item(s) to delete.",
      "addWarning": "Fill all the fields.",

      "alreadyInPantry" : "Some item(s) are already in your pantry.",
      "complete": "Complete",
      "emptyList": "Please add items into the list to see summary.",
      "alreadyInGrocery" : "This item is already in your grocery list.",
      "emptyComplete": "Check items before completing them.",

      // -------------------------Pantry Page and Sign in page----------------------------
      "item": "Item",
      "removed": "removed",
      "undo": "Undo",
      "addItem": "Add Item",
      "itemName": "Item Name",
      "cancel": "Cancel",
      "add": "Add",
      "signin": "Welcome to UniFood, please sign in to continue!",
      "signup": "Welcome to UniFood, please sign up to continue!",
      "termsAndConditions": "By signing in, you agree to ours, Google''s, Firebase''s and Flutter''s terms and conditions.",
      "uniFood": "Uni Food",
      "scheduledNoti": "Scheduled Expiry Notification",
      "expires": "will expire on",

      // -------------------------Map, Reviews and Reviews Form page----------------------------
      "noReviews": "No reviews",
      "locServDis": "Location services are disabled.",
      "locDen": "Location permissions are denied",
      "locPermDen": "Location permissions are permanently denied, we cannot request permissions.",
      "revPosted": "Review posted",
      "all": "All",
      "somErr": "Something went wrong",
      "loading": "Loading",
      "rating": "Rating",
      "addReview": "Add Review",
      "frequency": "Frequency",
      "newReview": "New Review",
      "comment": "Comment",
      "currLen": "Current length",
      "error": "Error",
      "ok": "OK",
      "submit": "Submit",
      "commTooLong": "The comment is too long and should be within 300 characters.",
      "selectRatingComment": "Please select a rating and add a comment.",
      "chooseRating": "Please choose a rating.",
      "addComment": "Please add a comment.",
      "howTo": "How to use the app",
      "description": "1. Search up a grocery store using the search bar (include the city name) or view the default grocery stores in the Oshawa area. "
          "\n\n2. Adjust the km radius as you wish using the options button next to the search bar to see only the grocery stores in the specified area. "
          "\n\n3. View or add reviews for each specific store. You can filter reviews by rating. "
          "\n\n4. Add items to your pantry and grocery list."
          "\n\n5. Check the nutritional summary of your grocery list. "
          "\n\n6. Add expiry notifications for the items in your pantry.",
      "permDenied": "Notification Permissions Denied",
      "permDenExp": "Since notification permissions are denied, you will not be able to use the expiry date notification feature. "
          "\n\nPlease enable notifications for this app in your device settings.",
    },
    'es': { // ----------------------------------------------ES-------------------------------------
      'title': 'Hola Mundo',
      "groceryList": "Lista de Compra",
      "grocery": "Compras",
      "quantity": "Cantidad",
      "summary": "Resumen",
      "totalNutrition": "Nutrición Total",
      "calories": "Calorías",
      "fat": "Grasa",
      "protein": "Proteínas",
      "carbs": "Carbohidratos",
      "search": "Buscar",
      "servings": "porcion(es)",

      "map": "Mapa",
      "mapSearch": "Busca mercados (incluye nombre de ciudad)",
      "reviews": "Reseñas",

      "pantry": "Despensa",
      "pantryPage": "Mi Despensa",

      "profile": "Perfil",
      "userProfile": "Perfil de Usuario",
      "emailVerifiedFalse": "Su correo no está verificado",
      "dismiss": "Ignorar",
      "sendEmailVer": "Enviar correo de verificación",
      "signInMethods": "Métodos de registro",
      "moreSignIn": "Más metodos de registro",
      "signOut": "Cerrar sesión",
      "deleteAccount": "Eliminar Cuenta",

      "deleteWarning": "Seleccione que objeto(s) eliminar.",
      "addWarning": "Rellene todos los campos.",

      "finishTitle": "Compra completada?",
      "finishDescription": "Terminó la compra y desea remover los productos selectos de la lista?",
      "yes": "Si",

      "alreadyInPantry" : "Algunos producto(s) ya están en su despensa.",
      "complete": "Completar",
      "emptyList": "Porfavor añada productos a la lista para ver la información nutricional.",
      "alreadyInGrocery" : "Este producto ya se encuentra en su lista de compra.",
      "emptyComplete": "Marque productos ya completados antes de completar la compra.",


      // -------------------------Pantry page----------------------------
      "item": "Producto",
      "removed": "removido",
      "undo": "deshacer",
      "addItem": "Añadir Producto",
      "itemName": "Nombre de Producto",
      "cancel": "Cancelar",
      "add": "Añadir",
      "signin": "Bienvenidos a UniFood, porfavor registrate para continuar.",
      "signup": "Bienvenidos a UniFood, porfavor registrate para continuar.",
      "termsAndConditions": "Al registrarte, aceptas los términos y condiciones de Google, Firebase y Flutter.",
      "uniFood": "Uni Food",
      "scheduledNoti": "Producto Expirado!",
      "expires": "Se expira en ",
      // -------------------------Map, Reviews and Reviews Form page----------------------------

      "noReviews": "No hay reseñas.",
      "locServDis": "Servicio de ubicación está desactivado.",
      "locDen": "Permisos de ubicación rechazados.",
      "locPermDen": "Permisos de ubicación están permanentemente desactivados, no podemos solicitar los permisos.",
      "revPosted": "Reseña publicada",
      "all": "Todos",
      "somErr": "Hubo algún error",
      "loading": "Cargando",
      "rating": "Calificación",
      "addReview": "Añadir Reseña",
      "frequency": "Frequencia",
      "newReview": "Nueva Reseña",
      "comment": "Comentario",
      "currLen": "Tamaño actual",
      "error": "Error",
      "ok": "OK",
      "submit": "Enviar",
      "commTooLong": "El comentario es más de 300 carácteres.",
      "selectRatingComment": "Porfavor seleccione una calicifación y añada un comentario.",
      "chooseRating": "Porfavor seleccione una calificación.",
      "addComment": "Porfavor añada un comentario.",
      "howTo": "Como utilizar la aplicación.",
      "description": "1. Busque un mercado usando la barra de búsqueda (incluya el nombre de la ciudad) o por defecto, busque en el área de Oshawa."
          "\n\n2. Ajuste como desee el radio de km utilizando el botón de opciones al lado de la barra de búsqueda, mostrando así, solo las tiendas dentro del radio selecto."
          "\n\n3. Lea o añada reseñas para cada tienda."
          "\n\n4. Añada productos a su despensa o lista de compra."
          "\n\n5. Abra los datos de nutrición de su lista de compra."
          "\n\n6. Programe notificaciones de expiración de cada producto en su despensa.",
      "permDenied": "Permisos de notificación deshabilitados.",
      "permDenExp": "Debido a que los permisos de notificación estan deshabilitados, la notificación de expiración no estará disponible."
          "\n\n Porfavor, habilite las notificaciones para esta aplicación en los ajustes de su dispositivo.",
    },
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String get title => _localizedValues[locale.languageCode]?['title'] ?? "...";
  String get groceryList => _localizedValues[locale.languageCode]?['groceryList'] ?? "...";
  String get grocery => _localizedValues[locale.languageCode]?['grocery'] ?? "...";
  String get itemName => _localizedValues[locale.languageCode]?['itemName'] ?? "...";
  String get quantity => _localizedValues[locale.languageCode]?['quantity'] ?? "...";
  String get summary => _localizedValues[locale.languageCode]?['summary'] ?? "...";
  String get totalNutrition => _localizedValues[locale.languageCode]?['totalNutrition'] ?? "...";
  String get calories => _localizedValues[locale.languageCode]?['calories'] ?? "...";
  String get fat => _localizedValues[locale.languageCode]?['fat'] ?? "...";
  String get protein => _localizedValues[locale.languageCode]?['protein'] ?? "...";
  String get carbs => _localizedValues[locale.languageCode]?['carbs'] ?? "...";
  String get map => _localizedValues[locale.languageCode]?['map'] ?? "...";
  String get mapSearch => _localizedValues[locale.languageCode]?['mapSearch'] ?? "...";
  String get reviews => _localizedValues[locale.languageCode]?['reviews'] ?? "...";
  String get pantry => _localizedValues[locale.languageCode]?['pantry'] ?? "...";
  String get pantryPage => _localizedValues[locale.languageCode]?['pantryPage'] ?? "...";
  String get userProfile => _localizedValues[locale.languageCode]?['userProfile'] ?? "...";
  String get emailVerifiedFalse => _localizedValues[locale.languageCode]?['emailVerifiedFalse'] ?? "...";
  String get dismiss => _localizedValues[locale.languageCode]?['dismiss'] ?? "...";
  String get sendEmailVer => _localizedValues[locale.languageCode]?['sendEmailVer'] ?? "...";
  String get signInMethods => _localizedValues[locale.languageCode]?['signInMethods'] ?? "...";
  String get moreSignIn => _localizedValues[locale.languageCode]?['moreSignIn'] ?? "...";
  String get signOut => _localizedValues[locale.languageCode]?['signOut'] ?? "...";
  String get deleteAccount => _localizedValues[locale.languageCode]?['deleteAccount'] ?? "...";
  String get search => _localizedValues[locale.languageCode]?['search'] ?? "...";
  String get deleteWarning => _localizedValues[locale.languageCode]?['deleteWarning'] ?? "...";
  String get addWarning => _localizedValues[locale.languageCode]?['addWarning'] ?? "...";
  String get servings => _localizedValues[locale.languageCode]?['servings'] ?? "...";
  String get yes => _localizedValues[locale.languageCode]?['yes'] ?? "...";
  String get finishTitle => _localizedValues[locale.languageCode]?['finishTitle'] ?? "...";
  String get finishDescription => _localizedValues[locale.languageCode]?['finishDescription'] ?? "...";
  String get alreadyInPantry => _localizedValues[locale.languageCode]?['alreadyInPantry'] ?? "...";
  String get complete => _localizedValues[locale.languageCode]?['complete'] ?? "...";
  String get emptyList => _localizedValues[locale.languageCode]?['emptyList'] ?? "...";
  String get alreadyInGrocery => _localizedValues[locale.languageCode]?['alreadyInGrocery'] ?? "...";
  String get emptyComplete => _localizedValues[locale.languageCode]?['emptyComplete'] ?? "...";


  //  Pantry Page
  String get item => _localizedValues[locale.languageCode]?['item'] ?? "...";
  String get removed => _localizedValues[locale.languageCode]?['removed'] ?? "...";
  String get undo => _localizedValues[locale.languageCode]?['undo'] ?? "...";
  String get addItem => _localizedValues[locale.languageCode]?['addItem'] ?? "...";
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? "...";
  String get add => _localizedValues[locale.languageCode]?['add'] ?? "...";
  String get signin => _localizedValues[locale.languageCode]?['signin'] ?? "...";
  String get signup => _localizedValues[locale.languageCode]?['signup'] ?? "...";
  String get termsAndConditions => _localizedValues[locale.languageCode]?['termsAndConditions'] ?? "...";
  String get uniFood => _localizedValues[locale.languageCode]?['uniFood'] ?? "...";
  String get scheduledNoti => _localizedValues[locale.languageCode]?['scheduledNoti'] ?? "...";
  String get expires => _localizedValues[locale.languageCode]?['expires'] ?? "...";

  //  Map Page
  String get noReviews => _localizedValues[locale.languageCode]?['noReviews'] ?? "...";
  String get locServDis => _localizedValues[locale.languageCode]?['locServDis'] ?? "...";
  String get locDen => _localizedValues[locale.languageCode]?['locDen'] ?? "...";
  String get locPermDen => _localizedValues[locale.languageCode]?['locPermDen'] ?? "...";
  String get revPosted => _localizedValues[locale.languageCode]?['revPosted'] ?? "...";
  String get all => _localizedValues[locale.languageCode]?['all'] ?? "...";
  String get somErr => _localizedValues[locale.languageCode]?['somErr'] ?? "...";
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? "...";
  String get rating => _localizedValues[locale.languageCode]?['rating'] ?? "...";
  String get addReview => _localizedValues[locale.languageCode]?['addReview'] ?? "...";
  String get frequency => _localizedValues[locale.languageCode]?['frequency'] ?? "...";
  String get newReview => _localizedValues[locale.languageCode]?['newReview'] ?? "...";
  String get comment => _localizedValues[locale.languageCode]?['comment'] ?? "...";
  String get currLen => _localizedValues[locale.languageCode]?['currLen'] ?? "...";
  String get error => _localizedValues[locale.languageCode]?['error'] ?? "...";
  String get ok => _localizedValues[locale.languageCode]?['ok'] ?? "...";
  String get submit => _localizedValues[locale.languageCode]?['submit'] ?? "...";
  String get commTooLong => _localizedValues[locale.languageCode]?['commTooLong'] ?? "...";
  String get selectRatingComment => _localizedValues[locale.languageCode]?['selectRatingComment'] ?? "...";
  String get chooseRating => _localizedValues[locale.languageCode]?['chooseRating'] ?? "...";
  String get addComment => _localizedValues[locale.languageCode]?['addComment'] ?? "...";
  String get howTo => _localizedValues[locale.languageCode]?['howTo'] ?? "...";
  String get description => _localizedValues[locale.languageCode]?['description'] ?? "...";
  String get permDenied => _localizedValues[locale.languageCode]?['permDenied'] ?? "...";
  String get permDenExp => _localizedValues[locale.languageCode]?['permDenExp'] ?? "...";
}
// #enddocregion Demo

// #docregion Delegate
class DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      DemoLocalizations.languages().contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<DemoLocalizations>(DemoLocalizations(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
// #enddocregion Delegate
