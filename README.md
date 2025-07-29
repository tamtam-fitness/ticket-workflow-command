# ticket-workflow-command

## 🎯 システム概要

### コンセプト

このシステムは、**任意のドメインによらないチケット**（タスク・要件・プロジェクト）を受け取り、**実行可能なタスクレベルまで段階的にを適切な抽象度で分析・詳細化・分解**し、**実際にそれを実行できる**統合ワークフローツールです。


## 📊 主な機能

### 要件分析・詳細化
- **WHY/WHAT/WHO/CONSTRAINTS/VOLUME**の充足度分析
- 制約条件・要件の抜け漏れ防止
- プロジェクト固有知識を活用した詳細化
- 知識不足時の動的ユーザー問い合わせ

### タスク分解・依存関係管理
- 0.5人日基準での適切な粒度制御
- 確定タスクとTODOタスクの分離
- 依存関係の明確化と管理
- 並行実行可能性の最大化

### プロジェクト固有ナレッジ活用
- 過去の調査・設計・戦略成果物の自動活用
- ユーザー定義制約・要求事項の参照
- 横断的知識（他チケットからの知見）の活用
- 非コード成果物の自動分類・蓄積

### 実行管理
- 実行時の動的調査（プロジェクト固有知識優先）
- ユーザーとの対話的情報収集
- 実行結果の構造化記録
- 次タスクへの継承情報管理

## システム全体構成

```mermaid
graph TB
    subgraph "プレゼンテーション層"
        CLI[💻 Claude Code CLI]
    end

    subgraph "オーケストレーション層"
        UA[🔍 Universal Analyzer<br/>中核判定・2層知識統合<br/>分岐制御]
        WF_INIT[🔄 Workflow Init<br/>名前空間作成<br/>ディレクトリ初期化]
    end

    subgraph "サブエージェント層"
        REQ_ANA[📊 Requirements<br/>Analyzer]
        REQ_ELAB[📝 Requirements<br/>Elaborator<br/>+ユーザー問い合わせ]
        TASK_DECOMP[🔧 Task<br/>Decomposer<br/>+過去事例参照]
        TASK_EXEC[⚡ Task<br/>Executor<br/>+ナレッジ蓄積]
    end

    subgraph "知識注入層"
        GEN_KNOW[🧠 General Knowledge<br/>Injector<br/>汎用ドメイン知識]
        SPEC_KNOW[🎯 Specified Knowledge<br/>Injector<br/>プロジェクト固有知識]
    end

    subgraph "ナレッジ層"
        subgraph "汎用知識"
            DOMAIN[🌐 ドメイン知識<br/>Web Development<br/>Marketing]
            CRITERIA[📋 判断基準<br/>Analysis Criteria<br/>Execution Guidelines]
        end
        subgraph "プロジェクト固有知識"
            PROJ_KNOW["📁 Project Knowledge<br/>.ticket-workflow/namespace/knowledge/<br/>調査書・設計書・戦略書"]
            USER_KNOW["👤 User Constraints<br/>user-input-*.md<br/>プロジェクト制約・要求"]
        end
    end

    subgraph "外部ツール層"
        WEB_SEARCH[🔍 Web検索<br/>O3]
        FILE_SYSTEM[📁 ファイルシステム]
        CONTEXT7[🧠 Context7<br/>コードベース分析]
        TOOLS[🛠️ その他ツール]
    end

    CLI --> WF_INIT
    WF_INIT --> UA
    UA --> REQ_ANA
    UA --> REQ_ELAB
    UA --> TASK_DECOMP
    UA --> TASK_EXEC

    UA -.->|知識統合呼び出し| GEN_KNOW
    UA -.->|知識統合呼び出し| SPEC_KNOW

    GEN_KNOW -.->|汎用知識取得| DOMAIN
    GEN_KNOW -.->|汎用知識取得| CRITERIA
    SPEC_KNOW -.->|固有知識取得| PROJ_KNOW
    SPEC_KNOW -.->|固有知識取得| USER_KNOW

    REQ_ELAB --> WEB_SEARCH
    REQ_ELAB -.->|ユーザー回答保存| PROJ_KNOW
    TASK_EXEC --> FILE_SYSTEM
    TASK_EXEC --> CONTEXT7
    TASK_EXEC --> TOOLS
    TASK_EXEC -.->|成果物保存| PROJ_KNOW

    REQ_ANA --> UA
    REQ_ELAB --> UA
    TASK_DECOMP --> UA
    TASK_EXEC --> UA
    UA --> CLI
```

### エージェント構成

