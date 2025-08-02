#!/usr/bin/env bash
set -euo pipefail

# Source common utilities if available
if [[ -f "$(dirname "$0")/common.sh" ]]; then
  source "$(dirname "$0")/common.sh"
else
  # Fallback logging if common.sh not found
  log_info()    { echo -e "\033[0;34m📋 $1\033[0m"; }
  log_success() { echo -e "\033[0;32m✅ $1\033[0m"; }
  log_warning() { echo -e "\033[1;33m⚠️  $1\033[0m"; }
  log_error()   { echo -e "\033[0;31m❌ $1\033[0m"; }
  log_step()    { echo -e "\033[0;36m🔄 $1\033[0m"; }
fi

log_step "Bước 1: Kiểm tra remote 'origin'..."
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -z "$remote_url" ]]; then
  log_error "Không tìm thấy remote 'origin'."
  exit 1
fi

if [[ "$remote_url" != git@github.com:* ]]; then
  if [[ "$remote_url" =~ github.com[:/]+([^/]+)/([^.]+)(\.git)?$ ]]; then
    username="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
    ssh_url="git@github.com:${username}/${repo}.git"
    log_step "Chuyển remote 'origin' sang SSH: $ssh_url"
    git remote set-url origin "$ssh_url"
    remote_url="$ssh_url"
  else
    log_error "Không thể phân tích remote URL: $remote_url"
    exit 2
  fi
else
  log_success "Remote 'origin' đã dùng SSH."
fi

log_step "Bước 2: Kiểm tra xác thực SSH với GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  log_success "Xác thực SSH thành công với GitHub."
else
  log_error "Không thể xác thực SSH với GitHub. Hãy kiểm tra SSH key và cấu hình trên GitHub: https://github.com/settings/keys"
  exit 3
fi

log_step "Bước 3: Thực hiện git push..."
git push && log_success "Push thành công!" || { log_error "Push thất bại!"; exit 4; }
