#!/bin/bash

set -e

SOURCE_DIR="./.claude"
TARGET_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "エラー: ソースディレクトリ '$SOURCE_DIR' が見つかりません。"
    exit 1
fi

echo "🚀 Claude Code 設定をインストールしています..."
echo "ソースディレクトリ: $SCRIPT_DIR/$SOURCE_DIR"
echo "インストール先: $TARGET_DIR"
echo ""

# ターゲットディレクトリ作成
mkdir -p "$TARGET_DIR"

# 統計カウンター
updated_files=0
new_files=0
skipped_files=0

# 設定ファイル（.jsonファイル）のインストール
echo "📝 設定ファイルのインストール..."
for file in "$SOURCE_DIR"/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target_file="$TARGET_DIR/$filename"
        
        echo "  → $filename を処理中..."

        # スクリプトディレクトリパスを実際のパスに置換
        sed -e "s|<script_path>|$SCRIPT_DIR|g" \
            -e "s|<claude_code_tools_path>|$SCRIPT_DIR|g" \
            "$file" > "$target_file.tmp"

        if [ -f "$target_file" ]; then
            if ! cmp -s "$target_file.tmp" "$target_file"; then
                mv "$target_file.tmp" "$target_file"
                echo "  ↻ $filename を更新しました"
                updated_files=$((updated_files + 1))
            else
                rm "$target_file.tmp"
                echo "  ✓ $filename は最新版です"
                skipped_files=$((skipped_files + 1))
            fi
        else
            mv "$target_file.tmp" "$target_file"
            echo "  + $filename を新規作成しました"
            new_files=$((new_files + 1))
        fi
    fi
done

# agentsディレクトリのインストール
if [ -d "$SOURCE_DIR/agents" ]; then
    echo ""
    echo "🤖 エージェントディレクトリのインストール..."
    
    mkdir -p "$TARGET_DIR/agents"
    
    for source_file in "$SOURCE_DIR/agents"/*.md; do
        if [ -f "$source_file" ]; then
            filename=$(basename "$source_file")
            target_file="$TARGET_DIR/agents/$filename"
            
            if [ -f "$target_file" ]; then
                if ! cmp -s "$source_file" "$target_file"; then
                    echo "  ↻ agents/$filename を更新中..."
                    cp "$source_file" "$target_file"
                    updated_files=$((updated_files + 1))
                else
                    echo "  ✓ agents/$filename は最新版です"
                    skipped_files=$((skipped_files + 1))
                fi
            else
                echo "  + agents/$filename を追加中..."
                cp "$source_file" "$target_file"
                new_files=$((new_files + 1))
            fi
        fi
    done
fi

# commandsディレクトリのインストール
if [ -d "$SOURCE_DIR/commands" ]; then
    echo ""
    echo "🛠️  コマンドディレクトリのインストール..."
    
    mkdir -p "$TARGET_DIR/commands"
    
    # 直接.mdファイルがある場合
    for source_file in "$SOURCE_DIR/commands"/*.md; do
        if [ -f "$source_file" ]; then
            filename=$(basename "$source_file")
            target_file="$TARGET_DIR/commands/$filename"
            
            if [ -f "$target_file" ]; then
                if ! cmp -s "$source_file" "$target_file"; then
                    echo "  ↻ commands/$filename を更新中..."
                    cp "$source_file" "$target_file"
                    updated_files=$((updated_files + 1))
                else
                    echo "  ✓ commands/$filename は最新版です"
                    skipped_files=$((skipped_files + 1))
                fi
            else
                echo "  + commands/$filename を追加中..."
                cp "$source_file" "$target_file"
                new_files=$((new_files + 1))
            fi
        fi
    done
    
    # 各名前空間ディレクトリを処理
    for source_namespace in "$SOURCE_DIR/commands"/*/; do
        if [ -d "$source_namespace" ]; then
            namespace=$(basename "$source_namespace")
            target_namespace="$TARGET_DIR/commands/$namespace"
            
            echo "  📁 名前空間 '$namespace' を処理中..."
            mkdir -p "$target_namespace"
            
            for source_file in "$source_namespace"*.md; do
                if [ -f "$source_file" ]; then
                    filename=$(basename "$source_file")
                    target_file="$target_namespace/$filename"
                    
                    if [ -f "$target_file" ]; then
                        if ! cmp -s "$source_file" "$target_file"; then
                            echo "    ↻ $namespace/$filename を更新中..."
                            cp "$source_file" "$target_file"
                            updated_files=$((updated_files + 1))
                        else
                            echo "    ✓ $namespace/$filename は最新版です"
                            skipped_files=$((skipped_files + 1))
                        fi
                    else
                        echo "    + $namespace/$filename を追加中..."
                        cp "$source_file" "$target_file"
                        new_files=$((new_files + 1))
                    fi
                fi
            done
        fi
    done
