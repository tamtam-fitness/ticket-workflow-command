# ticket-workflow-command

チケット（タスク・要件・プロジェクト）を適切な抽象度で分析・詳細化・分解し、実行可能なタスクレベルまで段階的に詳細化するワークフローコマンドツール。

## 📋 目的

任意のチケットを受け取り、以下を実現します：
- 適切な抽象度での分析・詳細化・分解
- 制約条件や要件の抜け漏れ防止
- 実行可能なタスクレベル（0.5人日基準）までの段階的詳細化
- ドメインに依存しない汎用フレームワークの提供

## 🎯 コア価値

- **品質担保**: 制約条件や要件の抜け漏れを防ぐ
- **効率化**: 適切な抽象度での段階的詳細化により、無駄な作業を削減
- **汎用性**: ドメインに依存しない汎用フレームワークで様々な業務に対応
- **透明性**: 4段階のユーザー確認により、意思決定の透明性を確保

## 🏗️ Architecture構成

### システム全体構成

```mermaid
graph TB
    subgraph "プレゼンテーション層"
        CLI[💻 Claude Code CLI]
    end

    subgraph "オーケストレーション層"
        UA[🔍 Universal Analyzer<br/>オーケストラエージェント<br/>中核判定・分岐制御]
    end

    subgraph "サブエージェント層"
        REQ_ANA[📊 Requirements<br/>Analyzer]
        REQ_ELAB[📝 Requirements<br/>Elaborator]
        TASK_DECOMP[🔧 Task<br/>Decomposer]
        TASK_EXEC[⚡ Task<br/>Executor]
    end

    subgraph "ナレッジ層"
        DOMAIN[🧠 ドメイン知識<br/>Web Development<br/>Marketing]
        CRITERIA[🎯 判断基準<br/>Analysis Criteria<br/>Execution Guidelines]
    end

    subgraph "外部ツール層"
        WEB_SEARCH[🔍 Web検索]
        FILE_SYSTEM[📁 ファイルシステム]
        NOTION[📝 Notion API]
        TOOLS[🛠️ その他ツール]
    end

    CLI --> UA
    UA --> REQ_ANA
    UA --> REQ_ELAB
    UA --> TASK_DECOMP
    UA --> TASK_EXEC

    REQ_ANA -.->|知識参照| DOMAIN
    REQ_ANA -.->|判断基準参照| CRITERIA
    REQ_ELAB -.->|知識参照| DOMAIN
    REQ_ELAB -.->|判断基準参照| CRITERIA
    TASK_DECOMP -.->|知識参照| DOMAIN
    TASK_DECOMP -.->|判断基準参照| CRITERIA
    TASK_EXEC -.->|知識参照| DOMAIN
    TASK_EXEC -.->|判断基準参照| CRITERIA

    REQ_ELAB --> WEB_SEARCH
    TASK_EXEC --> FILE_SYSTEM
    TASK_EXEC --> NOTION
    TASK_EXEC --> TOOLS

    REQ_ANA --> UA
    REQ_ELAB --> UA
    TASK_DECOMP --> UA
    TASK_EXEC --> UA
    UA --> CLI
```

### エージェント構成

- **🔍 Universal Analyzer**: 中核判定エンジン。状態確認・次アクション判定・タスク粒度判定（0.5人日基準）
- **📊 Requirements Analyzer**: WHY/WHAT/WHO/CONSTRAINTS/VOLUMEの充足度分析
- **📝 Requirements Elaborator**: 不足要件の調査・補完・詳細化
- **🔧 Task Decomposer**: 確定タスク＋TODO分解・依存関係管理
- **⚡ Task Executor**: 前提確認・実行準備・実行内容・影響範囲確認
- **🧠 Domain Injector**: ドメイン知識注入処理

## 🔄 Workflow

### 完全なワークフローフロー

