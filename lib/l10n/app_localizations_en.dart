// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchTextField => 'Search Pokémon';

  @override
  String get searchButton => 'Search';

  @override
  String get errorBadRequest => 'Bad request. Please try again.';

  @override
  String get errorUnauthorized => 'Unauthorized access.';

  @override
  String get errorUnexpected => 'An unexpected error occurred.';

  @override
  String get errorPokemonNotFound => 'Pokémon not found.';

  @override
  String get errorNetworkUnavailable =>
      'No internet connection. Please check your network.';

  @override
  String get errorRequestTimeout => 'The request timed out. Please try again.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorServer => 'Server error occurred. Please try again later.';

  @override
  String get errorInvalidResponse =>
      'Received an invalid response from the server.';

  @override
  String get errorStorage => 'A storage error occurred. Please try again.';

  @override
  String get loading => 'Loading...';

  @override
  String get details => 'Details';

  @override
  String get backButton => 'Back';

  @override
  String get settings => 'Settings';

  @override
  String get useDeviceLanguage => 'Use device language';

  @override
  String get useDeviceLanguageInfo =>
      'If enabled, the app will use your device\'s language.';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get pokemonCry => 'Pokemon Cry';

  @override
  String get baseStats => 'Base Stats';

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Attack';

  @override
  String get statDefense => 'Defense';

  @override
  String get statSpAtk => 'Sp. Atk';

  @override
  String get statSpDef => 'Sp. Def';

  @override
  String get statSpeed => 'Speed';

  @override
  String get statsNotAvailable => 'Stats not available';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheClearedSuccessfully => 'Cache cleared successfully';

  @override
  String get tabInfo => 'Info';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabMoves => 'Moves';

  @override
  String get tabItemsGames => 'Items & Games';

  @override
  String get baseExp => 'Base Exp';

  @override
  String get order => 'Order';

  @override
  String get defaultForm => 'Default Form';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cries => 'Cries';

  @override
  String get cryLatest => 'Latest';

  @override
  String get cryLegacy => 'Legacy';

  @override
  String get abilities => 'Abilities';

  @override
  String get abilityHidden => 'Hidden';

  @override
  String get movesSearchPlaceholder => 'Search moves...';

  @override
  String get movesSearchEmpty => 'No moves found';

  @override
  String get movesFilterAll => 'All';

  @override
  String get movesFilterLevelUp => 'Level';

  @override
  String get movesFilterMachine => 'TM';

  @override
  String get movesFilterTutor => 'Tutor';

  @override
  String get movesFilterEgg => 'Egg';

  @override
  String moveBadgeLevel({required int level}) {
    return 'Lv. $level';
  }

  @override
  String get moveBadgeTutor => 'Tutor';

  @override
  String get moveDetailPower => 'Power';

  @override
  String get moveDetailAccuracy => 'Accuracy';

  @override
  String get moveDetailPP => 'PP';

  @override
  String get moveDetailType => 'Type';

  @override
  String get moveDetailClass => 'Category';

  @override
  String get moveDetailEffect => 'Effect';

  @override
  String get damageClassPhysical => 'Physical';

  @override
  String get damageClassSpecial => 'Special';

  @override
  String get damageClassStatus => 'Status';

  @override
  String get heldItems => 'Wild Held Items';

  @override
  String get heldItemsEmpty => 'No wild items held';

  @override
  String get rarity => 'Rarity';

  @override
  String get species => 'Species';

  @override
  String get locationAreaEncounters => 'Location Encounters';

  @override
  String get gameIndices => 'Game Versions';

  @override
  String get spriteToggleShiny => 'Toggle Shiny View';

  @override
  String get spriteTitle => 'Sprite Gallery';

  @override
  String get statsBase => 'Base';

  @override
  String get statsMin => 'Min';

  @override
  String get statsMax => 'Max';

  @override
  String get gameSelectorLabel => 'Game:';

  @override
  String get noData => 'No data available';

  @override
  String get encountersEmpty => 'No encounters found';

  @override
  String get formSelectorTitle => 'Select Form & Appearance';

  @override
  String get formSelectorShiny => 'Shiny Version';

  @override
  String get versionLabel => 'Version';

  @override
  String get formSelectorForms => 'Available Forms';

  @override
  String formTypeModifier({required String type}) {
    return '$type';
  }

  @override
  String get typeNormal => 'Normal';

  @override
  String get typeFire => 'Fire';

  @override
  String get typeWater => 'Water';

  @override
  String get typeGrass => 'Grass';

  @override
  String get typeElectric => 'Electric';

  @override
  String get typeIce => 'Ice';

  @override
  String get typeFighting => 'Fighting';

  @override
  String get typePoison => 'Poison';

  @override
  String get typeGround => 'Ground';

  @override
  String get typeFlying => 'Flying';

  @override
  String get typePsychic => 'Psychic';

  @override
  String get typeBug => 'Bug';

  @override
  String get typeRock => 'Rock';

  @override
  String get typeGhost => 'Ghost';

  @override
  String get typeDragon => 'Dragon';

  @override
  String get typeSteel => 'Steel';

  @override
  String get typeFairy => 'Fairy';

  @override
  String get typeDark => 'Dark';

  @override
  String get typeStellar => 'Stellar';

  @override
  String get typeShadow => 'Shadow';

  @override
  String get typeUnknown => 'Unknown';

  @override
  String get gameRed => 'Red';

  @override
  String get gameBlue => 'Blue';

  @override
  String get gameYellow => 'Yellow';

  @override
  String get gameGold => 'Gold';

  @override
  String get gameSilver => 'Silver';

  @override
  String get gameCrystal => 'Crystal';

  @override
  String get gameRuby => 'Ruby';

  @override
  String get gameSapphire => 'Sapphire';

  @override
  String get gameEmerald => 'Emerald';

  @override
  String get gameFirered => 'FireRed';

  @override
  String get gameLeafgreen => 'LeafGreen';

  @override
  String get gameDiamond => 'Diamond';

  @override
  String get gamePearl => 'Pearl';

  @override
  String get gamePlatinum => 'Platinum';

  @override
  String get gameHeartgold => 'HeartGold';

  @override
  String get gameSoulsilver => 'SoulSilver';

  @override
  String get gameBlack => 'Black';

  @override
  String get gameWhite => 'White';

  @override
  String get gameBlack2 => 'Black 2';

  @override
  String get gameWhite2 => 'White 2';

  @override
  String get gameX => 'X';

  @override
  String get gameY => 'Y';

  @override
  String get gameOmegaRuby => 'Omega Ruby';

  @override
  String get gameAlphaSapphire => 'Alpha Sapphire';

  @override
  String get gameSun => 'Sun';

  @override
  String get gameMoon => 'Moon';

  @override
  String get gameUltraSun => 'Ultra Sun';

  @override
  String get gameUltraMoon => 'Ultra Moon';

  @override
  String get gameLetsGoPikachu => 'Let\'s Go, Pikachu!';

  @override
  String get gameLetsGoEevee => 'Let\'s Go, Eevee!';

  @override
  String get gameSword => 'Sword';

  @override
  String get gameShield => 'Shield';

  @override
  String get gameTheIsleOfArmor => 'The Isle of Armor';

  @override
  String get gameTheCrownTundra => 'The Crown Tundra';

  @override
  String get gameLegendsArceus => 'Legends: Arceus';

  @override
  String get gameScarlet => 'Scarlet';

  @override
  String get gameViolet => 'Violet';

  @override
  String get gameTheTealMask => 'The Teal Mask';

  @override
  String get gameTheIndigoDisk => 'The Indigo Disk';

  @override
  String get gameColosseum => 'Colosseum';

  @override
  String get gameXd => 'XD';

  @override
  String get gameGroupRedBlue => 'Red/Blue';

  @override
  String get gameGroupGoldSilver => 'Gold/Silver';

  @override
  String get gameGroupRubySapphire => 'Ruby/Sapphire';

  @override
  String get gameGroupFireredLeafgreen => 'FireRed/LeafGreen';

  @override
  String get gameGroupDiamondPearl => 'Diamond/Pearl';

  @override
  String get gameGroupHeartgoldSoulsilver => 'HeartGold/SoulSilver';

  @override
  String get gameGroupBlackWhite => 'Black/White';

  @override
  String get gameGroupBlack2White2 => 'Black 2/White 2';

  @override
  String get gameGroupXY => 'X/Y';

  @override
  String get gameGroupOmegaRubyAlphaSapphire => 'Omega Ruby/Alpha Sapphire';

  @override
  String get gameGroupSunMoon => 'Sun/Moon';

  @override
  String get gameGroupUltraSunUltraMoon => 'Ultra Sun/Ultra Moon';

  @override
  String get gameGroupLetsGoPikachuLetsGoEevee => 'Let\'s Go, Pikachu/Eevee';

  @override
  String get gameGroupSwordShield => 'Sword/Shield';

  @override
  String get gameGroupScarletViolet => 'Scarlet/Violet';

  @override
  String get startupErrorTitle => 'Startup Failed';

  @override
  String get startupErrorMessage =>
      'An error occurred while initializing app storage. Please try again.';

  @override
  String get retryButton => 'Retry';

  @override
  String get routeNotFoundTitle => 'Page Not Found';

  @override
  String get routeNotFoundMessage =>
      'The requested Pokémon or page could not be found.';

  @override
  String get goHome => 'Go to Home';

  @override
  String get editSearchButton => 'Edit Search';

  @override
  String get errorEncounters => 'Failed to load encounters.';

  @override
  String get errorFormDetails => 'Failed to load form details.';

  @override
  String get errorMoveDetails => 'Failed to load move details.';

  @override
  String get defaultFormRollback => 'Reset to default form';

  @override
  String get errorSuggestions => 'Failed to load suggestions.';

  @override
  String get cryPlayTooltip => 'Play cry';

  @override
  String get cryStopTooltip => 'Stop cry';

  @override
  String get cryReplayTooltip => 'Replay cry';

  @override
  String get cryLoadingTooltip => 'Loading cry...';

  @override
  String get cryUnavailableTooltip => 'Cry unavailable. Tap to retry';

  @override
  String cryPlayFor({required String pokemon}) {
    return 'Play cry for $pokemon';
  }

  @override
  String get staleDataNotice => 'Offline cached data';

  @override
  String get browsePokedex => 'Browse Pokédex';

  @override
  String get pokedexTitle => 'Pokédex';

  @override
  String get filter => 'Filter';

  @override
  String get filters => 'Filters';

  @override
  String filterCount({required int count}) {
    return '$count active';
  }

  @override
  String get types => 'Types';

  @override
  String get generation => 'Generation';

  @override
  String get generationAll => 'All Generations';

  @override
  String generationNum({required int number}) {
    return 'Gen $number';
  }

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortIdAscending => 'Number: Lowest first';

  @override
  String get sortIdDescending => 'Number: Highest first';

  @override
  String get sortNameAscending => 'Name: A - Z';

  @override
  String get sortNameDescending => 'Name: Z - A';

  @override
  String get randomPokemon => 'Random Pokémon';

  @override
  String get noPokemonFound => 'No Pokémon found matching your filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get searchPokedexPlaceholder => 'Search by name or number...';

  @override
  String get offlineIndexNotice => 'Browsing offline cached Pokédex';

  @override
  String get forms => 'Forms';

  @override
  String get formFilterAll => 'All Forms';

  @override
  String get formFilterCanonicalOnly => 'Canonical Only';

  @override
  String get formFilterMega => 'Mega Evolutions';

  @override
  String get formFilterRegional => 'Regional Forms';

  @override
  String get formFilterGmax => 'Gigantamax';

  @override
  String get includeCosmeticForms => 'Include cosmetic & costume forms';

  @override
  String get formBadgeMegaIndicator => '⚡ Mega';

  @override
  String get formBadgeRegionalIndicator => '🌍 Regional';

  @override
  String get formBadgeGmaxIndicator => '💥 G-Max';

  @override
  String get formBadgeFormsIndicator => '✨ Forms';

  @override
  String get hasAlternateFormsSemantics => 'alternate forms available';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesEmptyTitle => 'No Favorites Yet';

  @override
  String get favoritesEmptyMessage =>
      'Tap the heart icon on any Pokémon to add it to your favorites.';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get removeFromHistory => 'Remove from history';

  @override
  String get sortRecentlyAdded => 'Recently Added';

  @override
  String get recentlyViewed => 'Recently Viewed';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryConfirmation =>
      'Are you sure you want to clear your search and viewing history?';

  @override
  String get historyEnabled => 'Keep history';

  @override
  String get historyEnabledInfo =>
      'Record recently viewed Pokémon and searches.';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get unitSystem => 'Measurement Units';

  @override
  String get unitSystemMetric => 'Metric (m, kg)';

  @override
  String get unitSystemImperial => 'Imperial (ft, lbs)';

  @override
  String get audioSettings => 'Audio';

  @override
  String get autoPlayCry => 'Auto-play cry on open';

  @override
  String get autoPlayCryInfo =>
      'Automatically play the Pokémon\'s cry when opening the details screen.';

  @override
  String get cryVolume => 'Cry Volume';

  @override
  String get storageAndCache => 'Storage & Cache';

  @override
  String cacheSize({required String size}) {
    return 'Cache size: $size';
  }

  @override
  String get clearCacheConfirmation =>
      'Are you sure you want to clear the cache? Downloaded data and images will need to be reloaded.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get clear => 'Clear';

  @override
  String get genus => 'Category';

  @override
  String get captureRate => 'Capture Rate';

  @override
  String get baseHappiness => 'Base Friendship';

  @override
  String get growthRate => 'Growth Rate';

  @override
  String get habitat => 'Habitat';

  @override
  String get eggGroups => 'Egg Groups';

  @override
  String get flavorText => 'Pokédex Description';

  @override
  String get evolutionChain => 'Evolution Chain';

  @override
  String get noEvolutions => 'This Pokémon does not evolve.';

  @override
  String evolutionTriggerLevel({required int level}) {
    return 'Lv. $level';
  }

  @override
  String evolutionTriggerItem({required String item}) {
    return 'Use $item';
  }

  @override
  String get evolutionTriggerTrade => 'Trade';

  @override
  String evolutionTriggerTradeItem({required String item}) {
    return 'Trade holding $item';
  }

  @override
  String get evolutionTriggerHappiness => 'High Friendship';

  @override
  String get evolutionTriggerHappinessDay => 'Friendship (Day)';

  @override
  String get evolutionTriggerHappinessNight => 'Friendship (Night)';

  @override
  String evolutionTriggerLocation({required String location}) {
    return 'Level up at $location';
  }

  @override
  String evolutionTriggerMove({required String move}) {
    return 'Knows $move';
  }

  @override
  String get evolutionTriggerOther => 'Special Condition';

  @override
  String get abilityDetail => 'Ability Info';

  @override
  String get abilityEffect => 'In-Battle Effect';

  @override
  String get abilityShortEffect => 'Summary';

  @override
  String get allGameVersions => 'All Versions';

  @override
  String get filterByVersion => 'Game Version';

  @override
  String baseSpeciesDataNotice({required String formName}) {
    return 'Appearance & types reflect $formName. Stats, moves, and abilities reflect the base species.';
  }

  @override
  String get encountersUnavailableForVersion =>
      'No encounters found for this game version.';

  @override
  String get heldItemsUnavailableForVersion =>
      'No held items found for this game version.';

  @override
  String get movesUnavailableForVersion =>
      'No moves found for this game version.';

  @override
  String get errorSpecies => 'Failed to load species information.';

  @override
  String get errorEvolutionChain => 'Failed to load evolution chain.';

  @override
  String get errorAbilityDetail => 'Failed to load ability details.';

  @override
  String evolutionTriggerLevelUpsideDown({required int level}) {
    return 'Lv. $level (Upside down)';
  }

  @override
  String evolutionTriggerLevelRain({required int level}) {
    return 'Lv. $level (Rain)';
  }

  @override
  String evolutionTriggerLevelAtkGtDef({required int level}) {
    return 'Lv. $level (Atk > Def)';
  }

  @override
  String evolutionTriggerLevelDefGtAtk({required int level}) {
    return 'Lv. $level (Def > Atk)';
  }

  @override
  String evolutionTriggerLevelAtkEqDef({required int level}) {
    return 'Lv. $level (Atk = Def)';
  }

  @override
  String evolutionTriggerLevelDay({required int level}) {
    return 'Lv. $level (Day)';
  }

  @override
  String evolutionTriggerLevelNight({required int level}) {
    return 'Lv. $level (Night)';
  }

  @override
  String evolutionTriggerLevelParty({
    required int level,
    required String species,
  }) {
    return 'Lv. $level (with $species)';
  }

  @override
  String evolutionTriggerLevelPartyType({
    required int level,
    required String type,
  }) {
    return 'Lv. $level ($type in party)';
  }

  @override
  String evolutionTriggerLevelGenderFemale({required int level}) {
    return 'Lv. $level (Female)';
  }

  @override
  String evolutionTriggerLevelGenderMale({required int level}) {
    return 'Lv. $level (Male)';
  }

  @override
  String evolutionTriggerTradeSpecies({required String species}) {
    return 'Trade for $species';
  }

  @override
  String get evolutionTriggerShed => 'Empty slot & Poké Ball';

  @override
  String get evolutionTriggerTurnUpsideDown => 'Turn device upside down';

  @override
  String get evolutionTriggerRain => 'Rain';

  @override
  String get alternateForms => 'Alternate Forms';

  @override
  String get currentForm => 'Current Form';

  @override
  String get currentPokemon => 'Current Pokémon';

  @override
  String evolutionTriggerPartySpecies({required String species}) {
    return 'With $species';
  }

  @override
  String evolutionTriggerItemGenderMale({required String item}) {
    return 'Use $item (Male)';
  }

  @override
  String evolutionTriggerItemGenderFemale({required String item}) {
    return 'Use $item (Female)';
  }

  @override
  String evolutionTriggerItemDay({required String item}) {
    return 'Use $item (Day)';
  }

  @override
  String evolutionTriggerItemNight({required String item}) {
    return 'Use $item (Night)';
  }

  @override
  String evolutionTriggerHeldItem({required String item}) {
    return 'Hold $item';
  }

  @override
  String evolutionTriggerHeldItemDay({required String item}) {
    return 'Hold $item (Day)';
  }

  @override
  String evolutionTriggerHeldItemNight({required String item}) {
    return 'Hold $item (Night)';
  }

  @override
  String get evolutionTriggerAffection => 'High Affection';

  @override
  String get evolutionTriggerBeauty => 'High Beauty';

  @override
  String evolutionTriggerPartyType({required String type}) {
    return '$type in party';
  }

  @override
  String get evolutionTriggerGenderMale => 'Male';

  @override
  String get evolutionTriggerGenderFemale => 'Female';

  @override
  String get aboutPokeFinder => 'About PokéFinder';

  @override
  String get aboutAppDescription =>
      'A lightweight, modern Pokédex app for exploring Pokémon, abilities, moves, and stats.';

  @override
  String aboutVersion({required String version}) {
    return 'Version $version';
  }

  @override
  String aboutBuildNumber({required String buildNumber}) {
    return 'Build $buildNumber';
  }

  @override
  String get aboutDataSource => 'Data Source';

  @override
  String get aboutDataSourceDescription =>
      'All Pokémon data, sprites, and assets are sourced from PokeAPI.';

  @override
  String get aboutPokeApiWebsite => 'PokeAPI Website';

  @override
  String get aboutDisclaimer => 'Disclaimer';

  @override
  String get aboutDisclaimerText =>
      'PokéFinder is an unofficial, non-commercial fan-made app and is not affiliated with, endorsed, or supported by Nintendo, GAME FREAK, or The Pokémon Company.';

  @override
  String get aboutOpenSourceLicenses => 'Open Source Licenses';

  @override
  String get aboutSourceCode => 'Source Code';

  @override
  String get aboutGitHubRepository => 'GitHub Repository';

  @override
  String get aboutReportIssue => 'Report an Issue';
}
