protocol MoveEngineProtocol: AnyObject {
    func rawMoves(for piece: ChessPiece, pieces: [ChessPiece]) -> [(row: Int, col: Int)]
    func possibleMoves(for piece: ChessPiece, pieces: [ChessPiece]) -> [(row: Int, col: Int)]
}
