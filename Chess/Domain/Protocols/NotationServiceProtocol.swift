protocol NotationServiceProtocol {
    static func notation(
        piece: ChessPiece,
        fromRow: Int,
        fromCol: Int,
        toRow: Int,
        toCol: Int,
        capture: Bool,
        castleSide: CastleSide?,
        checkState: CheckState
    ) -> String
}

enum CastleSide {
    case kingside
    case queenside
}

enum CheckState {
    case none
    case check
    case checkmate
}
