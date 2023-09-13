#!/bin/bash

GITHUB_USERNAME="thotsbay"
GITHUB_REPO="blog"
#GITHUB_TOKEN="your-github-token"
GO_VERSION="1.20.7"

sudo apt-get update
sudo apt-get install -y upx-ucl curl unzip

update_readme() {
  cat <<EOL > README.md
Latest Cloudflared Version: $latest_version
EOL
}

download_compile_upload() {
  wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
  export PATH=$PATH:/usr/local/go/bin

  download_url="https://github.com/cloudflare/cloudflared/archive/$latest_version.zip"
  curl -LO "$download_url"
  unzip "$latest_version.zip"
  cd "cloudflared-$latest_version"

  go build -o cloudflared -trimpath -ldflags "-s -w -buildid=" ./cmd/cloudflared
  upx -o gost cloudflared
  sudo chmod +x gost
}

upload_to_github() {
  git add README.md gost
  git commit -m "Update Cloudflared version to $latest_version"
  git push
}

latest_release_info=$(curl -s https://api.github.com/repos/cloudflare/cloudflared/releases/latest)
latest_version=$(echo "$latest_release_info" | grep '"tag_name":' | cut -d '"' -f 4)

current_version=$(curl -s "https://raw.githubusercontent.com/$GITHUB_USERNAME/$GITHUB_REPO/main/README.md" | grep 'Latest Cloudflared Version:' | awk '{print $NF}')

if [ "$latest_version" != "$current_version" ]; then
  echo "Remote Cloudflared version ($current_version) is different from latest version ($latest_version). Updating..."

  update_readme

  download_compile_upload

  upload_to_github

else
  echo "Remote Cloudflared version is up to date. No need to download and compile gost."
fi
