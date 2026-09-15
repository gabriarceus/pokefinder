// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get searchTextField => 'Cerca Pokémon';

  @override
  String get searchButton => 'Cerca';

  @override
  String get errorBadRequest => 'Richiesta errata. Riprova.';

  @override
  String get errorUnauthorized => 'Accesso non autorizzato.';

  @override
  String get errorUnexpected => 'Si è verificato un errore imprevisto.';

  @override
  String get errorPokemonNotFound => 'Pokémon non trovato.';

  @override
  String get errorNetworkUnavailable =>
      'Nessuna connessione a Internet. Verifica la tua rete.';

  @override
  String get errorRequestTimeout => 'La richiesta è scaduta. Riprova.';

  @override
  String get errorRateLimited =>
      'Troppe richieste. Attendi un momento e riprova.';

  @override
  String get errorServer =>
      'Si è verificato un errore del server. Riprova più tardi.';

  @override
  String get errorInvalidResponse =>
      'Ricevuta una risposta non valida dal server.';

  @override
  String get errorStorage => 'Si è verificato un errore di memoria. Riprova.';

  @override
  String get loading => 'Caricamento...';

  @override
  String get details => 'Dettagli';

  @override
  String get backButton => 'Indietro';

  @override
  String get settings => 'Impostazioni';

  @override
  String get useDeviceLanguage => 'Usa la lingua del dispositivo';

  @override
  String get useDeviceLanguageInfo =>
      'Se attivato, l\'app userà la stessa lingua del tuo dispositivo.';

  @override
  String get about => 'Informazioni';

  @override
  String get language => 'Lingua';

  @override
  String get weight => 'Peso';

  @override
  String get height => 'Altezza';

  @override
  String get pokemonCry => 'Verso del Pokemon';

  @override
  String get baseStats => 'Statistiche Base';

  @override
  String get statHp => 'PS';

  @override
  String get statAttack => 'Attacco';

  @override
  String get statDefense => 'Difesa';

  @override
  String get statSpAtk => 'Att. Sp.';

  @override
  String get statSpDef => 'Dif. Sp.';

  @override
  String get statSpeed => 'Velocità';

  @override
  String get statsNotAvailable => 'Statistiche non disponibili';

  @override
  String get clearCache => 'Svuota cache';

  @override
  String get cacheClearedSuccessfully => 'Cache svuotata con successo';

  @override
  String get tabInfo => 'Info';

  @override
  String get tabStats => 'Statistiche';

  @override
  String get tabMoves => 'Mosse';

  @override
  String get tabItemsGames => 'Strumenti';

  @override
  String get baseExp => 'Esperienza di base ceduta';

  @override
  String get order => 'Ordine';

  @override
  String get defaultForm => 'Forma Default';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get cries => 'Versi';

  @override
  String get cryLatest => 'Recente';

  @override
  String get cryLegacy => 'Storico';

  @override
  String get abilities => 'Abilità';

  @override
  String get abilityHidden => 'Nascosta';

  @override
  String get movesSearchPlaceholder => 'Cerca mosse...';

  @override
  String get movesSearchEmpty => 'Nessuna mossa trovata';

  @override
  String get movesFilterAll => 'Tutte';

  @override
  String get movesFilterLevelUp => 'Livello';

  @override
  String get movesFilterMachine => 'MT';

  @override
  String get movesFilterTutor => 'Esperto';

  @override
  String get movesFilterEgg => 'Uovo';

  @override
  String moveBadgeLevel({required int level}) {
    return 'Lvl $level';
  }

  @override
  String get moveBadgeTutor => 'Tutor';

  @override
  String get moveDetailPower => 'Potenza';

  @override
  String get moveDetailAccuracy => 'Precisione';

  @override
  String get moveDetailPP => 'PP';

  @override
  String get moveDetailType => 'Tipo';

  @override
  String get moveDetailClass => 'Categoria';

  @override
  String get moveDetailEffect => 'Effetto';

  @override
  String get damageClassPhysical => 'Fisico';

  @override
  String get damageClassSpecial => 'Speciale';

  @override
  String get damageClassStatus => 'Stato';

  @override
  String get heldItems => 'Strumenti Selvatici';

  @override
  String get heldItemsEmpty => 'Nessuno strumento selvatico';

  @override
  String get rarity => 'Rarità';

  @override
  String get species => 'Specie';

  @override
  String get locationAreaEncounters => 'Aree d\'incontro';

  @override
  String get gameIndices => 'Versioni di gioco';

  @override
  String get spriteToggleShiny => 'Mostra Shiny';

  @override
  String get spriteTitle => 'Galleria Sprite';

  @override
  String get statsBase => 'Base';

  @override
  String get statsMin => 'Min';

  @override
  String get statsMax => 'Max';

  @override
  String get gameSelectorLabel => 'Gioco:';

  @override
  String get noData => 'Nessun dato disponibile';

  @override
  String get encountersEmpty => 'Nessun incontro trovato';

  @override
  String get formSelectorTitle => 'Seleziona Forma & Aspetto';

  @override
  String get formSelectorShiny => 'Versione Shiny';

  @override
  String get versionLabel => 'Versione';

  @override
  String get formSelectorForms => 'Forme Disponibili';

  @override
  String formTypeModifier({required String type}) {
    return 'Tipo $type';
  }

  @override
  String get typeNormal => 'Normale';

  @override
  String get typeFire => 'Fuoco';

  @override
  String get typeWater => 'Acqua';

  @override
  String get typeGrass => 'Erba';

  @override
  String get typeElectric => 'Elettro';

  @override
  String get typeIce => 'Ghiaccio';

  @override
  String get typeFighting => 'Lotta';

  @override
  String get typePoison => 'Veleno';

  @override
  String get typeGround => 'Terra';

  @override
  String get typeFlying => 'Volante';

  @override
  String get typePsychic => 'Psico';

  @override
  String get typeBug => 'Coleottero';

  @override
  String get typeRock => 'Roccia';

  @override
  String get typeGhost => 'Spettro';

  @override
  String get typeDragon => 'Drago';

  @override
  String get typeSteel => 'Acciaio';

  @override
  String get typeFairy => 'Folletto';

  @override
  String get typeDark => 'Buio';

  @override
  String get typeStellar => 'Stellare';

  @override
  String get typeShadow => 'Ombra';

  @override
  String get typeUnknown => 'Sconosciuto';

  @override
  String get gameRed => 'Rosso';

  @override
  String get gameBlue => 'Blu';

  @override
  String get gameYellow => 'Giallo';

  @override
  String get gameGold => 'Oro';

  @override
  String get gameSilver => 'Argento';

  @override
  String get gameCrystal => 'Cristallo';

  @override
  String get gameRuby => 'Rubino';

  @override
  String get gameSapphire => 'Zaffiro';

  @override
  String get gameEmerald => 'Smeraldo';

  @override
  String get gameFirered => 'Rosso Fuoco';

  @override
  String get gameLeafgreen => 'Verde Foglia';

  @override
  String get gameDiamond => 'Diamante';

  @override
  String get gamePearl => 'Perla';

  @override
  String get gamePlatinum => 'Platino';

  @override
  String get gameHeartgold => 'HeartGold';

  @override
  String get gameSoulsilver => 'SoulSilver';

  @override
  String get gameBlack => 'Nero';

  @override
  String get gameWhite => 'Bianco';

  @override
  String get gameBlack2 => 'Nero 2';

  @override
  String get gameWhite2 => 'Bianco 2';

  @override
  String get gameX => 'X';

  @override
  String get gameY => 'Y';

  @override
  String get gameOmegaRuby => 'Rubino Omega';

  @override
  String get gameAlphaSapphire => 'Zaffiro Alpha';

  @override
  String get gameSun => 'Sole';

  @override
  String get gameMoon => 'Luna';

  @override
  String get gameUltraSun => 'Ultrasole';

  @override
  String get gameUltraMoon => 'Ultraluna';

  @override
  String get gameLetsGoPikachu => 'Let\'s Go, Pikachu!';

  @override
  String get gameLetsGoEevee => 'Let\'s Go, Eevee!';

  @override
  String get gameSword => 'Spada';

  @override
  String get gameShield => 'Scudo';

  @override
  String get gameTheIsleOfArmor => 'L\'isola solitaria dell\'armatura';

  @override
  String get gameTheCrownTundra => 'Le terre innevate della corona';

  @override
  String get gameLegendsArceus => 'Leggende: Arceus';

  @override
  String get gameScarlet => 'Scarlatto';

  @override
  String get gameViolet => 'Violetto';

  @override
  String get gameTheTealMask => 'La maschera turchese';

  @override
  String get gameTheIndigoDisk => 'Il disco indaco';

  @override
  String get gameColosseum => 'Colosseum';

  @override
  String get gameXd => 'XD';

  @override
  String get gameGroupRedBlue => 'Rosso/Blu';

  @override
  String get gameGroupGoldSilver => 'Oro/Argento';

  @override
  String get gameGroupRubySapphire => 'Rubino/Zaffiro';

  @override
  String get gameGroupFireredLeafgreen => 'Rosso Fuoco/Verde Foglia';

  @override
  String get gameGroupDiamondPearl => 'Diamante/Perla';

  @override
  String get gameGroupHeartgoldSoulsilver => 'HeartGold/SoulSilver';

  @override
  String get gameGroupBlackWhite => 'Nero/Bianco';

  @override
  String get gameGroupBlack2White2 => 'Nero 2/Bianco 2';

  @override
  String get gameGroupXY => 'X/Y';

  @override
  String get gameGroupOmegaRubyAlphaSapphire => 'Rubino Omega/Zaffiro Alpha';

  @override
  String get gameGroupSunMoon => 'Sole/Luna';

  @override
  String get gameGroupUltraSunUltraMoon => 'Ultrasole/Ultraluna';

  @override
  String get gameGroupLetsGoPikachuLetsGoEevee => 'Let\'s Go, Pikachu/Eevee';

  @override
  String get gameGroupSwordShield => 'Spada/Scudo';

  @override
  String get gameGroupScarletViolet => 'Scarlatto/Violetto';

  @override
  String get startupErrorTitle => 'Avvio non riuscito';

  @override
  String get startupErrorMessage =>
      'Si è verificato un errore durante l\'inizializzazione della memoria. Riprova.';

  @override
  String get retryButton => 'Riprova';

  @override
  String get routeNotFoundTitle => 'Pagina non trovata';

  @override
  String get routeNotFoundMessage =>
      'Il Pokémon o la pagina richiesta non è stata trovata.';

  @override
  String get goHome => 'Torna alla Home';

  @override
  String get editSearchButton => 'Modifica ricerca';

  @override
  String get errorEncounters => 'Impossibile caricare gli incontri.';

  @override
  String get errorFormDetails => 'Impossibile caricare i dettagli della forma.';

  @override
  String get errorMoveDetails => 'Impossibile caricare i dettagli della mossa.';

  @override
  String get defaultFormRollback => 'Ripristina forma predefinita';

  @override
  String get errorSuggestions => 'Impossibile caricare i suggerimenti.';

  @override
  String get cryPlayTooltip => 'Riproduci verso';

  @override
  String get cryStopTooltip => 'Interrompi verso';

  @override
  String get cryReplayTooltip => 'Riascolta verso';

  @override
  String get cryLoadingTooltip => 'Caricamento verso...';

  @override
  String get cryUnavailableTooltip =>
      'Verso non disponibile. Tocca per riprovare';

  @override
  String cryPlayFor({required String pokemon}) {
    return 'Riproduci verso di $pokemon';
  }

  @override
  String get staleDataNotice => 'Dati memorizzati offline';

  @override
  String get browsePokedex => 'Esplora Pokédex';

  @override
  String get pokedexTitle => 'Pokédex';

  @override
  String get filter => 'Filtra';

  @override
  String get filters => 'Filtri';

  @override
  String filterCount({required int count}) {
    return '$count attivi';
  }

  @override
  String get types => 'Tipi';

  @override
  String get generation => 'Generazione';

  @override
  String get generationAll => 'Tutte le generazioni';

  @override
  String generationNum({required int number}) {
    return 'Gen $number';
  }

  @override
  String get sortBy => 'Ordina per';

  @override
  String get sortIdAscending => 'Numero: Minore';

  @override
  String get sortIdDescending => 'Numero: Maggiore';

  @override
  String get sortNameAscending => 'Nome: A - Z';

  @override
  String get sortNameDescending => 'Nome: Z - A';

  @override
  String get randomPokemon => 'Pokémon casuale';

  @override
  String get noPokemonFound =>
      'Nessun Pokémon trovato con i filtri selezionati';

  @override
  String get clearFilters => 'Reimposta filtri';

  @override
  String get apply => 'Applica';

  @override
  String get reset => 'Reimposta';

  @override
  String get searchPokedexPlaceholder => 'Cerca per nome o numero...';

  @override
  String get offlineIndexNotice => 'Consultazione Pokédex offline';

  @override
  String get forms => 'Forme';

  @override
  String get formFilterAll => 'Tutte le forme';

  @override
  String get formFilterCanonicalOnly => 'Solo canoniche';

  @override
  String get formFilterMega => 'Megaevoluzioni';

  @override
  String get formFilterRegional => 'Forme regionali';

  @override
  String get formFilterGmax => 'Gigamax';

  @override
  String get includeCosmeticForms => 'Includi forme estetiche e costumi';

  @override
  String get formBadgeMegaIndicator => '⚡ Mega';

  @override
  String get formBadgeRegionalIndicator => '🌍 Regionali';

  @override
  String get formBadgeGmaxIndicator => '💥 Gigamax';

  @override
  String get formBadgeFormsIndicator => '✨ Forme';

  @override
  String get hasAlternateFormsSemantics => 'forme alternative disponibili';

  @override
  String get favorites => 'Preferiti';

  @override
  String get favoritesEmptyTitle => 'Nessun preferito';

  @override
  String get favoritesEmptyMessage =>
      'Tocca l\'icona del cuore su un Pokémon per aggiungerlo ai tuoi preferiti.';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get removeFromHistory => 'Rimuovi dalla cronologia';

  @override
  String get sortRecentlyAdded => 'Aggiunti di recente';

  @override
  String get recentlyViewed => 'Visti di recente';

  @override
  String get recentSearches => 'Ricerche recenti';

  @override
  String get clearHistory => 'Cancella cronologia';

  @override
  String get clearHistoryConfirmation =>
      'Sei sicuro di voler cancellare la cronologia delle ricerche e visualizzazioni?';

  @override
  String get historyEnabled => 'Salva cronologia';

  @override
  String get historyEnabledInfo =>
      'Registra i Pokémon visualizzati e le ricerche effettuate.';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get unitSystem => 'Unità di misura';

  @override
  String get unitSystemMetric => 'Metrico (m, kg)';

  @override
  String get unitSystemImperial => 'Imperiale (ft, lbs)';

  @override
  String get audioSettings => 'Audio';

  @override
  String get autoPlayCry => 'Riproduci verso all\'apertura';

  @override
  String get autoPlayCryInfo =>
      'Riproduce automaticamente il verso del Pokémon all\'apertura dei dettagli.';

  @override
  String get cryVolume => 'Volume verso';

  @override
  String get storageAndCache => 'Memoria e Cache';

  @override
  String cacheSize({required String size}) {
    return 'Dimensione cache: $size';
  }

  @override
  String get clearCacheConfirmation =>
      'Sei sicuro di voler svuotare la cache? I dati e le immagini salvati dovranno essere scaricati di nuovo.';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get clear => 'Svuota';

  @override
  String get genus => 'Categoria';

  @override
  String get captureRate => 'Tasso di cattura';

  @override
  String get baseHappiness => 'Amicizia base';

  @override
  String get growthRate => 'Crescita';

  @override
  String get habitat => 'Habitat';

  @override
  String get eggGroups => 'Gruppi uovo';

  @override
  String get flavorText => 'Descrizione Pokédex';

  @override
  String get evolutionChain => 'Catena Evolutiva';

  @override
  String get noEvolutions => 'Questo Pokémon non si evolve.';

  @override
  String evolutionTriggerLevel({required int level}) {
    return 'Liv. $level';
  }

  @override
  String evolutionTriggerItem({required String item}) {
    return 'Usa $item';
  }

  @override
  String get evolutionTriggerTrade => 'Scambio';

  @override
  String evolutionTriggerTradeItem({required String item}) {
    return 'Scambio con $item';
  }

  @override
  String get evolutionTriggerHappiness => 'Amicizia alta';

  @override
  String get evolutionTriggerHappinessDay => 'Amicizia (Giorno)';

  @override
  String get evolutionTriggerHappinessNight => 'Amicizia (Notte)';

  @override
  String evolutionTriggerLocation({required String location}) {
    return 'Sali di livello a $location';
  }

  @override
  String evolutionTriggerMove({required String move}) {
    return 'Conosce $move';
  }

  @override
  String get evolutionTriggerOther => 'Condizione speciale';

  @override
  String get abilityDetail => 'Info Abilità';

  @override
  String get abilityEffect => 'Effetto in Battaglia';

  @override
  String get abilityShortEffect => 'Riepilogo';

  @override
  String get allGameVersions => 'Tutte le versioni';

  @override
  String get filterByVersion => 'Versione gioco';

  @override
  String baseSpeciesDataNotice({required String formName}) {
    return 'Aspetto e tipi riflettono $formName. Statistiche, mosse e abilità riflettono la specie base.';
  }

  @override
  String get encountersUnavailableForVersion =>
      'Nessun incontro trovato per questa versione.';

  @override
  String get heldItemsUnavailableForVersion =>
      'Nessuno strumento trovato per questa versione.';

  @override
  String get movesUnavailableForVersion =>
      'Nessuna mossa trovata per questa versione.';

  @override
  String get errorSpecies =>
      'Impossibile caricare le informazioni sulla specie.';

  @override
  String get errorEvolutionChain => 'Impossibile caricare la catena evolutiva.';

  @override
  String get errorAbilityDetail =>
      'Impossibile caricare i dettagli dell\'abilità.';

  @override
  String evolutionTriggerLevelUpsideDown({required int level}) {
    return 'Liv. $level (Sottosopra)';
  }

  @override
  String evolutionTriggerLevelRain({required int level}) {
    return 'Liv. $level (Con pioggia)';
  }

  @override
  String evolutionTriggerLevelAtkGtDef({required int level}) {
    return 'Liv. $level (Att > Dif)';
  }

  @override
  String evolutionTriggerLevelDefGtAtk({required int level}) {
    return 'Liv. $level (Dif > Att)';
  }

  @override
  String evolutionTriggerLevelAtkEqDef({required int level}) {
    return 'Liv. $level (Att = Dif)';
  }

  @override
  String evolutionTriggerLevelDay({required int level}) {
    return 'Liv. $level (Giorno)';
  }

  @override
  String evolutionTriggerLevelNight({required int level}) {
    return 'Liv. $level (Notte)';
  }

  @override
  String evolutionTriggerLevelParty({
    required int level,
    required String species,
  }) {
    return 'Liv. $level (con $species)';
  }

  @override
  String evolutionTriggerLevelPartyType({
    required int level,
    required String type,
  }) {
    return 'Liv. $level (tipo $type in squadra)';
  }

  @override
  String evolutionTriggerLevelGenderFemale({required int level}) {
    return 'Liv. $level (Femmina)';
  }

  @override
  String evolutionTriggerLevelGenderMale({required int level}) {
    return 'Liv. $level (Maschio)';
  }

  @override
  String evolutionTriggerTradeSpecies({required String species}) {
    return 'Scambio per $species';
  }

  @override
  String get evolutionTriggerShed => 'Spazio libero e Poké Ball';

  @override
  String get evolutionTriggerTurnUpsideDown => 'Gira la console sottosopra';

  @override
  String get evolutionTriggerRain => 'Con pioggia';

  @override
  String get alternateForms => 'Forme alternative';

  @override
  String get currentForm => 'Forma attuale';

  @override
  String get currentPokemon => 'Pokémon attuale';

  @override
  String evolutionTriggerPartySpecies({required String species}) {
    return 'Con $species';
  }

  @override
  String evolutionTriggerItemGenderMale({required String item}) {
    return 'Usa $item (Maschio)';
  }

  @override
  String evolutionTriggerItemGenderFemale({required String item}) {
    return 'Usa $item (Femmina)';
  }

  @override
  String evolutionTriggerItemDay({required String item}) {
    return 'Usa $item (Giorno)';
  }

  @override
  String evolutionTriggerItemNight({required String item}) {
    return 'Usa $item (Notte)';
  }

  @override
  String evolutionTriggerHeldItem({required String item}) {
    return 'Tiene $item';
  }

  @override
  String evolutionTriggerHeldItemDay({required String item}) {
    return 'Tiene $item (Giorno)';
  }

  @override
  String evolutionTriggerHeldItemNight({required String item}) {
    return 'Tiene $item (Notte)';
  }

  @override
  String get evolutionTriggerAffection => 'Affetto elevato';

  @override
  String get evolutionTriggerBeauty => 'Bellezza elevata';

  @override
  String evolutionTriggerPartyType({required String type}) {
    return '$type in squadra';
  }

  @override
  String get evolutionTriggerGenderMale => 'Maschio';

  @override
  String get evolutionTriggerGenderFemale => 'Femmina';

  @override
  String get aboutPokeFinder => 'Informazioni su PokéFinder';

  @override
  String get aboutAppDescription =>
      'Un Pokédex moderno e leggero per esplorare Pokémon, abilità, mosse e statistiche.';

  @override
  String aboutVersion({required String version}) {
    return 'Versione $version';
  }

  @override
  String aboutBuildNumber({required String buildNumber}) {
    return 'Build $buildNumber';
  }

  @override
  String get aboutDataSource => 'Fonte dati';

  @override
  String get aboutDataSourceDescription =>
      'Tutti i dati, gli sprite e le risorse dei Pokémon provengono da PokeAPI.';

  @override
  String get aboutPokeApiWebsite => 'Sito web PokeAPI';

  @override
  String get aboutDisclaimer => 'Dichiarazione di non responsabilità';

  @override
  String get aboutDisclaimerText =>
      'PokéFinder è un\'applicazione creata da fan non ufficiale e non commerciale, non affiliata, approvata o supportata da Nintendo, GAME FREAK o The Pokémon Company.';

  @override
  String get aboutOpenSourceLicenses => 'Licenze open source';

  @override
  String get aboutSourceCode => 'Codice sorgente';

  @override
  String get aboutGitHubRepository => 'Repository GitHub';

  @override
  String get aboutReportIssue => 'Segnala un problema';

  @override
  String get shareLink => 'Copia link';

  @override
  String get shareLinkCopied => 'Link copiato negli appunti';
}