- **🔍 Universal Analyzer**: 中核判定エンジン。状態確認・次アクション判定・2層知識統合
- **🔄 Workflow Init**: ワークフロー初期化。チケット名前空間・ディレクトリ構造作成
- **📊 Requirements Analyzer**: WHY/WHAT/WHO/CONSTRAINTS/VOLUMEの充足度分析（2層知識活用）
- **📝 Requirements Elaborator**: 不足要件の調査・補完・詳細化・ユーザー問い合わせ（プロジェクト固有知識活用）
- **🔧 Task Decomposer**: 確定タスク＋TODO分解・依存関係管理（過去事例参照）
- **⚡ Task Executor**: 前提確認・実行準備・実行内容・影響範囲確認（ナレッジ蓄積）
- **🧠 General Knowledge Injector**: 汎用ドメイン知識注入処理
- **🎯 Specified Knowledge Injector**: プロジェクト固有知識取得・活用

### ワークフロー

```mermaid
graph TD
    INPUT[チケット入力]

    WF_INIT[🔄 Workflow Init<br/>チケット名前空間生成<br/>ディレクトリ構造作成]

    UA[🔍 Universal Analyzer<br/>状態確認・2層知識統合<br/>次アクション判定]

    KNOWLEDGE_INJECTION{🧠 知識統合<br/>General + Specified<br/>Knowledge Injection}

    REQ_ANA[📊 Requirements Analyzer<br/>WHY/WHAT/WHO/CONSTRAINTS<br/>VOLUME充足度分析<br/>2層知識活用]

    USER_CHECK1{👤 ユーザー確認1<br/>要件分析結果確認<br/>A詳細化実行<br/>Bこのまま進む<br/>C手動修正}

    REQ_ELAB[📝 Requirements Elaborator<br/>不足要件の詳細化<br/>プロジェクト固有知識活用<br/>ユーザー問い合わせ]

    USER_QUERY{💬 知識不足確認<br/>プロジェクト固有情報<br/>が不足している場合<br/>ユーザーに問い合わせ}

    USER_CHECK2{👤 ユーザー確認2<br/>詳細化結果確認<br/>Aタスク分解進む<br/>B再詳細化<br/>C手動編集}

    TASK_DECOMP[🔧 Task Decomposer<br/>確定タスク＋TODO分解<br/>過去事例参照<br/>依存関係管理]

    USER_CHECK3{👤 ユーザー確認3<br/>分解結果確認<br/>A実行開始<br/>B再分解<br/>C手動調整}

    TASK_EXEC[⚡ Task Executor<br/>プロジェクト固有ナレッジ確認<br/>実行・成果物生成<br/>ナレッジ蓄積]

    USER_CHECK4{👤 ユーザー確認4<br/>実行結果確認<br/>A次タスク<br/>B完了<br/>C修正}

    USER_MANUAL[✏️ ユーザー手動編集<br/>直接ファイル編集]

    subgraph NAMESPACE_STRUCTURE [名前空間構造]
        STATE["📁 .ticket-workflow/namespace/<br/>current-state.json<br/>requirements.md<br/>tasks.md"]
        KNOWLEDGE_STORE["💾 knowledge/<br/>investigation-*.md<br/>design-*.md<br/>strategy-*.md<br/>user-input-*.md"]
    end

    subgraph KNOWLEDGE_FLOW [知識フロー]
        GEN_KNOW[🧠 General Knowledge<br/>汎用ドメイン知識]
        SPEC_KNOW[🎯 Specified Knowledge<br/>プロジェクト固有知識]
    end

    INPUT --> WF_INIT
    WF_INIT --> STATE
    WF_INIT --> UA

    UA --> KNOWLEDGE_INJECTION
    KNOWLEDGE_INJECTION --> GEN_KNOW
    KNOWLEDGE_INJECTION --> SPEC_KNOW
    KNOWLEDGE_INJECTION --> REQ_ANA

    REQ_ANA --> USER_CHECK1

    USER_CHECK1 -->|A詳細化実行| REQ_ELAB
    USER_CHECK1 -->|Bこのまま進む| TASK_DECOMP
    USER_CHECK1 -->|C手動修正| USER_MANUAL

    REQ_ELAB --> USER_QUERY
    USER_QUERY -->|知識追加| KNOWLEDGE_STORE
    USER_QUERY --> USER_CHECK2

    USER_CHECK2 -->|Aタスク分解進む| TASK_DECOMP
    USER_CHECK2 -->|B再詳細化| REQ_ELAB
    USER_CHECK2 -->|C手動編集| USER_MANUAL

    TASK_DECOMP --> USER_CHECK3

    USER_CHECK3 -->|A実行開始| TASK_EXEC
    USER_CHECK3 -->|B再分解| TASK_DECOMP
    USER_CHECK3 -->|C手動調整| USER_MANUAL

    TASK_EXEC --> KNOWLEDGE_STORE
    TASK_EXEC --> USER_CHECK4

    USER_CHECK4 -->|A次タスク| UA
    USER_CHECK4 -->|B完了| INPUT
    USER_CHECK4 -->|C修正| USER_MANUAL

    USER_MANUAL --> UA

    SPEC_KNOW -.->|参照| KNOWLEDGE_STORE
    KNOWLEDGE_STORE -.->|蓄積| SPEC_KNOW
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

```
# user memoryを想定
.claude/
├── commands/
│   └── ticket-workflow.md              # 統合制御・状態遷移管理
├── agents/
│   ├── universal-analyzer.md           # 中核判定・2層知識統合
│   ├── workflow-init.md                # ワークフロー初期化
│   ├── requirements-analyzer.md        # 充足度分析処理
│   ├── requirements-elaborator.md      # 詳細化・ユーザー問い合わせ処理
│   ├── task-decomposer.md             # 分解処理ロジック
│   ├── task-executor.md               # 実行・ナレッジ蓄積処理
│   ├── general-knowledge-injector.md   # 汎用ドメイン知識注入
│   └── specified-knowledge-injector.md # プロジェクト固有知識取得
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
├── .ticket-workflow/                   # 実行時生成（新構造）
│   └── {ticket-namespace}/             # チケット別名前空間
│       ├── current-state.json          # 現在状態
│       ├── requirements.md             # 蓄積要件
│       ├── tasks.md                    # タスク一覧
│       ├── tasks/                      # 個別タスク
│       │   ├── task1.md
│       │   └── task2.md
│       └── knowledge/                  # プロジェクト固有ナレッジ(下記は例)
│           ├── investigation-*.md      # 調査書
│           ├── design-*.md             # 設計書
│           ├── strategy-*.md           # 戦略書
│           └── user-input-*.md         # ユーザー定義制約
└── {既存プロジェクト構造}
```

## 🎬 デモ

*こちらにデモ動画を掲載予定*

実際のチケットを使用したワークフローの動作例：
- チケット入力からタスク分解までの流れ
- プロジェクト固有ナレッジの活用例
- 段階的詳細化プロセスの実際

## 🔮 今後の方向性

- **外部ツールAPI連携**
  - Notion API、Linear API統合
  - チケット自動同期機能

- **コードベース分析強化**
  - プロジェクト構造の深度分析
  - 技術的依存関係の自動抽出

- **MCPサーバー化**
  - Claude Code以外での利用可能化
  - 他の開発環境・IDEとの統合

- **共創AIプラットフォーム化**
  - 複数ユーザーでの知識共有
  - チーム利用最適化


## Appendix

### 📋 プロジェクトの価値

#### 解決したい問題

1. **タスク抽象度の標準化不足**
   - 個人によってタスクの粒度が異なる
   - 大きすぎる/小さすぎるタスクの混在

2. **制約条件・要件の抜け漏れ**
   - 重要な制約の見落としによる手戻り発生
   - 要件定義の不完全性

3. **手作業による非効率な分解プロセス**
   - 人による分解プロセスでAIに比べてスピードが低下
   - 属人的な分解品質のばらつき

#### 提供価値（対応する解決策）

1. **AI制御された抽象度管理**
   - 0.5人日基準での一貫した粒度制御
   - 適切なタスク分解レベルの自動判定

2. **制約条件・要件の抜け漏れ防止**
   - AIによる体系的な要件チェック思考
   - ドメイン知識に基づく制約条件の網羅

3. **AIによる分解プロセスの効率化**
   - 高速かつ一貫性のある自動分解
   - プロジェクト固有知識の活用による精度向上

### 特徴

- **汎用性**: ドメインに依存しない汎用フレームワーク
- **段階的詳細化**: 4段階のユーザー確認による透明性
- **知識蓄積**: プロジェクト固有ナレッジの継続的活用

### 🤝 共創AIとの関わり

#### 共創AI（Co-creative AI）の定義

共創AIとは、**AIと人間が協力して価値を創造**するプロセスです。基本的なサイクルは以下の通りです：

```
人間がAIに指示 → AIが生成 → 人間が評価 → 改善・反復
```

#### このプロジェクトが解決する共創AIの課題

従来の共創AIサイクルには以下の課題がありました：

1. **人の指示の曖昧性**
   - フィードバックが不明確で、AIが適切に理解できない
   - 指示の抽象度が一定しない

2. **評価の属人性**
   - 個人の主観による評価のばらつき
   - 評価基準の不統一

3. **AIの生成品質のばらつき**
   - 同じ指示でも結果の品質が安定しない
   - コンテキスト不足による出力品質の低下

#### 本システムによる改善

このチケットワークフローシステムは、**共創AIのループをより強固にする**ことで上記課題を解決します：

- **構造化された指示**: 段階的詳細化により明確で一貫した指示を実現
- **標準化された評価**: 段階的なユーザー確認による客観的評価基準
- **プロジェクト固有知識の活用**: AIの生成品質を文脈に応じて向上
- **継続的学習**: 過去の成果物を活用した品質向上循環
