# #!/usr/bin/env bash
# #-------------------------------------------------------------------------------------------------------------
# # Copyright (c) Microsoft Corporation. All rights reserved.
# # Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
# #-------------------------------------------------------------------------------------------------------------
# #
# # Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/java.md
# # Maintainer: The VS Code and Codespaces Teams
# #
# # Syntax: ./java-debian.sh [JDK version] [SDKMAN_DIR] [non-root user] [Add to rc files flag]

# JAVA_VERSION="${VERSION:-"latest"}"
# INSTALL_GRADLE="${INSTALLGRADLE:-"false"}"
# GRADLE_VERSION="${GRADLEVERSION:-"latest"}"
# INSTALL_MAVEN="${INSTALLMAVEN:-"false"}"
# MAVEN_VERSION="${MAVENVERSION:-"latest"}"
# INSTALL_ANT="${INSTALLANT:-"false"}"
# ANT_VERSION="${ANTVERSION:-"latest"}"
# INSTALL_GROOVY="${INSTALLGROOVY:-"false"}"
# GROOVY_VERSION="${GROOVYVERSION:-"latest"}"
# JDK_DISTRO="${JDKDISTRO:-"ms"}"

# export SDKMAN_DIR="${SDKMAN_DIR:-"/usr/local/sdkman"}"
# USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
# UPDATE_RC="${UPDATE_RC:-"true"}"

# # Comma-separated list of java versions to be installed
# # alongside JAVA_VERSION, but not set as default.
# ADDITIONAL_VERSIONS="${ADDITIONALVERSIONS:-""}"

# set -e

# if [ "$(id -u)" -ne 0 ]; then
#     echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
#     exit 1
# fi

# # Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
# . /etc/os-release
# # Get an adjusted ID independent of distro variants
# MAJOR_VERSION_ID=$(echo ${VERSION_ID} | cut -d . -f 1)
# if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
#     ADJUSTED_ID="debian"
# elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID}" = "mariner" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* || "${ID_LIKE}" = *"mariner"* ]]; then
#     ADJUSTED_ID="rhel"
#     if [[ "${ID}" = "rhel" ]] || [[ "${ID}" = *"alma"* ]] || [[ "${ID}" = *"rocky"* ]]; then
#         VERSION_CODENAME="rhel${MAJOR_VERSION_ID}"
#     else
#         VERSION_CODENAME="${ID}${MAJOR_VERSION_ID}"
#     fi
# else
#     echo "Linux distro ${ID} not supported."
#     exit 1
# fi

# # Setup INSTALL_CMD & PKG_MGR_CMD
# if type apt-get > /dev/null 2>&1; then
#     PKG_MGR_CMD=apt-get
#     INSTALL_CMD="${PKG_MGR_CMD} -y install --no-install-recommends"
# elif type microdnf > /dev/null 2>&1; then
#     PKG_MGR_CMD=microdnf
#     INSTALL_CMD="${PKG_MGR_CMD} -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0"
# elif type dnf > /dev/null 2>&1; then
#     PKG_MGR_CMD=dnf
#     INSTALL_CMD="${PKG_MGR_CMD} -y install"
# elif type yum > /dev/null 2>&1; then
#     PKG_MGR_CMD=yum
#     INSTALL_CMD="${PKG_MGR_CMD} -y install"
# else
#     echo "(Error) Unable to find a supported package manager."
#     exit 1
# fi

