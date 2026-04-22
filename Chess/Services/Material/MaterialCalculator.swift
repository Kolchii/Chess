//
//  MaterialCalculator.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//
import Foundation

enum MaterialCalculator: MaterialServiceProtocol {

    static func value(of piece: PieceType) -> Int {
        switch piece {
        case .pawn:   return 1
        case .knight: return 3
        case .bishop: return 3
        case .rook:   return 5
        case .queen:  return 9
        case .king:   return 0
        }
    }

    static func materialScore(for color: PieceColor,
                              pieces: [ChessPiece]) -> Int {

        pieces
            .filter { $0.color == color }
            .map { value(of: $0.type) }
            .reduce(0, +)
    }

    static func materialAdvantage(pieces: [ChessPiece]) -> (white:Int, black:Int) {

        let whiteScore = materialScore(for: .white, pieces: pieces)
        let blackScore = materialScore(for: .black, pieces: pieces)

        if whiteScore > blackScore {
            return (whiteScore - blackScore, 0)
        } else if blackScore > whiteScore {
            return (0, blackScore - whiteScore)
        } else {
            return (0,0)
        }
    }
}
