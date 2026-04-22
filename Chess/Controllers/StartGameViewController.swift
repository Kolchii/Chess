import UIKit

final class StartGameController: UIViewController {

    private var selectedMinutes = 5
    private var selectedIncrement = 0

    // MARK: - UI

    private let knightLabel: UILabel = {
        let l = UILabel()
        l.text = "♞"
        l.font = .systemFont(ofSize: 64)
        l.textAlignment = .center
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "ChessMate"
        l.font = ChessTheme.Font.display(size: 36)
        l.textColor = ChessTheme.Color.primaryText
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Thoughtful chess for modern players."
        l.font = ChessTheme.Font.body()
        l.textColor = ChessTheme.Color.secondaryText
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let timeCards = TimeOptionRow(
        options: ["Bullet 1+0", "Blitz 3+2", "Rapid 10+0", "Classical 30+0"],
        values:  [1, 3, 10, 30]
    )
    private let incrementCards = TimeOptionRow(
        options: ["0s", "+2s", "+5s"],
        values:  [0, 2, 5]
    )

    private let startButton = CMPrimaryButton(title: "Play now")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ChessTheme.Color.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        timeCards.selectIndex(2)
        incrementCards.selectIndex(0)
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
    }

    // MARK: - Layout

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let heroStack = UIStackView(arrangedSubviews: [knightLabel, titleLabel, subtitleLabel])
        heroStack.axis = .vertical
        heroStack.spacing = ChessTheme.Spacing.xs
        heroStack.alignment = .center

        let timeCard  = makeSectionCard(header: "Time control", content: timeCards)
        let incrCard  = makeSectionCard(header: "Increment per move", content: incrementCards)

        let mainStack = UIStackView(arrangedSubviews: [
            heroStack,
            makeSpacer(ChessTheme.Spacing.xxl),
            timeCard,
            incrCard,
            makeSpacer(ChessTheme.Spacing.xs),
            startButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = ChessTheme.Spacing.sm
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: content.topAnchor, constant: ChessTheme.Spacing.xxxl),
            mainStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: ChessTheme.Spacing.lg),
            mainStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -ChessTheme.Spacing.lg),
            mainStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -ChessTheme.Spacing.xxxl),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func makeSectionCard(header: String, content: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = ChessTheme.Color.surface
        card.layer.cornerRadius = ChessTheme.Radius.lg
        card.layer.borderColor = ChessTheme.Color.border.cgColor
        card.layer.borderWidth = 0.5

        let headerLabel = UILabel()
        headerLabel.text = header.uppercased()
        headerLabel.font = ChessTheme.Font.caption()
        headerLabel.textColor = ChessTheme.Color.tertiaryText
        headerLabel.letterSpacing(0.5)

        let stack = UIStackView(arrangedSubviews: [headerLabel, content])
        stack.axis = .vertical
        stack.spacing = ChessTheme.Spacing.xs
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: ChessTheme.Spacing.md),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -ChessTheme.Spacing.md),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: ChessTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -ChessTheme.Spacing.md)
        ])

        return card
    }

    private func makeSpacer(_ height: CGFloat) -> UIView {
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    // MARK: - Actions

    @objc private func startGame() {
        let minutesOptions = [1, 3, 10, 30]
        let incrementOptions = [0, 2, 5]

        selectedMinutes = minutesOptions[timeCards.selectedIndex]
        selectedIncrement = incrementOptions[incrementCards.selectedIndex]

        let settings = GameSettings(minutes: selectedMinutes, increment: selectedIncrement)
        ChessClockManager.shared.configure(settings: settings)

        let vc = ChessBoardController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - CMPrimaryButton

final class CMPrimaryButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = ChessTheme.Color.accent
        setTitleColor(ChessTheme.Color.background, for: .normal)
        titleLabel?.font = ChessTheme.Font.heading(size: 17)
        layer.cornerRadius = ChessTheme.Radius.lg

        addTarget(self, action: #selector(down), for: .touchDown)
        addTarget(self, action: #selector(up),   for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func down() {
        UIView.animate(withDuration: 0.10) { self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
    }

    @objc private func up() {
        UIView.animate(withDuration: 0.20, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 6) {
            self.transform = .identity
        }
    }
}

// MARK: - TimeOptionRow

final class TimeOptionRow: UIView {

    private(set) var selectedIndex: Int = 0
    private var chips: [TimeChip] = []

    init(options: [String], values: [Int]) {
        super.init(frame: .zero)

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = ChessTheme.Spacing.xs
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 40),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.heightAnchor)
        ])

        for (i, option) in options.enumerated() {
            let chip = TimeChip(title: option)
            chip.tag = i
            chip.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(chip)
            chips.append(chip)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func selectIndex(_ index: Int) {
        selectedIndex = index
        chips.enumerated().forEach { i, chip in chip.setSelected(i == index) }
    }

    @objc private func tapped(_ sender: UIButton) { selectIndex(sender.tag) }
}

private final class TimeChip: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = ChessTheme.Radius.pill
        contentEdgeInsets = UIEdgeInsets(top: 0, left: ChessTheme.Spacing.md, bottom: 0, right: ChessTheme.Spacing.md)
        titleLabel?.font = ChessTheme.Font.callout()
        setSelected(false)
    }

    required init?(coder: NSCoder) { fatalError() }

    convenience init(title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }

    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.18) {
            if selected {
                self.backgroundColor = ChessTheme.Color.accentMuted
                self.setTitleColor(ChessTheme.Color.accent, for: .normal)
                self.layer.borderColor = ChessTheme.Color.accent.cgColor
                self.layer.borderWidth = 1
            } else {
                self.backgroundColor = ChessTheme.Color.elevated
                self.setTitleColor(ChessTheme.Color.secondaryText, for: .normal)
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0
            }
        }
    }
}

// MARK: - UILabel extension

extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let t = text else { return }
        attributedText = NSAttributedString(string: t, attributes: [
            .kern: spacing,
            .foregroundColor: textColor as Any,
            .font: font as Any
        ])
    }
}
