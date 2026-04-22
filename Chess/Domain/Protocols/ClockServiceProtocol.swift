import Foundation

protocol ClockServiceProtocol: AnyObject {
    var onTick: (() -> Void)? { get set }
    var onTimeOver: ((PieceColor) -> Void)? { get set }
    var whiteTime: Int { get }
    var blackTime: Int { get }

    func configure(settings: GameSettings)
    func start(turn: PieceColor)
    func switchTurn(to turn: PieceColor)
    func reset()
    func formattedWhiteTime() -> String
    func formattedBlackTime() -> String
}
