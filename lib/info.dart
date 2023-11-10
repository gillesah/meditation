import 'package:flutter/material.dart';

Future<void> dialogBuilder(BuildContext context, int consecutiveDays) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child:IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();},
                  tooltip: 'Fermer',
                  icon: const Icon(Icons.close),
                  color: Color.fromRGBO(142, 45, 226, 1),
                  iconSize: 60
              ),
            ),
            Text('ZenFlow', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),),
            Text(
              "Découvrez notre app de méditation pour initiés ! \n\n"
                  "Choisissez parmi une variété de sons apaisants et réglez la durée selon vos besoins. "
                  "Plongez-vous dans une expérience personnalisée de méditation, conçue pour vous offrir calme et concentration. "
                  "Profitez de moments de détente et de sérénité tout en vous recentrant sur l'instant présent. "
                  "\nBonnes méditations ! \n🧘\n\n\n",
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Text(
              '$consecutiveDays',
              style: TextStyle(color: Colors.black, fontSize: 30),
              textAlign: TextAlign.center,
            ),
            Text(
              'jours consécutifs',
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Fermer'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
