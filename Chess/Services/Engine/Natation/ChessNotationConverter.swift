import Foundation

enum ChessNotationConverter: NotationServiceProtocol {

    static func notation(
        piece: ChessPiece,
        fromRow: Int,
        fromCol: Int,
        toRow: Int,
        toCol: Int,
        capture: Bool,
        castleSide: CastleSide?,
        checkState: CheckState
    ) -> String {

        let base = baseNotation(
            piece: piece,
            fromCol: fromCol,
            toRow: toRow,
            toCol: toCol,
            capture: capture,
            castleSide: castleSide
        )

        switch checkState {
        case .none:      return base
        case .check:     return base + "+"
        case .checkmate: return base + "#"
        }
    }

    private static func baseNotation(
        piece: ChessPiece,
        fromCol: Int,
        toRow: Int,
        toCol: Int,
        capture: Bool,
        castleSide: CastleSide?
    ) -> String {

        if let side = castleSide {
            return side == .kingside ? "O-O" : "O-O-O"
        }

        let files = ["a","b","c","d","e","f","g","h"]
        let destination = files[toCol] + String(8 - toRow)

        let symbol: String = {
            switch piece.type {
            case .pawn:   return ""
            case .knight: return "N"
            case .bishop: return "B"
            case .rook:   return "R"
            case .queen:  return "Q"
            case .king:   return "K"
            }
        }()

        if capture {
            if piece.type == .pawn { return files[fromCol] + "x" + destination }
            return symbol + "x" + destination
        }

        return symbol + destination
    }
}
