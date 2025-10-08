#!/bin/bash

set -e

# Script to prune CometBFT block store up to a specified height
# Usage: ./prune-blocks.sh <height> [--prune-indexers] [data-dir] [db-backend]

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <height> [--prune-indexers] [data-dir] [db-backend]"
    echo ""
    echo "Arguments:"
    echo "  height            - Height to prune up to (not including this height)"
    echo "  --prune-indexers  - Optional flag to also prune tx and block indexers"
    echo "  data-dir          - Path to the data directory (default: \$HOME/.cometbft/data)"
    echo "  db-backend        - Database backend type (default: goleveldb)"
    echo ""
    echo "Examples:"
    echo "  $0 1000"
    echo "  $0 1000 --prune-indexers"
    echo "  $0 1000 --prune-indexers /path/to/data goleveldb"
    echo "  $0 1000 /path/to/data goleveldb"
    exit 1
fi

HEIGHT=$1
shift

# Check for --prune-indexers flag
PRUNE_INDEXERS=""
if [ "$1" = "--prune-indexers" ]; then
    PRUNE_INDEXERS="-prune-indexers"
    shift
fi

DATA_DIR=${1:-""}
DB_BACKEND=${2:-"goleveldb"}

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
PRUNE_TOOL_DIR="$PROJECT_ROOT/cmd/prune-blocks"

echo "==> Building prune-blocks tool..."
cd "$PRUNE_TOOL_DIR"
go build -o prune-blocks main.go

echo "==> Running prune-blocks tool..."
if [ -z "$DATA_DIR" ]; then
    ./prune-blocks -height "$HEIGHT" -db-backend "$DB_BACKEND" $PRUNE_INDEXERS
else
    ./prune-blocks -height "$HEIGHT" -data-dir "$DATA_DIR" -db-backend "$DB_BACKEND" $PRUNE_INDEXERS
fi

echo "==> Pruning completed successfully!"
