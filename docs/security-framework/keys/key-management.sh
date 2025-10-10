#!/usr/bin/env sh

# OpenCode Plugin Key Management - POSIX Cryptographic Operations
# 
# Secure key generation, rotation, and revocation for plugin signing
# Uses OpenSSL and ssh-keygen for cross-platform compatibility
# 
# Security Features:
# - Ed25519 and RSA key generation
# - Secure permission setting (600 for private keys)
# - Key fingerprinting and verification
# - Rotation and revocation procedures
# - No private key material in logs or stdout

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default paths
DEFAULT_KEY_DIR="$HOME/.opencode/keys"
TRUSTED_PUBLISHERS="$HOME/.opencode/configs/trusted_publishers.json"
REVOCATION_LIST="$HOME/.opencode/configs/revocation-list.json"

# Logging functions
log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        printf "${BLUE}[DEBUG]${NC} %s\n" "$1"
    fi
}

# Validate required tools
check_dependencies() {
    local missing=""
    
    # Check for ssh-keygen (most portable)
    if ! command -v ssh-keygen >/dev/null 2>&1; then
        missing="$missing ssh-keygen"
    fi
    
    # Check for openssl
    if ! command -v openssl >/dev/null 2>&1; then
        missing="$missing openssl"
    fi
    
    # Check for Node.js for signing operations
    if ! command -v node >/dev/null 2>&1; then
        missing="$missing node"
    fi
    
    if [ -n "$missing" ]; then
        log_error "Missing required tools:$missing"
        log_error "Please install the missing tools and try again"
        exit 1
    fi
    
    log_debug "All required tools available"
}

# Create secure directory structure
setup_directories() {
    local key_dir="${1:-$DEFAULT_KEY_DIR}"
    
    # Create directories with secure permissions
    mkdir -p "$key_dir"
    chmod 700 "$key_dir"
    
    mkdir -p "$(dirname "$TRUSTED_PUBLISHERS")"
    mkdir -p "$(dirname "$REVOCATION_LIST")"
    
    log_debug "Directory structure created: $key_dir"
}

# Generate Ed25519 key pair
gen_ed25519_key() {
    local publisher_id="$1"
    local key_dir="${2:-$DEFAULT_KEY_DIR}"
    local key_path="$key_dir/${publisher_id}_ed25519"
    
    if [ -z "$publisher_id" ]; then
        log_error "Publisher ID required for key generation"
        return 1
    fi
    
    log_info "Generating Ed25519 key pair for publisher: $publisher_id"
    
    # Generate key pair using ssh-keygen (most portable)
    if ! ssh-keygen -q -t ed25519 -f "$key_path" -N "" -C "$publisher_id"; then
        log_error "Failed to generate Ed25519 key"
        return 1
    fi
    
    # Set secure permissions
    chmod 600 "$key_path"          # Private key
    chmod 644 "${key_path}.pub"    # Public key
    
    # Convert public key to PEM format for Node.js crypto
    if ! ssh-keygen -e -f "${key_path}.pub" -m PEM > "${key_path}.pub.pem"; then
        log_error "Failed to convert public key to PEM"
        return 1
    fi
    
    # Generate key ID and fingerprint
    local key_id="${publisher_id}-ed25519-$(date +%Y%m%d)"
    local fingerprint
    fingerprint=$(get_key_fingerprint "${key_path}.pub.pem")
    
    log_info "Key generated successfully:"
    log_info "  Private key: $key_path (mode 600)"
    log_info "  Public key:  ${key_path}.pub.pem"
    log_info "  Key ID:      $key_id"
    log_info "  Fingerprint: $fingerprint"
    
    # Create key metadata
    cat > "${key_path}.meta" << EOF
{
  "keyId": "$key_id",
  "algorithm": "ed25519",
  "fingerprint": "$fingerprint",
  "publisherId": "$publisher_id",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "publicKeyPath": "${key_path}.pub.pem",
  "privateKeyPath": "$key_path"
}
EOF
    
    log_info "Key metadata saved: ${key_path}.meta"
    
    # Warn about secure storage
    log_warn "SECURITY: Store private key securely!"
    log_warn "  macOS: Consider importing to Keychain"
    log_warn "  Linux: Use ssh-agent or encrypted storage"
    log_warn "  Never commit private keys to version control"
}

