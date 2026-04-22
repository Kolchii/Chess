import UIKit

final class StartGameController: UIViewController {

    private var selectedMinutes = 5
    private var selectedIncrement = 0

    private let logoLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let timeCards = TimeOptionRow(
        options: ["3 min", "5 min", "10 min"],
        values: [3, 5, 10]
    )
    private let incrementCards = TimeOptionRow(
        options: ["0s", "+3s", "+5s"],
        values: [0, 3, 5]
    )

    private let startButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ChessTheme.Color.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        timeCards.selectIndex(1)
        incrementCards.selectIndex(0)
    }

    private func setupUI() {
        logoLabel.text = "♟"
        logoLabel.font = .systemFont(ofSize: 72)
        logoLabel.textAlignment = .center

        titleLabel.text = "Chess"
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = ChessTheme.Color.primaryText
        titleLabel.textAlignment = .center

        subtitleLabel.text = "Choose your time control"
        subtitleLabel.font = ChessTheme.Font.body(size: 14)
        subtitleLabel.textColor = ChessTheme.Color.secondaryText
        subtitleLabel.textAlignment = .center

        let sectionTime = makeSectionLabel("Time")
        let sectionIncrement = makeSectionLabel("Increment per move")

        startButton.setTitle("Start Game", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        startButton.backgroundColor = ChessTheme.Color.accent
        startButton.tintColor = ChessTheme.Clock.activeText
        startButton.layer.cornerRadius = ChessTheme.Radius.lg
        startButton.heightAnchor.constraint(equalToConstant: 58).isActive = true
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        addButtonPressAnimation(startButton)

        let stack = UIStackView(arrangedSubviews: [
            logoLabel,
            titleLabel,
            subtitleLabel,
            makeSpacer(height: 8),
            sectionTime,
            timeCards,
            makeSpacer(height: 4),
            sectionIncrement,
            incrementCards,
            makeSpacer(height: 16),
            startButton
        ])

        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)
        ])
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = ChessTheme.Font.body(size: 11)
        label.textColor = ChessTheme.Color.secondaryText
        label.letterSpacing(1.2)
        return label
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    private func addButtonPressAnimation(_ button: UIButton) {
        button.addTarget(self, action: #selector(buttonDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func buttonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) { sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
    }

    @objc private func buttonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6) {
            sender.transform = .identity
        }
    }

    @objc private func startGame() {
        let minutesOptions = [3, 5, 10]
        let incrementOptions = [0, 3, 5]

        selectedMinutes = minutesOptions[timeCards.selectedIndex]
        selectedIncrement = incrementOptions[incrementCards.selectedIndex]

        let settings = GameSettings(minutes: selectedMinutes, increment: selectedIncrement)
        ChessClockManager.shared.configure(settings: settings)

        let vc = ChessBoardController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Time Option Row

private final class TimeOptionRow: UIView {

    private(set) var selectedIndex: Int = 0
    private var buttons: [TimeOptionButton] = []
    private let values: [Int]

    init(options: [String], values: [Int]) {
        self.values = values
        super.init(frame: .zero)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 52)
        ])

        for (i, option) in options.enumerated() {
            let btn = TimeOptionButton(title: option)
            btn.tag = i
            btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
            buttons.append(btn)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func selectIndex(_ index: Int) {
        selectedIndex = index
        buttons.enumerated().forEach { i, btn in btn.setSelected(i == index) }
    }

    @objc private func tapped(_ sender: UIButton) {
        selectIndex(sender.tag)
    }
}

private final class TimeOptionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = ChessTheme.Radius.sm
        titleLabel?.font = ChessTheme.Font.heading(size: 15)
        setSelected(false)
    }

    required init?(coder: NSCoder) { fatalError() }

    convenience init(title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }

    func setSelected(_ selected: Bool) {
        if selected {
            backgroundColor = ChessTheme.Color.accentMuted
            setTitleColor(ChessTheme.Color.accent, for: .normal)
            layer.borderColor = ChessTheme.Color.accent.cgColor
            layer.borderWidth = 1.5
        } else {
            backgroundColor = ChessTheme.Color.card
            setTitleColor(ChessTheme.Color.secondaryText, for: .normal)
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attributed = NSAttributedString(
            string: text,
            attributes: [.kern: spacing, .foregroundColor: textColor as Any, .font: font as Any]
        )
        attributedText = attributed
    }
}
