# Chess

**Chess** is a fully-featured iOS chess application built with Swift and UIKit. Play a complete game of chess with a polished dark interface, real-time clocks, move history, and sound effects — all running entirely on-device with no internet connection required.

---

## Features

- **Full Chess Rules** — legal move validation for every piece, including castling, en passant, and pawn promotion
- **Check & Checkmate Detection** — moves are annotated with standard algebraic notation (`+` for check, `#` for checkmate)
- **Chess Clock** — Fischer increment time control keeps games competitive
- **Move History** — every move is recorded and displayed in real time
- **Material Calculator** — tracks the total captured piece value for each side
- **Board Flip** — instantly switch the board perspective between white and black
- **Sound Effects** — audio feedback for moves and key game events
- **Game Over Screen** — clear end-game messaging for checkmate, stalemate, and timeout

---

## Architecture

Chess is built with **Onion Architecture**, keeping game logic, UI, and data cleanly separated. All views are written programmatically with UIKit — no storyboards.

```
Chess/
├── App/                    # Entry point, AppDelegate
├── Controllers/            # UIKit view controllers
├── ViewModels/             # Business logic, state management
├── Views/                  # UI components (ChessBoardView, ClockView, MoveHistoryView…)
├── Model/                  # Data models — pieces, board state, move records
├── Domain/
│   └── Protocols/          # Abstractions & interfaces
├── Services/               # Core game logic services
├── Networking/             # Network layer (future use)
├── Helper/                 # Utility extensions
├── Presentation/
│   └── Theme/              # ChessTheme — dark palette, golden accents
├── Resources/              # Fonts, localization files
├── Sound-MP3/              # Audio assets
└── Assets.xcassets/        # Images & color sets
```

---

## Requirements

| | |
|---|---|
| Platform | iOS 15.0+ |
| Language | Swift 5 |
| UI Framework | UIKit (programmatic) |
| Xcode | 14+ |

---

## Getting Started

```bash
# Clone the repository
git clone https://github.com/Kolchii/Chess.git
cd Chess

# Open in Xcode
open Chess.xcodeproj
```

Build and run on a simulator or physical device. No external dependencies or package manager setup required.

---

## Roadmap

- [ ] AI opponent (Stockfish integration)
- [ ] Online multiplayer
- [ ] Opening book and move suggestions
- [ ] PGN export and import
- [ ] iPad support

---

## License

MIT