# Generate RSA key pair
gen_rsa_key() {
    local publisher_id="$1"
    local key_dir="${2:-$DEFAULT_KEY_DIR}"
    local bits="${3:-4096}"
    local key_path="$key_dir/${publisher_id}_rsa$bits"
    
    if [ -z "$publisher_id" ]; then
        log_error "Publisher ID required for key generation"
        return 1
    fi
    
    log_info "Generating RSA-$bits key pair for publisher: $publisher_id"
    
    # Generate private key
    if ! openssl genpkey -algorithm RSA -pkcs8 -out "$key_path" -pkeyopt rsa_keygen_bits:"$bits"; then
        log_error "Failed to generate RSA private key"
        return 1
    fi
    
    # Extract public key
    if ! openssl pkey -in "$key_path" -pubout -out "${key_path}.pub.pem"; then
        log_error "Failed to extract RSA public key"
        return 1
    fi
    
    # Set secure permissions
    chmod 600 "$key_path"             # Private key
    chmod 644 "${key_path}.pub.pem"   # Public key
    
    # Generate key ID and fingerprint
    local key_id="${publisher_id}-rsa$bits-$(date +%Y%m%d)"
    local fingerprint
    fingerprint=$(get_key_fingerprint "${key_path}.pub.pem")
    
    log_info "RSA key generated successfully:"
    log_info "  Private key: $key_path (mode 600)"
    log_info "  Public key:  ${key_path}.pub.pem"
    log_info "  Key ID:      $key_id"
    log_info "  Fingerprint: $fingerprint"
    
    # Create key metadata
    cat > "${key_path}.meta" << EOF
{
  "keyId": "$key_id",
  "algorithm": "rsa",
  "bits": $bits,
  "fingerprint": "$fingerprint",
  "publisherId": "$publisher_id",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "publicKeyPath": "${key_path}.pub.pem",
  "privateKeyPath": "$key_path"
}
EOF
    
    log_info "Key metadata saved: ${key_path}.meta"
}

# Get key fingerprint (SHA-256 of public key)
get_key_fingerprint() {
    local pubkey_path="$1"
    
    if [ ! -f "$pubkey_path" ]; then
        log_error "Public key file not found: $pubkey_path"
        return 1
    fi
    
    # Extract raw public key and compute SHA-256
    openssl pkey -pubin -in "$pubkey_path" -outform DER | openssl dgst -sha256 -binary | openssl enc -base64 | tr -d '\n'
}

# Add publisher to trusted list
add_trusted_publisher() {
    local pubkey_path="$1"
    local publisher_id="$2"
    local key_id="$3"
    
    if [ ! -f "$pubkey_path" ]; then
        log_error "Public key file not found: $pubkey_path"
        return 1
    fi
    
    local fingerprint
    fingerprint=$(get_key_fingerprint "$pubkey_path")
    
    local algorithm="ed25519"
    if grep -q "RSA" "$pubkey_path"; then
        algorithm="rsa"
    fi
    
    local pubkey_pem
    pubkey_pem=$(cat "$pubkey_path")
    
    # Create or update trusted publishers file
    if [ ! -f "$TRUSTED_PUBLISHERS" ]; then
        echo "[]" > "$TRUSTED_PUBLISHERS"
    fi
    
    # Add publisher entry (simple JSON append - in production use proper JSON tools)
    local entry="{
  \"publisherId\": \"$publisher_id\",
  \"keyId\": \"$key_id\",
  \"algorithm\": \"$algorithm\",
  \"fingerprint\": \"$fingerprint\",
  \"addedAt\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
  \"publicKeyPem\": \"$(echo "$pubkey_pem" | sed ':a;N;$!ba;s/\n/\\n/g')\"
}"
    
    log_info "Adding trusted publisher:"
    log_info "  Publisher: $publisher_id"
    log_info "  Key ID:    $key_id"
    log_info "  Algorithm: $algorithm"
    log_info "  Fingerprint: $fingerprint"
    
    # Note: In production, use proper JSON manipulation
    log_warn "Manual step: Add entry to $TRUSTED_PUBLISHERS"
    log_warn "Entry to add:"
    echo "$entry"
}

