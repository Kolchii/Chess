//
//  CheckMate.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//

import Foundation

enum CheckmateValidator: CheckmateServiceProtocol {

    static func isCheckmate(color: PieceColor,
                            pieces: [ChessPiece]) -> Bool {

        if !CheckValidator.isKingInCheck(color: color, pieces: pieces) {
            return false
        }

        let friendlyPieces = pieces.filter { $0.color == color }

        for piece in friendlyPieces {

            let moves = ChessEngine.shared.possibleMoves(for: piece, pieces: pieces)

            if !moves.isEmpty {
                return false
            }
        }

        return true
    }
}
