import UIKit

final class MoveCell: UITableViewCell {

    private let numberLabel = UILabel()
    private let whiteButton = MovePill()
    private let blackButton = MovePill()
    private let spacer = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        numberLabel.font = ChessTheme.Font.moveNumber()
        numberLabel.textColor = ChessTheme.Color.secondaryText
        numberLabel.textAlignment = .right
        numberLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true

        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [numberLabel, whiteButton, blackButton, spacer])
        stack.axis = .horizontal
        stack.spacing = ChessTheme.Spacing.xs
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            whiteButton.widthAnchor.constraint(equalToConstant: 80),
            blackButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    func configure(move: MoveRecord, row: Int, isLatest: Bool) {
        numberLabel.text = "\(row + 1)"

        whiteButton.setText(move.whiteMove ?? "—")
        blackButton.setText(move.blackMove ?? "")

        whiteButton.setHighlighted(isLatest && move.blackMove == nil)
        blackButton.setHighlighted(isLatest && move.blackMove != nil)
        blackButton.isHidden = move.blackMove == nil && !isLatest
    }
}

// MARK: - Move Pill

private final class MovePill: UIView {

    private let label = UILabel()
    private var isHighlighted = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        layer.cornerRadius = 5
        backgroundColor = .clear

        label.font = ChessTheme.Font.notation()
        label.textColor = ChessTheme.Color.primaryText
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }

    func setText(_ text: String) {
        label.text = text
    }

    func setHighlighted(_ highlighted: Bool) {
        isHighlighted = highlighted
        backgroundColor = highlighted ? ChessTheme.Color.accentMuted : .clear
        label.textColor = highlighted ? ChessTheme.Color.accent : ChessTheme.Color.primaryText
        label.font = highlighted
            ? ChessTheme.Font.notation().withBold()
            : ChessTheme.Font.notation()
    }
}

private extension UIFont {
    func withBold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
