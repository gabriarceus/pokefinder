import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';

class FormSelectionBottomSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonBloc, PokemonBlocState>(
      builder: (context, state) {
        final String? selectedFormName;
        final bool isLoadingForm;

        if (state is PokemonBlocSuccess) {
          selectedFormName = state.selectedFormDetails?.name;
          isLoadingForm = state.isLoadingForm;
        } else {
          selectedFormName = pokemon.name;
          isLoadingForm = false;
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.t().formSelectorTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    secondary: Icon(
                      showShiny ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    title: Text(
                      context.t().formSelectorShiny,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: showShiny,
                    activeThumbColor: typeColor,
                    onChanged: (val) {
                      setModalState(() {});
                      onShinyChanged(val);
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    context.t().formSelectorForms,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoadingForm)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: pokemon.forms.length,
                        itemBuilder: (context, index) {
                          final form = pokemon.forms[index];
                          final isSelected = form.name == selectedFormName;
                          final displayFormName = form.name
                              .replaceAll('-', ' ')
                              .split(' ')
                              .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                              .join(' ');

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: InkWell(
                              onTap: () {
                                if (state is PokemonBlocSuccess && !state.isLoadingForm) {
                                  context.read<PokemonBloc>().add(SelectPokemonFormEvent(form));
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? typeColor.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? typeColor : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      displayFormName,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? typeColor : null,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: typeColor,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
