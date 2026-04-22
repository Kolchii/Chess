//
//  ChessClockManager.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//
import Foundation

final class ChessClockManager: ClockServiceProtocol {

    static let shared = ChessClockManager()
    private init() {}

    private var timer: Timer?

    private(set) var currentSettings = GameSettings(minutes: 10, increment: 0)
    private(set) var whiteTime: Int = 600
    private(set) var blackTime: Int = 600
    private(set) var increment: Int = 0

    private var currentTurn: PieceColor = .white

    var onTick: (() -> Void)?
    var onTimeOver: ((PieceColor) -> Void)?

    func configure(settings: GameSettings) {
        currentSettings = settings
        whiteTime = settings.minutes * 60
        blackTime = settings.minutes * 60
        increment = settings.increment
        onTick?()
    }

    func start(turn: PieceColor) {
        currentTurn = turn
        startTimer()
    }

    func switchTurn(to turn: PieceColor) {
        addIncrement()
        currentTurn = turn
    }

    func reset() {
        timer?.invalidate()
        onTick?()
    }

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick()
        }
    }

    private func tick() {
        if currentTurn == .white {
            whiteTime -= 1
            if whiteTime <= 0 {
                timer?.invalidate()
                onTimeOver?(.white)
            }
        } else {
            blackTime -= 1
            if blackTime <= 0 {
                timer?.invalidate()
                onTimeOver?(.black)
            }
        }
        onTick?()
    }

    private func addIncrement() {
        if currentTurn == .white {
            whiteTime += increment
        } else {
            blackTime += increment
        }
    }

    func formattedWhiteTime() -> String { format(whiteTime) }
    func formattedBlackTime() -> String { format(blackTime) }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