# Rotate publisher key
rotate_key() {
    local old_key_path="$1"
    local publisher_id="$2"
    local algorithm="${3:-ed25519}"
    
    if [ ! -f "$old_key_path" ]; then
        log_error "Old private key not found: $old_key_path"
        return 1
    fi
    
    log_info "Rotating key for publisher: $publisher_id"
    
    # Generate new key
    case "$algorithm" in
        "ed25519")
            gen_ed25519_key "$publisher_id"
            ;;
        "rsa"|"rsa4096")
            gen_rsa_key "$publisher_id" "$DEFAULT_KEY_DIR" 4096
            ;;
        *)
            log_error "Unsupported algorithm: $algorithm"
            return 1
            ;;
    esac
    
    # Create rotation statement (to be signed)
    local rotation_file="/tmp/rotation_${publisher_id}_$(date +%s).json"
    cat > "$rotation_file" << EOF
{
  "type": "key-rotation",
  "publisherId": "$publisher_id",
  "oldKeyFingerprint": "$(get_key_fingerprint "${old_key_path}.pub.pem")",
  "newKeyFingerprint": "$(get_key_fingerprint "$DEFAULT_KEY_DIR/${publisher_id}_${algorithm}.pub.pem")",
  "issuedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "reason": "key-rotation"
}
EOF
    
    log_info "Rotation statement created: $rotation_file"
    log_warn "Next steps:"
    log_warn "1. Sign rotation statement with old key"
    log_warn "2. Publish signed rotation to trusted channels"
    log_warn "3. Update trusted_publishers.json"
    log_warn "4. Securely destroy old private key"
}

# Revoke key
revoke_key() {
    local key_id="$1"
    local reason="${2:-compromised}"
    local signer_key="$3"
    
    if [ -z "$key_id" ]; then
        log_error "Key ID required for revocation"
        return 1
    fi
    
    log_info "Creating revocation for key: $key_id"
    
    # Create revocation entry
    local revocation_file="/tmp/revocation_${key_id}_$(date +%s).json"
    cat > "$revocation_file" << EOF
{
  "type": "key-revocation",
  "keyId": "$key_id",
  "reason": "$reason",
  "revokedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "signerKeyId": "$(basename "$signer_key" | sed 's/\.[^.]*$//')"
}
EOF
    
    log_info "Revocation statement created: $revocation_file"
    log_warn "Next steps:"
    log_warn "1. Sign revocation statement with authorized key"
    log_warn "2. Add to revocation-list.json"
    log_warn "3. Distribute updated revocation list"
}

# List keys in directory
list_keys() {
    local key_dir="${1:-$DEFAULT_KEY_DIR}"
    
    if [ ! -d "$key_dir" ]; then
        log_warn "Key directory not found: $key_dir"
        return 1
    fi
    
    log_info "Keys in $key_dir:"
    
    for meta_file in "$key_dir"/*.meta; do
        if [ -f "$meta_file" ]; then
            local key_id
            local algorithm
            local fingerprint
            local created_at
            
            # Extract metadata (simple grep - in production use proper JSON parser)
            key_id=$(grep '"keyId"' "$meta_file" | sed 's/.*: *"\([^"]*\)".*/\1/')
            algorithm=$(grep '"algorithm"' "$meta_file" | sed 's/.*: *"\([^"]*\)".*/\1/')
            fingerprint=$(grep '"fingerprint"' "$meta_file" | sed 's/.*: *"\([^"]*\)".*/\1/')
            created_at=$(grep '"createdAt"' "$meta_file" | sed 's/.*: *"\([^"]*\)".*/\1/')
            
            printf "  %s (%s) - %s - %s\n" "$key_id" "$algorithm" "$created_at" "${fingerprint:0:16}..."
        fi
    done
}

