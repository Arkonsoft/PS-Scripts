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
    local source_222="${1}"
    local search_223="${2}"
    local replace_224="${3}"
    # Here we use a command to avoid #646
    local result_225=""
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
        result_225="${source_222//"${search_223}"/"${replace_224}"}"
        __status=$?
    else
        result_225="${source_222//"${search_223}"/${replace_224}}"
        __status=$?
    fi
    ret_replace0_v0="${result_225}"
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
    local text_319="${1}"
    local delimiter_320="${2}"
    local result_321=()
    # zsh uses -A for array, bash uses -a, ksh is VERY bad at splitting anything
    if [ "$([ "_${EXEC_SHELL}" != "_zsh" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_320}" read -rd '' -A result_321 < <(printf %s "$text_319")
        __status=$?
    elif [ "$([ "_${EXEC_SHELL}" != "_ksh" ]; echo $?)" != 0 ]; then
        if [ "$([ "_${delimiter_320}" != "_
" ]; echo $?)" != 0 ]; then
            while read -r -d $'\n'; do result_321+=("$REPLY"); done < <(echo "$text_319")
            __status=$?
        else
            IFS="${delimiter_320}" read -rd '' -a result_321 < <(printf %s "$text_319")
            __status=$?
        fi
    elif [ "$([ "_${EXEC_SHELL}" != "_bash" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_320}" read -rd '' -a result_321 < <(printf %s "$text_319")
        __status=$?
    fi
    ret_split4_v0=("${result_321[@]}")
    return 0
}

# split_lines(text: Text)
split_lines__5_v0() {
    local text_318="${1}"
    split__4_v0 "${text_318}" "
"
    ret_split_lines5_v0=("${ret_split4_v0[@]}")
    return 0
}

# trim(text: Text)
trim__10_v0() {
    local text_214="${1}"
    local result_215=""
    result_215="${text_214#${text_214%%[![:space:]]*}}"
    __status=$?
    result_215="${result_215%${result_215##*[![:space:]]}}"
    __status=$?
    ret_trim10_v0="${result_215}"
    return 0
}

# lowercase(text: Text)
lowercase__11_v0() {
    local text_244="${1}"
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
        text_244="$(printf '%s' "${text_244}" | tr '[:upper:]' '[:lower:]')"
        __status=$?
    else
        typeset -l text_244
            text_244="${text_244}"
        __status=$?
    fi
    ret_lowercase11_v0="${text_244}"
    return 0
}

# match_regex(source: Text, search: Text, extended: Bool)
match_regex__19_v0() {
    local source_218="${1}"
    local search_219="${2}"
    local extended_220="${3}"
    sed_version__2_v0 
    local sed_version_221="${ret_sed_version2_v0}"
    replace__0_v0 "${search_219}" "/" "\\/"
    search_219="${ret_replace0_v0}"
    local output_226=""
    if [ "$(( $(( sed_version_221 == __SED_VERSION_GNU_1 )) || $(( sed_version_221 == __SED_VERSION_BUSYBOX_2 )) ))" != 0 ]; then
        # '\b' is supported but not in POSIX standards. Disable it
        replace__0_v0 "${search_219}" "\\b" "\\\\b"
        search_219="${ret_replace0_v0}"
    fi
    if [ "${extended_220}" != 0 ]; then
        # GNU sed versions 4.0 through 4.2 support extended regex syntax,
        # but only via the "-r" option
        if [ "$(( sed_version_221 == __SED_VERSION_GNU_1 ))" != 0 ]; then
            # '\b' is not in POSIX standards. Disable it
            replace__0_v0 "${search_219}" "\\b" "\\b"
            search_219="${ret_replace0_v0}"
            local command_3
            command_3="$(sed -r -ne "/${search_219}/p" <<<"${source_218}")"
            __status=$?
            output_226="${command_3}"
        else
            local command_4
            command_4="$(sed -E -ne "/${search_219}/p" <<<"${source_218}")"
            __status=$?
            output_226="${command_4}"
        fi
    else
        if [ "$(( $(( sed_version_221 == __SED_VERSION_GNU_1 )) || $(( sed_version_221 == __SED_VERSION_BUSYBOX_2 )) ))" != 0 ]; then
            # GNU Sed BRE handle \| as a metacharacter, but it is not POSIX standands. Disable it
            replace__0_v0 "${search_219}" "\\|" "|"
            search_219="${ret_replace0_v0}"
        fi
        local command_5
        command_5="$(sed -ne "/${search_219}/p" <<<"${source_218}")"
        __status=$?
        output_226="${command_5}"
    fi
    if [ "$([ "_${output_226}" == "_" ]; echo $?)" != 0 ]; then
        ret_match_regex19_v0=1
        return 0
    fi
    ret_match_regex19_v0=0
    return 0
}

# log_info(msg: Text)
log_info__39_v0() {
    local msg_242="${1}"
    printf "\033[1;36m[INFO]\033[0m %s
" "${msg_242}"
    __status=$?
}

# log_success(msg: Text)
log_success__40_v0() {
    local msg_286="${1}"
    printf "\033[1;32m[SUCCESS]\033[0m %s
" "${msg_286}"
    __status=$?
}

# log_warning(msg: Text)
log_warning__41_v0() {
    local msg_240="${1}"
    printf "\033[1;33m[WARNING]\033[0m %s
" "${msg_240}"
    __status=$?
}

# log_error(msg: Text)
log_error__42_v0() {
    local msg_239="${1}"
    printf "\033[1;31m[ERROR]\033[0m %s
" "${msg_239}" >&2
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
    local msg_329="${1}"
    printf "\033[1;32m[SUCCESS]\033[0m %s
" "${msg_329}"
    __status=$?
}

# log_warning(msg: Text)
log_warning__52_v0() {
    local msg_15="${1}"
    printf "\033[1;33m[WARNING]\033[0m %s
" "${msg_15}"
    __status=$?
}

# log_error(msg: Text)
log_error__53_v0() {
    local msg_14="${1}"
    printf "\033[1;31m[ERROR]\033[0m %s
" "${msg_14}" >&2
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
    local fp_325="${1}"
    local search_text_326="${2}"
    local replace_text_arg_327="${3}"
    grep -q -F "${search_text_326}" "${fp_325}"
    __status=$?
    code_328="${__status}"
        if [ "$(( code_328 == 0 ))" != 0 ]; then
            sed -i "s/${search_text_326}/${replace_text_arg_327}/g" "${fp_325}"
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
    local search_text_315="${1}"
    local replace_text_arg_316="${2}"
    local command_7
    command_7="$(find . -type f -not -path "*/.*" -not -path "*/vendor/*")"
    __status=$?
    local raw_317="${command_7}"
    trim__10_v0 "${raw_317}"
    local ret_trim10_v0__18_34="${ret_trim10_v0}"
    split_lines__5_v0 "${ret_trim10_v0__18_34}"
    local ret_split_lines5_v0__18_22=("${ret_split_lines5_v0[@]}")
    for path_line_322 in "${ret_split_lines5_v0__18_22[@]}"; do
        trim__10_v0 "${path_line_322}"
        local fp_323="${ret_trim10_v0}"
        if [ "$([ "_${fp_323}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        test -s "${fp_323}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            continue
        fi
        local command_10
        command_10="$(basename "${fp_323}")"
        __status=$?
        local bn_324="${command_10}"
        trim__10_v0 "${bn_324}"
        local ret_trim10_v0__28_40="${ret_trim10_v0}"
        log_warning__52_v0 "Processing file: ${ret_trim10_v0__28_40}"
        replace_text_in_file__62_v0 "${fp_323}" "${search_text_315}" "${replace_text_arg_316}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_replace_text_in_files63_v0=''
            return "${__status}"
        fi
    done
}

# move_file(src: Text, dest: Text)
move_file__65_v0() {
    local src_369="${1}"
    local dest_370="${2}"
    mv -- "${src_369}" "${dest_370}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_move_file65_v0=''
        return "${__status}"
    fi
}

# remove_file_if_exists(path: Text)
remove_file_if_exists__66_v0() {
    local path_386="${1}"
    trim__10_v0 "${path_386}"
    local p_387="${ret_trim10_v0}"
    if [ "$([ "_${p_387}" == "_" ]; echo $?)" != 0 ]; then
        test -f "${p_387}"
        __status=$?
        code_388="${__status}"
            if [ "$(( code_388 == 0 ))" != 0 ]; then
                rm -f "${p_387}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_remove_file_if_exists66_v0=''
                    return "${__status}"
                fi
                log_success__51_v0 "Removed file: ${p_387}"
            else
                log_warning__52_v0 "File not found (skip): ${p_387}"
            fi
    fi
}

# remove_dir_if_exists(path: Text)
remove_dir_if_exists__67_v0() {
    local path_390="${1}"
    trim__10_v0 "${path_390}"
    local p_391="${ret_trim10_v0}"
    if [ "$([ "_${p_391}" == "_" ]; echo $?)" != 0 ]; then
        test -d "${p_391}"
        __status=$?
        code_392="${__status}"
            if [ "$(( code_392 == 0 ))" != 0 ]; then
                rm -rf "${p_391}"
                __status=$?
                if [ "${__status}" != 0 ]; then
                    ret_remove_dir_if_exists67_v0=''
                    return "${__status}"
                fi
                log_success__51_v0 "Removed directory: ${p_391}"
            else
                log_warning__52_v0 "Directory not found (skip): ${p_391}"
            fi
    fi
}

# is_module_pascal_name(name: Text)
is_module_pascal_name__76_v0() {
    local name_217="${1}"
    trim__10_v0 "${name_217}"
    local ret_trim10_v0__9_24="${ret_trim10_v0}"
    match_regex__19_v0 "${ret_trim10_v0__9_24}" "^[A-Z][a-zA-Z0-9]*\$" 0
    ret_is_module_pascal_name76_v0="${ret_match_regex19_v0}"
    return 0
}

# prompt_pascal_module_with_caption(caption: Text)
prompt_pascal_module_with_caption__77_v0() {
    local caption_212="${1}"
    while :
    do
        printf "%s" "${caption_212}"
        __status=$?
        local line_213=""
        read -r line_213
        __status=$?
        trim__10_v0 "${line_213}"
        local n_216="${ret_trim10_v0}"
        if [ "$([ "_${n_216}" != "_" ]; echo $?)" != 0 ]; then
            log_warning__52_v0 "Module name cannot be empty"
            continue
        fi
        is_module_pascal_name__76_v0 "${n_216}"
        local ret_is_module_pascal_name76_v0__22_12="${ret_is_module_pascal_name76_v0}"
        if [ "${ret_is_module_pascal_name76_v0__22_12}" != 0 ]; then
            ret_prompt_pascal_module_with_caption77_v0="${n_216}"
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
    local args_211=("${!1}")
    local __length_11=("${args_211[@]}")
    if [ "$(( ${#__length_11[@]} < 2 ))" != 0 ]; then
        prompt_module_name__78_v0 
        ret_resolve_module_name_for_create79_v0="${ret_prompt_module_name78_v0}"
        return 0
    fi
    trim__10_v0 "${args_211[1]?"Index out of bounds (at src/./utils/module.ab:37:28)"}"
    local name_227="${ret_trim10_v0}"
    if [ "$([ "_${name_227}" != "_" ]; echo $?)" != 0 ]; then
        prompt_module_name__78_v0 
        ret_resolve_module_name_for_create79_v0="${ret_prompt_module_name78_v0}"
        return 0
    fi
    is_module_pascal_name__76_v0 "${name_227}"
    local ret_is_module_pascal_name76_v0__41_8="${ret_is_module_pascal_name76_v0}"
    if [ "${ret_is_module_pascal_name76_v0__41_8}" != 0 ]; then
        ret_resolve_module_name_for_create79_v0="${name_227}"
        return 0
    fi
    log_error__53_v0 "Invalid module name: use PascalCase (e.g. MyModule)"
    exit 1
}

__EXAMPLE_LOWER_3="arkonexample"
__EXAMPLE_PASCAL_4="ArkonExample"
__GITHUB_REPO_5="https://github.com/Arkonsoft/PS-Example-Module.git"
__REPO_MODULE_SUBPATH_6="prestashop/modules/arkonexample"
__TEMPLATE_FILES_TO_REMOVE_7=("README.md")
__TEMPLATE_DIRS_TO_REMOVE_8=(".github")
# sayln(msg: Text)
sayln__82_v0() {
    local msg_253="${1}"
    printf "%s
" "${msg_253}"
    __status=$?
}

# prompt_github_branch_for_prestashop()
prompt_github_branch_for_prestashop__83_v0() {
    while :
    do
        printf "%s" "Select PrestaShop version (8 or 1.7): "
        __status=$?
        local line_251=""
        read -r line_251
        __status=$?
        trim__10_v0 "${line_251}"
        local c_252="${ret_trim10_v0}"
        if [ "$([ "_${c_252}" != "_8" ]; echo $?)" != 0 ]; then
            ret_prompt_github_branch_for_prestashop83_v0="ps8"
            return 0
        fi
        if [ "$([ "_${c_252}" != "_1.7" ]; echo $?)" != 0 ]; then
            ret_prompt_github_branch_for_prestashop83_v0="ps17"
            return 0
        fi
        sayln__82_v0 "Enter 8 for PrestaShop 8+, or 1.7 for 1.7.4+"
    done
}

# show_module_configuration(module_lower: Text, module_pascal: Text, github_branch: Text)
show_module_configuration__84_v0() {
    local module_lower_258="${1}"
    local module_pascal_259="${2}"
    local github_branch_260="${3}"
    sayln__82_v0 "Module configuration:"
    sayln__82_v0 "- Module name (lower): ${module_lower_258}"
    sayln__82_v0 "- Module name (pascal): ${module_pascal_259}"
    sayln__82_v0 "- Template branch: ${github_branch_260}"
    cwd__48_v0 
    local ret_cwd48_v0__55_30="${ret_cwd48_v0}"
    sayln__82_v0 "- Target folder: ${ret_cwd48_v0__55_30}"
}

# get_target_path(module_lower: Text)
get_target_path__85_v0() {
    local module_lower_264="${1}"
    cwd__48_v0 
    local ret_cwd48_v0__59_47="${ret_cwd48_v0}"
    local command_14
    command_14="$(basename "${ret_cwd48_v0__59_47}")"
    __status=$?
    local current_folder_265="${command_14}"
    trim__10_v0 "${current_folder_265}"
    local current_trim_266="${ret_trim10_v0}"
    if [ "$([ "_${current_trim_266}" != "_${module_lower_264}" ]; echo $?)" != 0 ]; then
        cwd__48_v0 
        ret_get_target_path85_v0="${ret_cwd48_v0}"
        return 0
    fi
    cwd__48_v0 
    local ret_cwd48_v0__64_14="${ret_cwd48_v0}"
    ret_get_target_path85_v0="${ret_cwd48_v0__64_14}/${module_lower_264}"
    return 0
}

# refuse_if_target_module_path_busy(target_path: Text)
refuse_if_target_module_path_busy__86_v0() {
    local target_path_270="${1}"
    trim__10_v0 "${target_path_270}"
    local ret_trim10_v0__68_8="${ret_trim10_v0}"
    cwd__48_v0 
    local ret_cwd48_v0__68_34="${ret_cwd48_v0}"
    trim__10_v0 "${ret_cwd48_v0__68_34}"
    local ret_trim10_v0__68_29="${ret_trim10_v0}"
    if [ "$([ "_${ret_trim10_v0__68_8}" == "_${ret_trim10_v0__68_29}" ]; echo $?)" != 0 ]; then
        test -e "${target_path_270}"
        __status=$?
        code_271="${__status}"
            if [ "$(( code_271 == 0 ))" != 0 ]; then
                log_error__42_v0 "Path already exists (choose another name or remove it): ${target_path_270}"
                exit 1
            fi
    fi
}

# initialize_module_repository(target_path: Text, github_branch: Text)
initialize_module_repository__87_v0() {
    local target_path_280="${1}"
    local github_branch_281="${2}"
    log_info__39_v0 "Cloning module from repository..."
    local command_15
    command_15="$(mktemp -d)"
    __status=$?
    trim__10_v0 "${command_15}"
    local tmp_root_282="${ret_trim10_v0}"
    local clone_dest_283="${tmp_root_282}/repo"
    git clone --branch "${github_branch_281}" --single-branch "${__GITHUB_REPO_5}" "${clone_dest_283}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        log_error__42_v0 "Error while cloning module"
        rm -rf "${tmp_root_282}">/dev/null 2>&1
        __status=$?
        exit 1
    fi
    local module_src_284="${clone_dest_283}/${__REPO_MODULE_SUBPATH_6}"
    test -d "${module_src_284}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        log_error__42_v0 "Module template path not found in repository: ${__REPO_MODULE_SUBPATH_6}"
        rm -rf "${tmp_root_282}">/dev/null 2>&1
        __status=$?
        exit 1
    fi
    cwd__48_v0 
    local workdir_285="${ret_cwd48_v0}"
    trim__10_v0 "${target_path_280}"
    local ret_trim10_v0__96_8="${ret_trim10_v0}"
    trim__10_v0 "${workdir_285}"
    local ret_trim10_v0__96_29="${ret_trim10_v0}"
    if [ "$([ "_${ret_trim10_v0__96_8}" != "_${ret_trim10_v0__96_29}" ]; echo $?)" != 0 ]; then
        cp -a "${module_src_284}/." "${target_path_280}/"
        __status=$?
        if [ "${__status}" != 0 ]; then
            log_error__42_v0 "Error copying module template"
            rm -rf "${tmp_root_282}">/dev/null 2>&1
            __status=$?
            exit 1
        fi
    else
        mv "${module_src_284}" "${target_path_280}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            log_error__42_v0 "Error moving module to target folder"
            rm -rf "${tmp_root_282}">/dev/null 2>&1
            __status=$?
            exit 1
        fi
    fi
    rm -rf "${tmp_root_282}">/dev/null 2>&1
    __status=$?
    cd "${target_path_280}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_initialize_module_repository87_v0=''
        return "${__status}"
    fi
    rm -rf .git>/dev/null 2>&1
    __status=$?
    log_success__40_v0 "Module cloned successfully"
}

# renamed_module_basename(fn: Text, module_lower: Text, module_pascal: Text, template_lower: Text, template_pascal: Text)
renamed_module_basename__88_v0() {
    local fn_362="${1}"
    local module_lower_363="${2}"
    local module_pascal_364="${3}"
    local template_lower_365="${4}"
    local template_pascal_366="${5}"
    local command_16
    command_16="$(printf "%s" "${fn_362}" | sed -e "s/${template_lower_365}/${module_lower_363}/g" -e "s/${template_pascal_366}/${module_pascal_364}/g")"
    __status=$?
    trim__10_v0 "${command_16}"
    ret_renamed_module_basename88_v0="${ret_trim10_v0}"
    return 0
}

# rename_module_files(module_lower: Text, module_pascal: Text)
rename_module_files__89_v0() {
    local module_lower_354="${1}"
    local module_pascal_355="${2}"
    log_info__39_v0 "Renaming files..."
    local command_17
    command_17="$(find . -type f -not -path "*/.*" -not -path "*/vendor/*")"
    __status=$?
    local raw_356="${command_17}"
    trim__10_v0 "${raw_356}"
    local ret_trim10_v0__130_34="${ret_trim10_v0}"
    split_lines__5_v0 "${ret_trim10_v0__130_34}"
    local ret_split_lines5_v0__130_22=("${ret_split_lines5_v0[@]}")
    for path_line_357 in "${ret_split_lines5_v0__130_22[@]}"; do
        trim__10_v0 "${path_line_357}"
        local fp_358="${ret_trim10_v0}"
        if [ "$([ "_${fp_358}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        local command_20
        command_20="$(basename "${fp_358}")"
        __status=$?
        local filename_359="${command_20}"
        local command_21
        command_21="$(dirname "${fp_358}")"
        __status=$?
        local directory_360="${command_21}"
        trim__10_v0 "${filename_359}"
        local fn_361="${ret_trim10_v0}"
        renamed_module_basename__88_v0 "${fn_361}" "${module_lower_354}" "${module_pascal_355}" "${__EXAMPLE_LOWER_3}" "${__EXAMPLE_PASCAL_4}"
        local newname_367="${ret_renamed_module_basename88_v0}"
        if [ "$([ "_${newname_367}" == "_${fn_361}" ]; echo $?)" != 0 ]; then
            log_warning__41_v0 "Renaming: ${fn_361} -> ${newname_367}"
            trim__10_v0 "${directory_360}"
            local ret_trim10_v0__142_33="${ret_trim10_v0}"
            local dest_path_368="${ret_trim10_v0__142_33}/${newname_367}"
            move_file__65_v0 "${fp_358}" "${dest_path_368}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_rename_module_files89_v0=''
                return "${__status}"
            fi
        fi
    done
}

# install_module_dependencies()
install_module_dependencies__90_v0() {
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
confirm_module_location__91_v0() {
    cwd__48_v0 
    local ret_cwd48_v0__158_52="${ret_cwd48_v0}"
    local command_22
    command_22="$(basename "${ret_cwd48_v0__158_52}")"
    __status=$?
    trim__10_v0 "${command_22}"
    local current_folder_238="${ret_trim10_v0}"
    if [ "$([ "_${current_folder_238}" == "_modules" ]; echo $?)" != 0 ]; then
        log_error__42_v0 "You are not in a 'modules' folder"'!'""
        log_warning__41_v0 "Creating modules outside of a 'modules' directory is not recommended."
        printf "%s" "Do you want to continue anyway? (y/N) "
        __status=$?
        local confirmation_241=""
        read -r confirmation_241
        __status=$?
        if [ "$([ "_${confirmation_241}" != "_y" ]; echo $?)" != 0 ]; then
            true
            __status=$?
        elif [ "$([ "_${confirmation_241}" != "_Y" ]; echo $?)" != 0 ]; then
            true
            __status=$?
        else
            log_info__39_v0 "Operation cancelled by user"
            exit 0
        fi
    fi
}

# remove_template_artifacts()
remove_template_artifacts__92_v0() {
    log_info__39_v0 "Removing template files and directories..."
    for path_385 in "${__TEMPLATE_FILES_TO_REMOVE_7[@]}"; do
        trim__10_v0 "${path_385}"
        local ret_trim10_v0__185_31="${ret_trim10_v0}"
        remove_file_if_exists__66_v0 "${ret_trim10_v0__185_31}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_remove_template_artifacts92_v0=''
            return "${__status}"
        fi
    done
    for path_389 in "${__TEMPLATE_DIRS_TO_REMOVE_8[@]}"; do
        trim__10_v0 "${path_389}"
        local ret_trim10_v0__188_30="${ret_trim10_v0}"
        remove_dir_if_exists__67_v0 "${ret_trim10_v0__188_30}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_remove_template_artifacts92_v0=''
            return "${__status}"
        fi
    done
}

typeset -r args_9=("$0" "$@")
test -n "${args_9[0]?"Index out of bounds (at src/create.ab:193:35)"}">/dev/null 2>&1
__status=$?
check_composer__56_v0 
resolve_module_name_for_create__79_v0 args_9[@]
module_name_228="${ret_resolve_module_name_for_create79_v0}"
cwd__48_v0 
original_location_229="${ret_cwd48_v0}"
confirm_module_location__91_v0 
lowercase__11_v0 "${module_name_228}"
ret_lowercase11_v0__199_31="${ret_lowercase11_v0}"
trim__10_v0 "${ret_lowercase11_v0__199_31}"
module_lower_245="${ret_trim10_v0}"
trim__10_v0 "${module_name_228}"
module_pascal_246="${ret_trim10_v0}"
prompt_github_branch_for_prestashop__83_v0 
github_branch_254="${ret_prompt_github_branch_for_prestashop83_v0}"
show_module_configuration__84_v0 "${module_lower_245}" "${module_pascal_246}" "${github_branch_254}"
get_target_path__85_v0 "${module_lower_245}"
target_path_267="${ret_get_target_path85_v0}"
refuse_if_target_module_path_busy__86_v0 "${target_path_267}"
initialize_module_repository__87_v0 "${target_path_267}" "${github_branch_254}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_warning__41_v0 "Replacing lowercase names..."
replace_text_in_files__63_v0 "${__EXAMPLE_LOWER_3}" "${module_lower_245}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_warning__41_v0 "Replacing PascalCase names..."
replace_text_in_files__63_v0 "${__EXAMPLE_PASCAL_4}" "${module_pascal_246}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
rename_module_files__89_v0 "${module_lower_245}" "${module_pascal_246}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
remove_template_artifacts__92_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
install_module_dependencies__90_v0 
cd "${original_location_229}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_info__39_v0 "Module configuration completed successfully"
log_warning__41_v0 "Module location: ${target_path_267}"
