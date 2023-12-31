:- use_module(library(pce)).

% Définition des restaurants (à adapter selon vos besoins)
restaurant(le_petit_chef, 'Le Petit Chef', 'Francaise', 'Abordable', 'Centre-ville').
restaurant(la_pasta, 'La Pasta', 'Italienne', 'Moyen', 'Quartier residentiel').
restaurant(noodles, 'Noodles', 'Asiatique', 'Cher', 'Grand quartier').


% Prédicat de recommandation
recommander(Restaurant, Cuisine, Prix, Emplacement) :-
    restaurant(Restaurant, _, Cuisine, Prix, Emplacement).
% Trouver une alternative basée sur le budget
trouver_alternative(Restaurant, _, _, Prix) :-
    restaurant(Restaurant, _, _, Prix, _).

afficher_interface :-
    new(Dialog, dialog('Systeme de Recommandation de Restaurants')),
    send(Dialog, append, new(TextCuisine, text('Quel type de cuisine preferez-vous ?'))),
    send(Dialog, append, new(Cuisine, menu(cuisine, marked))),
    send_list(Cuisine, append, ['Francaise', 'Italienne', 'Asiatique']),

    send(Dialog, append, new(TextPrix, text('Quel est votre budget ?'))),
    send(Dialog, append, new(Prix, menu(prix, marked))),
    send_list(Prix, append, ['Abordable', 'Moyen', 'Cher']),

    send(Dialog, append, new(TextEmplacement, text('Dans quelle region souhaitez-vous manger ?'))),
    send(Dialog, append, new(Emplacement, menu(emplacement, marked))),
    send_list(Emplacement, append, ['Centre-ville', 'Quartier residentiel', 'Grand quartier']),

    % Ajout dun élément de texte pour afficher le résultat
    send(Dialog, append, new(ResultText, text(''))),

    send(Dialog, append, button(repondre, 
                                message(@prolog, afficher_reponse, Cuisine, Prix, Emplacement, ResultText))),
    send(Dialog, open).

afficher_reponse(Cuisine, Prix, Emplacement, ResultText) :-
    % Recuperer les sélections de lutilisateur
    get(Cuisine, selection, SelectedCuisine),
    get(Prix, selection, SelectedPrix),
    get(Emplacement, selection, SelectedEmplacement),

    % Utiliser les sélections pour recommander un restaurant
    (recommander(Restaurant, SelectedCuisine, SelectedPrix, SelectedEmplacement) ->
        % Afficher le résultat
        send(ResultText, value, 'Recommandation de restaurant : '),
        send(ResultText, append, Restaurant)
    ;   % Si aucune recommandation alternative nest trouvée, trouver une alternative basée sur le budget
        trouver_alternative(BudgetRestaurant, _, _, SelectedPrix) ->
        % Afficher une recommandation basée sur le budget
        send(ResultText, value, 'Recommandation alternative de restaurant basée sur le budget : '),
        send(ResultText, append, BudgetRestaurant)
    ;   % Si aucune recommandation alternative nest trouvée, afficher un message par défaut
        send(ResultText, value, 'Aucune recommandation disponible. Veuillez ajuster vos preferences.')
    ).

