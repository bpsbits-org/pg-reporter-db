#!/usr/bin/env bash
# Combines all install scripts into single file in proper order
# bash ./scripts/generate-install-file.sh
#
SCRIPT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_FILE
SCRIPT_DIR=$(dirname "${SCRIPT_FILE}")
readonly SCRIPT_DIR
PROJECT_DIR=$(dirname "${SCRIPT_DIR}")
readonly PROJECT_DIR
readonly INSTALL_ORDER_FILE="${PROJECT_DIR}/src/db/pgr/.install-order"
readonly FILE_SQL_SRIPTS="${PROJECT_DIR}/dist/install-files.txt"
readonly FILE_SQL_INSTALL="${PROJECT_DIR}/dist/install.sql"

# Go to project dir
cd "${PROJECT_DIR}" || exit

# Create dist directory and remove existing install-files.txt and install.sql
mkdir -p "${PROJECT_DIR}/dist"
rm -f "${FILE_SQL_SRIPTS}"
rm -f "${FILE_SQL_INSTALL}"

getSqlFilesList() {
    local inputFile="$1"
    local line
    local filePath
    local errors=0

    # Check if the input file exists
    if [[ ! -f "${inputFile}" ]]; then
        echo "Error: Input file '${inputFile}' does not exist" >&2
        return 1
    fi

    # Read non-empty lines from the input file
    while IFS= read -r line; do
        # Skip empty lines or lines with only whitespace
        if [[ -n "${line}" && ! "${line}" =~ ^[[:space:]]*$ ]]; then
            filePath="${PROJECT_DIR}/${line}"
            # Check if the file exists
            if [[ -f "${filePath}" ]]; then
                # Check if the file ends with .sql
                if [[ "${filePath}" =~ \.sql$ ]]; then
                    echo "${filePath}"
                # Check if the file ends with .install-order
                elif [[ "${filePath}" =~ \.install-order$ ]]; then
                    # Recursively process the .install-order file
                    getSqlFilesList "${filePath}" || ((errors++))
                else
                    echo "Error: File '${filePath}' is neither .sql nor .install-order" >&2
                    ((errors++))
                fi
            else
                echo "Error: File '${filePath}' does not exist" >&2
                ((errors++))
            fi
        fi
    done < <(grep -v '^[[:space:]]*$' "${inputFile}")

    # Return non-zero exit code if any errors occurred
    [[ ${errors} -gt 0 ]] && return 1
    return 0
}

combineSqlFiles() {
    local inputList="$1"
    local outputFile="$2"
    local line
    local relativePath
    local errors=0

    # Check if the input list file exists
    if [[ ! -f "${inputList}" ]]; then
        echo "Error: Input list file '${inputList}' does not exist" >&2
        return 1
    fi

    # Read each line (file path) from the input list
    while IFS= read -r line; do
        # Skip empty lines or lines with only whitespace
        if [[ -n "${line}" && ! "${line}" =~ ^[[:space:]]*$ ]]; then
            # Check if the file exists and is readable
            if [[ -f "${line}" && -r "${line}" ]]; then
                # Compute the relative path by removing PROJECT_DIR prefix
                relativePath="${line#"${PROJECT_DIR}"/}"
                # Append the file contents to the output file with relative path in comment
                echo -e "-- ---------------------------------------------------------------------" >> "${outputFile}"
                echo -e "-- SCRIPT: ${relativePath}\n" >> "${outputFile}"
                cat "${line}" >> "${outputFile}" || {
                    echo "Error: Failed to append contents of '${line}' to '${outputFile}'" >&2
                    ((errors++))
                }
                echo -e "\n\n" >> "${outputFile}"
            else
                echo "Error: File '${line}' does not exist or is not readable" >&2
                ((errors++))
            fi
        fi
    done < "${inputList}"

    # Return non-zero exit code if any errors occurred
    [[ ${errors} -gt 0 ]] && return 1
    return 0
}

# Initialize empty files
echo '' > "${FILE_SQL_SRIPTS}"
echo '' > "${FILE_SQL_INSTALL}"

# Get list of install files and store the result
getSqlFilesList "${INSTALL_ORDER_FILE}" > "${FILE_SQL_SRIPTS}" || {
    echo "Errors occurred while processing files" >&2
    exit 1
}

# Combine all install files into single install file
combineSqlFiles "${FILE_SQL_SRIPTS}" "${FILE_SQL_INSTALL}" || {
    echo "Errors occurred while combining SQL files" >&2
    exit 1
}
