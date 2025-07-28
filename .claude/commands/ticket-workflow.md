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

1. **analysis** - Requirements Analyzer による要件分析
2. **elaboration** - Requirements Elaborator による要件詳細化
3. **decomposition** - Task Decomposer によるタスク分解
4. **execution** - Task Executor によるタスク実行

各段階でユーザー確認を行い、承認後に次段階へ進行

### サブエージェント呼び出しパターン

```bash
# Universal Analyzer による状態判定
Use the universal-analyzer sub agent to analyze current state: [current-state.json + チケット内容]

# Requirements Analyzer 呼び出し
Use the requirements-analyzer sub agent to analyze: [チケット内容]

# Requirements Elaborator 呼び出し
Use the requirements-elaborator sub agent with analysis results: [分析結果概要]

# Task Decomposer 呼び出し
Use the task-decomposer sub agent to decompose requirements: [requirements.md参照]

# Task Executor 呼び出し
Use the task-executor sub agent to execute task: [task1.md]
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

### 標準出力パス構造（READMEと整合）
```
{プロジェクトルート}/
├── ticket-workflow/                    # 実行時生成
│   ├── current-state.json              # 現在状態
│   ├── requirements.md                 # 蓄積要件
│   ├── tasks.md                        # タスク一覧
│   └── tasks/                          # 個別タスク
│       ├── task1.md
│       └── task2.md
└── {既存プロジェクト構造}
```

### 各エージェントの出力責務
- **Requirements Analyzer**: `ticket-workflow/requirements.md` への分析結果追記
- **Requirements Elaborator**: `ticket-workflow/requirements.md` への詳細化結果追記 
- **Task Decomposer**: `ticket-workflow/tasks.md` + 個別タスクファイル（`ticket-workflow/tasks/`）
- **Task Executor**: 個別タスクファイルへの実行結果追記

## 処理完了の考え方

- 各段階の完了は**ユーザーの承認**によって決まる
- ワークフロー全体の「完了」という概念は存在しない
- 最後に実行されたタスクが完了した時点でそのフローは終了
- 必要に応じて新しいチケット・フローを開始する