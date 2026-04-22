import UIKit

final class ChessBoardController: UIViewController {

    private let viewModel       = ChessBoardViewModel()
    private let topPlayerRow    = PlayerRowView(name: "Black", initial: "B")
    private let bottomPlayerRow = PlayerRowView(name: "White", initial: "W")
    private let boardView       = ChessBoardView()
    private let moveStrip       = MoveStripView()
    private let promotionView   = PromotionView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ChessTheme.Color.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        setupCollection()
        bindViewModel()
        viewModel.fetchBoard()
        SoundManager.shared.gameStart()
        BoardAnimator.flip(boardView.collection, for: .white)
        ChessClockManager.shared.start(turn: .white)
        topPlayerRow.setActive(false)
        bottomPlayerRow.setActive(true)
    }

    // MARK: - Layout

    private func setupUI() {
        let topBar    = makeTopBar()
        let actionBar = makeActionBar()

        [topBar, topPlayerRow, boardView, bottomPlayerRow, moveStrip, actionBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 36),

            topPlayerRow.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 6),
            topPlayerRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topPlayerRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topPlayerRow.heightAnchor.constraint(equalToConstant: 52),

            boardView.topAnchor.constraint(equalTo: topPlayerRow.bottomAnchor, constant: 10),
            boardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            boardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor),

            bottomPlayerRow.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 10),
            bottomPlayerRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomPlayerRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomPlayerRow.heightAnchor.constraint(equalToConstant: 52),

            moveStrip.topAnchor.constraint(equalTo: bottomPlayerRow.bottomAnchor, constant: 10),
            moveStrip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            moveStrip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            moveStrip.heightAnchor.constraint(equalToConstant: 44),

            actionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            actionBar.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func makeTopBar() -> UIView {
        let container = UIView()

        let backBtn = CircleIconButton(systemName: "chevron.left")
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let modeLabel = UILabel()
        modeLabel.text = ChessClockManager.shared.currentSettings.modeLabel
        modeLabel.font = ChessTheme.Font.callout()
        modeLabel.textColor = ChessTheme.Color.secondaryText

        let menuBtn = CircleIconButton(systemName: "ellipsis")
        menuBtn.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)

        [backBtn, modeLabel, menuBtn].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 36),
            backBtn.heightAnchor.constraint(equalToConstant: 36),

            modeLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            modeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            menuBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            menuBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            menuBtn.widthAnchor.constraint(equalToConstant: 36),
            menuBtn.heightAnchor.constraint(equalToConstant: 36),
        ])

        return container
    }

    private func makeActionBar() -> UIStackView {
        let actions: [(String, String, Selector?)] = [
            ("flag",                "Resign", #selector(resignTapped)),
            ("equal",               "Draw",   nil),
            ("arrow.up.arrow.down", "Flip",   #selector(flipBoard)),
            ("ellipsis",            "More",   #selector(menuTapped)),
        ]

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually

        for (icon, label, action) in actions {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let img = UIImage(systemName: icon, withConfiguration: config)
            let btn = ActionBarButton(image: img, label: label)
            if let action { btn.addTarget(self, action: action, for: .touchUpInside) }
            stack.addArrangedSubview(btn)
        }
        return stack
    }

    // MARK: - Collection

    private func setupCollection() {
        let cv = boardView.collection
        cv.backgroundColor = .clear
        cv.register(ChessCell.self, forCellWithReuseIdentifier: ChessCell.identifier)
        cv.dataSource = self
        cv.delegate = self
    }

    // MARK: - Bindings

    private func bindViewModel() {
        ChessClockManager.shared.onTick = { [weak self] in
            guard let self else { return }
            let wt = ChessClockManager.shared.whiteTime
            let bt = ChessClockManager.shared.blackTime
            let isWhiteTurn = self.viewModel.currentTurn == .white
            self.bottomPlayerRow.setTime(ChessClockManager.shared.formattedWhiteTime())
            self.topPlayerRow.setTime(ChessClockManager.shared.formattedBlackTime())
            self.bottomPlayerRow.setActive(isWhiteTurn, timeRemaining: wt)
            self.topPlayerRow.setActive(!isWhiteTurn, timeRemaining: bt)
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
            self.topPlayerRow.configure(captured: self.viewModel.capturedBlack, score: self.viewModel.blackAdvantage)
            self.bottomPlayerRow.configure(captured: self.viewModel.capturedWhite, score: self.viewModel.whiteAdvantage)
            self.moveStrip.configure(with: self.viewModel.displayHistory)

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

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func menuTapped() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "New Game", style: .destructive) { [weak self] _ in self?.resetGame() })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func resignTapped() {
        let alert = UIAlertController(title: "Resign?", message: "This will end the game.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Resign", style: .destructive) { [weak self] _ in self?.resetGame() })
        present(alert, animated: true)
    }

    @objc private func flipBoard() {
        let flipped: PieceColor = viewModel.currentTurn == .white ? .black : .white
        BoardAnimator.flip(boardView.collection, for: flipped)
    }

    // MARK: - Game Over

    private func showGameOverAlert(winner: PieceColor, reason: String) {
        let name = winner == .white ? "White" : "Black"
        let alert = UIAlertController(title: "\(name) wins", message: "Won \(reason)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "New Game", style: .default) { [weak self] _ in self?.resetGame() })
        present(alert, animated: true)
    }

    private func resetGame() {
        viewModel.resetGame()
        ChessClockManager.shared.reset()
        ChessClockManager.shared.start(turn: .white)
        bottomPlayerRow.setActive(true, timeRemaining: ChessClockManager.shared.whiteTime)
        topPlayerRow.setActive(false, timeRemaining: ChessClockManager.shared.blackTime)
        bottomPlayerRow.setTime(ChessClockManager.shared.formattedWhiteTime())
        topPlayerRow.setTime(ChessClockManager.shared.formattedBlackTime())
        moveStrip.configure(with: [])
    }

    // MARK: - Piece Animation

    private func animateMove(from old: (Int, Int), to new: (Int, Int)) {
        let cv = boardView.collection
        let fromIndex = IndexPath(item: old.0 * 8 + old.1, section: 0)
        let toIndex   = IndexPath(item: new.0 * 8 + new.1, section: 0)

        guard let fromCell = cv.cellForItem(at: fromIndex) else { cv.reloadData(); return }

        let snapshot = fromCell.snapshotView(afterScreenUpdates: false) ?? UIView()
        snapshot.frame = cv.convert(fromCell.frame, to: view)
        view.addSubview(snapshot)
        fromCell.alpha = 0

        guard let toCell = cv.cellForItem(at: toIndex) else {
            snapshot.removeFromSuperview(); cv.reloadData(); return
        }

        UIView.animate(
            withDuration: 0.28, delay: 0,
            usingSpringWithDamping: 0.78, initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            snapshot.frame = cv.convert(toCell.frame, to: self.view)
        } completion: { _ in
            snapshot.removeFromSuperview()
            cv.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ChessBoardController: UICollectionViewDataSource {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection s: Int) -> Int { 64 }

    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: ChessCell.identifier, for: ip) as! ChessCell
        let row = ip.item / 8, col = ip.item % 8
        cell.configure(
            row: row, col: col,
            piece: viewModel.piece(at: row, col: col),
            isSelected:     viewModel.selectedPiece?.row == row && viewModel.selectedPiece?.col == col,
            isPossibleMove: viewModel.possibleMoves.contains { $0.row == row && $0.col == col },
            isKingInCheck:  viewModel.isKingCell(row: row, col: col),
            isLastMoveFrom: viewModel.lastMoveFrom?.row == row && viewModel.lastMoveFrom?.col == col,
            isLastMoveTo:   viewModel.lastMoveTo?.row == row && viewModel.lastMoveTo?.col == col
        )
        return cell
    }
}

extension ChessBoardController: UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, didSelectItemAt ip: IndexPath) {
        viewModel.selectPiece(at: ip.item / 8, col: ip.item % 8)
    }
}

