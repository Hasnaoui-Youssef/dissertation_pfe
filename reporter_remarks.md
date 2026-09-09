# Reporter's remarks on the PFE report draft

These are the remarks left by the project reporter on the draft of my engineering graduation project (PFE) report, extracted verbatim from the annotated PDF `jury_report_remarks.pdf` (page numbers and highlighted passages preserved alongside each remark; tick a box once the remark is addressed).

## Page 4

- [ ] Le remerciement doit être rédigé en format de texte officiel
  _Highlighted:_ "I would like to sincerely thank everyone who had a hand in the development of this project."

- [ ] non centré et non italique
  _Highlighted:_ "I wo"

## Page 5

- [ ] 5 pages ne constitue pas un chapitre
  _Highlighted:_ "7"

- [ ] of what ?titre non spécifique
  _Highlighted:_ "Theory and Key Concepts"

## Page 6

- [ ] (Highlight with no written remark.)
  _Highlighted:_ "2.5.1 Device Description: CMSIS-SVD ."

## Page 12

- [ ] reduit l'interligne
  _Highlighted:_ "List of Acronyms"

- [ ] La liste d’acronymes est très longue. Supprimer les acronymes trop généraux ou peu utiles (par exemple RAM, ROM, XML, API si leur usage ne justifie pas une entrée) et conserver surtout les termes spécifiques au sujet. Harmoniser aussi la nomenclature Arm/ARM selon les conventions actuelles.

## Page 14

- [ ] Orthographe : « Integrated Development Environment ».
  _Highlighted:_ "Integrated Developement Environment"

## Page 16

- [ ] efernce bibliographique
  _Highlighted:_ "OpenCSD,"

- [ ] La problématique doit être formulée explicitement. Par exemple : comment rendre les capacités de trace d’instructions des STM32 accessibles dans une chaîne de débogage ouverte et intégrée, sans sonde de trace dédiée ni dépendance à un environnement propriétaire ?

## Page 17

- [ ] Les sommaires des chapitres sont réservés aux rapports volumineux.Supprime le
  _Highlighted:_ "Contents 1 Host Organization . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3 2 Project Context . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5 3 Conclusion . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7"

## Page 18

- [ ] La présentation de l’entreprise est trop développée; concentre toi sur son lien avec ton projet.

## Page 20

- [ ] Ca, c'est pas une problématique, c'est plutot un contexte.Il faut continuer et énoncer ce que tu dois réaliser dans ton projet (problématique)
  _Highlighted:_ "Debugging software offers a unified experience across many chips, vendors and architectures. It achieves this through a common layer of abstraction that presents heterogeneous targets behind a single conceptual model. The abstraction holds for simple primitives such as memory views and breakpoints. It fails for the advanced features, such as reconstructing execution flow, conditional and cross-triggering of debug events, or recovering execution history after a failure. Those features do not generalize, since each is tightly coupled to a vendor-specific implementation. The gap between what a chip provides and what a developer can reach is the central concern of this project."

## Page 21

- [ ] Etat de l'art est trop général, spécifie le domaine
  _Highlighted:_ "State of the Art"

- [ ] ??
  _Highlighted:_ "The features the proprietary"

- [ ] Ajouter une colonne « Proposed approach » ou un tableau de positionnement final avec des critères tels que : debug classique, instruction trace, on-chip trace, décodage offline, intégration IDE, dépendance à une sonde dédiée, caractère open source. Cela permettra de visualiser immédiatement l’apport du projet par rapport à l’existant.

## Page 22

- [ ] Ta problématique annonce quatre résultats, alors que le chapitre 3 parle de trois livrables. Harmoniser les deux niveaux : distinguer éventuellement les livrables industriels des contributions techniques.

## Page 24

- [ ] a
  _Highlighted:_ "an"

- [ ] (Highlight with no written remark.)
  _Highlighted:_ "An"

- [ ] Ce chapitre est très riche mais trop long par rapport au reste du mémoire Réduire les éléments de type cours général et conserver les concepts mobilisés dans l’architecture, l’implémentation et la validation.

- [ ] Termine ce chapitre par une section « Positioning of this work » expliquant précisément le verrou non couvert par l’existant.

## Page 25

- [ ] Tu n'as pas introduit le RSP
  _Highlighted:_ "RSP"

## Page 26

- [ ] Cette partie est pertinente car elle est réutilisée ensuite pour justifier la stratégie de placement automatique des breakpoints. Conserver ce type de contenu directement relié à une décision de conception, et alléger les notions qui ne sont pas exploitées ensuite.

- [ ] modifying
  _Highlighted:_ "midoifying t"

## Page 29

- [ ] functioning
  _Highlighted:_ "s functionning."

## Page 31

- [ ] The addresses of the exception handlers are stored in a vector table indexed by the exception number
  _Highlighted:_ "And the address of the entirety of the handlers are stored contiguously i"

## Page 34

- [ ] combines
  _Highlighted:_ "h comibenes t"

## Page 41

- [ ] Tu n'as pas besoin d'écrire taken from, met juste la référence.
  _Highlighted:_ "taken from"

## Page 47

- [ ] Les objectifs détaillés arrivent trop tard, après près de 30 pages. Une synthèse des objectifs, contraintes et livrables doit être donnée dès  le chapitre 1. Le chapitre 3 peut ensuite conserver la spécification détaillée des exigences et de l’environnement de travail.

