import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @searchTextField.
  ///
  /// In en, this message translates to:
  /// **'Search Pokémon'**
  String get searchTextField;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @errorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Bad request. Please try again.'**
  String get errorBadRequest;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access.'**
  String get errorUnauthorized;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnexpected;

  /// No description provided for @errorPokemonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Pokémon not found.'**
  String get errorPokemonNotFound;

  /// No description provided for @errorNetworkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNetworkUnavailable;

  /// No description provided for @errorRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get errorRequestTimeout;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Received an invalid response from the server.'**
  String get errorInvalidResponse;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'A storage error occurred. Please try again.'**
  String get errorStorage;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @useDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLanguage;

  /// No description provided for @useDeviceLanguageInfo.
  ///
  /// In en, this message translates to:
  /// **'If enabled, the app will use your device\'s language.'**
  String get useDeviceLanguageInfo;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @pokemonCry.
  ///
  /// In en, this message translates to:
  /// **'Pokemon Cry'**
  String get pokemonCry;

  /// No description provided for @baseStats.
  ///
  /// In en, this message translates to:
  /// **'Base Stats'**
  String get baseStats;

  /// No description provided for @statHp.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get statHp;

  /// No description provided for @statAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get statAttack;

  /// No description provided for @statDefense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get statDefense;

  /// No description provided for @statSpAtk.
  ///
  /// In en, this message translates to:
  /// **'Sp. Atk'**
  String get statSpAtk;

  /// No description provided for @statSpDef.
  ///
  /// In en, this message translates to:
  /// **'Sp. Def'**
  String get statSpDef;

  /// No description provided for @statSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get statSpeed;

  /// No description provided for @statsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Stats not available'**
  String get statsNotAvailable;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @cacheClearedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheClearedSuccessfully;

  /// No description provided for @tabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tabInfo;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @tabMoves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get tabMoves;

  /// No description provided for @tabItemsGames.
  ///
  /// In en, this message translates to:
  /// **'Items & Games'**
  String get tabItemsGames;

  /// No description provided for @baseExp.
  ///
  /// In en, this message translates to:
  /// **'Base Exp'**
  String get baseExp;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @defaultForm.
  ///
  /// In en, this message translates to:
  /// **'Default Form'**
  String get defaultForm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cries.
  ///
  /// In en, this message translates to:
  /// **'Cries'**
  String get cries;

  /// No description provided for @cryLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get cryLatest;

  /// No description provided for @cryLegacy.
  ///
  /// In en, this message translates to:
  /// **'Legacy'**
  String get cryLegacy;

  /// No description provided for @abilities.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get abilities;

  /// No description provided for @abilityHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get abilityHidden;

  /// No description provided for @movesSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search moves...'**
  String get movesSearchPlaceholder;

  /// No description provided for @movesSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No moves found'**
  String get movesSearchEmpty;

  /// No description provided for @movesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get movesFilterAll;

  /// No description provided for @movesFilterLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get movesFilterLevelUp;

  /// No description provided for @movesFilterMachine.
  ///
  /// In en, this message translates to:
  /// **'TM'**
  String get movesFilterMachine;

  /// No description provided for @movesFilterTutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get movesFilterTutor;

  /// No description provided for @movesFilterEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get movesFilterEgg;

  /// No description provided for @moveBadgeLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level}'**
  String moveBadgeLevel({required int level});

  /// No description provided for @moveBadgeTutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get moveBadgeTutor;

  /// No description provided for @moveDetailPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get moveDetailPower;

  /// No description provided for @moveDetailAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get moveDetailAccuracy;

  /// No description provided for @moveDetailPP.
  ///
  /// In en, this message translates to:
  /// **'PP'**
  String get moveDetailPP;

  /// No description provided for @moveDetailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get moveDetailType;

  /// No description provided for @moveDetailClass.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get moveDetailClass;

  /// No description provided for @moveDetailEffect.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get moveDetailEffect;

  /// No description provided for @damageClassPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get damageClassPhysical;

  /// No description provided for @damageClassSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get damageClassSpecial;

  /// No description provided for @damageClassStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get damageClassStatus;

  /// No description provided for @heldItems.
  ///
  /// In en, this message translates to:
  /// **'Wild Held Items'**
  String get heldItems;

  /// No description provided for @heldItemsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wild items held'**
  String get heldItemsEmpty;

  /// No description provided for @rarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get rarity;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @locationAreaEncounters.
  ///
  /// In en, this message translates to:
  /// **'Location Encounters'**
  String get locationAreaEncounters;

  /// No description provided for @gameIndices.
  ///
  /// In en, this message translates to:
  /// **'Game Versions'**
  String get gameIndices;

  /// No description provided for @spriteToggleShiny.
  ///
  /// In en, this message translates to:
  /// **'Toggle Shiny View'**
  String get spriteToggleShiny;

  /// No description provided for @spriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Sprite Gallery'**
  String get spriteTitle;

  /// No description provided for @galleryArtworkDefault.
  ///
  /// In en, this message translates to:
  /// **'Official artwork'**
  String get galleryArtworkDefault;

  /// No description provided for @galleryArtworkShiny.
  ///
  /// In en, this message translates to:
  /// **'Official artwork (shiny)'**
  String get galleryArtworkShiny;

  /// No description provided for @galleryFrontDefault.
  ///
  /// In en, this message translates to:
  /// **'Front (default)'**
  String get galleryFrontDefault;

  /// No description provided for @galleryBackDefault.
  ///
  /// In en, this message translates to:
  /// **'Back (default)'**
  String get galleryBackDefault;

  /// No description provided for @galleryFrontShiny.
  ///
  /// In en, this message translates to:
  /// **'Front (shiny)'**
  String get galleryFrontShiny;

  /// No description provided for @galleryBackShiny.
  ///
  /// In en, this message translates to:
  /// **'Back (shiny)'**
  String get galleryBackShiny;

  /// No description provided for @galleryFrontFemale.
  ///
  /// In en, this message translates to:
  /// **'Front (female)'**
  String get galleryFrontFemale;

  /// No description provided for @galleryBackFemale.
  ///
  /// In en, this message translates to:
  /// **'Back (female)'**
  String get galleryBackFemale;

  /// No description provided for @galleryFrontShinyFemale.
  ///
  /// In en, this message translates to:
  /// **'Front (shiny, female)'**
  String get galleryFrontShinyFemale;

  /// No description provided for @galleryBackShinyFemale.
  ///
  /// In en, this message translates to:
  /// **'Back (shiny, female)'**
  String get galleryBackShinyFemale;

  /// No description provided for @galleryHomeDefault.
  ///
  /// In en, this message translates to:
  /// **'Home (default)'**
  String get galleryHomeDefault;

  /// No description provided for @galleryHomeFemale.
  ///
  /// In en, this message translates to:
  /// **'Home (female)'**
  String get galleryHomeFemale;

  /// No description provided for @galleryHomeShiny.
  ///
  /// In en, this message translates to:
  /// **'Home (shiny)'**
  String get galleryHomeShiny;

  /// No description provided for @galleryHomeShinyFemale.
  ///
  /// In en, this message translates to:
  /// **'Home (shiny, female)'**
  String get galleryHomeShinyFemale;

  /// No description provided for @statsBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get statsBase;

  /// No description provided for @statsMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get statsMin;

  /// No description provided for @statsMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get statsMax;

  /// No description provided for @gameSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Game:'**
  String get gameSelectorLabel;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @encountersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No encounters found'**
  String get encountersEmpty;

  /// No description provided for @formSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Form & Appearance'**
  String get formSelectorTitle;

  /// No description provided for @formSelectorShiny.
  ///
  /// In en, this message translates to:
  /// **'Shiny Version'**
  String get formSelectorShiny;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @formSelectorForms.
  ///
  /// In en, this message translates to:
  /// **'Available Forms'**
  String get formSelectorForms;

  /// No description provided for @formTypeModifier.
  ///
  /// In en, this message translates to:
  /// **'{type}'**
  String formTypeModifier({required String type});

  /// No description provided for @typeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get typeNormal;

  /// No description provided for @typeFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get typeFire;

  /// No description provided for @typeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get typeWater;

  /// No description provided for @typeGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get typeGrass;

  /// No description provided for @typeElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get typeElectric;

  /// No description provided for @typeIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get typeIce;

  /// No description provided for @typeFighting.
  ///
  /// In en, this message translates to:
  /// **'Fighting'**
  String get typeFighting;

  /// No description provided for @typePoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get typePoison;

  /// No description provided for @typeGround.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get typeGround;

  /// No description provided for @typeFlying.
  ///
  /// In en, this message translates to:
  /// **'Flying'**
  String get typeFlying;

  /// No description provided for @typePsychic.
  ///
  /// In en, this message translates to:
  /// **'Psychic'**
  String get typePsychic;

  /// No description provided for @typeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get typeBug;

  /// No description provided for @typeRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get typeRock;

  /// No description provided for @typeGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost'**
  String get typeGhost;

  /// No description provided for @typeDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get typeDragon;

  /// No description provided for @typeSteel.
  ///
  /// In en, this message translates to:
  /// **'Steel'**
  String get typeSteel;

  /// No description provided for @typeFairy.
  ///
  /// In en, this message translates to:
  /// **'Fairy'**
  String get typeFairy;

  /// No description provided for @typeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get typeDark;

  /// No description provided for @typeStellar.
  ///
  /// In en, this message translates to:
  /// **'Stellar'**
  String get typeStellar;

  /// No description provided for @typeShadow.
  ///
  /// In en, this message translates to:
  /// **'Shadow'**
  String get typeShadow;

  /// No description provided for @typeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get typeUnknown;

  /// No description provided for @gameRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get gameRed;

  /// No description provided for @gameBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get gameBlue;

  /// No description provided for @gameYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get gameYellow;

  /// No description provided for @gameGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gameGold;

  /// No description provided for @gameSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get gameSilver;

  /// No description provided for @gameCrystal.
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get gameCrystal;

  /// No description provided for @gameRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get gameRuby;

  /// No description provided for @gameSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire'**
  String get gameSapphire;

  /// No description provided for @gameEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get gameEmerald;

  /// No description provided for @gameFirered.
  ///
  /// In en, this message translates to:
  /// **'FireRed'**
  String get gameFirered;

  /// No description provided for @gameLeafgreen.
  ///
  /// In en, this message translates to:
  /// **'LeafGreen'**
  String get gameLeafgreen;

  /// No description provided for @gameDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get gameDiamond;

  /// No description provided for @gamePearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get gamePearl;

  /// No description provided for @gamePlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get gamePlatinum;

  /// No description provided for @gameHeartgold.
  ///
  /// In en, this message translates to:
  /// **'HeartGold'**
  String get gameHeartgold;

  /// No description provided for @gameSoulsilver.
  ///
  /// In en, this message translates to:
  /// **'SoulSilver'**
  String get gameSoulsilver;

  /// No description provided for @gameBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get gameBlack;

  /// No description provided for @gameWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get gameWhite;

  /// No description provided for @gameBlack2.
  ///
  /// In en, this message translates to:
  /// **'Black 2'**
  String get gameBlack2;

  /// No description provided for @gameWhite2.
  ///
  /// In en, this message translates to:
  /// **'White 2'**
  String get gameWhite2;

  /// No description provided for @gameX.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get gameX;

  /// No description provided for @gameY.
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get gameY;

  /// No description provided for @gameOmegaRuby.
  ///
  /// In en, this message translates to:
  /// **'Omega Ruby'**
  String get gameOmegaRuby;

  /// No description provided for @gameAlphaSapphire.
  ///
  /// In en, this message translates to:
  /// **'Alpha Sapphire'**
  String get gameAlphaSapphire;

  /// No description provided for @gameSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get gameSun;

  /// No description provided for @gameMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get gameMoon;

  /// No description provided for @gameUltraSun.
  ///
  /// In en, this message translates to:
  /// **'Ultra Sun'**
  String get gameUltraSun;

  /// No description provided for @gameUltraMoon.
  ///
  /// In en, this message translates to:
  /// **'Ultra Moon'**
  String get gameUltraMoon;

  /// No description provided for @gameLetsGoPikachu.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go, Pikachu!'**
  String get gameLetsGoPikachu;

  /// No description provided for @gameLetsGoEevee.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go, Eevee!'**
  String get gameLetsGoEevee;

  /// No description provided for @gameSword.
  ///
  /// In en, this message translates to:
  /// **'Sword'**
  String get gameSword;

  /// No description provided for @gameShield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get gameShield;

  /// No description provided for @gameTheIsleOfArmor.
  ///
  /// In en, this message translates to:
  /// **'The Isle of Armor'**
  String get gameTheIsleOfArmor;

  /// No description provided for @gameTheCrownTundra.
  ///
  /// In en, this message translates to:
  /// **'The Crown Tundra'**
  String get gameTheCrownTundra;

  /// No description provided for @gameLegendsArceus.
  ///
  /// In en, this message translates to:
  /// **'Legends: Arceus'**
  String get gameLegendsArceus;

  /// No description provided for @gameScarlet.
  ///
  /// In en, this message translates to:
  /// **'Scarlet'**
  String get gameScarlet;

  /// No description provided for @gameViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get gameViolet;

  /// No description provided for @gameTheTealMask.
  ///
  /// In en, this message translates to:
  /// **'The Teal Mask'**
  String get gameTheTealMask;

  /// No description provided for @gameTheIndigoDisk.
  ///
  /// In en, this message translates to:
  /// **'The Indigo Disk'**
  String get gameTheIndigoDisk;

  /// No description provided for @gameColosseum.
  ///
  /// In en, this message translates to:
  /// **'Colosseum'**
  String get gameColosseum;

  /// No description provided for @gameXd.
  ///
  /// In en, this message translates to:
  /// **'XD'**
  String get gameXd;

  /// No description provided for @gameGroupRedBlue.
  ///
  /// In en, this message translates to:
  /// **'Red/Blue'**
  String get gameGroupRedBlue;

  /// No description provided for @gameGroupGoldSilver.
  ///
  /// In en, this message translates to:
  /// **'Gold/Silver'**
  String get gameGroupGoldSilver;

  /// No description provided for @gameGroupRubySapphire.
  ///
  /// In en, this message translates to:
  /// **'Ruby/Sapphire'**
  String get gameGroupRubySapphire;

  /// No description provided for @gameGroupFireredLeafgreen.
  ///
  /// In en, this message translates to:
  /// **'FireRed/LeafGreen'**
  String get gameGroupFireredLeafgreen;

  /// No description provided for @gameGroupDiamondPearl.
  ///
  /// In en, this message translates to:
  /// **'Diamond/Pearl'**
  String get gameGroupDiamondPearl;

  /// No description provided for @gameGroupHeartgoldSoulsilver.
  ///
  /// In en, this message translates to:
  /// **'HeartGold/SoulSilver'**
  String get gameGroupHeartgoldSoulsilver;

  /// No description provided for @gameGroupBlackWhite.
  ///
  /// In en, this message translates to:
  /// **'Black/White'**
  String get gameGroupBlackWhite;

  /// No description provided for @gameGroupBlack2White2.
  ///
  /// In en, this message translates to:
  /// **'Black 2/White 2'**
  String get gameGroupBlack2White2;

  /// No description provided for @gameGroupXY.
  ///
  /// In en, this message translates to:
  /// **'X/Y'**
  String get gameGroupXY;

  /// No description provided for @gameGroupOmegaRubyAlphaSapphire.
  ///
  /// In en, this message translates to:
  /// **'Omega Ruby/Alpha Sapphire'**
  String get gameGroupOmegaRubyAlphaSapphire;

  /// No description provided for @gameGroupSunMoon.
  ///
  /// In en, this message translates to:
  /// **'Sun/Moon'**
  String get gameGroupSunMoon;

  /// No description provided for @gameGroupUltraSunUltraMoon.
  ///
  /// In en, this message translates to:
  /// **'Ultra Sun/Ultra Moon'**
  String get gameGroupUltraSunUltraMoon;

  /// No description provided for @gameGroupLetsGoPikachuLetsGoEevee.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go, Pikachu/Eevee'**
  String get gameGroupLetsGoPikachuLetsGoEevee;

  /// No description provided for @gameGroupSwordShield.
  ///
  /// In en, this message translates to:
  /// **'Sword/Shield'**
  String get gameGroupSwordShield;

  /// No description provided for @gameGroupScarletViolet.
  ///
  /// In en, this message translates to:
  /// **'Scarlet/Violet'**
  String get gameGroupScarletViolet;

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Startup Failed'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while initializing app storage. Please try again.'**
  String get startupErrorMessage;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The requested Pokémon or page could not be found.'**
  String get routeNotFoundMessage;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goHome;

  /// No description provided for @editSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Search'**
  String get editSearchButton;

  /// No description provided for @errorEncounters.
  ///
  /// In en, this message translates to:
  /// **'Failed to load encounters.'**
  String get errorEncounters;

  /// No description provided for @errorFormDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load form details.'**
  String get errorFormDetails;

  /// No description provided for @errorMoveDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load move details.'**
  String get errorMoveDetails;

  /// No description provided for @defaultFormRollback.
  ///
  /// In en, this message translates to:
  /// **'Reset to default form'**
  String get defaultFormRollback;

  /// No description provided for @errorSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions.'**
  String get errorSuggestions;

  /// No description provided for @cryPlayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play cry'**
  String get cryPlayTooltip;

  /// No description provided for @cryStopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop cry'**
  String get cryStopTooltip;

  /// No description provided for @cryReplayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Replay cry'**
  String get cryReplayTooltip;

  /// No description provided for @cryLoadingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Loading cry...'**
  String get cryLoadingTooltip;

  /// No description provided for @cryUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cry unavailable. Tap to retry'**
  String get cryUnavailableTooltip;

  /// No description provided for @cryPlayFor.
  ///
  /// In en, this message translates to:
  /// **'Play cry for {pokemon}'**
  String cryPlayFor({required String pokemon});

  /// No description provided for @staleDataNotice.
  ///
  /// In en, this message translates to:
  /// **'Offline cached data'**
  String get staleDataNotice;

  /// No description provided for @browsePokedex.
  ///
  /// In en, this message translates to:
  /// **'Browse Pokédex'**
  String get browsePokedex;

  /// No description provided for @pokedexTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokédex'**
  String get pokedexTitle;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filterCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String filterCount({required int count});

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @generation.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get generation;

  /// No description provided for @generationAll.
  ///
  /// In en, this message translates to:
  /// **'All Generations'**
  String get generationAll;

  /// No description provided for @generationNum.
  ///
  /// In en, this message translates to:
  /// **'Gen {number}'**
  String generationNum({required int number});

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortIdAscending.
  ///
  /// In en, this message translates to:
  /// **'Number: Lowest first'**
  String get sortIdAscending;

  /// No description provided for @sortIdDescending.
  ///
  /// In en, this message translates to:
  /// **'Number: Highest first'**
  String get sortIdDescending;

  /// No description provided for @sortNameAscending.
  ///
  /// In en, this message translates to:
  /// **'Name: A - Z'**
  String get sortNameAscending;

  /// No description provided for @sortNameDescending.
  ///
  /// In en, this message translates to:
  /// **'Name: Z - A'**
  String get sortNameDescending;

  /// No description provided for @randomPokemon.
  ///
  /// In en, this message translates to:
  /// **'Random Pokémon'**
  String get randomPokemon;

  /// No description provided for @noPokemonFound.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon found matching your filters'**
  String get noPokemonFound;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @searchPokedexPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or number...'**
  String get searchPokedexPlaceholder;

  /// No description provided for @offlineIndexNotice.
  ///
  /// In en, this message translates to:
  /// **'Browsing offline cached Pokédex'**
  String get offlineIndexNotice;

  /// No description provided for @forms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get forms;

  /// No description provided for @formFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All Forms'**
  String get formFilterAll;

  /// No description provided for @formFilterCanonicalOnly.
  ///
  /// In en, this message translates to:
  /// **'Canonical Only'**
  String get formFilterCanonicalOnly;

  /// No description provided for @formFilterMega.
  ///
  /// In en, this message translates to:
  /// **'Mega Evolutions'**
  String get formFilterMega;

  /// No description provided for @formFilterRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional Forms'**
  String get formFilterRegional;

  /// No description provided for @formFilterGmax.
  ///
  /// In en, this message translates to:
  /// **'Gigantamax'**
  String get formFilterGmax;

  /// No description provided for @includeCosmeticForms.
  ///
  /// In en, this message translates to:
  /// **'Include cosmetic & costume forms'**
  String get includeCosmeticForms;

  /// No description provided for @formBadgeMegaIndicator.
  ///
  /// In en, this message translates to:
  /// **'⚡ Mega'**
  String get formBadgeMegaIndicator;

  /// No description provided for @formBadgeRegionalIndicator.
  ///
  /// In en, this message translates to:
  /// **'🌍 Regional'**
  String get formBadgeRegionalIndicator;

  /// No description provided for @formBadgeGmaxIndicator.
  ///
  /// In en, this message translates to:
  /// **'💥 G-Max'**
  String get formBadgeGmaxIndicator;

  /// No description provided for @formBadgeFormsIndicator.
  ///
  /// In en, this message translates to:
  /// **'✨ Forms'**
  String get formBadgeFormsIndicator;

  /// No description provided for @hasAlternateFormsSemantics.
  ///
  /// In en, this message translates to:
  /// **'alternate forms available'**
  String get hasAlternateFormsSemantics;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any Pokémon to add it to your favorites.'**
  String get favoritesEmptyMessage;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @removeFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get removeFromHistory;

  /// No description provided for @sortRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get sortRecentlyAdded;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get recentlyViewed;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your search and viewing history?'**
  String get clearHistoryConfirmation;

  /// No description provided for @historyEnabled.
  ///
  /// In en, this message translates to:
  /// **'Keep history'**
  String get historyEnabled;

  /// No description provided for @historyEnabledInfo.
  ///
  /// In en, this message translates to:
  /// **'Record recently viewed Pokémon and searches.'**
  String get historyEnabledInfo;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @unitSystem.
  ///
  /// In en, this message translates to:
  /// **'Measurement Units'**
  String get unitSystem;

  /// No description provided for @unitSystemMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (m, kg)'**
  String get unitSystemMetric;

  /// No description provided for @unitSystemImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (ft, lbs)'**
  String get unitSystemImperial;

  /// No description provided for @audioSettings.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioSettings;

  /// No description provided for @autoPlayCry.
  ///
  /// In en, this message translates to:
  /// **'Auto-play cry on open'**
  String get autoPlayCry;

  /// No description provided for @autoPlayCryInfo.
  ///
  /// In en, this message translates to:
  /// **'Automatically play the Pokémon\'s cry when opening the details screen.'**
  String get autoPlayCryInfo;

  /// No description provided for @cryVolume.
  ///
  /// In en, this message translates to:
  /// **'Cry Volume'**
  String get cryVolume;

  /// No description provided for @storageAndCache.
  ///
  /// In en, this message translates to:
  /// **'Storage & Cache'**
  String get storageAndCache;

  /// No description provided for @cacheSize.
  ///
  /// In en, this message translates to:
  /// **'Cache size: {size}'**
  String cacheSize({required String size});

  /// No description provided for @clearCacheConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the cache? Downloaded data and images will need to be reloaded.'**
  String get clearCacheConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @genus.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get genus;

  /// No description provided for @captureRate.
  ///
  /// In en, this message translates to:
  /// **'Capture Rate'**
  String get captureRate;

  /// No description provided for @baseHappiness.
  ///
  /// In en, this message translates to:
  /// **'Base Friendship'**
  String get baseHappiness;

  /// No description provided for @growthRate.
  ///
  /// In en, this message translates to:
  /// **'Growth Rate'**
  String get growthRate;

  /// No description provided for @habitat.
  ///
  /// In en, this message translates to:
  /// **'Habitat'**
  String get habitat;

  /// No description provided for @eggGroups.
  ///
  /// In en, this message translates to:
  /// **'Egg Groups'**
  String get eggGroups;

  /// No description provided for @flavorText.
  ///
  /// In en, this message translates to:
  /// **'Pokédex Description'**
  String get flavorText;

  /// No description provided for @evolutionChain.
  ///
  /// In en, this message translates to:
  /// **'Evolution Chain'**
  String get evolutionChain;

  /// No description provided for @noEvolutions.
  ///
  /// In en, this message translates to:
  /// **'This Pokémon does not evolve.'**
  String get noEvolutions;

  /// No description provided for @evolutionTriggerLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level}'**
  String evolutionTriggerLevel({required int level});

  /// No description provided for @evolutionTriggerItem.
  ///
  /// In en, this message translates to:
  /// **'Use {item}'**
  String evolutionTriggerItem({required String item});

  /// No description provided for @evolutionTriggerTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get evolutionTriggerTrade;

  /// No description provided for @evolutionTriggerTradeItem.
  ///
  /// In en, this message translates to:
  /// **'Trade holding {item}'**
  String evolutionTriggerTradeItem({required String item});

  /// No description provided for @evolutionTriggerHappiness.
  ///
  /// In en, this message translates to:
  /// **'High Friendship'**
  String get evolutionTriggerHappiness;

  /// No description provided for @evolutionTriggerHappinessDay.
  ///
  /// In en, this message translates to:
  /// **'Friendship (Day)'**
  String get evolutionTriggerHappinessDay;

  /// No description provided for @evolutionTriggerHappinessNight.
  ///
  /// In en, this message translates to:
  /// **'Friendship (Night)'**
  String get evolutionTriggerHappinessNight;

  /// No description provided for @evolutionTriggerLocation.
  ///
  /// In en, this message translates to:
  /// **'Level up at {location}'**
  String evolutionTriggerLocation({required String location});

  /// No description provided for @evolutionTriggerMove.
  ///
  /// In en, this message translates to:
  /// **'Knows {move}'**
  String evolutionTriggerMove({required String move});

  /// No description provided for @evolutionTriggerOther.
  ///
  /// In en, this message translates to:
  /// **'Special Condition'**
  String get evolutionTriggerOther;

  /// No description provided for @abilityDetail.
  ///
  /// In en, this message translates to:
  /// **'Ability Info'**
  String get abilityDetail;

  /// No description provided for @abilityEffect.
  ///
  /// In en, this message translates to:
  /// **'In-Battle Effect'**
  String get abilityEffect;

  /// No description provided for @abilityShortEffect.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get abilityShortEffect;

  /// No description provided for @allGameVersions.
  ///
  /// In en, this message translates to:
  /// **'All Versions'**
  String get allGameVersions;

  /// No description provided for @filterByVersion.
  ///
  /// In en, this message translates to:
  /// **'Game Version'**
  String get filterByVersion;

  /// No description provided for @baseSpeciesDataNotice.
  ///
  /// In en, this message translates to:
  /// **'Appearance & types reflect {formName}. Stats, moves, and abilities reflect the base species.'**
  String baseSpeciesDataNotice({required String formName});

  /// No description provided for @encountersUnavailableForVersion.
  ///
  /// In en, this message translates to:
  /// **'No encounters found for this game version.'**
  String get encountersUnavailableForVersion;

  /// No description provided for @heldItemsUnavailableForVersion.
  ///
  /// In en, this message translates to:
  /// **'No held items found for this game version.'**
  String get heldItemsUnavailableForVersion;

  /// No description provided for @movesUnavailableForVersion.
  ///
  /// In en, this message translates to:
  /// **'No moves found for this game version.'**
  String get movesUnavailableForVersion;

  /// No description provided for @errorSpecies.
  ///
  /// In en, this message translates to:
  /// **'Failed to load species information.'**
  String get errorSpecies;

  /// No description provided for @errorEvolutionChain.
  ///
  /// In en, this message translates to:
  /// **'Failed to load evolution chain.'**
  String get errorEvolutionChain;

  /// No description provided for @errorAbilityDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed to load ability details.'**
  String get errorAbilityDetail;

  /// No description provided for @evolutionTriggerLevelUpsideDown.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Upside down)'**
  String evolutionTriggerLevelUpsideDown({required int level});

  /// No description provided for @evolutionTriggerLevelRain.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Rain)'**
  String evolutionTriggerLevelRain({required int level});

  /// No description provided for @evolutionTriggerLevelAtkGtDef.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Atk > Def)'**
  String evolutionTriggerLevelAtkGtDef({required int level});

  /// No description provided for @evolutionTriggerLevelDefGtAtk.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Def > Atk)'**
  String evolutionTriggerLevelDefGtAtk({required int level});

  /// No description provided for @evolutionTriggerLevelAtkEqDef.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Atk = Def)'**
  String evolutionTriggerLevelAtkEqDef({required int level});

  /// No description provided for @evolutionTriggerLevelDay.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Day)'**
  String evolutionTriggerLevelDay({required int level});

  /// No description provided for @evolutionTriggerLevelNight.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Night)'**
  String evolutionTriggerLevelNight({required int level});

  /// No description provided for @evolutionTriggerLevelParty.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (with {species})'**
  String evolutionTriggerLevelParty({
    required int level,
    required String species,
  });

  /// No description provided for @evolutionTriggerLevelPartyType.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} ({type} in party)'**
  String evolutionTriggerLevelPartyType({
    required int level,
    required String type,
  });

  /// No description provided for @evolutionTriggerLevelGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Female)'**
  String evolutionTriggerLevelGenderFemale({required int level});

  /// No description provided for @evolutionTriggerLevelGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level} (Male)'**
  String evolutionTriggerLevelGenderMale({required int level});

  /// No description provided for @evolutionTriggerTradeSpecies.
  ///
  /// In en, this message translates to:
  /// **'Trade for {species}'**
  String evolutionTriggerTradeSpecies({required String species});

  /// No description provided for @evolutionTriggerShed.
  ///
  /// In en, this message translates to:
  /// **'Empty slot & Poké Ball'**
  String get evolutionTriggerShed;

  /// No description provided for @evolutionTriggerTurnUpsideDown.
  ///
  /// In en, this message translates to:
  /// **'Turn device upside down'**
  String get evolutionTriggerTurnUpsideDown;

  /// No description provided for @evolutionTriggerRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get evolutionTriggerRain;

  /// No description provided for @alternateForms.
  ///
  /// In en, this message translates to:
  /// **'Alternate Forms'**
  String get alternateForms;

  /// No description provided for @currentForm.
  ///
  /// In en, this message translates to:
  /// **'Current Form'**
  String get currentForm;

  /// No description provided for @currentPokemon.
  ///
  /// In en, this message translates to:
  /// **'Current Pokémon'**
  String get currentPokemon;

  /// No description provided for @evolutionTriggerPartySpecies.
  ///
  /// In en, this message translates to:
  /// **'With {species}'**
  String evolutionTriggerPartySpecies({required String species});

  /// No description provided for @evolutionTriggerItemGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Use {item} (Male)'**
  String evolutionTriggerItemGenderMale({required String item});

  /// No description provided for @evolutionTriggerItemGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Use {item} (Female)'**
  String evolutionTriggerItemGenderFemale({required String item});

  /// No description provided for @evolutionTriggerItemDay.
  ///
  /// In en, this message translates to:
  /// **'Use {item} (Day)'**
  String evolutionTriggerItemDay({required String item});

  /// No description provided for @evolutionTriggerItemNight.
  ///
  /// In en, this message translates to:
  /// **'Use {item} (Night)'**
  String evolutionTriggerItemNight({required String item});

  /// No description provided for @evolutionTriggerHeldItem.
  ///
  /// In en, this message translates to:
  /// **'Hold {item}'**
  String evolutionTriggerHeldItem({required String item});

  /// No description provided for @evolutionTriggerHeldItemDay.
  ///
  /// In en, this message translates to:
  /// **'Hold {item} (Day)'**
  String evolutionTriggerHeldItemDay({required String item});

  /// No description provided for @evolutionTriggerHeldItemNight.
  ///
  /// In en, this message translates to:
  /// **'Hold {item} (Night)'**
  String evolutionTriggerHeldItemNight({required String item});

  /// No description provided for @evolutionTriggerAffection.
  ///
  /// In en, this message translates to:
  /// **'High Affection'**
  String get evolutionTriggerAffection;

  /// No description provided for @evolutionTriggerBeauty.
  ///
  /// In en, this message translates to:
  /// **'High Beauty'**
  String get evolutionTriggerBeauty;

  /// No description provided for @evolutionTriggerPartyType.
  ///
  /// In en, this message translates to:
  /// **'{type} in party'**
  String evolutionTriggerPartyType({required String type});

  /// No description provided for @evolutionTriggerGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get evolutionTriggerGenderMale;

  /// No description provided for @evolutionTriggerGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get evolutionTriggerGenderFemale;

  /// No description provided for @aboutPokeFinder.
  ///
  /// In en, this message translates to:
  /// **'About PokéFinder'**
  String get aboutPokeFinder;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'A lightweight, modern Pokédex app for exploring Pokémon, abilities, moves, and stats.'**
  String get aboutAppDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion({required String version});

  /// No description provided for @aboutBuildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build {buildNumber}'**
  String aboutBuildNumber({required String buildNumber});

  /// No description provided for @aboutDataSource.
  ///
  /// In en, this message translates to:
  /// **'Data Source'**
  String get aboutDataSource;

  /// No description provided for @aboutDataSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'All Pokémon data, sprites, and assets are sourced from PokeAPI.'**
  String get aboutDataSourceDescription;

  /// No description provided for @aboutPokeApiWebsite.
  ///
  /// In en, this message translates to:
  /// **'PokeAPI Website'**
  String get aboutPokeApiWebsite;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get aboutDisclaimer;

  /// No description provided for @aboutDisclaimerText.
  ///
  /// In en, this message translates to:
  /// **'PokéFinder is an unofficial, non-commercial fan-made app and is not affiliated with, endorsed, or supported by Nintendo, GAME FREAK, or The Pokémon Company.'**
  String get aboutDisclaimerText;

  /// No description provided for @aboutOpenSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get aboutOpenSourceLicenses;

  /// No description provided for @aboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get aboutSourceCode;

  /// No description provided for @aboutGitHubRepository.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get aboutGitHubRepository;

  /// No description provided for @aboutReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get aboutReportIssue;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get shareLink;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get shareLinkCopied;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compareTitle;

  /// No description provided for @compareAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to comparison'**
  String get compareAdd;

  /// No description provided for @compareRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from comparison'**
  String get compareRemove;

  /// No description provided for @compareClear.
  ///
  /// In en, this message translates to:
  /// **'Clear comparison'**
  String get compareClear;

  /// No description provided for @compareEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon to compare'**
  String get compareEmptyTitle;

  /// No description provided for @compareEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add up to 2 Pokémon from the Pokédex cards or the detail screen to compare them side by side.'**
  String get compareEmptyMessage;

  /// No description provided for @compareAddSecond.
  ///
  /// In en, this message translates to:
  /// **'Add a second Pokémon to compare'**
  String get compareAddSecond;

  /// No description provided for @compareFull.
  ///
  /// In en, this message translates to:
  /// **'Comparison is full (2 max)'**
  String get compareFull;

  /// No description provided for @compareAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to comparison'**
  String get compareAdded;

  /// No description provided for @compareView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get compareView;

  /// No description provided for @compareTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get compareTotal;

  /// No description provided for @matchupTitle.
  ///
  /// In en, this message translates to:
  /// **'Type matchups'**
  String get matchupTitle;

  /// No description provided for @matchupDefendingTypes.
  ///
  /// In en, this message translates to:
  /// **'Defending types'**
  String get matchupDefendingTypes;

  /// No description provided for @matchupDefendingHint.
  ///
  /// In en, this message translates to:
  /// **'Select up to 2 types'**
  String get matchupDefendingHint;

  /// No description provided for @matchupEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No defending type selected'**
  String get matchupEmptyTitle;

  /// No description provided for @matchupEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Select 1 or 2 defending types to see weaknesses, resistances and immunities.'**
  String get matchupEmptyMessage;

  /// No description provided for @matchupGroup4x.
  ///
  /// In en, this message translates to:
  /// **'4× weak to'**
  String get matchupGroup4x;

  /// No description provided for @matchupGroup2x.
  ///
  /// In en, this message translates to:
  /// **'2× weak to'**
  String get matchupGroup2x;

  /// No description provided for @matchupGroupHalf.
  ///
  /// In en, this message translates to:
  /// **'½× resistant to'**
  String get matchupGroupHalf;

  /// No description provided for @matchupGroupQuarter.
  ///
  /// In en, this message translates to:
  /// **'¼× resistant to'**
  String get matchupGroupQuarter;

  /// No description provided for @matchupGroupImmune.
  ///
  /// In en, this message translates to:
  /// **'Immune to'**
  String get matchupGroupImmune;

  /// No description provided for @matchupClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get matchupClearSelection;

  /// No description provided for @matchupViewMatchups.
  ///
  /// In en, this message translates to:
  /// **'View matchups'**
  String get matchupViewMatchups;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