# pkg_manager_update() {
#     case $ADJUSTED_ID in
#         debian)
#             if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
#                 echo "Running apt-get update..."
#                 ${PKG_MGR_CMD} update -y
#             fi
#             ;;
#         rhel)
#             if [ ${PKG_MGR_CMD} = "microdnf" ]; then
#                 if [ "$(ls /var/cache/yum/* 2>/dev/null | wc -l)" = 0 ]; then
#                     echo "Running ${PKG_MGR_CMD} makecache ..."
#                     ${PKG_MGR_CMD} makecache
#                 fi
#             else
#                 if [ "$(ls /var/cache/${PKG_MGR_CMD}/* 2>/dev/null | wc -l)" = 0 ]; then
#                     echo "Running ${PKG_MGR_CMD} check-update ..."
#                     set +e
#                         stderr_messages=$(${PKG_MGR_CMD} -q check-update 2>&1)
#                         rc=$?
#                         # centos 7 sometimes returns a status of 100 when it apears to work.
#                         if [ $rc != 0 ] && [ $rc != 100 ]; then
#                             echo "(Error) ${PKG_MGR_CMD} check-update produced the following error message(s):"
#                             echo "${stderr_messages}"
#                             exit 1
#                         fi
#                     set -e
#                 fi
#             fi
#             ;;
#     esac
# }

# # Checks if packages are installed and installs them if not
# check_packages() {
#     case ${ADJUSTED_ID} in
#         debian)
#             if ! dpkg -s "$@" > /dev/null 2>&1; then
#                 pkg_manager_update
#                 ${INSTALL_CMD} "$@"
#             fi
#             ;;
#         rhel)
#             if ! rpm -q "$@" > /dev/null 2>&1; then
#                 pkg_manager_update
#                 ${INSTALL_CMD} "$@"
#             fi
#             ;;
#     esac
# }

# if [ "${ADJUSTED_ID}" = "rhel" ] && [ "${VERSION_CODENAME-}" = "centos7" ]; then
#     # As of 1 July 2024, mirrorlist.centos.org no longer exists.
#     # Update the repo files to reference vault.centos.org.
#     sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
#     sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
#     sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
#     yum update -y
#     check_packages epel-release
# fi

# # Clean up
# clean_up() {
#     local pkg
#     case ${ADJUSTED_ID} in
#         debian)
#             rm -rf /var/lib/apt/lists/*
#             ;;
#         rhel)
#             for pkg in epel-release epel-release-latest packages-microsoft-prod; do
#                 ${PKG_MGR_CMD} -y remove $pkg 2>/dev/null || /bin/true
#             done
#             rm -rf /var/cache/dnf/* /var/cache/yum/*
#             rm -f /etc/yum.repos.d/docker-ce.repo
#             ;;
#     esac
# }

# # Ensure that login shells get the correct path if the user updated the PATH using ENV.
# rm -f /etc/profile.d/00-restore-env.sh
# echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
# chmod +x /etc/profile.d/00-restore-env.sh

# # Determine the appropriate non-root user
# if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
#     USERNAME=""
#     POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
#     for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
#         if id -u ${CURRENT_USER} > /dev/null 2>&1; then
#             USERNAME=${CURRENT_USER}
#             break
#         fi
#     done
#     if [ "${USERNAME}" = "" ]; then
#         USERNAME=root
#     fi
# elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
#     USERNAME=root
# fi

# updaterc() {
#     local _bashrc
#     local _zshrc
#     if [ "${UPDATE_RC}" = "true" ]; then
#         case $ADJUSTED_ID in
#             debian)
#                 _bashrc=/etc/bash.bashrc
#                 _zshrc=/etc/zsh/zshrc
#                 ;;
#             rhel)
#                 _bashrc=/etc/bashrc
#                 _zshrc=/etc/zshrc
#             ;;
#         esac
#         echo "Updating ${_bashrc} and ${_zshrc}..."
#         if [[ "$(cat ${_bashrc})" != *"$1"* ]]; then
#             echo -e "$1" >> "${_bashrc}"
#         fi
#         if [ -f "${_zshrc}" ] && [[ "$(cat ${_zshrc})" != *"$1"* ]]; then
#             echo -e "$1" >> "${_zshrc}"
#         fi
#     fi
# }

# find_version_list() {
#     prefix="$1"
#     suffix="$2"
#     install_type=$3
#     ifLts="$4"
#     version_list=$5
#     java_ver=$6
    
