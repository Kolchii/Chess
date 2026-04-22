import UIKit

final class ClockView: UIView {

    private let timeLabel = UILabel()
    private let playerLabel = UILabel()
    private var isPulsing = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        layer.cornerRadius = ChessTheme.Radius.sm
        clipsToBounds = true

        timeLabel.font = ChessTheme.Font.clock(size: 18)
        timeLabel.textAlignment = .center
        timeLabel.textColor = ChessTheme.Clock.inactiveText

        playerLabel.font = ChessTheme.Font.body(size: 10)
        playerLabel.textAlignment = .center
        playerLabel.textColor = ChessTheme.Clock.inactiveText
        playerLabel.alpha = 0.7

        let stack = UIStackView(arrangedSubviews: [playerLabel, timeLabel])
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])

        setInactive()
    }

    func setTime(_ text: String) {
        timeLabel.text = text
    }

    func setPlayerName(_ name: String) {
        playerLabel.text = name.uppercased()
    }

    func setActive(_ active: Bool, timeRemaining: Int? = nil) {
        stopPulse()

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            if active {
                if let t = timeRemaining, t <= ChessTheme.Clock.warningThreshold {
                    self.backgroundColor = ChessTheme.Clock.warningBackground
                    self.timeLabel.textColor = ChessTheme.Clock.warningText
                    self.playerLabel.textColor = ChessTheme.Clock.warningText
                    self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                } else {
                    self.backgroundColor = ChessTheme.Clock.activeBackground
                    self.timeLabel.textColor = ChessTheme.Clock.activeText
                    self.playerLabel.textColor = ChessTheme.Clock.activeText
                    self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }
            } else {
                self.setInactive()
            }
        }

        if active, let t = timeRemaining, t <= ChessTheme.Clock.warningThreshold {
            startPulse()
        }
    }

    private func setInactive() {
        backgroundColor = ChessTheme.Clock.inactiveBackground
        timeLabel.textColor = ChessTheme.Clock.inactiveText
        playerLabel.textColor = ChessTheme.Clock.inactiveText
        transform = .identity
    }

    private func startPulse() {
        guard !isPulsing else { return }
        isPulsing = true

        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]
        ) {
            self.alpha = 0.65
        }
    }

    private func stopPulse() {
        guard isPulsing else { return }
        isPulsing = false
        layer.removeAllAnimations()
        alpha = 1
    }
}
