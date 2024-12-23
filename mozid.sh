set -euo pipefail

# Display usage information
display_usage() {
    cat <<USAGE
Usage: mozid [options] <base> <url>

Description:
  This script downloads a program extension (given a program-specific base) from the given URL, extracts it, and retrieves the extension ID from the 'manifest.json' file.

Options:
  -v, --verbose
    Enable verbose output for debugging

  -h, --help
    Display this help message and exit

Example:
  mozid https://addons.mozilla.org/firefox/downloads/file https://addons.mozilla.org/en-US/firefox/addon/vimium-ff

USAGE
}

# Initialize variables
verbose=false
base_url=""
extension_url=""

# Parse arguments using a while loop
while [[ $# -gt 0 ]]; do
    case $1 in
        -v | --verbose)
            verbose=true
            shift
            ;;
        -h | --help)
            display_usage
            exit 0
            ;;
        *)
            # Treat the first two non-options as the URLs
            if [[ -z "$base_url" ]]; then
                base_url="$1"
                shift
            elif [[ -z "$extension_url" ]]; then
                extension_url="$1"
                shift
            else
                echo "error: unknown option -- '$1'"
                echo "try '--help' for more information"
                exit 1
            fi
            ;;
    esac
done

# Check if the URLs are provided
if [[ -z "$base_url" ]]; then
    echo "error: no base url provided"
    display_usage
    exit 1
fi
if [[ -z "$extension_url" ]]; then
    echo "error: no extension url provided"
    display_usage
    exit 1
fi

# Ensure the URLs do not have query params but trailing slash
base_url=$(cut -d\? -f1 <<< "${base_url}")
if [[ "${base_url: -1}" != "/" ]]; then
    base_url="${base_url}/"
fi
extension_url=$(cut -d\? -f1 <<< "${extension_url}")
if [[ "${extension_url: -1}" != "/" ]]; then
    extension_url="${extension_url}/"
fi

# Verbose output function
say() {
    if [[ "$verbose" = true ]]; then
        echo "$@"
    fi
}

# Create a temporary directory
TMP_DIR=$(mktemp -d)
if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
    echo "error: failed to create a temporary directory"
    exit 1
fi
say "status: using temporary directory '$TMP_DIR'"

# Download the page and extract the '*.xpi' URL
PREFIX_URL="$(cut -d/ -f-3 <<< "$base_url")"
MATCH_URL="$(cut -d/ -f4- <<< "$base_url")"
say "status: matching '*.xpi' download link on '$MATCH_URL'"

XPI_URL=$(curl -s "$extension_url" | \
    grep -Po "(?<=href=\")[^\"]*${MATCH_URL}[^\"]+\.xpi(?!.*type:attachment)" | head -n 1)

if [[ -z "$XPI_URL" ]]; then
    echo "error: failed to extract '*.xpi' download link from the provided url"
    exit 1
elif [[ "$XPI_URL" != "$PREFIX_URL"* ]]; then
    XPI_URL="$PREFIX_URL/$XPI_URL"
fi
say "status: downloading '*.xpi' file from '$XPI_URL'"

# Download the '*.xpi' file
XPI_FILE="$TMP_DIR/extension.xpi"
if ! curl -sSL -o "$XPI_FILE" "$XPI_URL"; then
    echo "error: failed to download '*.xpi' file"
    exit 1
fi
say "status: downloaded '*.xpi' file '$XPI_FILE'"

# Extract the files
EXTRACT_DIR="$TMP_DIR/extracted_xpi"
mkdir -p "$EXTRACT_DIR"
if ! unzip -q "$XPI_FILE" -d "$EXTRACT_DIR"; then
    echo "error: failed to extract '*.xpi' file"
    exit 1
fi
say "status: extracted '*.xpi' file to '$EXTRACT_DIR'"

# Check if manifest.json exists
MANIFEST_FILE="$EXTRACT_DIR/manifest.json"
if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "error: 'manifest.json' not found in the extracted files"
    exit 1
fi
say "status: found 'manifest.json' file"

# Extract the ID
ID=$(grep -Po '(?<="id": ")[^"]+' "$MANIFEST_FILE")
if [[ -z "$ID" ]]; then
    echo "error: id not found in the 'manifest.json' file"
    exit 1
fi

# Output results in the appropriate format
if [[ -d "$TMP_DIR" && "$TMP_DIR" == "$(dirname $(mktemp -u))"* ]]; then
    rm -r "$TMP_DIR"
    say "status: removed temporary directory '$TMP_DIR'"
fi
echo "$ID"
exit 0
