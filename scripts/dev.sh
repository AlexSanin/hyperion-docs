#!/usr/bin/env bash

IS_INIT=0
MIN_NODE_VERSION=22
ROOT_DIR=$(dirname $(dirname $(realpath $0)))

while test $# -gt 0; do
  case "$1" in
    --init)
      IS_INIT=1
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🛫 Starting local development environment..."
echo ""
echo "Is init run: $IS_INIT"
echo ""

echo "🔍 Checking dependencies..."

if ! command_exists brew; then
    echo "❌ Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

if command_exists node; then
    echo "✅ Node.js is already installed (version $(node -v))"

    NODE_VERSION=$(node -v | cut -c 2-)
    NODE_VERSION_MAJOR=$(echo "$NODE_VERSION" | cut -d '.' -f 1)
    if [ "$NODE_VERSION_MAJOR" -lt "$MIN_NODE_VERSION" ]; then
        echo "❌ Node.js version is too old. Please update to version $MIN_NODE_VERSION or higher."
        exit 1
    fi
else
    echo "📦 Installing Node.js using Homebrew..."
    brew install node
    if command_exists node; then
        echo "✅ Node.js successfully installed (version $(node -v))"
    else
        echo "❌ Failed to install Node.js"
        exit 1
    fi
fi

if command_exists pnpm; then
    echo "✅ pnpm is already installed (version $(pnpm -v))"
else
    echo "📦 Installing pnpm using Homebrew..."
    npm install -g pnpm@10
    if command_exists pnpm; then
        echo "✅ pnpm successfully installed (version $(pnpm -v))"
    else
        echo "❌ Failed to install pnpm"
        exit 1
    fi
fi

echo "🔄 Installing dependencies..."
pnpm install
echo "✅ Dependencies installed successfully."
echo ""

echo "🔄 Starting Docker containers..."

# Only build if --init flag passed or image doesn't exist
if [ "$IS_INIT" -eq 1 ] || [ -z "$(docker images -q hyperion-docs-docs 2>/dev/null)" ]; then
    echo "🔨 Building Docker image..."
    docker compose -f $ROOT_DIR/docker-compose.dev.yml up -d --build
else
    echo "⚡ Using existing image (use --init to rebuild)"
    docker compose -f $ROOT_DIR/docker-compose.dev.yml up -d
fi