extension ChessBoardController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, layout l: UICollectionViewLayout, sizeForItemAt ip: IndexPath) -> CGSize {
        CGSize(width: floor(cv.bounds.width / 8), height: floor(cv.bounds.width / 8))
    }
}

// MARK: - PlayerRowView

final class PlayerRowView: UIView {

    private let nameLabel    = UILabel()
    private let capturedView = CapturedPiecesView()
    private let clockView    = ClockView()

    init(name: String, initial: String) {
        super.init(frame: .zero)
        setup(name: name, initial: initial)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup(name: String, initial: String) {
        let avatar = UIView()
        avatar.backgroundColor = ChessTheme.Color.elevated2
        avatar.layer.cornerRadius = 16
        avatar.translatesAutoresizingMaskIntoConstraints = false

        let initLabel = UILabel()
        initLabel.text = String(initial.prefix(1)).uppercased()
        initLabel.font = ChessTheme.Font.heading(size: 13)
        initLabel.textColor = ChessTheme.Color.primaryText
        initLabel.textAlignment = .center
        initLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(initLabel)

        NSLayoutConstraint.activate([
            initLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 32),
            avatar.heightAnchor.constraint(equalToConstant: 32),
        ])

        nameLabel.text = name
        nameLabel.font = ChessTheme.Font.heading(size: 15)
        nameLabel.textColor = ChessTheme.Color.primaryText

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, capturedView])
        infoStack.axis = .vertical
        infoStack.spacing = 3
        infoStack.alignment = .leading

        clockView.setPlayerName(name)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [avatar, infoStack, spacer, clockView])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.centerYAnchor.constraint(equalTo: centerYAnchor),
            clockView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])
    }

    func setActive(_ active: Bool, timeRemaining: Int? = nil) {
        clockView.setActive(active, timeRemaining: timeRemaining)
        nameLabel.textColor = active ? ChessTheme.Color.primaryText : ChessTheme.Color.secondaryText
    }

    func setTime(_ text: String) { clockView.setTime(text) }

    func configure(captured: [ChessPiece], score: Int) {
        capturedView.configure(with: captured, score: score)
    }
}

