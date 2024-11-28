enum RelationType {
  parent('pai/mãe'),
  child('filho(a)'),
  spouse('cônjuge'),
  sibling('irmão/irmã'),
  friend('amigo(a)'),
  other('outro');

  final String description;

  const RelationType(this.description);

  bool isValidWith(RelationType other) {
    switch (this) {
      case RelationType.parent:
        return other == RelationType.child;
      case RelationType.child:
        return other == RelationType.parent;
      case RelationType.spouse:
        return other == RelationType.spouse;
      case RelationType.sibling:
        return other == RelationType.sibling;
      default:
        return true;
    }
  }
}
