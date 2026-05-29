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
    Locale('it')
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
      'that was used.');
}
