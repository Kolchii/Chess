import Foundation

final class ChessBoardViewModel {

    private(set) var pieces: [ChessPiece] = []
    private(set) var selectedPiece: ChessPiece?
    private(set) var possibleMoves: [(row: Int, col: Int)] = []

    private(set) var capturedWhite: [ChessPiece] = []
    private(set) var capturedBlack: [ChessPiece] = []

    private(set) var currentTurn: PieceColor = .white
    private(set) var kingInCheck: PieceColor?
    private(set) var checkmateWinner: PieceColor?

    private(set) var lastMoveFrom: (row: Int, col: Int)?
    private(set) var lastMoveTo: (row: Int, col: Int)?

    private(set) var whiteAdvantage: Int = 0
    private(set) var blackAdvantage: Int = 0

    private(set) var promotionPiece: ChessPiece?
    var showPromotion: (() -> Void)?

    private(set) var moveHistory: [MoveRecord] = []
    private var pendingWhiteMove: String?

    var displayHistory: [MoveRecord] {
        var history = moveHistory
        if let pending = pendingWhiteMove {
            history.append(MoveRecord(whiteMove: pending, blackMove: nil))
        }
        return history
    }

    var reloadBoard: (() -> Void)?
    var didMovePiece: ((_ r1: Int, _ c1: Int, _ r2: Int, _ c2: Int) -> Void)?

    func fetchBoard() {
        LocalNetworkManager.shared.fetchBoard { [weak self] result in
            switch result {
            case .success(let pieces):
                self?.pieces = pieces
                DispatchQueue.main.async { self?.reloadBoard?() }
            case .failure(let error):
                print("Fetch error:", error)
            }
        }
    }

    func piece(at row: Int, col: Int) -> ChessPiece? {
        pieces.first { $0.row == row && $0.col == col }
    }

    func isKingCell(row: Int, col: Int) -> Bool {
        guard let color = kingInCheck else { return false }
        return pieces.contains {
            $0.type == .king && $0.color == color && $0.row == row && $0.col == col
        }
    }

    func selectPiece(at row: Int, col: Int) {
        if possibleMoves.contains(where: { $0.row == row && $0.col == col }) {
            movePiece(to: row, col: col)
            return
        }

        guard let piece = piece(at: row, col: col),
              piece.color == currentTurn else {
            selectedPiece = nil
            possibleMoves.removeAll()
            reloadBoard?()
            return
        }

        selectedPiece = piece
        possibleMoves = ChessEngine.shared.possibleMoves(for: piece, pieces: pieces)
        reloadBoard?()
    }

    private func performCastlingIfNeeded(king: ChessPiece, fromCol: Int, toCol: Int, row: Int) {
        guard abs(fromCol - toCol) == 2 else { return }

        let rookFromCol = toCol == 6 ? 7 : 0
        let rookToCol   = toCol == 6 ? 5 : 3

        if let rookIndex = pieces.firstIndex(where: {
            $0.type == .rook && $0.row == row && $0.col == rookFromCol
        }) {
            let rook = pieces.remove(at: rookIndex)
            pieces.append(ChessPiece(type: .rook, color: rook.color, row: row, col: rookToCol, hasMoved: true))
        }

        SoundManager.shared.castle()
    }

    private func movePiece(to row: Int, col: Int) {
        guard let selected = selectedPiece else { return }

        let oldRow = selected.row
        let oldCol = selected.col
        var isCapture = false

        if let target = EnPassantManager.shared.targetSquare,
           target.row == row, target.col == col,
           let pawn = EnPassantManager.shared.pawnToCapture {

            pieces.removeAll { $0.row == pawn.row && $0.col == pawn.col }
            if selected.color == .white { capturedWhite.append(pawn) }
            else { capturedBlack.append(pawn) }
            SoundManager.shared.capture()
            isCapture = true
        }

        pieces.removeAll { $0.row == oldRow && $0.col == oldCol }

        if let capturedIndex = pieces.firstIndex(where: { $0.row == row && $0.col == col }) {
            let captured = pieces[capturedIndex]
            if selected.color == .white { capturedWhite.append(captured) }
            else { capturedBlack.append(captured) }
            pieces.remove(at: capturedIndex)
            if !isCapture { SoundManager.shared.capture() }
            isCapture = true
        } else if !isCapture {
            SoundManager.shared.moveSelf()
        }

        let movedPiece = ChessPiece(type: selected.type, color: selected.color, row: row, col: col, hasMoved: true)
        pieces.append(movedPiece)

        let castleSide: CastleSide? = {
            guard selected.type == .king, abs(oldCol - col) == 2 else { return nil }
            return col == 6 ? .kingside : .queenside
        }()

        if castleSide != nil {
            performCastlingIfNeeded(king: selected, fromCol: oldCol, toCol: col, row: row)
        }

        EnPassantManager.shared.registerDoublePawnMove(piece: movedPiece, fromRow: oldRow, toRow: row)

        currentTurn = currentTurn == .white ? .black : .white
        ChessClockManager.shared.switchTurn(to: currentTurn)

        let opponentColor: PieceColor = selected.color == .white ? .black : .white
        let checkState: CheckState
        if CheckmateValidator.isCheckmate(color: opponentColor, pieces: pieces) {
            checkmateWinner = selected.color
            kingInCheck = opponentColor
            SoundManager.shared.gameEnd()
            checkState = .checkmate
        } else if CheckValidator.isKingInCheck(color: opponentColor, pieces: pieces) {
            kingInCheck = opponentColor
            SoundManager.shared.check()
            checkState = .check
        } else {
            kingInCheck = nil
            checkState = .none
        }

        if CheckmateValidator.isCheckmate(color: selected.color, pieces: pieces) && checkmateWinner == nil {
            checkmateWinner = opponentColor
            SoundManager.shared.gameEnd()
        }

        let notation = ChessNotationConverter.notation(
            piece: selected,
            fromRow: oldRow,
            fromCol: oldCol,
            toRow: row,
            toCol: col,
            capture: isCapture,
            castleSide: castleSide,
            checkState: checkState
        )

        if selected.color == .white {
            pendingWhiteMove = notation
        } else {
            moveHistory.append(MoveRecord(whiteMove: pendingWhiteMove, blackMove: notation))
            pendingWhiteMove = nil
        }

        selectedPiece = nil
        possibleMoves.removeAll()
        lastMoveFrom = (oldRow, oldCol)
        lastMoveTo = (row, col)

        let advantage = MaterialCalculator.materialAdvantage(pieces: pieces)
        whiteAdvantage = advantage.white
        blackAdvantage = advantage.black

        didMovePiece?(oldRow, oldCol, row, col)
        reloadBoard?()
    }

    func promotePawn(to option: PromotionOption) {
        guard let pawn = promotionPiece else { return }
        pieces.removeAll { $0.row == pawn.row && $0.col == pawn.col }
        let promoted = PromotionHandler.promote(piece: pawn, to: option)
        pieces.append(promoted)
        SoundManager.shared.promote()
        promotionPiece = nil
        reloadBoard?()
    }

    func resetGame() {
        pieces = GameResetManager.initialBoard()
        capturedWhite.removeAll()
        capturedBlack.removeAll()
        moveHistory.removeAll()
        pendingWhiteMove = nil
        selectedPiece = nil
        possibleMoves.removeAll()
        currentTurn = .white
        kingInCheck = nil
        checkmateWinner = nil
        whiteAdvantage = 0
        blackAdvantage = 0
        lastMoveFrom = nil
        lastMoveTo = nil
        SoundManager.shared.gameStart()
        reloadBoard?()
    }
}
