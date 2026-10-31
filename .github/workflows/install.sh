#!/bin/bash
set -e

echo "Installing Jekyll and Bundler..."

if ! command -v ruby >/dev/null 2>&1; then
    echo "Error: Ruby is required to install Jekyll and Bundler." >&2
    exit 1
fi

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    gem install --no-document jekyll bundler
else
    # Install for current user
    gem install --user-install --no-document jekyll bundler

    USER_DIR=$(ruby -e 'print Gem.user_dir')
    GEM_BIN=$USER_DIR/bin

    export GEM_HOME="$USER_DIR"
    export PATH="$GEM_BIN:$PATH"

    if [ -n "$GITHUB_ENV" ]; then
        echo "GEM_HOME=$USER_DIR" >> "$GITHUB_ENV"
    fi
    if [ -n "$GITHUB_PATH" ]; then
        echo "$GEM_BIN" >> "$GITHUB_PATH"
    # Add to GITHUB_PATH if running in GitHub Actions
    if [ -n "$GITHUB_PATH" ]; then
        echo "$GEM_BIN" >> "$GITHUB_PATH"
        echo "Added $GEM_BIN to GITHUB_PATH"
    fi

    # Add to .bashrc if not already there
    if ! grep -q "$GEM_BIN" ~/.bashrc; then
        echo "export GEM_HOME=\"$USER_DIR\"" >> ~/.bashrc
        echo "export PATH=\"$GEM_BIN:\$PATH\"" >> ~/.bashrc
        echo "Added $GEM_BIN and GEM_HOME to ~/.bashrc"
    fi

    # Add to .profile if it exists and not already there
    if [ -f ~/.profile ] && ! grep -q "$GEM_BIN" ~/.profile; then
        echo "export GEM_HOME=\"$USER_DIR\"" >> ~/.profile
        echo "export PATH=\"$GEM_BIN:\$PATH\"" >> ~/.profile
        echo "Added $GEM_BIN and GEM_HOME to ~/.profile"
    fi

    if [ -f "Gemfile" ]; then
        echo "Configuring local bundle path..."
        bundle config set --local path 'vendor/bundle'
    fi
fi

if [ -f "Gemfile" ]; then
    echo "Installing bundle dependencies from Gemfile..."
    bundle install
fi

echo "Installation complete."
