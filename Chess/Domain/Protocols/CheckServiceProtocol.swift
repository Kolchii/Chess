protocol CheckServiceProtocol {
    static func isKingInCheck(color: PieceColor, pieces: [ChessPiece]) -> Bool
}

protocol CheckmateServiceProtocol {
    static func isCheckmate(color: PieceColor, pieces: [ChessPiece]) -> Bool
}
