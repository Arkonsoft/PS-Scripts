#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.6.0-alpha
if [ -n "$ZSH_VERSION" ]; then
    EXEC_SHELL="zsh"
    IFS='.' read -A EXEC_SHELL_VERSION <<< "$ZSH_VERSION"
elif [ -n "$KSH_VERSION" ]; then
    EXEC_SHELL="ksh"
    __exec_shell_version="${.sh.version##*/}"
    IFS='.' read -a EXEC_SHELL_VERSION <<< "${__exec_shell_version%% *}"
else
    EXEC_SHELL="bash"
    EXEC_SHELL_VERSION=("${BASH_VERSINFO[0]}" "${BASH_VERSINFO[1]}" "${BASH_VERSINFO[2]}")
fi
# replace(source: Text, search: Text, replace: Text)
replace__0_v0() {
    local source_223="${1}"
    local search_224="${2}"
    local replace_225="${3}"
    # Here we use a command to avoid #646
    local result_226=""
    left_comp=("${EXEC_SHELL_VERSION[@]}")
    right_comp=(4 3)
    local comp
    comp="$(
        # Compare if left array >= right array
        len_comp="$( (( "${#left_comp[@]}" < "${#right_comp[@]}" )) && echo "${#left_comp[@]}"|| echo "${#right_comp[@]}")"
        for (( i=0; i<len_comp; i++ )); do
            left="${left_comp[i]?"Index out of bounds (at unknown)"}"
            right="${right_comp[i]?"Index out of bounds (at unknown)"}"
            if (( "${left}" > "${right}" )); then
                echo 1
                exit
            elif (( "${left}" < "${right}" )); then
                echo 0
                exit
            fi
        done
        (( "${#left_comp[@]}" == "${#right_comp[@]}" || "${#left_comp[@]}" > "${#right_comp[@]}" )) && echo 1 || echo 0
)"
    if [ "$(( $([ "_${EXEC_SHELL}" != "_ksh" ]; echo $?) || $(( $([ "_${EXEC_SHELL}" != "_bash" ]; echo $?) && comp )) ))" != 0 ]; then
        result_226="${source_223//"${search_224}"/"${replace_225}"}"
        __status=$?
    else
        result_226="${source_223//"${search_224}"/${replace_225}}"
        __status=$?
    fi
    ret_replace0_v0="${result_226}"
    return 0
}

__SED_VERSION_UNKNOWN_0=0
__SED_VERSION_GNU_1=1
__SED_VERSION_BUSYBOX_2=2
# sed_version()
sed_version__2_v0() {
    # We can't match against a word "GNU" because
    # alpine's busybox sed returns "This is not GNU sed version"
    re='Copyright.+Free Software Foundation'; [[ $(sed --version 2>/dev/null) =~ $re ]]
    __status=$?
    if [ "$(( __status == 0 ))" != 0 ]; then
        ret_sed_version2_v0="${__SED_VERSION_GNU_1}"
        return 0
    fi
    # On BSD single `sed` waits for stdin. We must use `sed --help` to avoid this.
    re='BusyBox'; [[ $(sed --help 2>&1) =~ $re ]]
    __status=$?
    if [ "$(( __status == 0 ))" != 0 ]; then
        ret_sed_version2_v0="${__SED_VERSION_BUSYBOX_2}"
        return 0
    fi
    ret_sed_version2_v0="${__SED_VERSION_UNKNOWN_0}"
    return 0
}