#     check_packages jq
#     all_versions=$(curl -s https://api.adoptium.net/v3/info/available_releases)
#     if [ "${ifLts}" = "true" ]; then 
#         major_version=$(echo "$all_versions" | jq -r '.most_recent_lts')
#     elif [ "${java_ver}" = "latest" ]; then
#         major_version=$(echo "$all_versions" | jq -r '.most_recent_feature_release') 
#     else
#         major_version=$(echo "$java_ver" | cut -d '.' -f 1)
#     fi
    
#     # Remove the hardcoded fallback as this fails for new jdk latest version released ex: 24
#     # Related Issue: https://github.com/devcontainers/features/issues/1308
#     if [ "${JDK_DISTRO}" = "ms" ]; then
#         # Check if the requested version is available in the 'ms' distribution
#         echo "Check if OpenJDK is available for version ${major_version} for ${JDK_DISTRO} Distro"
#         available_versions=$(su ${USERNAME} -c ". ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk list ${install_type} | grep ${JDK_DISTRO} | grep -oE '[0-9]+(\.[0-9]+(\.[0-9]+)?)?' | sort -u")
#         if echo "${available_versions}" | grep -q "^${major_version}"; then
#             echo "JDK version ${major_version} is available in ${JDK_DISTRO}..."
#         else
#             echo "JDK version ${major_version} not available in  ${JDK_DISTRO}.... Switching to (tem)."
#             JDK_DISTRO="tem"
#         fi
#     fi
#     echo "JDK_DISTRO: ${JDK_DISTRO}"
#     if [ "${install_type}" != "java" ]; then
#         regex="${prefix}\\K[0-9]+\\.?[0-9]*\\.?[0-9]*${suffix}"
#     else
#         regex="${prefix}\\K${major_version}\\.?[0-9]*\\.?[0-9]*${suffix}${JDK_DISTRO}\\s*"
#     fi
#     declare -g ${version_list}="$(su ${USERNAME} -c ". \${SDKMAN_DIR}/bin/sdkman-init.sh && sdk list ${install_type} 2>&1 | grep -oP \"${regex}\" | tr -d ' ' | sort -rV")"
# }

# # Use SDKMAN to install something using a partial version match
# sdk_install() {
#     local install_type=$1
#     local requested_version=$2
#     local prefix=$3
#     local suffix="${4:-"\\s*"}"
#     local full_version_check=${5:-".*-[a-z]+"}
#     local set_as_default=${6:-"true"}
#     pkgs=("maven" "gradle" "ant" "groovy")
#     pkg_vals="${pkgs[@]}"
#     if [ "${requested_version}" = "none" ]; then return; fi
#     if [ "${requested_version}" = "default" ]; then
#         requested_version=""
#     elif [[ "${pkg_vals}" =~ "${install_type}" ]] && [ "${requested_version}" = "latest" ]; then
#         requested_version=""
#     elif [ "${requested_version}" = "lts" ]; then
#             find_version_list "$prefix" "$suffix" "$install_type" "true" version_list "${requested_version}"
#             requested_version="$(echo "${version_list}" | head -n 1)"
#     elif echo "${requested_version}" | grep -oE "${full_version_check}" > /dev/null 2>&1; then
#         echo "${requested_version}"
#     else 
#         find_version_list "$prefix" "$suffix" "$install_type" "false" version_list "${requested_version}"
#         if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ]; then
#             requested_version="$(echo "${version_list}" | head -n 1)"
#         else
#             set +e
#             requested_version="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|-|$)")"
#             set -e
#         fi
#         if [ -z "${requested_version}" ] || ! echo "${version_list}" | grep "^${requested_version//./\\.}$" > /dev/null 2>&1; then
#             echo -e "Version $2 not found. Available versions:\n${version_list}" >&2
#             exit 1
#         fi
#     fi
#     if [ "${set_as_default}" = "true" ]; then
#         JAVA_VERSION=${requested_version}
#     fi

#     su ${USERNAME} -c "umask 0002 && . ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install ${install_type} ${requested_version} && sdk flush archives && sdk flush temp"
# }

# export DEBIAN_FRONTEND=noninteractive

