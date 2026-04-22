//
//  GameResetManager.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//

import Foundation

enum GameResetManager {

    static func initialBoard() -> [ChessPiece] {

        var pieces: [ChessPiece] = []

        let backRank: [PieceType] = [
            .rook, .knight, .bishop, .queen,
            .king, .bishop, .knight, .rook
        ]

        for col in 0..<8 {
            pieces.append(ChessPiece(type: backRank[col], color: .black, row: 0, col: col, hasMoved: false))
            pieces.append(ChessPiece(type: .pawn, color: .black, row: 1, col: col, hasMoved: false))
        }

        for col in 0..<8 {
            pieces.append(ChessPiece(type: .pawn, color: .white, row: 6, col: col, hasMoved: false))
            pieces.append(ChessPiece(type: backRank[col], color: .white, row: 7, col: col, hasMoved: false))
        }

        return pieces
    }
}
