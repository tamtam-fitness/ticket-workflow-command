# Ticket Workflow Command

> チケットから実行可能タスクまでの段階的詳細化ワークフロー

## 概要
チケット入力を受け取り、4段階のユーザー確認を伴いながら適切なサブエージェントを呼び出し、実行可能なタスクレベルまで段階的に詳細化する統合制御コマンド。

## 責務
### 1. チケット入力の処理
- テキスト形式のチケット内容
- ファイルパス指定によるマークダウンファイル読み込み
- 複数ファイル・フォルダ指定による一括処理

### 2. 状態管理・遷移制御
- `current-state.json` による処理段階の追跡
- 4段階のワークフロー状態遷移管理
- ユーザー確認・承認状態の記録

### 3. サブエージェント呼び出し制御
Universal Analyzer の判定結果に基づく適切なサブエージェント呼び出し

## 実行フロー
### チケット入力パターン

```bash
# テキスト直接指定
/ticket-workflow "ECサイトのユーザー管理機能を追加したい"

# マークダウンファイル指定
/ticket-workflow "path/to/ticket.md"
```

### 状態遷移フロー

1. **initialization** - Workflow Init による名前空間・ディレクトリ構造作成
2. **analysis** - Requirements Analyzer による要件分析（2層知識注入）
3. **elaboration** - Requirements Elaborator による要件詳細化（プロジェクト固有知識活用）
4. **decomposition** - Task Decomposer によるタスク分解（過去事例参照）
5. **execution** - Task Executor によるタスク実行（ナレッジ蓄積）

各段階でユーザー確認を行い、承認後に次段階へ進行

### サブエージェント呼び出しパターン

```bash
# チケット入力時の初期化
Use the workflow-init sub agent to initialize workflow: [チケット内容]

# Universal Analyzer による状態・知識統合
Use the universal-analyzer sub agent to analyze current state: [current-state.json + チケット内容]

# Requirements Analyzer 呼び出し（2層知識統合）
Use the requirements-analyzer sub agent to analyze: [チケット内容 + General Knowledge + Specified Knowledge]

# Requirements Elaborator 呼び出し（プロジェクト固有知識活用・ユーザー問い合わせ）
Use the requirements-elaborator sub agent with analysis results: [分析結果概要 + Project Knowledge + Knowledge Gaps]

# Task Decomposer 呼び出し（過去事例参照）
Use the task-decomposer sub agent to decompose requirements: [requirements.md + Past Decomposition Patterns]

# Task Executor 呼び出し（ナレッジ蓄積）
Use the task-executor sub agent to execute task: [task1.md + Project Knowledge + Knowledge Storage Strategy]
```

## 状態管理構造

### current-state.json（簡素化版）

```json
{
  "ticket_content": "元のチケット内容（またはファイルパス）",
  "current_phase": "analysis|elaboration|decomposition|execution",
  "user_confirmations": {
    "analysis_confirmed": false,
    "elaboration_confirmed": false,
    "decomposition_confirmed": false
  },
  "domain": "web-development|marketing|general",
  "last_updated": "2024-01-01T12:00:00Z"
}
```

## 出力ファイル管理

### 新しい出力パス構造
```
{プロジェクトルート}/
├── .ticket-workflow/                   # 実行時生成
│   └── {ticket-namespace}/             # チケット別名前空間
│       ├── current-state.json          # 現在状態
│       ├── requirements.md             # 蓄積要件
│       ├── tasks.md                    # タスク一覧
│       ├── tasks/                      # 個別タスク
│       │   ├── task1.md
│       │   └── task2.md
│       └── knowledge/                  # プロジェクト固有ナレッジ
│           ├── investigation-*.md      # 調査書
│           ├── design-*.md             # 設計書
│           ├── strategy-*.md           # 戦略書
│           └── user-input-*.md         # ユーザー定義制約
└── {既存プロジェクト構造}
```

### 各エージェントの出力責務
- **Workflow Init**: `.ticket-workflow/{namespace}/` ディレクトリ構造作成・初期化
- **Requirements Analyzer**: `.ticket-workflow/{namespace}/requirements.md` への分析結果追記
- **Requirements Elaborator**: `.ticket-workflow/{namespace}/requirements.md` への詳細化結果追記 + ユーザー回答を `knowledge/user-input-*.md` に保存
- **Task Decomposer**: `.ticket-workflow/{namespace}/tasks.md` + 個別タスクファイル（`.ticket-workflow/{namespace}/tasks/`）
- **Task Executor**: 個別タスクファイルへの実行結果追記 + 非コード成果物を `knowledge/` に分類保存

## 処理完了の考え方

- 各段階の完了は**ユーザーの承認**によって決まる
- ワークフロー全体の「完了」という概念は存在しない
- 最後に実行されたタスクが完了した時点でそのフローは終了
- 必要に応じて新しいチケット・フローを開始する