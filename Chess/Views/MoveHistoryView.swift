import UIKit

final class MoveHistoryView: UIView {

    private var moves: [MoveRecord] = []

    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let countBadge = BadgeLabel()
    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = ChessTheme.Color.surface
        layer.cornerRadius = ChessTheme.Radius.md
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true

        setupHeader()
        setupTable()
        setupEmpty()
    }

    private func setupHeader() {
        headerView.backgroundColor = ChessTheme.Color.card
        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)

        titleLabel.text = "MOVES"
        titleLabel.font = ChessTheme.Font.body(size: 11)
        titleLabel.textColor = ChessTheme.Color.secondaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        countBadge.translatesAutoresizingMaskIntoConstraints = false

        let divider = UIView()
        divider.backgroundColor = ChessTheme.Color.divider
        divider.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        headerView.addSubview(countBadge)
        addSubview(divider)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            countBadge.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            countBadge.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            divider.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupTable() {
        tableView.register(MoveCell.self, forCellReuseIdentifier: "MoveCell")
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 32
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 1),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupEmpty() {
        emptyLabel.text = "No moves yet"
        emptyLabel.font = ChessTheme.Font.body(size: 13)
        emptyLabel.textColor = ChessTheme.Color.secondaryText
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 18)
        ])
    }

    func configure(with moves: [MoveRecord]) {
        let previousCount = self.moves.count
        self.moves = moves

        emptyLabel.isHidden = !moves.isEmpty
        countBadge.setCount(moves.count > 0 ? moves.count : nil)

        tableView.reloadData()

        if moves.count > previousCount {
            animateNewRow()
        }

        scrollToBottom()
    }

    private func animateNewRow() {
        guard let lastIndex = tableView.indexPathsForVisibleRows?.last else { return }
        guard let cell = tableView.cellForRow(at: lastIndex) else { return }
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 10)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    private func scrollToBottom() {
        guard moves.count > 0 else { return }
        let indexPath = IndexPath(row: moves.count - 1, section: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension MoveHistoryView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moves.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoveCell", for: indexPath) as! MoveCell
        let isLatest = indexPath.row == moves.count - 1
        cell.configure(move: moves[indexPath.row], row: indexPath.row, isLatest: isLatest)
        return cell
    }
}

// MARK: - Badge Label

private final class BadgeLabel: UIView {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = ChessTheme.Color.accentMuted
        layer.cornerRadius = 9

        label.font = ChessTheme.Font.moveNumber(size: 11)
        label.textColor = ChessTheme.Color.accent
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 26),
            heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func setCount(_ count: Int?) {
        if let c = count, c > 0 {
            label.text = "\(c)"
            isHidden = false
        } else {
            isHidden = true
        }
    }
}
