class GameCard {
  final String syllable;
  final bool isSelected;

  GameCard({
    required this.syllable,
    this.isSelected = false,
  });

  GameCard copyWith({
    String? syllable,
    bool? isSelected,
  }) {
    return GameCard(
      syllable: syllable ?? this.syllable,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
