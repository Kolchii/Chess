//
//  StartGameViewController.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//

import UIKit

final class StartGameController: UIViewController {

    private var selectedMinutes = 5
    private var selectedIncrement = 0

    private let timeSegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["3 min", "5 min", "10 min"])
        sc.selectedSegmentIndex = 1
        return sc
    }()

    private let incrementSegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["0s", "3s", "5s"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let startButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Start Game", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 22)
        btn.backgroundColor = .systemGreen
        btn.tintColor = .white
        btn.layer.cornerRadius = 16
        btn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Game"
        view.backgroundColor = .systemBackground

        let stack = UIStackView(arrangedSubviews: [
            UILabel(text: "Time"),
            timeSegment,
            UILabel(text: "Increment"),
            incrementSegment,
            startButton
        ])

        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
    }

    @objc private func startGame() {

        let minutesOptions = [3,5,10]
        let incrementOptions = [0,3,5]

        selectedMinutes = minutesOptions[timeSegment.selectedSegmentIndex]
        selectedIncrement = incrementOptions[incrementSegment.selectedSegmentIndex]

        let settings = GameSettings(
            minutes: selectedMinutes,
            increment: selectedIncrement
        )

        ChessClockManager.shared.configure(settings: settings)

        let vc = ChessBoardController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
