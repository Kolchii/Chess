protocol MoveCalculatorProtocol {
    static func moves(for piece: ChessPiece, pieces: [ChessPiece]) -> [(row: Int, col: Int)]
}