# architecture="$(uname -m)"
# if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "x86_64" ] && [ "${architecture}" != "arm64" ] && [ "${architecture}" != "aarch64" ]; then
#     echo "(!) Architecture $architecture unsupported"
#     exit 1
# fi

# # Install dependencies,
# check_packages ca-certificates zip unzip sed findutils util-linux tar
# # Make sure passwd (Debian) and shadow-utils RHEL family is installed
# if [ ${ADJUSTED_ID} = "debian" ]; then
#     check_packages passwd
# elif [ ${ADJUSTED_ID} = "rhel" ]; then
#     check_packages shadow-utils
# fi
# # minimal RHEL installs may not include curl, or includes curl-minimal instead.
# # Install curl if the "curl" command is not present.
# if ! type curl > /dev/null 2>&1; then
#     check_packages curl
# fi

# # Install sdkman if not installed
# if [ ! -d "${SDKMAN_DIR}" ]; then
#     # Create sdkman group, dir, and set sticky bit
#     if ! cat /etc/group | grep -e "^sdkman:" > /dev/null 2>&1; then
#         groupadd -r sdkman
#     fi
#     usermod -a -G sdkman ${USERNAME}
#     umask 0002
#     # Install SDKMAN
#     curl -sSL "https://get.sdkman.io?rcupdate=false" | bash
#     chown -R "${USERNAME}:sdkman" ${SDKMAN_DIR}
#     find ${SDKMAN_DIR} -type d -print0 | xargs -d '\n' -0 chmod g+s
#     # Add sourcing of sdkman into bashrc/zshrc files (unless disabled)
#     updaterc "export SDKMAN_DIR=${SDKMAN_DIR}\n. \${SDKMAN_DIR}/bin/sdkman-init.sh"
# fi

# sdk_install java ${JAVA_VERSION} "\\s*" "(\\.[a-z0-9]+)*-" ".*-[a-z]+$" "true"

# # Additional java versions to be installed but not be set as default.
# if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
#     OLDIFS=$IFS
#     IFS=","
#         read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
#         for version in "${additional_versions[@]}"; do
#             sdk_install java ${version} "\\s*" "(\\.[a-z0-9]+)*-" ".*-[a-z]+$" "false"
#         done
#     IFS=$OLDIFS
#     su ${USERNAME} -c ". ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk default java ${JAVA_VERSION}"
# fi

# # Install Ant
# if [[ "${INSTALL_ANT}" = "true" ]] && ! ant -version > /dev/null 2>&1; then
#     sdk_install ant ${ANT_VERSION}
# fi

# # Install Gradle
# if [[ "${INSTALL_GRADLE}" = "true" ]] && ! gradle --version > /dev/null 2>&1; then
#     sdk_install gradle ${GRADLE_VERSION}
# fi

# # Install Maven
# if [[ "${INSTALL_MAVEN}" = "true" ]] && ! mvn --version > /dev/null 2>&1; then
#     sdk_install maven ${MAVEN_VERSION}
# fi

# # Install Groovy
# if [[ "${INSTALL_GROOVY}" = "true" ]] && ! groovy --version > /dev/null 2>&1; then
#     sdk_install groovy "${GROOVY_VERSION}"
# fi

# # Clean up
# clean_up

# echo "Done!"

# ###POWERSHELL
# #!/usr/bin/env bash
# #-------------------------------------------------------------------------------------------------------------
# # Copyright (c) Microsoft Corporation. All rights reserved.
# # Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
# #-------------------------------------------------------------------------------------------------------------
# #
# # Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/powershell.md
# # Maintainer: The VS Code and Codespaces Teams

# set -e

# # Clean up
# rm -rf /var/lib/apt/lists/*

# POWERSHELL_VERSION=${VERSION:-"latest"}
# POWERSHELL_MODULES="${MODULES:-""}"
# POWERSHELL_PROFILE_URL="${POWERSHELLPROFILEURL}"

