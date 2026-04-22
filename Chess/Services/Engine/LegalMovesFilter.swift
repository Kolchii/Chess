//
//  LegalMovesFilter.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//

import Foundation

enum LegalMovesFilter {

    static func filterLegalMoves(
        for piece: ChessPiece,
        moves: [(row:Int,col:Int)],
        pieces: [ChessPiece]
    ) -> [(row:Int,col:Int)] {

        moves.filter { move in
            isMoveLegal(piece: piece, move: move, pieces: pieces)
        }
    }

    private static func isMoveLegal(
        piece: ChessPiece,
        move: (row:Int,col:Int),
        pieces: [ChessPiece]
    ) -> Bool {

        var simulatedBoard = pieces

        simulatedBoard.removeAll {
            $0.row == piece.row && $0.col == piece.col
        }

        simulatedBoard.removeAll {
            $0.row == move.row && $0.col == move.col
        }

        let movedPiece = ChessPiece(
            type: piece.type,
            color: piece.color,
            row: move.row,
            col: move.col,
            hasMoved: true
        )

        simulatedBoard.append(movedPiece)

        let kingStillInCheck = CheckValidator.isKingInCheck(
            color: piece.color,
            pieces: simulatedBoard
        )

        return !kingStillInCheck
    }
}