fi

# docsディレクトリのインストール（再帰的にコピー）
if [ -d "$SOURCE_DIR/docs" ]; then
    echo ""
    echo "📚 ドキュメントディレクトリのインストール..."
    
    # docsディレクトリを再帰的にコピー
    find "$SOURCE_DIR/docs" -type f -name "*.md" | while read -r source_file; do
        # 相対パスを取得
        relative_path=${source_file#$SOURCE_DIR/}
        target_file="$TARGET_DIR/$relative_path"
        target_dir=$(dirname "$target_file")
        
        # ターゲットディレクトリ作成
        mkdir -p "$target_dir"
        
        if [ -f "$target_file" ]; then
            if ! cmp -s "$source_file" "$target_file"; then
                echo "  ↻ $relative_path を更新中..."
                cp "$source_file" "$target_file"
                updated_files=$((updated_files + 1))
            else
                echo "  ✓ $relative_path は最新版です"
                skipped_files=$((skipped_files + 1))
            fi
        else
            echo "  + $relative_path を追加中..."
            cp "$source_file" "$target_file"
            new_files=$((new_files + 1))
        fi
    done
fi

# claude.mdファイルのインストール
echo ""
echo "📄 CLAUDE.mdファイルのインストール..."
claude_md_found=false

for claude_file in "$SOURCE_DIR/claude.md" "$SOURCE_DIR/CLAUDE.md"; do
    if [ -f "$claude_file" ]; then
        filename=$(basename "$claude_file")
        target_file="$TARGET_DIR/claude.md"
        
        if [ -f "$target_file" ]; then
            if ! cmp -s "$claude_file" "$target_file"; then
                echo "  ↻ $filename を claude.md として更新中..."
                cp "$claude_file" "$target_file"
                updated_files=$((updated_files + 1))
            else
                echo "  ✓ claude.md は最新版です"
                skipped_files=$((skipped_files + 1))
            fi
        else
            echo "  + $filename を claude.md として追加中..."
            cp "$claude_file" "$target_file"
            new_files=$((new_files + 1))
        fi
        claude_md_found=true
        break
    fi
done

if [ "$claude_md_found" = false ]; then
    echo "  ⚠️  claude.md または CLAUDE.md が見つかりませんでした"
fi

# 統計情報を表示
echo ""
echo "✅ インストール完了！"
echo ""
echo "📊 処理結果:"
echo "  • 新規ファイル: $new_files 個"
echo "  • 更新ファイル: $updated_files 個"
echo "  • スキップ: $skipped_files 個"

# インストールされた内容の統計
if [ -d "$TARGET_DIR/agents" ]; then
    agent_count=$(find "$TARGET_DIR/agents" -name "*.md" -type f | wc -l | tr -d ' ')
    echo "  • エージェント: $agent_count 個"
fi

if [ -d "$TARGET_DIR/commands" ]; then
    command_count=$(find "$TARGET_DIR/commands" -name "*.md" -type f | wc -l | tr -d ' ')
    echo "  • コマンド: $command_count 個"
fi

if [ -d "$TARGET_DIR/docs" ]; then
    doc_count=$(find "$TARGET_DIR/docs" -name "*.md" -type f | wc -l | tr -d ' ')
    echo "  • ドキュメント: $doc_count 個"
fi

echo ""
echo "📍 インストール場所:"
echo "  • メイン設定: $TARGET_DIR/"
if [ -f "$TARGET_DIR/claude.md" ]; then
    echo "  • CLAUDE.md: $TARGET_DIR/claude.md"
fi
if [ -d "$TARGET_DIR/agents" ]; then
    echo "  • エージェント: $TARGET_DIR/agents/"
fi
if [ -d "$TARGET_DIR/commands" ]; then
    echo "  • コマンド: $TARGET_DIR/commands/"
fi
if [ -d "$TARGET_DIR/docs" ]; then
    echo "  • ドキュメント: $TARGET_DIR/docs/"
fi

echo ""
echo "💡 使用方法:"
echo "  claude \"/command-name\""
echo "  例: claude \"/ticket-workflow\""

echo ""
echo "🎉 Claude Code 設定のインストールが完了しました！"