# MICROSOFT_GPG_KEYS_URI="https://packages.microsoft.com/keys/microsoft.asc"
# #MICROSOFT_GPG_KEYS_URI=$(curl https://packages.microsoft.com/keys/microsoft.asc -o /usr/share/keyrings/microsoft-archive-keyring.gpg)
# POWERSHELL_ARCHIVE_ARCHITECTURES_UBUNTU="amd64"
# POWERSHELL_ARCHIVE_ARCHITECTURES_ALMALINUX="x86_64"
# POWERSHELL_ARCHIVE_VERSION_CODENAMES="stretch buster bionic focal bullseye jammy bookworm noble"

# #These key servers are used to verify the authenticity of packages and repositories.
# #keyservers for ubuntu and almalinux are different so we need to specify both
# GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com
# keyserver hkp://keyserver.ubuntu.com:80
# keyserver hkps://keys.openpgp.org
# keyserver hkp://keyserver.pgp.com
# keyserver hkp://keyserver.fedoraproject.org
# keyserver hkps://keys.openpgp.org
# keyserver hkp://pgp.mit.edu
# keyserver hkp://keyserver.redhat.com"


# if [ "$(id -u)" -ne 0 ]; then
#     echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
#     exit 1
# fi

# # Clean up package manager cache
# clean_cache() {
#     if [ -d "/var/cache/apt" ]; then
#         apt-get clean
#     fi
#     if [ -d "/var/cache/dnf" ]; then
#         rm -rf /var/cache/dnf/*
#     fi
# }
# # Install dependencies for RHEL/CentOS/AlmaLinux (DNF-based systems)
# install_using_dnf() {
#    dnf remove -y curl-minimal
#    dnf install -y curl gnupg2 ca-certificates dnf-plugins-core
#    dnf clean all
#    dnf makecache
#    curl --version
# }

# # Install PowerShell on RHEL/CentOS/AlmaLinux-based systems (DNF)
# install_powershell_dnf() {
#     # Install wget, if not already installed
#     dnf install -y wget

#     # Download Microsoft GPG key
#     curl https://packages.microsoft.com/keys/microsoft.asc -o /usr/share/keyrings/microsoft-archive-keyring.gpg
#     ls -l /usr/share/keyrings/microsoft-archive-keyring.gpg

#     # Install necessary dependencies
#     dnf install -y krb5-libs libicu openssl-libs zlib

#     # Add Microsoft PowerShell repository 
#         curl "https://packages.microsoft.com/config/rhel/9.0/prod.repo" > /etc/yum.repos.d/microsoft.repo
    
#     # Install PowerShell
#      dnf install --assumeyes powershell
# }


# # Detect the package manager and OS
# detect_package_manager() {
#     if [ -f /etc/os-release ]; then
#         . /etc/os-release
#         if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
#             echo "Detected Debian/Ubuntu-based system"
#             install_using_apt
#             install_pwsh
#         elif [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "almalinux" ]]; then
#             echo "Detected RHEL/CentOS/AlmaLinux-based system"
#             install_using_dnf
#             install_powershell_dnf
#             install_pwsh
#         else
#             echo "Unsupported Linux distribution: $ID"
#             exit 1
#         fi
#     else
#         echo "Could not detect OS"
#         exit 1
#     fi
# }

# # Figure out correct version of a three part version number is not passed
# find_version_from_git_tags() {
#     local variable_name=$1
#     local requested_version=${!variable_name}
#     if [ "${requested_version}" = "none" ]; then return; fi
#     local repository=$2
#     local prefix=${3:-"tags/v"}
#     local separator=${4:-"."}
#     local last_part_optional=${5:-"false"}    
#     if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
#         local escaped_separator=${separator//./\\.}
#         local last_part
#         if [ "${last_part_optional}" = "true" ]; then
#             last_part="(${escaped_separator}[0-9]+)?"
#         else
#             last_part="${escaped_separator}[0-9]+"
#         fi
#         local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
#         local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
#         if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
#             declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
#         else
#             set +e
#             declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
#             set -e
#         fi
#     fi
#     if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
#         echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
#         exit 1
#     fi
#     echo "${variable_name}=${!variable_name}"
# }

