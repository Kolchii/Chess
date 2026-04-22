import UIKit

final class ChessBoardController: UIViewController {

    private let viewModel = ChessBoardViewModel()

    private let topPlayerCard  = PlayerCardView(playerName: "Black", position: .top)
    private let bottomPlayerCard = PlayerCardView(playerName: "White", position: .bottom)
    private let boardView = ChessBoardView()
    private let historyView = MoveHistoryView()
    private let promotionView = PromotionView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ChessTheme.Color.background
        setupNavBar()
        setupUI()
        setupCollection()
        bindViewModel()
        viewModel.fetchBoard()
        SoundManager.shared.gameStart()
        BoardAnimator.flip(boardView.collection, for: .white)
        ChessClockManager.shared.start(turn: .white)
        topPlayerCard.setActive(false)
        bottomPlayerCard.setActive(true)
    }

    // MARK: - Navigation

    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = ChessTheme.Color.accent
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: ChessTheme.Color.primaryText,
            .font: ChessTheme.Font.heading()
        ]
        navigationController?.navigationBar.barTintColor = ChessTheme.Color.background
        navigationController?.navigationBar.isTranslucent = false
        title = "Chess"

        let newGame = UIBarButtonItem(
            image: UIImage(systemName: "arrow.counterclockwise"),
            style: .plain,
            target: self,
            action: #selector(confirmReset)
        )
        navigationItem.rightBarButtonItem = newGame
    }

    // MARK: - Layout

    private func setupUI() {
        [topPlayerCard, boardView, bottomPlayerCard, historyView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            topPlayerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topPlayerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            topPlayerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            topPlayerCard.heightAnchor.constraint(equalToConstant: 48),

            boardView.topAnchor.constraint(equalTo: topPlayerCard.bottomAnchor, constant: 8),
            boardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            boardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor),

            bottomPlayerCard.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 8),
            bottomPlayerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            bottomPlayerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            bottomPlayerCard.heightAnchor.constraint(equalToConstant: 48),

            historyView.topAnchor.constraint(equalTo: bottomPlayerCard.bottomAnchor, constant: 8),
            historyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            historyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCollection() {
        let collection = boardView.collection
        collection.backgroundColor = .clear
        collection.register(ChessCell.self, forCellWithReuseIdentifier: ChessCell.identifier)
        collection.dataSource = self
        collection.delegate = self
    }

    // MARK: - Bindings

    private func bindViewModel() {
        ChessClockManager.shared.onTick = { [weak self] in
            guard let self else { return }
            let wt = ChessClockManager.shared.whiteTime
            let bt = ChessClockManager.shared.blackTime
            let isWhiteTurn = self.viewModel.currentTurn == .white

            self.bottomPlayerCard.setTime(ChessClockManager.shared.formattedWhiteTime())
            self.topPlayerCard.setTime(ChessClockManager.shared.formattedBlackTime())

            self.bottomPlayerCard.setActive(isWhiteTurn, timeRemaining: wt)
            self.topPlayerCard.setActive(!isWhiteTurn, timeRemaining: bt)
        }

        ChessClockManager.shared.onTimeOver = { [weak self] loser in
            guard let self else { return }
            let winner: PieceColor = loser == .white ? .black : .white
            self.showGameOverAlert(winner: winner, reason: "on time")
        }

        viewModel.reloadBoard = { [weak self] in
            guard let self else { return }
            self.boardView.collection.reloadData()
            BoardAnimator.flip(self.boardView.collection, for: self.viewModel.currentTurn)
            self.topPlayerCard.configure(captured: self.viewModel.capturedBlack, score: self.viewModel.blackAdvantage)
            self.bottomPlayerCard.configure(captured: self.viewModel.capturedWhite, score: self.viewModel.whiteAdvantage)
            self.historyView.configure(with: self.viewModel.displayHistory)
            self.updateStatusIndicator()

            if let winner = self.viewModel.checkmateWinner {
                self.showGameOverAlert(winner: winner, reason: "by checkmate")
            }
        }

        viewModel.didMovePiece = { [weak self] r1, c1, r2, c2 in
            self?.animateMove(from: (r1, c1), to: (r2, c2))
        }

        viewModel.showPromotion = { [weak self] in
            guard let self else { return }
            self.view.addSubview(self.promotionView)
            self.promotionView.frame = self.view.bounds
            self.promotionView.onSelect = { [weak self] option in
                self?.viewModel.promotePawn(to: option)
            }
        }
    }

    private func updateStatusIndicator() {
        if let color = viewModel.kingInCheck {
            title = color == .white ? "White in check ⚠️" : "Black in check ⚠️"
        } else {
            title = "Chess"
        }
    }

    // MARK: - Game Over

    @objc private func confirmReset() {
        let alert = UIAlertController(
            title: "New Game?",
            message: "Current game progress will be lost.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "New Game", style: .destructive) { [weak self] _ in
            self?.resetGame()
        })
        present(alert, animated: true)
    }

    private func showGameOverAlert(winner: PieceColor, reason: String) {
        let name = winner == .white ? "White" : "Black"
        let alert = UIAlertController(
            title: "\(name) wins 🏆",
            message: "Won \(reason)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        present(alert, animated: true)
    }

    private func resetGame() {
        viewModel.resetGame()
        ChessClockManager.shared.reset()
        ChessClockManager.shared.start(turn: .white)
        bottomPlayerCard.setActive(true, timeRemaining: ChessClockManager.shared.whiteTime)
        topPlayerCard.setActive(false, timeRemaining: ChessClockManager.shared.blackTime)
        bottomPlayerCard.setTime(ChessClockManager.shared.formattedWhiteTime())
        topPlayerCard.setTime(ChessClockManager.shared.formattedBlackTime())
        title = "Chess"
    }

    // MARK: - Piece Animation

    private func animateMove(from old: (Int, Int), to new: (Int, Int)) {
        let collection = boardView.collection
        let fromIndex = IndexPath(item: old.0 * 8 + old.1, section: 0)
        let toIndex   = IndexPath(item: new.0 * 8 + new.1, section: 0)

        guard let fromCell = collection.cellForItem(at: fromIndex) else {
            collection.reloadData()
            return
        }

        let snapshot = fromCell.snapshotView(afterScreenUpdates: false) ?? UIView()
        snapshot.frame = collection.convert(fromCell.frame, to: view)
        view.addSubview(snapshot)
        fromCell.alpha = 0

        guard let toCell = collection.cellForItem(at: toIndex) else {
            snapshot.removeFromSuperview()
            collection.reloadData()
            return
        }

        let targetFrame = collection.convert(toCell.frame, to: view)

        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            snapshot.frame = targetFrame
        } completion: { _ in
            snapshot.removeFromSuperview()
            collection.reloadData()
        }
    }
}

