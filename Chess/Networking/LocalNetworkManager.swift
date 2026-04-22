//
//  LocalNetworkManager.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 16.02.26.
//
import Foundation

final class LocalNetworkManager: BoardRepositoryProtocol {

    static let shared = LocalNetworkManager()
    private init() {}

    func fetchBoard(completion: @escaping (Result<[ChessPiece], Error>) -> Void) {

        guard let url = Bundle.main.url(forResource: "boardMock", withExtension: "json") else {
            completion(.failure(NSError(domain: "File not found", code: 404)))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(BoardResponse.self, from: data)
            completion(.success(response.pieces))
        } catch {
            completion(.failure(error))
        }
    }
}
