#!/bin/bash

# Build parquet-cli with dependencies
# https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/parquet-cli.rb

set -euo pipefail

git clone https://github.com/apache/parquet-mr.git
cd parquet-mr/parquet-cli
git apply ../../pom.patch
mvn package -DskipTests=true
mvn dependency:copy-dependencies

mkdir -p "$HOME/.local/lib/parquet-cli"
cp target/parquet-cli-*-runtime.jar "$HOME/.local/lib/parquet-cli"
cp target/dependency/* "$HOME/.local/lib/parquet-cli"

cat << 'EOF' > "$HOME/.local/bin/parquet-cli"
#!/bin/bash

set -euo pipefail

java -cp "$HOME/.local/lib/parquet-cli/*" org.apache.parquet.cli.Main "$@"
EOF

chmod +x "$HOME/.local/bin/parquet-cli"

cd ../../
rm -rf parquet-mr
