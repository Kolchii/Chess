//
//  SoundManager.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//
import AVFoundation

final class SoundManager: SoundServiceProtocol {

    static let shared = SoundManager()
    private init() {
        prepareAudioSession()
    }

    private var player: AVAudioPlayer?

    // MARK: - Audio Session (important)

    private func prepareAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession error:", error)
        }
    }

    // MARK: - Core play function

    private func play(_ file: String) {

        guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else {
            print("Sound not found:", file)
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 1.0
            player?.prepareToPlay()
            player?.play()
        } catch {
            print(" Sound play error:", error)
        }
    }

    // MARK: - Game Events

    func gameStart() {
        play("game-start")
    }

    func gameEnd() {
        play("game-end")
    }

    func notify() {
        play("notify")
    }

    // MARK: - Moves

    func moveSelf() {
        play("move-self")
    }

    func moveOpponent() {
        play("move-opponent")
    }

    func capture() {
        play("capture")
    }

    func castle() {
        play("castle")
    }

    func check() {
        play("move-check")
    }

    func checkmate() {
        play("game-end")   // chess.com 
    }

    func illegal() {
        play("illegal")
    }

    func promote() {
        play("promote")
    }
}
