import UIKit

final class ChessCell: UICollectionViewCell {

    static let identifier = "ChessCell"

    private let pieceImageView = UIImageView()
    private let highlightView = UIView()
    private let moveDot = UIView()
    private let captureRing = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        clipsToBounds = true

        contentView.addSubview(highlightView)
        contentView.addSubview(pieceImageView)
        contentView.addSubview(moveDot)
        contentView.addSubview(captureRing)

        [highlightView, pieceImageView, moveDot, captureRing].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        pieceImageView.contentMode = .scaleAspectFit

        moveDot.backgroundColor = ChessTheme.Board.moveDotColor
        moveDot.layer.cornerRadius = 9
        moveDot.isHidden = true

        captureRing.backgroundColor = .clear
        captureRing.layer.borderColor = ChessTheme.Board.captureRingColor.cgColor
        captureRing.layer.borderWidth = 4
        captureRing.isHidden = true

        NSLayoutConstraint.activate([
            highlightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            highlightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            pieceImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pieceImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pieceImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.82),
            pieceImageView.heightAnchor.constraint(equalTo: pieceImageView.widthAnchor),

            moveDot.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moveDot.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moveDot.widthAnchor.constraint(equalToConstant: 18),
            moveDot.heightAnchor.constraint(equalToConstant: 18),

            captureRing.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            captureRing.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            captureRing.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            captureRing.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        captureRing.layer.cornerRadius = captureRing.bounds.width / 2
    }

    func configure(
        row: Int,
        col: Int,
        piece: ChessPiece?,
        isSelected: Bool,
        isPossibleMove: Bool,
        isKingInCheck: Bool,
        isLastMoveFrom: Bool,
        isLastMoveTo: Bool
    ) {
        let isDark = (row + col) % 2 == 1
        contentView.backgroundColor = isDark ? ChessTheme.Board.darkSquare : ChessTheme.Board.lightSquare

        highlightView.backgroundColor = .clear
        highlightView.layer.borderWidth = 0
        moveDot.isHidden = true
        captureRing.isHidden = true

        if let piece = piece {
            pieceImageView.image = UIImage(named: piece.imageName)
        } else {
            pieceImageView.image = nil
        }

        if isLastMoveFrom || isLastMoveTo {
            highlightView.backgroundColor = ChessTheme.Board.lastMoveOverlay
        }

        if isSelected {
            highlightView.backgroundColor = ChessTheme.Board.selectedOverlay
        }

        if isKingInCheck {
            highlightView.backgroundColor = ChessTheme.Board.checkOverlay
        }

        if isPossibleMove {
            if piece != nil {
                captureRing.isHidden = false
            } else {
                moveDot.isHidden = false
            }
        }

        updateCoordinateLabel(row: row, col: col, isDark: isDark)
    }

    private var coordinateLabel: UILabel?

    private func updateCoordinateLabel(row: Int, col: Int, isDark: Bool) {
        coordinateLabel?.removeFromSuperview()
        coordinateLabel = nil

        let showFile = row == 7
        let showRank = col == 0
        guard showFile || showRank else { return }

        let label = UILabel()
        label.font = ChessTheme.Font.coordinate(size: 9)
        label.textColor = isDark ? ChessTheme.Board.coordinateDark : ChessTheme.Board.coordinateLight
        label.translatesAutoresizingMaskIntoConstraints = false

        if showFile && showRank {
            label.text = ["a","b","c","d","e","f","g","h"][col]
            let rankLabel = UILabel()
            rankLabel.font = ChessTheme.Font.coordinate(size: 9)
            rankLabel.textColor = label.textColor
            rankLabel.text = "\(8 - row)"
            rankLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(rankLabel)
            NSLayoutConstraint.activate([
                rankLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
                rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2)
            ])
        } else if showFile {
            label.text = ["a","b","c","d","e","f","g","h"][col]
        } else {
            label.text = "\(8 - row)"
        }

        contentView.addSubview(label)

        if showFile {
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
            ])
        } else {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2)
            ])
        }

        coordinateLabel = label
    }
}