# apt_get_update()
# {
#     if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
#         echo "Running apt-get update..."
#         apt-get update -y
#     fi
# }

# # Checks if packages are installed and installs them if not
#    check_packages() {
#     if command -v dpkg > /dev/null 2>&1; then
#         # If dpkg exists, assume APT-based system (Debian/Ubuntu)
#         for package in "$@"; do
#             if ! dpkg -s "$package" > /dev/null 2>&1; then
#                 echo "Package $package not installed. Installing using apt-get..."
#                 apt-get update
#                 apt-get install -y --no-install-recommends "$package"
#             else
#                 echo "Package $package is already installed (APT)."
#             fi
#         done
#         elif command -v dnf > /dev/null 2>&1; then
#     for package in "$@"; do
#         if ! dnf list installed "$package" > /dev/null 2>&1; then
#             echo "Package $package not installed. Installing using dnf..."
#             dnf install -y "$package"
#         else
#             echo "Package $package is already installed (DNF)."
#         fi
#     done
# else
#     echo "Unsupported package manager. Neither APT nor DNF found."
#     return 1
# fi

   
# }

# install_using_apt() {
#     # Install dependencies
#     check_packages apt-transport-https curl ca-certificates gnupg2 dirmngr
#     # Import key safely (new 'signed-by' method rather than deprecated apt-key approach) and install
   
#     curl -sSL ${MICROSOFT_GPG_KEYS_URI} | gpg --dearmor > /usr/share/keyrings/microsoft-archive-keyring.gpg
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/microsoft-${ID}-${VERSION_CODENAME}-prod ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/microsoft.list
    

#     # Update lists
#     apt-get update -yq

#     # Soft version matching for CLI
#     if [ "${POWERSHELL_VERSION}" = "latest" ] || [ "${POWERSHELL_VERSION}" = "lts" ] || [ "${POWERSHELL_VERSION}" = "stable" ]; then
#         # Empty, meaning grab whatever "latest" is in apt repo
#         version_suffix=""
#     else    
#         version_suffix="=$(apt-cache madison powershell | awk -F"|" '{print $2}' | sed -e 's/^[ \t]*//' | grep -E -m 1 "^(${POWERSHELL_VERSION})(\.|$|\+.*|-.*)")"

#         if [ -z ${version_suffix} ] || [ ${version_suffix} = "=" ]; then
#             echo "Provided POWERSHELL_VERSION (${POWERSHELL_VERSION}) was not found in the apt-cache for this package+distribution combo";
#             return 1
#         fi
#         echo "version_suffix ${version_suffix}"
#     fi

#     apt-get install -yq powershell${version_suffix} || return 1
# }

# # Use semver logic to decrement a version number then look for the closest match
# find_prev_version_from_git_tags() {
#     local variable_name=$1
#     local current_version=${!variable_name}
#     local repository=$2
#     # Normally a "v" is used before the version number, but support alternate cases
#     local prefix=${3:-"tags/v"}
#     # Some repositories use "_" instead of "." for version number part separation, support that
#     local separator=${4:-"."}
#     # Some tools release versions that omit the last digit (e.g. go)
#     local last_part_optional=${5:-"false"}
#     # Some repositories may have tags that include a suffix (e.g. actions/node-versions)
#     local version_suffix_regex=$6
#     # Try one break fix version number less if we get a failure. Use "set +e" since "set -e" can cause failures in valid scenarios.
#     set +e
#         major="$(echo "${current_version}" | grep -oE '^[0-9]+' || echo '')"
#         minor="$(echo "${current_version}" | grep -oP '^[0-9]+\.\K[0-9]+' || echo '')"
#         breakfix="$(echo "${current_version}" | grep -oP '^[0-9]+\.[0-9]+\.\K[0-9]+' 2>/dev/null || echo '')"

