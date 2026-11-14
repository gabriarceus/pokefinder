import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Copies the deep link of the Pokémon [name] to the clipboard and shows a
/// snackbar. Does nothing when [name] is not a valid Pokémon name.
Future<void> copyPokemonLink(BuildContext context, String name) async {
  final link = buildPokemonShareUri(name);
  if (link == null) return;
  await Clipboard.setData(ClipboardData(text: link.toString()));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.t().shareLinkCopied)));
}
