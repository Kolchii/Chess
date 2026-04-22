import UIKit

final class PromotionView: UIView {

    var onSelect: ((PromotionOption) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.72)

        let titleLabel = UILabel()
        titleLabel.text = "Promote Pawn"
        titleLabel.font = ChessTheme.Font.heading(size: 15)
        titleLabel.textColor = ChessTheme.Color.primaryText
        titleLabel.textAlignment = .center

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        PromotionOption.allCases.forEach { option in
            buttonStack.addArrangedSubview(makeOptionButton(for: option))
        }

        let mainStack = UIStackView(arrangedSubviews: [titleLabel, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = ChessTheme.Color.card
        container.layer.cornerRadius = ChessTheme.Radius.lg
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.6
        container.layer.shadowRadius = 16
        container.layer.shadowOffset = CGSize(width: 0, height: 8)
        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)
        container.addSubview(mainStack)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 300),

            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            buttonStack.heightAnchor.constraint(equalToConstant: 64)
        ])

        alpha = 0
        UIView.animate(withDuration: 0.2) { self.alpha = 1 }
    }

    private func makeOptionButton(for option: PromotionOption) -> UIButton {
        let btn = UIButton(type: .system)
        btn.tag = PromotionOption.allCases.firstIndex(of: option) ?? 0
        let imageName = "white_\(option.pieceType.rawValue)"
        btn.setImage(UIImage(named: imageName), for: .normal)
        btn.backgroundColor = ChessTheme.Color.surface
        btn.tintColor = .clear
        btn.layer.cornerRadius = ChessTheme.Radius.sm
        btn.layer.borderColor = ChessTheme.Color.divider.cgColor
        btn.layer.borderWidth = 1
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func tapped(_ sender: UIButton) {
        let option = PromotionOption.allCases[sender.tag]
        UIView.animate(withDuration: 0.15) { self.alpha = 0 } completion: { _ in
            self.onSelect?(option)
            self.removeFromSuperview()
        }
    }
}