```mermaid
graph TD
    INPUT[チケット入力]

    UA[🔍 Universal Analyzer<br/>状態確認・次アクション判定<br/>タスク粒度判定0.5人日基準]

    REQ_ANA[📊 Requirements Analyzer<br/>WHY/WHAT/WHO/CONSTRAINTS<br/>VOLUME工数見積もり充足度分析]

    USER_CHECK1{👤 ユーザー確認1<br/>要件分析結果確認<br/>A詳細化実行<br/>Bこのまま進む<br/>C手動修正}

    VOLUME_CHECK{👤 工数見積もり確認<br/>工数情報不足の場合<br/>A工数を指定する<br/>B工数不明のまま進む<br/>C手動で要件追記}

    REQ_ELAB[📝 Requirements Elaborator<br/>指定箇所の詳細化<br/>工数情報含むrequirements.md生成]

    USER_CHECK2{👤 ユーザー確認2<br/>生成要件確認<br/>Aタスク分解進む<br/>B再詳細化<br/>C手動編集}

    GRANULARITY_CHECK{🔍 タスク粒度判定<br/>0.5人日以下？<br/>分解不要 vs 分解必要}

    TASK_DECOMP[🔧 Task Decomposer<br/>確定タスク＋TODO分解<br/>依存関係管理<br/>tasks.md生成]

    USER_CHECK3{👤 ユーザー確認3<br/>分解結果確認<br/>A実行開始<br/>B再分解<br/>C手動調整}

    TASK_EXEC[⚡ Task Executor<br/>前提確認 + 実行準備<br/>実行内容・影響範囲確認]

    DEPENDENCY_CHECK{🔗 依存関係確認<br/>TODOタスクの<br/>詳細化タイミング？}

    TODO_ELABORATE[📋 TODO詳細化<br/>依存タスク完了後<br/>新たな分解実行]

    USER_MANUAL[✏️ ユーザー手動編集<br/>直接ファイル編集]

    subgraph STATE_MGMT [状態管理]
        STATE[📁 current-state.json<br/>処理段階の記録<br/>ユーザー選択履歴<br/>承認状態<br/>依存関係追跡]
    end

    subgraph OUTPUT_FILES [生成ファイル]
        REQ_FILE[📄 requirements.md<br/>VOLUME工数情報含む]
        TASK_FILE[📋 tasks.md<br/>確定タスク＋TODOリスト<br/>依存関係記録]
        CONFIRMED_TASKS[📝 確定タスクファイル<br/>task-001-name.md]
        TODO_TASKS[📝 TODOタスクファイル<br/>依存完了後に生成]
        EXECUTION_RESULTS[🎯 実行成果物]
    end

    INPUT --> UA
    UA --> REQ_ANA
    REQ_ANA --> USER_CHECK1

    USER_CHECK1 -->|A詳細化実行| VOLUME_CHECK
    USER_CHECK1 -->|Bこのまま進む| GRANULARITY_CHECK
    USER_CHECK1 -->|C手動修正| USER_MANUAL

    VOLUME_CHECK -->|A工数指定| REQ_ELAB
    VOLUME_CHECK -->|B工数不明で進む| REQ_ELAB
    VOLUME_CHECK -->|C手動要件追記| USER_MANUAL

    REQ_ELAB --> REQ_FILE
    REQ_ELAB --> USER_CHECK2

    USER_CHECK2 -->|Aタスク分解進む| GRANULARITY_CHECK
    USER_CHECK2 -->|B再詳細化| REQ_ELAB
    USER_CHECK2 -->|C手動編集| USER_MANUAL

    GRANULARITY_CHECK -->|0.5人日以下<br/>分解不要| TASK_EXEC
    GRANULARITY_CHECK -->|0.5人日超<br/>分解必要| TASK_DECOMP

    TASK_DECOMP --> TASK_FILE
    TASK_DECOMP --> CONFIRMED_TASKS
    TASK_DECOMP --> USER_CHECK3

    USER_CHECK3 -->|A実行開始| TASK_EXEC
    USER_CHECK3 -->|B再分解| TASK_DECOMP
    USER_CHECK3 -->|C手動調整| USER_MANUAL

    TASK_EXEC --> USER_CHECK4{👤 ユーザー確認4<br/>タスク実行前確認<br/>A実行承認<br/>B実行保留<br/>C条件変更}

    USER_CHECK4 -->|A実行承認| EXECUTION_RESULTS
    USER_CHECK4 -->|B実行保留| UA
    USER_CHECK4 -->|C条件変更| USER_MANUAL

    EXECUTION_RESULTS --> DEPENDENCY_CHECK

    DEPENDENCY_CHECK -->|TODOタスク詳細化必要| TODO_ELABORATE
    DEPENDENCY_CHECK -->|全タスク完了| UA

    TODO_ELABORATE --> TODO_TASKS
    TODO_ELABORATE --> UA

    USER_MANUAL --> UA

    USER_CHECK1 -.-> STATE
    VOLUME_CHECK -.-> STATE
    USER_CHECK2 -.-> STATE
    USER_CHECK3 -.-> STATE
    USER_CHECK4 -.-> STATE
    DEPENDENCY_CHECK -.-> STATE
```