# split(text: Text, delimiter: Text)
split__4_v0() {
    local text_308="${1}"
    local delimiter_309="${2}"
    local result_310=()
    # zsh uses -A for array, bash uses -a, ksh is VERY bad at splitting anything
    if [ "$([ "_${EXEC_SHELL}" != "_zsh" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_309}" read -rd '' -A result_310 < <(printf %s "$text_308")
        __status=$?
    elif [ "$([ "_${EXEC_SHELL}" != "_ksh" ]; echo $?)" != 0 ]; then
        if [ "$([ "_${delimiter_309}" != "_
" ]; echo $?)" != 0 ]; then
            while read -r -d $'\n'; do result_310+=("$REPLY"); done < <(echo "$text_308")
            __status=$?
        else
            IFS="${delimiter_309}" read -rd '' -a result_310 < <(printf %s "$text_308")
            __status=$?
        fi
    elif [ "$([ "_${EXEC_SHELL}" != "_bash" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_309}" read -rd '' -a result_310 < <(printf %s "$text_308")
        __status=$?
    fi
    ret_split4_v0=("${result_310[@]}")
    return 0
}

# split_lines(text: Text)
split_lines__5_v0() {
    local text_307="${1}"
    split__4_v0 "${text_307}" "
"
    ret_split_lines5_v0=("${ret_split4_v0[@]}")
    return 0
}

# trim(text: Text)
trim__10_v0() {
    local text_215="${1}"
    local result_216=""
    result_216="${text_215#${text_215%%[![:space:]]*}}"
    __status=$?
    result_216="${result_216%${result_216##*[![:space:]]}}"
    __status=$?
    ret_trim10_v0="${result_216}"
    return 0
}

# lowercase(text: Text)
lowercase__11_v0() {
    local text_245="${1}"
    left_comp=("${EXEC_SHELL_VERSION[@]}")
    right_comp=(4 3)
    local comp
    comp="$(
        # Compare if left array < right array
        len_comp="$( (( "${#left_comp[@]}" < "${#right_comp[@]}" )) && echo "${#left_comp[@]}"|| echo "${#right_comp[@]}")"
        for (( i=0; i<len_comp; i++ )); do
            left="${left_comp[i]?"Index out of bounds (at unknown)"}"
            right="${right_comp[i]?"Index out of bounds (at unknown)"}"
            if (( "${left}" < "${right}" )); then
                echo 1
                exit
            elif (( "${left}" > "${right}" )); then
                echo 0
                exit
            fi
        done
        (( "${#left_comp[@]}" < "${#right_comp[@]}" )) && echo 1 || echo 0
)"
    if [ "$(( $([ "_${EXEC_SHELL}" != "_bash" ]; echo $?) && comp ))" != 0 ]; then
        text_245="$(printf '%s' "${text_245}" | tr '[:upper:]' '[:lower:]')"
        __status=$?
    else
        typeset -l text_245
            text_245="${text_245}"
        __status=$?
    fi
    ret_lowercase11_v0="${text_245}"
    return 0
}

# match_regex(source: Text, search: Text, extended: Bool)
match_regex__19_v0() {
    local source_219="${1}"
    local search_220="${2}"
    local extended_221="${3}"
    sed_version__2_v0 
    local sed_version_222="${ret_sed_version2_v0}"
    replace__0_v0 "${search_220}" "/" "\\/"
    search_220="${ret_replace0_v0}"
    local output_227=""
    if [ "$(( $(( sed_version_222 == __SED_VERSION_GNU_1 )) || $(( sed_version_222 == __SED_VERSION_BUSYBOX_2 )) ))" != 0 ]; then
        # '\b' is supported but not in POSIX standards. Disable it
        replace__0_v0 "${search_220}" "\\b" "\\\\b"
        search_220="${ret_replace0_v0}"
    fi
    if [ "${extended_221}" != 0 ]; then
        # GNU sed versions 4.0 through 4.2 support extended regex syntax,
        # but only via the "-r" option
        if [ "$(( sed_version_222 == __SED_VERSION_GNU_1 ))" != 0 ]; then
            # '\b' is not in POSIX standards. Disable it
            replace__0_v0 "${search_220}" "\\b" "\\b"
            search_220="${ret_replace0_v0}"
            local command_3
            command_3="$(sed -r -ne "/${search_220}/p" <<<"${source_219}")"
            __status=$?
            output_227="${command_3}"
        else
            local command_4
            command_4="$(sed -E -ne "/${search_220}/p" <<<"${source_219}")"
            __status=$?
            output_227="${command_4}"
        fi
    else
        if [ "$(( $(( sed_version_222 == __SED_VERSION_GNU_1 )) || $(( sed_version_222 == __SED_VERSION_BUSYBOX_2 )) ))" != 0 ]; then
            # GNU Sed BRE handle \| as a metacharacter, but it is not POSIX standands. Disable it
            replace__0_v0 "${search_220}" "\\|" "|"
            search_220="${ret_replace0_v0}"
        fi
        local command_5
        command_5="$(sed -ne "/${search_220}/p" <<<"${source_219}")"
        __status=$?
        output_227="${command_5}"
    fi
    if [ "$([ "_${output_227}" == "_" ]; echo $?)" != 0 ]; then
        ret_match_regex19_v0=1
        return 0
    fi
    ret_match_regex19_v0=0
    return 0
}

# log_info(msg: Text)
log_info__39_v0() {
    local msg_243="${1}"
    printf "\033[1;36m[INFO]\033[0m %s
" "${msg_243}"
    __status=$?
}

# log_success(msg: Text)
log_success__40_v0() {
    local msg_275="${1}"
    printf "\033[1;32m[SUCCESS]\033[0m %s
" "${msg_275}"
    __status=$?
}

# log_warning(msg: Text)
log_warning__41_v0() {
    local msg_241="${1}"
    printf "\033[1;33m[WARNING]\033[0m %s
" "${msg_241}"
    __status=$?
}

# log_error(msg: Text)
log_error__42_v0() {
    local msg_240="${1}"
    printf "\033[1;31m[ERROR]\033[0m %s
" "${msg_240}" >&2
    __status=$?
}

# cwd()
cwd__48_v0() {
    local command_6
    command_6="$(pwd)"
    __status=$?
    trim__10_v0 "${command_6}"
    ret_cwd48_v0="${ret_trim10_v0}"
    return 0
}

# log_success(msg: Text)
log_success__51_v0() {
    local msg_318="${1}"
    printf "\033[1;32m[SUCCESS]\033[0m %s
" "${msg_318}"
    __status=$?
}

# log_warning(msg: Text)
log_warning__52_v0() {
    local msg_16="${1}"
    printf "\033[1;33m[WARNING]\033[0m %s
" "${msg_16}"
    __status=$?
}

# log_error(msg: Text)
log_error__53_v0() {
    local msg_15="${1}"
    printf "\033[1;31m[ERROR]\033[0m %s
" "${msg_15}" >&2
    __status=$?
}

# check_composer()
check_composer__56_v0() {
    command -v composer>/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        log_error__53_v0 "ERROR: Composer is not installed or not available in PATH"
        log_warning__52_v0 "Please install Composer before running this script: https://getcomposer.org/"
        exit 1
    fi
}

# replace_text_in_file(fp: Text, search_text: Text, replace_text_arg: Text)
replace_text_in_file__62_v0() {
    local fp_314="${1}"
    local search_text_315="${2}"
    local replace_text_arg_316="${3}"
    grep -q -F "${search_text_315}" "${fp_314}"
    __status=$?
    code_317="${__status}"
        if [ "$(( code_317 == 0 ))" != 0 ]; then
            sed -i "s/${search_text_315}/${replace_text_arg_316}/g" "${fp_314}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_replace_text_in_file62_v0=''
                return "${__status}"
            fi
            log_success__51_v0 "  Changes made to file"
        else
            echo "  No changes needed"
        fi
}

# replace_text_in_files(search_text: Text, replace_text_arg: Text)
replace_text_in_files__63_v0() {
    local search_text_304="${1}"
    local replace_text_arg_305="${2}"
    local command_7
    command_7="$(find . -type f -not -path "*/.*" -not -path "*/vendor/*")"
    __status=$?
    local raw_306="${command_7}"
    trim__10_v0 "${raw_306}"
    local ret_trim10_v0__18_34="${ret_trim10_v0}"
    split_lines__5_v0 "${ret_trim10_v0__18_34}"
    local ret_split_lines5_v0__18_22=("${ret_split_lines5_v0[@]}")
    for path_line_311 in "${ret_split_lines5_v0__18_22[@]}"; do
        trim__10_v0 "${path_line_311}"
        local fp_312="${ret_trim10_v0}"
        if [ "$([ "_${fp_312}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        test -s "${fp_312}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            continue
        fi
        local command_10
        command_10="$(basename "${fp_312}")"
        __status=$?
        local bn_313="${command_10}"
        trim__10_v0 "${bn_313}"
        local ret_trim10_v0__28_40="${ret_trim10_v0}"
        log_warning__52_v0 "Processing file: ${ret_trim10_v0__28_40}"
        replace_text_in_file__62_v0 "${fp_312}" "${search_text_304}" "${replace_text_arg_305}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_replace_text_in_files63_v0=''
            return "${__status}"
        fi
    done
}

# move_file(src: Text, dest: Text)
move_file__65_v0() {
    local src_358="${1}"
    local dest_359="${2}"
    mv -- "${src_358}" "${dest_359}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_move_file65_v0=''
        return "${__status}"
    fi
}

# remove_file_if_exists(path: Text)
remove_file_if_exists__66_v0() {
    local path_375="${1}"
    trim__10_v0 "${path_375}"
    local p_376="${ret_trim10_v0}"
    if [ "$([ "_${p_376}" == "_" ]; echo $?)" != 0 ]; then
        test -f "${p_376}"
        __status=$?
        code_377="${__status}"
            if [ "$(( code_377 == 0 ))" != 0 ]; then
                rm -f "${p_376}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_remove_file_if_exists66_v0=''
                    return "${__status}"
                fi
                log_success__51_v0 "Removed file: ${p_376}"
            else
                log_warning__52_v0 "File not found (skip): ${p_376}"
            fi
    fi
}

# remove_dir_if_exists(path: Text)
remove_dir_if_exists__67_v0() {
    local path_379="${1}"
    trim__10_v0 "${path_379}"
    local p_380="${ret_trim10_v0}"
    if [ "$([ "_${p_380}" == "_" ]; echo $?)" != 0 ]; then
        test -d "${p_380}"
        __status=$?
        code_381="${__status}"
            if [ "$(( code_381 == 0 ))" != 0 ]; then
                rm -rf "${p_380}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_remove_dir_if_exists67_v0=''
                    return "${__status}"
                fi
                log_success__51_v0 "Removed directory: ${p_380}"
            else
                log_warning__52_v0 "Directory not found (skip): ${p_380}"
            fi
    fi
}

# is_module_pascal_name(name: Text)
is_module_pascal_name__76_v0() {
    local name_218="${1}"
    trim__10_v0 "${name_218}"
    local ret_trim10_v0__9_24="${ret_trim10_v0}"
    match_regex__19_v0 "${ret_trim10_v0__9_24}" "^[A-Z][a-zA-Z0-9]*\$" 0
    ret_is_module_pascal_name76_v0="${ret_match_regex19_v0}"
    return 0
}

# prompt_pascal_module_with_caption(caption: Text)
prompt_pascal_module_with_caption__77_v0() {
    local caption_213="${1}"
    while :
    do
        printf "%s" "${caption_213}"
        __status=$?
        local line_214=""
        read -r line_214
        __status=$?
        trim__10_v0 "${line_214}"
        local n_217="${ret_trim10_v0}"
        if [ "$([ "_${n_217}" != "_" ]; echo $?)" != 0 ]; then
            log_warning__52_v0 "Module name cannot be empty"
            continue
        fi
        is_module_pascal_name__76_v0 "${n_217}"
        local ret_is_module_pascal_name76_v0__22_12="${ret_is_module_pascal_name76_v0}"
        if [ "${ret_is_module_pascal_name76_v0__22_12}" != 0 ]; then
            ret_prompt_pascal_module_with_caption77_v0="${n_217}"
            return 0
        fi
        log_warning__52_v0 "Invalid name: use PascalCase — uppercase first letter, then only letters and numbers"
    done
}

# prompt_module_name()
prompt_module_name__78_v0() {
    prompt_pascal_module_with_caption__77_v0 "Module name (PascalCase, e.g. MyModule): "
    ret_prompt_module_name78_v0="${ret_prompt_pascal_module_with_caption77_v0}"
    return 0
}

# resolve_module_name_for_create(args: [Text])
resolve_module_name_for_create__79_v0() {
    local args_212=("${!1}")
    local __length_11=("${args_212[@]}")
    if [ "$(( ${#__length_11[@]} < 2 ))" != 0 ]; then
        prompt_module_name__78_v0 
        ret_resolve_module_name_for_create79_v0="${ret_prompt_module_name78_v0}"
        return 0
    fi
    trim__10_v0 "${args_212[1]?"Index out of bounds (at src/./utils/module.ab:37:28)"}"
    local name_228="${ret_trim10_v0}"
    if [ "$([ "_${name_228}" != "_" ]; echo $?)" != 0 ]; then
        prompt_module_name__78_v0 
        ret_resolve_module_name_for_create79_v0="${ret_prompt_module_name78_v0}"
        return 0
    fi
    is_module_pascal_name__76_v0 "${name_228}"
    local ret_is_module_pascal_name76_v0__41_8="${ret_is_module_pascal_name76_v0}"
    if [ "${ret_is_module_pascal_name76_v0__41_8}" != 0 ]; then
        ret_resolve_module_name_for_create79_v0="${name_228}"
        return 0
    fi
    log_error__53_v0 "Invalid module name: use PascalCase (e.g. MyModule)"
    exit 1
}

__EXAMPLE_LOWER_3="arkonexample"
__EXAMPLE_PASCAL_4="ArkonExample"
__GITHUB_REPO_5="https://github.com/Arkonsoft/PS-Example-Module-8.git"
__GITHUB_BRANCH_6="ps8"
__REPO_MODULE_SUBPATH_7="prestashop/modules/arkonexample"
__TEMPLATE_FILES_TO_REMOVE_8=("README.md")
__TEMPLATE_DIRS_TO_REMOVE_9=(".github")
# show_module_configuration(module_lower: Text, module_pascal: Text)
show_module_configuration__82_v0() {
    local module_lower_250="${1}"
    local module_pascal_251="${2}"
    log_info__39_v0 "Module configuration:"
    log_warning__41_v0 "- Module name (lower): ${module_lower_250}"
    log_warning__41_v0 "- Module name (pascal): ${module_pascal_251}"
    cwd__48_v0 
    local ret_cwd48_v0__35_36="${ret_cwd48_v0}"
    log_warning__41_v0 "- Target folder: ${ret_cwd48_v0__35_36}"
}

# get_target_path(module_lower: Text)
get_target_path__83_v0() {
    local module_lower_255="${1}"
    cwd__48_v0 
    local ret_cwd48_v0__39_47="${ret_cwd48_v0}"
    local command_14
    command_14="$(basename "${ret_cwd48_v0__39_47}")"
    __status=$?
    local current_folder_256="${command_14}"
    trim__10_v0 "${current_folder_256}"
    local current_trim_257="${ret_trim10_v0}"
    if [ "$([ "_${current_trim_257}" != "_${module_lower_255}" ]; echo $?)" != 0 ]; then
        cwd__48_v0 
        ret_get_target_path83_v0="${ret_cwd48_v0}"
        return 0
    fi
    cwd__48_v0 
    local ret_cwd48_v0__44_14="${ret_cwd48_v0}"
    ret_get_target_path83_v0="${ret_cwd48_v0__44_14}/${module_lower_255}"
    return 0
}

# refuse_if_target_module_path_busy(target_path: Text)
refuse_if_target_module_path_busy__84_v0() {
    local target_path_261="${1}"
    trim__10_v0 "${target_path_261}"
    local ret_trim10_v0__48_8="${ret_trim10_v0}"
    cwd__48_v0 
    local ret_cwd48_v0__48_34="${ret_cwd48_v0}"
    trim__10_v0 "${ret_cwd48_v0__48_34}"
    local ret_trim10_v0__48_29="${ret_trim10_v0}"
    if [ "$([ "_${ret_trim10_v0__48_8}" == "_${ret_trim10_v0__48_29}" ]; echo $?)" != 0 ]; then
        test -e "${target_path_261}"
        __status=$?
        code_262="${__status}"
            if [ "$(( code_262 == 0 ))" != 0 ]; then
                log_error__42_v0 "Path already exists (choose another name or remove it): ${target_path_261}"
                exit 1
            fi
    fi
}

# initialize_module_repository(target_path: Text)
initialize_module_repository__85_v0() {
    local target_path_270="${1}"
    log_info__39_v0 "Cloning module from repository..."
    local command_15
    command_15="$(mktemp -d)"
    __status=$?
    trim__10_v0 "${command_15}"
    local tmp_root_271="${ret_trim10_v0}"
    local clone_dest_272="${tmp_root_271}/repo"
    git clone --branch "${__GITHUB_BRANCH_6}" --single-branch "${__GITHUB_REPO_5}" "${clone_dest_272}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        log_error__42_v0 "Error while cloning module"
        rm -rf "${tmp_root_271}">/dev/null 2>&1
        __status=$?
        exit 1
    fi
    local module_src_273="${clone_dest_272}/${__REPO_MODULE_SUBPATH_7}"
    test -d "${module_src_273}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        log_error__42_v0 "Module template path not found in repository: ${__REPO_MODULE_SUBPATH_7}"
        rm -rf "${tmp_root_271}">/dev/null 2>&1
        __status=$?
        exit 1
    fi
    cwd__48_v0 
    local workdir_274="${ret_cwd48_v0}"
    trim__10_v0 "${target_path_270}"
    local ret_trim10_v0__76_8="${ret_trim10_v0}"
    trim__10_v0 "${workdir_274}"
    local ret_trim10_v0__76_29="${ret_trim10_v0}"
    if [ "$([ "_${ret_trim10_v0__76_8}" != "_${ret_trim10_v0__76_29}" ]; echo $?)" != 0 ]; then
        cp -a "${module_src_273}/." "${target_path_270}/"
        __status=$?
        if [ "${__status}" != 0 ]; then
            log_error__42_v0 "Error copying module template"
            rm -rf "${tmp_root_271}">/dev/null 2>&1
            __status=$?
            exit 1
        fi
    else
        mv "${module_src_273}" "${target_path_270}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            log_error__42_v0 "Error moving module to target folder"
            rm -rf "${tmp_root_271}">/dev/null 2>&1
            __status=$?
            exit 1
        fi
    fi
    rm -rf "${tmp_root_271}">/dev/null 2>&1
    __status=$?
    cd "${target_path_270}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_initialize_module_repository85_v0=''
        return "${__status}"
    fi
    rm -rf .git>/dev/null 2>&1
    __status=$?
    log_success__40_v0 "Module cloned successfully"
}

# renamed_module_basename(fn: Text, module_lower: Text, module_pascal: Text, template_lower: Text, template_pascal: Text)
renamed_module_basename__86_v0() {
    local fn_351="${1}"
    local module_lower_352="${2}"
    local module_pascal_353="${3}"
    local template_lower_354="${4}"
    local template_pascal_355="${5}"
    local command_16
    command_16="$(printf "%s" "${fn_351}" | sed -e "s/${template_lower_354}/${module_lower_352}/g" -e "s/${template_pascal_355}/${module_pascal_353}/g")"
    __status=$?
    trim__10_v0 "${command_16}"
    ret_renamed_module_basename86_v0="${ret_trim10_v0}"
    return 0
}

# rename_module_files(module_lower: Text, module_pascal: Text)
rename_module_files__87_v0() {
    local module_lower_343="${1}"
    local module_pascal_344="${2}"
    log_info__39_v0 "Renaming files..."
    local command_17
    command_17="$(find . -type f -not -path "*/.*" -not -path "*/vendor/*")"
    __status=$?
    local raw_345="${command_17}"
    trim__10_v0 "${raw_345}"
    local ret_trim10_v0__110_34="${ret_trim10_v0}"
    split_lines__5_v0 "${ret_trim10_v0__110_34}"
    local ret_split_lines5_v0__110_22=("${ret_split_lines5_v0[@]}")
    for path_line_346 in "${ret_split_lines5_v0__110_22[@]}"; do
        trim__10_v0 "${path_line_346}"
        local fp_347="${ret_trim10_v0}"
        if [ "$([ "_${fp_347}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        local command_20
        command_20="$(basename "${fp_347}")"
        __status=$?
        local filename_348="${command_20}"
        local command_21
        command_21="$(dirname "${fp_347}")"
        __status=$?
        local directory_349="${command_21}"
        trim__10_v0 "${filename_348}"
        local fn_350="${ret_trim10_v0}"
        renamed_module_basename__86_v0 "${fn_350}" "${module_lower_343}" "${module_pascal_344}" "${__EXAMPLE_LOWER_3}" "${__EXAMPLE_PASCAL_4}"
        local newname_356="${ret_renamed_module_basename86_v0}"
        if [ "$([ "_${newname_356}" == "_${fn_350}" ]; echo $?)" != 0 ]; then
            log_warning__41_v0 "Renaming: ${fn_350} -> ${newname_356}"
            trim__10_v0 "${directory_349}"
            local ret_trim10_v0__122_33="${ret_trim10_v0}"
            local dest_path_357="${ret_trim10_v0__122_33}/${newname_356}"
            move_file__65_v0 "${fp_347}" "${dest_path_357}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_rename_module_files87_v0=''
                return "${__status}"
            fi
        fi
    done
}

# install_module_dependencies()
install_module_dependencies__88_v0() {
    log_info__39_v0 "Running composer install..."
    composer install
    __status=$?
    if [ "${__status}" != 0 ]; then
        log_error__42_v0 "Error running composer install"
        exit 1
    fi
    log_success__40_v0 "Composer install completed successfully"
}

# confirm_module_location()
confirm_module_location__89_v0() {
    cwd__48_v0 
    local ret_cwd48_v0__138_52="${ret_cwd48_v0}"
    local command_22
    command_22="$(basename "${ret_cwd48_v0__138_52}")"
    __status=$?
    trim__10_v0 "${command_22}"
    local current_folder_239="${ret_trim10_v0}"
    if [ "$([ "_${current_folder_239}" == "_modules" ]; echo $?)" != 0 ]; then
        log_error__42_v0 "You are not in a 'modules' folder"'!'""
        log_warning__41_v0 "Creating modules outside of a 'modules' directory is not recommended."
        printf "%s" "Do you want to continue anyway? (y/N) "
        __status=$?
        local confirmation_242=""
        read -r confirmation_242
        __status=$?
        if [ "$([ "_${confirmation_242}" != "_y" ]; echo $?)" != 0 ]; then
            true
            __status=$?
        elif [ "$([ "_${confirmation_242}" != "_Y" ]; echo $?)" != 0 ]; then
            true
            __status=$?
        else
            log_info__39_v0 "Operation cancelled by user"
            exit 0
        fi
    fi
}

# remove_template_artifacts()
remove_template_artifacts__90_v0() {
    log_info__39_v0 "Removing template files and directories..."
    for path_374 in "${__TEMPLATE_FILES_TO_REMOVE_8[@]}"; do
        trim__10_v0 "${path_374}"
        local ret_trim10_v0__165_31="${ret_trim10_v0}"
        remove_file_if_exists__66_v0 "${ret_trim10_v0__165_31}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_remove_template_artifacts90_v0=''
            return "${__status}"
        fi
    done
    for path_378 in "${__TEMPLATE_DIRS_TO_REMOVE_9[@]}"; do
        trim__10_v0 "${path_378}"
        local ret_trim10_v0__168_30="${ret_trim10_v0}"
        remove_dir_if_exists__67_v0 "${ret_trim10_v0__168_30}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_remove_template_artifacts90_v0=''
            return "${__status}"
        fi
    done
}

typeset -r args_10=("$0" "$@")
test -n "${args_10[0]?"Index out of bounds (at src/create.ab:173:35)"}">/dev/null 2>&1
__status=$?
check_composer__56_v0 
resolve_module_name_for_create__79_v0 args_10[@]
module_name_229="${ret_resolve_module_name_for_create79_v0}"
cwd__48_v0 
original_location_230="${ret_cwd48_v0}"
confirm_module_location__89_v0 
lowercase__11_v0 "${module_name_229}"
ret_lowercase11_v0__179_31="${ret_lowercase11_v0}"
trim__10_v0 "${ret_lowercase11_v0__179_31}"
module_lower_246="${ret_trim10_v0}"
trim__10_v0 "${module_name_229}"
module_pascal_247="${ret_trim10_v0}"
show_module_configuration__82_v0 "${module_lower_246}" "${module_pascal_247}"
get_target_path__83_v0 "${module_lower_246}"
target_path_258="${ret_get_target_path83_v0}"
refuse_if_target_module_path_busy__84_v0 "${target_path_258}"
initialize_module_repository__85_v0 "${target_path_258}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_warning__41_v0 "Replacing lowercase names..."
replace_text_in_files__63_v0 "${__EXAMPLE_LOWER_3}" "${module_lower_246}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_warning__41_v0 "Replacing PascalCase names..."
replace_text_in_files__63_v0 "${__EXAMPLE_PASCAL_4}" "${module_pascal_247}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
rename_module_files__87_v0 "${module_lower_246}" "${module_pascal_247}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
remove_template_artifacts__90_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
install_module_dependencies__88_v0 
cd "${original_location_230}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_info__39_v0 "Module configuration completed successfully"
log_warning__41_v0 "Module location: ${target_path_258}"