// MARK: - MoveStripView

final class MoveStripView: UIView {

    private let scrollView = UIScrollView()
    private let stackView  = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = ChessTheme.Color.surface
        layer.cornerRadius = ChessTheme.Radius.md
        layer.borderColor = ChessTheme.Color.border.cgColor
        layer.borderWidth = 0.5

        let movesLabel = UILabel()
        movesLabel.text = "MOVES"
        movesLabel.font = ChessTheme.Font.caption()
        movesLabel.textColor = ChessTheme.Color.tertiaryText
        movesLabel.letterSpacing(0.3)
        movesLabel.setContentHuggingPriority(.required, for: .horizontal)

        scrollView.showsHorizontalScrollIndicator = false

        stackView.axis = .horizontal
        stackView.spacing = 14
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])

        let chevron = UIImageView(image: UIImage(systemName: "chevron.up"))
        chevron.tintColor = ChessTheme.Color.tertiaryText
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [movesLabel, scrollView, chevron])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    func configure(with history: [MoveRecord]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if history.isEmpty {
            let empty = UILabel()
            empty.text = "No moves yet"
            empty.font = ChessTheme.Font.caption()
            empty.textColor = ChessTheme.Color.tertiaryText
            stackView.addArrangedSubview(empty)
            return
        }

        for (i, record) in history.enumerated() {
            let isLast = i == history.count - 1

            let numLabel = UILabel()
            numLabel.text = "\(i + 1)."
            numLabel.font = ChessTheme.Font.moveNumber()
            numLabel.textColor = ChessTheme.Color.tertiaryText

            let moveLabel = UILabel()
            var text = record.whiteMove ?? ""
            if let black = record.blackMove { text += text.isEmpty ? black : " \(black)" }
            moveLabel.text = text
            moveLabel.font = ChessTheme.Font.notation()
            moveLabel.textColor = isLast ? ChessTheme.Color.accent : ChessTheme.Color.primaryText

            let pair = UIStackView(arrangedSubviews: [numLabel, moveLabel])
            pair.axis = .horizontal
            pair.spacing = 3
            stackView.addArrangedSubview(pair)
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let maxX = self.scrollView.contentSize.width - self.scrollView.bounds.width
            if maxX > 0 { self.scrollView.setContentOffset(CGPoint(x: maxX, y: 0), animated: true) }
        }
    }
}

// MARK: - CircleIconButton

private final class CircleIconButton: UIButton {
    init(systemName: String) {
        super.init(frame: .zero)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        tintColor = ChessTheme.Color.primaryText
        backgroundColor = ChessTheme.Color.elevated
        layer.cornerRadius = 18
        addTarget(self, action: #selector(down), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func down() {
        UIView.animate(withDuration: 0.10) { self.transform = CGAffineTransform(scaleX: 0.88, y: 0.88) }
    }
    @objc private func up() {
        UIView.animate(withDuration: 0.20, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 6) {
            self.transform = .identity
        }
    }
}

// MARK: - ActionBarButton

private final class ActionBarButton: UIButton {
    init(image: UIImage?, label: String) {
        super.init(frame: .zero)

        let imgView = UIImageView(image: image)
        imgView.tintColor = ChessTheme.Color.primaryText
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = false

        let lbl = UILabel()
        lbl.text = label
        lbl.font = ChessTheme.Font.caption(size: 10)
        lbl.textColor = ChessTheme.Color.secondaryText
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false

        let stack = UIStackView(arrangedSubviews: [imgView, lbl])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            imgView.widthAnchor.constraint(equalToConstant: 18),
            imgView.heightAnchor.constraint(equalToConstant: 18),
        ])

        backgroundColor = ChessTheme.Color.surface
        layer.cornerRadius = ChessTheme.Radius.md
        layer.borderColor = ChessTheme.Color.border.cgColor
        layer.borderWidth = 0.5

        addTarget(self, action: #selector(down), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func down() { UIView.animate(withDuration: 0.10) { self.alpha = 0.6 } }
    @objc private func up()   { UIView.animate(withDuration: 0.20) { self.alpha = 1.0 } }
}
