import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/theme/readable_color.dart';

/// Bottom sheet that lets the user toggle shiny sprites and pick an
/// alternate Pokémon form.
///
/// Uses internal state for the shiny toggle so the switch reflects user
/// interaction immediately, then syncs back to the parent via [onShinyChanged].
class FormSelectionBottomSheet extends StatefulWidget {
  const FormSelectionBottomSheet({
    super.key,
    required this.pokemon,
    required this.typeColor,
    required this.textColor,
    required this.showShiny,
    required this.onShinyChanged,
  });

  final Pokemon pokemon;
  final Color typeColor;
  final Color textColor;
  final bool showShiny;
  final ValueChanged<bool> onShinyChanged;

  @override
  State<FormSelectionBottomSheet> createState() =>
      _FormSelectionBottomSheetState();
}

class _FormSelectionBottomSheetState extends State<FormSelectionBottomSheet> {
  late bool _localShowShiny;

  @override
  void initState() {
    super.initState();
    _localShowShiny = widget.showShiny;
  }

  void _onShinyToggled(bool value) {
    setState(() => _localShowShiny = value);
    widget.onShinyChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
      builder: (context, state) {
        final String? selectedFormName;
        final bool isLoadingForm;
        final formFailure = state is PokemonDetailSuccess
            ? state.formFailure
            : null;
        final failedForm = state is PokemonDetailSuccess
            ? state.failedForm
            : null;

        if (state is PokemonDetailSuccess) {
          selectedFormName = state.selectedFormDetails?.name;
          isLoadingForm = state.isLoadingForm;
        } else {
          selectedFormName = widget.pokemon.name;
          isLoadingForm = false;
        }

        final accentColor = widget.typeColor.readableOn(
          Theme.of(context).brightness,
        );

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.t().formSelectorTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    toggled: _localShowShiny,
                    label: context.t().formSelectorShiny,
                    child: SwitchListTile.adaptive(
                      secondary: Icon(
                        _localShowShiny
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      title: Text(
                        context.t().formSelectorShiny,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: _localShowShiny,
                      onChanged: _onShinyToggled,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    context.t().formSelectorForms,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (formFailure != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formFailure.localizedMessage(context),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (failedForm != null)
                                  TextButton.icon(
                                    onPressed: () {
                                      context.read<PokemonDetailBloc>().add(
                                        SelectPokemonFormEvent(failedForm),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                    ),
                                    label: Text(context.t().retryButton),
                                  ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    context.read<PokemonDetailBloc>().add(
                                      SelectPokemonFormEvent(
                                        PokemonForm(
                                          name: widget.pokemon.name,
                                          url: '',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.restore_rounded,
                                    size: 16,
                                  ),
                                  label: Text(context.t().defaultFormRollback),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isLoadingForm)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.pokemon.forms.length,
                      itemBuilder: (context, index) {
                        final form = widget.pokemon.forms[index];
                        final isSelected = form.name == selectedFormName;
                        final displayFormName = formatFormName(
                          context,
                          form.name,
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Semantics(
                            button: true,
                            selected: isSelected,
                            label: displayFormName,
                            child: InkWell(
                              onTap: () {
                                if (state is PokemonDetailSuccess) {
                                  context.read<PokemonDetailBloc>().add(
                                    SelectPokemonFormEvent(form),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 48,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? widget.typeColor.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? accentColor
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayFormName,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? accentColor
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: accentColor,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
