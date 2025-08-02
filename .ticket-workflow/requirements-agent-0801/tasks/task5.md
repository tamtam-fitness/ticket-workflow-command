# タスク: エージェント仕様書・統合設計書作成

## WHY（なぜやるか）
- **目的**: Task 1-4の成果物を統合し、実際のClaude Codeエージェントとして実装するための技術仕様と、既存ticket-workflowシステムとの統合設計を確立する
- **必要性**: 前4タスクで設計した要件分類システム、抽出手法、プロセス、チェックリストを統合し、既存のUniversal Analyzer、Requirements Analyzer/Elaboratorとシームレスに連携する実装可能な仕様が必要

## WHAT（何をやるか）
- **作業内容**:
  1. エージェント仕様書（requirements-definition-specialist.md）の作成
     - エージェントの役割・責務の明確化
     - 入力フォーマット・出力フォーマットの標準化
     - 実行ロジック・判断基準の詳細設計
  2. 既存エージェントとの統合設計
     - Universal Analyzerでの制御方法詳細設計
     - Requirements Analyzer/Elaboratorとの役割分担・インターフェース設計
     - ワークフロー内での実行タイミング・条件分岐の設計
  3. エラーハンドリング・例外処理の設計
  4. ドメイン知識注入との連携仕様
  5. 統合設計書（integration-design.md）の作成
  6. 実装・テスト計画書の策定
- **成果物**: requirements-definition-specialist.md、integration-design.md、実装計画書
- **使用ツール**: 既存エージェントファイル分析、.claude/agents/構造調査

## CONTEXT（コンテキスト）
- **関連要件**: requirements.md「5. エージェント仕様書・統合設計書の作成」
- **依存関係**: Task 1-4全完了後（全成果物の統合が必要）
- **制約条件**:
  - Claude Codeエコシステム標準準拠
  - .claude/agents/配下での標準エージェント仕様準拠
  - 既存システムへの影響最小化

## SUCCESS（完了条件）
- [ ] requirements-definition-specialist.mdエージェント仕様書が作成されている
- [ ] 統合設計書（integration-design.md）が作成されている
- [ ] 実装・テスト計画書が策定されている
- [ ] 既存エージェントとの役割分担・インターフェースが明確化されている
- [ ] Universal Analyzerでの制御方法が詳細設計されている
- [ ] エラーハンドリング・例外処理が設計されている
- [ ] ドメイン知識注入との連携仕様が確定している
- [ ] Task 1-4の全成果物が適切に統合されている

**工数**: 0.5人日 | **期限**: Task 1-4全完了後 | **優先度**: High