# Verify key integrity
verify_key() {
    local key_path="$1"
    
    if [ ! -f "$key_path" ]; then
        log_error "Key file not found: $key_path"
        return 1
    fi
    
    log_info "Verifying key: $key_path"
    
    # Check private key
    if openssl pkey -in "$key_path" -noout -check >/dev/null 2>&1; then
        log_info "Private key: VALID"
    else
        log_error "Private key: INVALID"
        return 1
    fi
    
    # Check public key if it exists
    if [ -f "${key_path}.pub.pem" ]; then
        if openssl pkey -pubin -in "${key_path}.pub.pem" -noout >/dev/null 2>&1; then
            log_info "Public key: VALID"
        else
            log_error "Public key: INVALID"
            return 1
        fi
        
        # Verify key pair match
        local priv_fingerprint
        local pub_fingerprint
        
        priv_fingerprint=$(openssl pkey -in "$key_path" -pubout | openssl dgst -sha256 -binary | openssl enc -base64 | tr -d '\n')
        pub_fingerprint=$(get_key_fingerprint "${key_path}.pub.pem")
        
        if [ "$priv_fingerprint" = "$pub_fingerprint" ]; then
            log_info "Key pair: MATCHED"
        else
            log_error "Key pair: MISMATCH"
            return 1
        fi
    fi
    
    log_info "Key verification: PASSED"
}

# Show help
show_help() {
    cat << 'EOF'
OpenCode Plugin Key Management

Usage: key-management.sh <command> [options]

Commands:
    gen-ed25519 <publisher-id> [key-dir]     Generate Ed25519 key pair
    gen-rsa <publisher-id> [key-dir] [bits]  Generate RSA key pair
    fingerprint <pubkey-file>                Show key fingerprint
    add-publisher <pubkey> <id> <key-id>     Add to trusted publishers
    rotate <old-key> <publisher-id> [algo]   Rotate publisher key
    revoke <key-id> [reason] [signer-key]    Revoke key
    list [key-dir]                           List available keys
    verify <key-file>                        Verify key integrity
    help                                     Show this help

Examples:
    ./key-management.sh gen-ed25519 example-publisher
    ./key-management.sh gen-rsa example-publisher ~/.opencode/keys 4096
    ./key-management.sh fingerprint ~/.opencode/keys/example_ed25519.pub.pem
    ./key-management.sh list
    ./key-management.sh verify ~/.opencode/keys/example_ed25519

Security Notes:
    - Private keys are created with 600 permissions
    - Store private keys securely (Keychain, ssh-agent, hardware token)
    - Never commit private keys to version control
    - Rotate keys regularly and on compromise
    - Verify key integrity before use

Environment Variables:
    DEBUG=1           Enable debug output
    OPENCODE_KEY_DIR  Override default key directory
EOF
}

# Main command dispatcher
main() {
    # Check dependencies first
    check_dependencies
    
    case "${1:-help}" in
        "gen-ed25519")
            setup_directories "${3:-$DEFAULT_KEY_DIR}"
            gen_ed25519_key "$2" "${3:-$DEFAULT_KEY_DIR}"
            ;;
        "gen-rsa")
            setup_directories "${3:-$DEFAULT_KEY_DIR}"
            gen_rsa_key "$2" "${3:-$DEFAULT_KEY_DIR}" "${4:-4096}"
            ;;
        "fingerprint")
            get_key_fingerprint "$2"
            ;;
        "add-publisher")
            add_trusted_publisher "$2" "$3" "$4"
            ;;
        "rotate")
            rotate_key "$2" "$3" "$4"
            ;;
        "revoke")
            revoke_key "$2" "$3" "$4"
            ;;
        "list")
            list_keys "$2"
            ;;
        "verify")
            verify_key "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 2
            ;;
    esac
}

# Run main function
main "$@"