### ワークフローの特徴

1. **4段階のユーザー確認**
   - 要件分析結果の確認
   - 生成要件の確認
   - タスク分解結果の確認
   - タスク実行前の確認

2. **段階的詳細化**
   - 要件分析 → 要件詳細化 → タスク分解 → タスク実行

3. **依存関係管理**
   - 確定タスクとTODOタスクの分離
   - 依存関係に基づく実行順序の最適化

4. **状態管理**
   - current-state.jsonによる進捗・承認状態の追跡
   - ユーザー選択履歴の記録

## 🚀 使用方法

```bash
# ワークフロー開始
/ticket-workflow "チケット内容"
```

## 📁 ディレクトリ構成

※

```
# user memory
.claude/
├── commands/
│   └── ticket-workflow.md              # 統合制御・状態遷移管理
├── agents/
│   ├── universal-analyzer.md           # 判定処理ロジック
│   ├── requirements-analyzer.md        # 充足度分析処理
│   ├── requirements-elaborator.md      # 詳細化処理
│   ├── task-decomposer.md             # 分解処理ロジック
│   ├── task-executor.md               # 実行処理ロジック
│   └── domain-injector.md             # ドメイン知識注入
└── docs/
    └── ticket-workflow/
        ├── core/...                    # 汎用的な判断軸・基準
        └── domains/
            ├── web-development/
            │   ├── requirements/
            │   │   └──  constraints.md
            │   ├── task-execution/
            │   │   ├── implementation-guide.md
            └── marketing/... # マーケティングドメインの知識

# project
{プロジェクトルート}/
├── CLAUDE.md                           # プロジェクト全体知識
├── ticket-workflow/                    # 実行時生成
│   ├── current-state.json              # 現在状態
│   ├── requirements.md                 # 蓄積要件
│   ├── tasks.md                        # タスク一覧
│   └── tasks/                          # 個別タスク
│       ├── task1.md
│       └── task2.md
└── {既存プロジェクト構造}
```

## 📊 主な機能

### 要件分析
- WHY（目的・価値）の明確化
- WHAT（作業内容）の具体化
- WHO（関係者・責任）の特定
- CONSTRAINTS（制約条件）の網羅
- VOLUME（工数・規模）の見積もり

### タスク分解
- 0.5人日基準での適切な粒度管理
- 依存関係の明確化と管理
- 確定タスクとTODOタスクの分離
- 並行実行可能性の最大化

### 実行管理
- 実行時の動的調査
- ユーザーとの対話的情報収集
- 実行結果の構造化記録
- 次タスクへの継承情報管理

## ライセンス

MIT License