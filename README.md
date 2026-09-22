# ChessBoard

Play chess against Stockfish or against another person — from the browser or from a **physical board** (Millennium eONE ChessLink over BLE) — with a clock, durable game history, per-move analysis and level-graded assisted play. Self-hosted on Kubernetes, built as a set of small Spring Boot and Python services around one gateway.

This repo is the **front door**: it holds the architecture overview and a script that clones every module next to it. Each module lives in its own repository; there is no code here.

**Start with [`ARCHITECTURE.md`](ARCHITECTURE.md)** — what exists, who owns which truth, the main flows, the invariants and the decisions behind the shape.

## Repositories

| Repo                                                                                            | app name                  | Type                    | Role in one sentence                                                                                           |
| ----------------------------------------------------------------------------------------------- | ------------------------- | ----------------------- | -------------------------------------------------------------------------------------------------------------- |
| [Chessboard-Api](https://github.com/artfern95/Chessboard-Api)                                   | `chessboard-api`          | Gateway BFF             | The edge: browser session, OAuth2, proxy with `TokenRelay=` to everything else                                 |
| [Chessboard-Orchestrator-Service](https://github.com/artfern95/Chessboard-Orchestrator-Service) | `chessboard-orchestrator` | WebFlux                 | Live game session: turn, clock, WS move-loop, matchmaking, device channel                                      |
| [Chessboard-Engine](https://github.com/artfern95/Chessboard-Engine)                             | `chessboard-engine`       | WebFlux                 | Stateless compute over a pool of Stockfish processes; three roles (`play`, `query`, `classify`) from one image |
| [Chessboard-History-Service](https://github.com/artfern95/Chessboard-History-Service)           | `chessboard-history`      | WebFlux                 | Durable truth in MongoDB: games, moves, annotations, players, devices                                          |
| [Chessboard-Analysis-Service](https://github.com/artfern95/Chessboard-Analysis-Service)         | `chessboard-analysis`     | Servlet (actuator only) | Kafka in, Kafka out: asks for each move to be classified and publishes the annotation                          |
| [Chessboard-Engine-Spec](https://github.com/artfern95/Chessboard-Engine-Spec)                   | —                         | OpenAPI contract        | Codegen → JAR; also publishes the `play` / `query` role views                                                  |
| [Chessboard-History-Spec](https://github.com/artfern95/Chessboard-History-Spec)                 | —                         | OpenAPI contract        | Codegen → JAR                                                                                                  |
| [Chessboard-Orchestrator-Spec](https://github.com/artfern95/Chessboard-Orchestrator-Spec)       | —                         | OpenAPI contract        | Codegen → JAR (Games, Invites, Meta; the move-loop goes over WS)                                               |
| [Chessboard-ChessLink-Bridge](https://github.com/artfern95/Chessboard-ChessLink-Bridge)         | —                         | Python ≥ 3.11           | BLE ↔ WS bridge between the physical board and the live game                                                   |
| [Chessboard-Ops-Bot](https://github.com/artfern95/Chessboard-Ops-Bot)                           | `chessboard-ops-bot`      | Python ≥ 3.12           | Telegram bot: `/status`, `/games`, `/alerts` and silences, reading Prometheus and Alertmanager                 |
| [Chessboard-UI](https://github.com/artfern95/Chessboard-UI)                                     | `chessboard-ui`           | Angular                 | SPA; its in-pod Caddy proxies the BFF so both share one origin                                                 |

Directory name, `artifactId` and `spring.application.name` do not match on purpose; `ARCHITECTURE.md` §2 is the source of truth.

## Clone everything

```bash
git clone https://github.com/artfern95/ChessBoard.git && cd ChessBoard
./clone-all.sh          # HTTPS; ./clone-all.sh --ssh for git@
```

`clone-all.sh` reads [`repos.txt`](repos.txt) and clones whatever is missing next to itself; repos already present are left untouched. The `Chessboard-*/` directories are in `.gitignore`: this repo does not version them, not even as submodules. A private repo with plans and specs is listed too; without access it is reported and skipped.

## Layout after cloning

```
ChessBoard/
├── ARCHITECTURE.md                 the overview — read this first
├── clone-all.sh · repos.txt        clone helper and its list
├── Chessboard-Api/                 ┐
├── Chessboard-Orchestrator-Service/│
├── Chessboard-Engine/              │ one git repo each,
├── Chessboard-History-Service/     │ built and deployed independently
├── Chessboard-Analysis-Service/    │
├── Chessboard-*-Spec/              │
├── Chessboard-ChessLink-Bridge/    │
└── Chessboard-Ops-Bot/             ┘
```

Each module's README explains how to build and run it. Java modules need Java 21 and Maven; the bridge and the bot need Python.
