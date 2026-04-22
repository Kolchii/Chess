import UIKit

final class CapturedPiecesView: UIView {

    private let piecesStack = UIStackView()
    private let scoreLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        piecesStack.axis = .horizontal
        piecesStack.spacing = 2
        piecesStack.alignment = .center

        scoreLabel.font = ChessTheme.Font.body(size: 13)
        scoreLabel.textColor = ChessTheme.Color.accent

        let container = UIStackView(arrangedSubviews: [piecesStack, scoreLabel])
        container.axis = .horizontal
        container.spacing = 6
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with pieces: [ChessPiece], score: Int) {
        piecesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let sorted = pieces.sorted { $0.type.materialValue > $1.type.materialValue }

        sorted.forEach { piece in
            let iv = UIImageView(image: UIImage(named: piece.imageName))
            iv.contentMode = .scaleAspectFit
            iv.widthAnchor.constraint(equalToConstant: 16).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 16).isActive = true
            piecesStack.addArrangedSubview(iv)
        }

        scoreLabel.text = score > 0 ? "+\(score)" : ""
    }
}

private extension PieceType {
    var materialValue: Int {
        switch self {
        case .queen: return 9
        case .rook: return 5
        case .bishop: return 3
        case .knight: return 3
        case .pawn: return 1
        case .king: return 0
        }
    }
}