#         if [ "${minor}" = "0" ] && [ "${breakfix}" = "0" ]; then
#             ((major=major-1))
#             declare -g ${variable_name}="${major}"
#             # Look for latest version from previous major release
#             find_version_from_git_tags "${variable_name}" "${repository}" "${prefix}" "${separator}" "${last_part_optional}"
#         # Handle situations like Go's odd version pattern where "0" releases omit the last part
#         elif [ "${breakfix}" = "" ] || [ "${breakfix}" = "0" ]; then
#             ((minor=minor-1))
#             declare -g ${variable_name}="${major}.${minor}"
#             # Look for latest version from previous minor release
#             find_version_from_git_tags "${variable_name}" "${repository}" "${prefix}" "${separator}" "${last_part_optional}"
#         else
#             ((breakfix=breakfix-1))
#             if [ "${breakfix}" = "0" ] && [ "${last_part_optional}" = "true" ]; then
#                 declare -g ${variable_name}="${major}.${minor}"
#             else 
#                 declare -g ${variable_name}="${major}.${minor}.${breakfix}"
#             fi
#         fi
#     set -e
# }

# # Function to fetch the version released prior to the latest version
# get_previous_version() {
#     local url=$1
#     local repo_url=$2
#     local variable_name=$3
#     prev_version=${!variable_name}
    
#     output=$(curl -s "$repo_url");
#     check_packages jq
#     message=$(echo "$output" | jq -r '.message')
    
#     if [[ $message == "API rate limit exceeded"* ]]; then
#         echo -e "\nAn attempt to find latest version using GitHub Api Failed... \nReason: ${message}"
#         echo -e "\nAttempting to find latest version using GitHub tags."
#         find_prev_version_from_git_tags prev_version "$url" "tags/v"
#         declare -g ${variable_name}="${prev_version}"
#     else 
#         echo -e "\nAttempting to find latest version using GitHub Api."
#         version=$(echo "$output" | jq -r '.tag_name')
#         declare -g ${variable_name}="${version#v}"
#     fi  
#     echo "${variable_name}=${!variable_name}"
# }

# get_github_api_repo_url() {
#     local url=$1
#     echo "${url/https:\/\/github.com/https:\/\/api.github.com\/repos}/releases/latest"
# }


# install_prev_pwsh() {
#     pwsh_url=$1
#     repo_url=$(get_github_api_repo_url $pwsh_url)
#     echo -e "\n(!) Failed to fetch the latest artifacts for powershell v${POWERSHELL_VERSION}..."
#     get_previous_version $pwsh_url $repo_url POWERSHELL_VERSION
#     echo -e "\nAttempting to install v${POWERSHELL_VERSION}"
#     install_pwsh "${POWERSHELL_VERSION}"
# }

# install_pwsh() {
#     POWERSHELL_VERSION=$1
#     powershell_filename="powershell-${POWERSHELL_VERSION}-linux-${architecture}.tar.gz"
#     powershell_target_path="/opt/microsoft/powershell/$(echo ${POWERSHELL_VERSION} | grep -oE '[^\.]+' | head -n 1)"
#     mkdir -p /tmp/pwsh "${powershell_target_path}"
#     cd /tmp/pwsh
#     curl -sSL -o "${powershell_filename}" "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/${powershell_filename}"
# }

# install_using_github() {
#     # Fall back on direct download if no apt package exists in microsoft pool
#     check_packages curl ca-certificates gnupg2 dirmngr libc6 libgcc1 libgssapi-krb5-2 libstdc++6 libunwind8 libuuid1 zlib1g libicu[0-9][0-9]
#     if ! type git > /dev/null 2>&1; then
#         check_packages git
#     fi

#      if [ "${architecture}" = "amd64" ]; then
#         architecture="x64"
#     fi
#     pwsh_url="https://github.com/PowerShell/PowerShell"
#     find_version_from_git_tags POWERSHELL_VERSION $pwsh_url
#     install_pwsh "${POWERSHELL_VERSION}"
#     if grep -q "Not Found" "${powershell_filename}"; then 
#         install_prev_pwsh $pwsh_url
#     fi
    
#     # downlaod the latest version of powershell and extracting the file to powershell directory
#     wget https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/${powershell_filename}
#     mkdir ~/powershell
#     tar -xvf powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz -C ~/powershell


