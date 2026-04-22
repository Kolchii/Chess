protocol BoardRepositoryProtocol: AnyObject {
    func fetchBoard(completion: @escaping (Result<[ChessPiece], Error>) -> Void)
}
