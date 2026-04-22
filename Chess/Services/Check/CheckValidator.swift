//
//  CheckValidator.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//

import Foundation

enum CheckValidator: CheckServiceProtocol {

    static func isKingInCheck(color: PieceColor,
                              pieces: [ChessPiece]) -> Bool {

        guard let king = pieces.first(where: {
            $0.type == .king && $0.color == color
        }) else { return false }

        for piece in pieces where piece.color != color {

            let enemyMoves = ChessEngine.shared.rawMoves(for: piece, pieces: pieces)

            if enemyMoves.contains(where: { $0.0 == king.row && $0.1 == king.col }) {
                return true
            }
        }

        return false
    }
}
extension CheckValidator {

    static func isMoveSafe(piece: ChessPiece,
                           toRow: Int,
                           toCol: Int,
                           pieces: [ChessPiece]) -> Bool {

        var simulated = pieces

        if let enemyIndex = simulated.firstIndex(where: {
            $0.row == toRow && $0.col == toCol && $0.color != piece.color
        }) {
            simulated.remove(at: enemyIndex)
        }

        if let index = simulated.firstIndex(where: {
            $0.row == piece.row && $0.col == piece.col
        }) {
            simulated[index] = ChessPiece(
                type: piece.type,
                color: piece.color,
                row: toRow,
                col: toCol,
                hasMoved: true
            )
        }

        return !isKingInCheck(color: piece.color, pieces: simulated)
    }
}
