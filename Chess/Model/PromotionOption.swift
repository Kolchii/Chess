//
//  PromotionOption.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//

import Foundation

enum PromotionOption: CaseIterable {
    case queen
    case rook
    case bishop
    case knight

    var pieceType: PieceType {
        switch self {
        case .queen:  return .queen
        case .rook:   return .rook
        case .bishop: return .bishop
        case .knight: return .knight
        }
    }

    var title: String {
        switch self {
        case .queen:  return "Queen"
        case .rook:   return "Rook"
        case .bishop: return "Bishop"
        case .knight: return "Knight"
        }
    }
}