- [ ] Une section ne peut pas contenir uniquement un tableau ou une figure, il faut toujours rédiger un paragraphe descriptif.
  _Highlighted:_ "3.1.1 Scope"

## Page 48

- [ ] Très bonne formalisation des exigences fonctionnelles. Pour renforcer la démarche d’ingénierie, relier explicitement chaque exigence à un composant d’architecture, à sa réalisation et au test qui la vérifie.

## Page 51

- [ ] Meme remarque partout dans ce chapitre, corrige toutes les sections concernées
  _Highlighted:_ "Trace Resources Available on the Target"

## Page 54

- [ ] Le chapitre décrit correctement ce qui a été construit, mais il doit davantage justifier pourquoi cette architecture a été choisie. Pour chaque décision importante, indiquer l’alternative envisagée, la contrainte associée et la raison du choix retenu.

## Page 55

- [ ] of what ?
  _Highlighted:_ "Layers"

- [ ] Tous les titres doivent avoir un sens complet, ils sont lus dans la table des matières indépendamment du contenu.
  _Highlighted:_ "Transport"

## Page 57

- [ ] Préciser davantage la justification de cette abstraction : quel problème de couplage résout-elle ? Quelles alternatives étaient possibles ? Quels bénéfices apporte-t-elle pour la portabilité, les tests et l’indépendance vis-à-vis des bibliothèques externes ?

## Page 58

- [ ] Cette phrase identifie enfin clairement la contribution principale. Elle doit être annoncée beaucoup plus tôt, idéalement dans l’introduction générale, puis reprise comme fil conducteur des chapitres d’architecture, d’implémentation et de validation.
  _Highlighted:_ "This section states the pipeline that turns the execution of a program into a record expressed in source terms. It is the primary contribution of the project."

## Page 59

- [ ] C'est une figure d'architecture. Expliquer avant la figure pourquoi cette décomposition est nécessaire, puis après la figure ce qu’elle permet : découplage matériel/hôte, analyse offline, testabilité, réutilisation.

## Page 62

- [ ] Renommer en Development Methodology, et présenter la démarche plutôt qu’une simple chronologie : exploration de la trace, validation offline, développement des pilotes, intégration du debugger, frontend, puis validation matérielle.

- [ ] Ajoute aussi un schéma synthétique de la méthodologie.

## Page 63

- [ ] Bien distinguer ici ce qui provient d’OpenOCD et ce qui a été conçu/modifié dans le cadre du PFE.

- [ ] Ta contribution personnelle doit être identifiable sans ambiguïté, notamment pour les adaptations du build, la gestion des terminaisons, l’intégration des scripts et la sérialisation des commandes.Ca permet de mettre en valeur ton travail.

## Page 67

- [ ] La combinaison LLDB + OpenOCD est un choix architectural central. Expliquer plus explicitement pourquoi LLDB seul et OpenOCD seul ne satisfont pas les besoins.

## Page 72

- [ ] If
  _Highlighted:_ "For each breakpoint the engine consults the memory map provided by the device description. if the location lies in writable memory, a software breakpoint is used. Otherwise a hardware breakpoint is used."

## Page 75

- [ ] Les captures d’écran sont trop petites pour une lecture confortable dans un rapport A4 ; chaque figure doit montrer clairement l’information que le texte analyse.

- [ ] Cette partie est suffisamment importante pour devenir un chapitre autonome « Experimental Validation and Results ». La validation ne doit pas apparaître comme une sous-partie de l’implémentation : elle doit démontrer séparément que la solution répond aux objectifs et exigences.

- [ ] Cette phrase est essentielle pour identifier la contribution personnelle, mais elle arrive très tard. Reprendre cette délimitation entre composants réutilisés et composants développés dès l’introduction et au début du chapitre d’implémentation.
  _Highlighted:_ "CoreSight drivers and the GDB RSP corrections added. Decoding is performed by OpenCSD. Written for this project are the two CoreSight drivers, the trace pipeline from extraction through reconstruction, the domain components that constitute the core of the engine, the device description provider, and the frontend extension. The licenses of the adopted work are carried unchanged."

## Page 76

- [ ] Le protocole de test est intéressant, mais il faut expliciter les critères de succès. L’absence de framework de tests peut être conservée, mais doit être justifiée comme un choix d’ingénierie plutôt qu’un simple constat.

## Page 77

- [ ] Résultat majeur à mieux valoriser. Ajouter un tableau de comparaison quantitatif : nombre d’instructions comparées, taux de concordance, divergences observées, conditions expérimentales et versions des outils.

## Page 78

- [ ] Très bonne synthèse de vérification des exigences. Pour renforcer la validation, associer à chaque exigence un ou plusieurs indicateurs mesurables et renvoyer à un protocole/test clairement identifié.

## Page 79

- [ ] Une seule capture est insuffisante pour caractériser les performances de la solution. Ajouter plusieurs charges : boucle, appels de fonctions, branches fréquentes, interruptions, débordement de buffer. Mesurer au minimum la taille de trace, le nombre d’instructions reconstruites, les gaps, le temps de décodage/reconstruction et éventuellement le débit.
  _Highlighted:_ "one capture"

## Page 81

- [ ] La conclusion doit être structurée explicitement autour de : objectif initial, contributions personnelles, résultats quantitatifs, limites, puis perspectives. Cela permettra de mieux valoriser le travail réalisé et d’éviter une simple répétition descriptive des chapitres.

- [ ] Réécris complètement la conclusion