#     powershell_archive_sha256="$(cat release.html | tr '\n' ' ' | sed 's|<[^>]*>||g' | grep -oP "${powershell_filename}\s+\K[0-9a-fA-F]{64}" || echo '')"
#     if [ -z "${powershell_archive_sha256}" ]; then
#         echo "(!) WARNING: Failed to retrieve SHA256 for archive. Skipping validaiton."
#     else
#         echo "SHA256: ${powershell_archive_sha256}"
#         echo "${powershell_archive_sha256} *${powershell_filename}" | sha256sum -c -
#     fi
#     tar xf "${powershell_filename}" -C "${powershell_target_path}"
#     chmod 755 "${powershell_target_path}/pwsh"
#     ln -sf "${powershell_target_path}/pwsh" /usr/bin/pwsh
#     add-shell "/usr/bin/pwsh"
#     cd /tmp
#     rm -rf /tmp/pwsh
# }

# if ! type pwsh >/dev/null 2>&1; then
#     export DEBIAN_FRONTEND=noninteractive
    
#     # Source /etc/os-release to get OS info
#     . /etc/os-release
#     architecture="$(uname -m)"
#     if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
#         POWERSHELL_ARCHIVE_ARCHITECTURES="${POWERSHELL_ARCHIVE_ARCHITECTURES_UBUNTU}"
#     elif [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "almalinux" ]]; then
#         POWERSHELL_ARCHIVE_ARCHITECTURES="${POWERSHELL_ARCHIVE_ARCHITECTURES_ALMALINUX}"
#     fi

#     if [[ "${POWERSHELL_ARCHIVE_ARCHITECTURES}" = *"${POWERSHELL_ARCHIVE_ARCHITECTURES_UBUNTU}"* ]] && [[  "${POWERSHELL_ARCHIVE_VERSION_CODENAMES}" = *"${VERSION_CODENAME}"* ]]; then
#         install_using_apt || use_github="true"
#     elif [[ "${POWERSHELL_ARCHIVE_ARCHITECTURES}" = *"${POWERSHELL_ARCHIVE_ARCHITECTURES_ALMALINUX}"* ]]; then 
#         install_using_dnf && install_powershell_dnf || use_github="true"
    
#     else 
#        use_github="true"
#     fi

#     if [ "${use_github}" = "true" ]; then
#         echo "Attempting install from GitHub release..."
#         install_using_github
#     fi
# else
#     echo "PowerShell is already installed."
# fi

# # If PowerShell modules are requested, loop through and install
# if [ ${#POWERSHELL_MODULES[@]} -gt 0 ]; then
#     echo "Installing PowerShell Modules: ${POWERSHELL_MODULES}"
#     modules=(`echo ${POWERSHELL_MODULES} | tr ',' ' '`)
#     for i in "${modules[@]}"
#     do
#         module_parts=(`echo ${i} | tr '==' ' '`)
#         module_name="${module_parts[0]}"  
#         args="-Name ${module_name} -AllowClobber -Force -Scope AllUsers"  
#         if [ "${#module_parts[@]}" -eq 2 ]; then
#             module_version="${module_parts[1]}"
#             echo "Installing ${module_name} v${module_version}"
#             args+=" -RequiredVersion ${module_version}"
#         else
#             echo "Installing latest version for ${i} module"
#         fi

#         pwsh -Command "Install-Module $args" || continue
#     done
# fi


# # If URL for powershell profile is provided, download it to '/opt/microsoft/powershell/7/profile.ps1'
# if [ -n "$POWERSHELL_PROFILE_URL" ]; then
#     echo "Downloading PowerShell Profile from: $POWERSHELL_PROFILE_URL"
#     # Get profile path from currently installed pwsh
#     profilePath=$(pwsh -noni -c '$PROFILE.AllUsersAllHosts')
#     sudo -E curl -sSL -o "$profilePath" "$POWERSHELL_PROFILE_URL"
# fi

# # Clean up
# rm -rf /var/lib/apt/lists/*

# echo "Done!"