// MARK: - Collection View

extension ChessBoardController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { 64 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChessCell.identifier, for: indexPath) as! ChessCell

        let row = indexPath.item / 8
        let col = indexPath.item % 8
        let piece = viewModel.piece(at: row, col: col)

        cell.configure(
            row: row, col: col, piece: piece,
            isSelected:      viewModel.selectedPiece?.row == row && viewModel.selectedPiece?.col == col,
            isPossibleMove:  viewModel.possibleMoves.contains { $0.row == row && $0.col == col },
            isKingInCheck:   viewModel.isKingCell(row: row, col: col),
            isLastMoveFrom:  viewModel.lastMoveFrom?.row == row && viewModel.lastMoveFrom?.col == col,
            isLastMoveTo:    viewModel.lastMoveTo?.row == row && viewModel.lastMoveTo?.col == col
        )

        return cell
    }
}

extension ChessBoardController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectPiece(at: indexPath.item / 8, col: indexPath.item % 8)
    }
}

extension ChessBoardController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = floor(collectionView.bounds.width / 8)
        return CGSize(width: side, height: side)
    }
}

// MARK: - Player Card

final class PlayerCardView: UIView {

    enum Position { case top, bottom }

    private let nameLabel  = UILabel()
    private let capturedView = CapturedPiecesView()
    private let clockView  = ClockView()

    init(playerName: String, position: Position) {
        super.init(frame: .zero)
        setup(name: playerName)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup(name: String) {
        backgroundColor = .clear

        nameLabel.text = name
        nameLabel.font = ChessTheme.Font.body(size: 13)
        nameLabel.textColor = ChessTheme.Color.secondaryText

        clockView.setPlayerName(name)

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, capturedView])
        infoStack.axis = .vertical
        infoStack.spacing = 2
        infoStack.alignment = .leading

        let row = UIStackView(arrangedSubviews: [infoStack, clockView])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.translatesAutoresizingMaskIntoConstraints = false

        addSubview(row)

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            clockView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }

    func setActive(_ active: Bool, timeRemaining: Int? = nil) {
        clockView.setActive(active, timeRemaining: timeRemaining)
        nameLabel.textColor = active ? ChessTheme.Color.primaryText : ChessTheme.Color.secondaryText
    }

    func setTime(_ text: String) {
        clockView.setTime(text)
    }

    func configure(captured: [ChessPiece], score: Int) {
        capturedView.configure(with: captured, score: score)
    }
}
