import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/services/i_pokemon_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeBlocEvent, HomeBlocState> {
  HomeBloc() : super(HomeBlocState.initial()) {
    on<UserInputEvent>((event, emit) {
      emit(state.copyWith(userInput: event.userInput));
    });
    on<IsButtonPressedEvent>((event, emit) {
      // Quando il pulsante viene premuto verrà inviato alla schermata di dettaglio l'input dell'utente
      emit(state.copyWith(optionFailureOrPokemonFound: some(right(unit))));
    });
  }
}
