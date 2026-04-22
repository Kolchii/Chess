//
//  GameSettings.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//
import Foundation

struct GameSettings {
    let minutes: Int
    let increment: Int

    var modeName: String {
        if minutes <= 2 { return "Bullet" }
        if minutes <= 5 { return "Blitz" }
        if minutes <= 15 { return "Rapid" }
        return "Classical"
    }

    var modeLabel: String { "\(modeName) · \(minutes)+\(increment)" }
}
