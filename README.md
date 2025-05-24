# PokeFinder

# Tools used

**go_router**: (Routing) to handle navigation between different screens

**BLoC**: (Business Logic Component) to handle states and events in the app

**get_it**: (Dependency Injection) to obtain the concrete class of the abstract one that we are requesting at run-time (used for real/mocked data)

# Functionalities

- Screen with an input and a button (search) to search for a pokemon by its name
- Pokemon detail screen
- Service with a method "getPokemon" that has two different implementations: "Mocked" and "Real". "Real" uses the Pokémon APIs for the search, "Mocked" returns a hardcoded pokemon in the app regardless of the input
- Toggle to chose the language of the app
