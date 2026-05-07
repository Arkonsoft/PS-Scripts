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
    local source_177="${1}"
    local search_178="${2}"
    local replace_179="${3}"
    # Here we use a command to avoid #646
    local result_180=""
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
        result_180="${source_177//"${search_178}"/"${replace_179}"}"
        __status=$?
    else
        result_180="${source_177//"${search_178}"/${replace_179}}"
        __status=$?
    fi
    ret_replace0_v0="${result_180}"
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
    local text_245="${1}"
    local delimiter_246="${2}"
    local result_247=()
    # zsh uses -A for array, bash uses -a, ksh is VERY bad at splitting anything
    if [ "$([ "_${EXEC_SHELL}" != "_zsh" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_246}" read -rd '' -A result_247 < <(printf %s "$text_245")
        __status=$?
    elif [ "$([ "_${EXEC_SHELL}" != "_ksh" ]; echo $?)" != 0 ]; then
        if [ "$([ "_${delimiter_246}" != "_
" ]; echo $?)" != 0 ]; then
            while read -r -d $'\n'; do result_247+=("$REPLY"); done < <(echo "$text_245")
            __status=$?
        else
            IFS="${delimiter_246}" read -rd '' -a result_247 < <(printf %s "$text_245")
            __status=$?
        fi
    elif [ "$([ "_${EXEC_SHELL}" != "_bash" ]; echo $?)" != 0 ]; then
        IFS="${delimiter_246}" read -rd '' -a result_247 < <(printf %s "$text_245")
        __status=$?
    fi
    ret_split4_v0=("${result_247[@]}")
    return 0
}

# split_lines(text: Text)
split_lines__5_v0() {
    local text_244="${1}"
    split__4_v0 "${text_244}" "
"
    ret_split_lines5_v0=("${ret_split4_v0[@]}")
    return 0
}

# trim(text: Text)
trim__10_v0() {
    local text_6="${1}"
    local result_7=""
    result_7="${text_6#${text_6%%[![:space:]]*}}"
    __status=$?
    result_7="${result_7%${result_7##*[![:space:]]}}"
    __status=$?
    ret_trim10_v0="${result_7}"
    return 0
}

# lowercase(text: Text)
lowercase__11_v0() {
    local text_193="${1}"
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
        text_193="$(printf '%s' "${text_193}" | tr '[:upper:]' '[:lower:]')"
        __status=$?
    else
        typeset -l text_193
            text_193="${text_193}"
        __status=$?
    fi
    ret_lowercase11_v0="${text_193}"
    return 0
}

# match_regex(source: Text, search: Text, extended: Bool)
match_regex__19_v0() {
    local source_173="${1}"
    local search_174="${2}"
    local extended_175="${3}"
    sed_version__2_v0 
    local sed_version_176="${ret_sed_version2_v0}"
    replace__0_v0 "${search_174}" "/" "\\/"
    search_174="${ret_replace0_v0}"
    local output_181=""
    if [ "$(( $(( sed_version_176 == __SED_VERSION_GNU_1 )) || $(( sed_version_176 == __SED_VERSION_BUSYBOX_2 )) ))" != 0 ]; then
        # '\b' is supported but not in POSIX standards. Disable it
        replace__0_v0 "${search_174}" "\\b" "\\\\b"
        search_174="${ret_replace0_v0}"
    fi
    if [ "${extended_175}" != 0 ]; then
        # GNU sed versions 4.0 through 4.2 support extended regex syntax,
        # but only via the "-r" option
        if [ "$(( sed_version_176 == __SED_VERSION_GNU_1 ))" != 0 ]; then
            # '\b' is not in POSIX standards. Disable it
            replace__0_v0 "${search_174}" "\\b" "\\b"
            search_174="${ret_replace0_v0}"
            local command_3
            command_3="$(sed -r -ne "/${search_174}/p" <<<"${source_173}")"
            __status=$?
            output_181="${command_3}"
        else
            local command_4
            command_4="$(sed -E -ne "/${search_174}/p" <<<"${source_173}")"
            __status=$?
            output_181="${command_4}"
        fi
    else
        if [ "$(( $(( sed_version_176 == __SED_VERSION_GNU_1 )) || $(( sed_version_176 == __SED_VERSION_BUSYBOX_2 )) ))" != 0 ]; then
            # GNU Sed BRE handle \| as a metacharacter, but it is not POSIX standands. Disable it
            replace__0_v0 "${search_174}" "\\|" "|"
            search_174="${ret_replace0_v0}"
        fi
        local command_5
        command_5="$(sed -ne "/${search_174}/p" <<<"${source_173}")"
        __status=$?
        output_181="${command_5}"
    fi
    if [ "$([ "_${output_181}" == "_" ]; echo $?)" != 0 ]; then
        ret_match_regex19_v0=1
        return 0
    fi
    ret_match_regex19_v0=0
    return 0
}

# log_info(msg: Text)
log_info__39_v0() {
    local msg_212="${1}"
    printf "\033[1;36m[INFO]\033[0m %s
" "${msg_212}"
    __status=$?
}

# log_success(msg: Text)
log_success__40_v0() {
    local msg_313="${1}"
    printf "\033[1;32m[SUCCESS]\033[0m %s
" "${msg_313}"
    __status=$?
}

# log_warning(msg: Text)
log_warning__41_v0() {
    local msg_208="${1}"
    printf "\033[1;33m[WARNING]\033[0m %s
" "${msg_208}"
    __status=$?
}

# log_error(msg: Text)
log_error__42_v0() {
    local msg_191="${1}"
    printf "\033[1;31m[ERROR]\033[0m %s
" "${msg_191}" >&2
    __status=$?
}

# log_success(msg: Text)
log_success__50_v0() {
    local msg_255="${1}"
    printf "\033[1;32m[SUCCESS]\033[0m %s
" "${msg_255}"
    __status=$?
}

# log_warning(msg: Text)
log_warning__51_v0() {
    local msg_185="${1}"
    printf "\033[1;33m[WARNING]\033[0m %s
" "${msg_185}"
    __status=$?
}

# log_error(msg: Text)
log_error__52_v0() {
    local msg_171="${1}"
    printf "\033[1;31m[ERROR]\033[0m %s
" "${msg_171}" >&2
    __status=$?
}

# replace_text_in_file(fp: Text, search_text: Text, replace_text_arg: Text)
replace_text_in_file__55_v0() {
    local fp_251="${1}"
    local search_text_252="${2}"
    local replace_text_arg_253="${3}"
    grep -q -F "${search_text_252}" "${fp_251}"
    __status=$?
    code_254="${__status}"
        if [ "$(( code_254 == 0 ))" != 0 ]; then
            sed -i "s/${search_text_252}/${replace_text_arg_253}/g" "${fp_251}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_replace_text_in_file55_v0=''
                return "${__status}"
            fi
            log_success__50_v0 "  Changes made to file"
        else
            echo "  No changes needed"
        fi
}

# replace_text_in_files(search_text: Text, replace_text_arg: Text)
replace_text_in_files__56_v0() {
    local search_text_241="${1}"
    local replace_text_arg_242="${2}"
    local command_6
    command_6="$(find . -type f -not -path "*/.*" -not -path "*/vendor/*")"
    __status=$?
    local raw_243="${command_6}"
    trim__10_v0 "${raw_243}"
    local ret_trim10_v0__18_34="${ret_trim10_v0}"
    split_lines__5_v0 "${ret_trim10_v0__18_34}"
    local ret_split_lines5_v0__18_22=("${ret_split_lines5_v0[@]}")
    for path_line_248 in "${ret_split_lines5_v0__18_22[@]}"; do
        trim__10_v0 "${path_line_248}"
        local fp_249="${ret_trim10_v0}"
        if [ "$([ "_${fp_249}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        test -s "${fp_249}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            continue
        fi
        local command_9
        command_9="$(basename "${fp_249}")"
        __status=$?
        local bn_250="${command_9}"
        trim__10_v0 "${bn_250}"
        local ret_trim10_v0__28_40="${ret_trim10_v0}"
        log_warning__51_v0 "Processing file: ${ret_trim10_v0__28_40}"
        replace_text_in_file__55_v0 "${fp_249}" "${search_text_241}" "${replace_text_arg_242}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_replace_text_in_files56_v0=''
            return "${__status}"
        fi
    done
}

# renamed_file_basename(fn: Text, old_pascal: Text, new_pascal: Text, old_camel: Text, new_camel: Text, old_lower: Text, new_lower: Text)
renamed_file_basename__57_v0() {
    local fn_300="${1}"
    local old_pascal_301="${2}"
    local new_pascal_302="${3}"
    local old_camel_303="${4}"
    local new_camel_304="${5}"
    local old_lower_305="${6}"
    local new_lower_306="${7}"
    local command_10
    command_10="$(printf "%s" "${fn_300}" | sed -e "s/${old_pascal_301}/${new_pascal_302}/g" -e "s/${old_camel_303}/${new_camel_304}/g" -e "s/${old_lower_305}/${new_lower_306}/g")"
    __status=$?
    trim__10_v0 "${command_10}"
    ret_renamed_file_basename57_v0="${ret_trim10_v0}"
    return 0
}

# move_file(src: Text, dest: Text)
move_file__58_v0() {
    local src_309="${1}"
    local dest_310="${2}"
    mv -- "${src_309}" "${dest_310}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_move_file58_v0=''
        return "${__status}"
    fi
}

# pascal_to_camel(pascal: Text)
pascal_to_camel__66_v0() {
    local pascal_200="${1}"
    trim__10_v0 "${pascal_200}"
    local p_201="${ret_trim10_v0}"
    local command_11
    command_11="$(printf "%s" "${p_201}" | cut -c1)"
    __status=$?
    trim__10_v0 "${command_11}"
    local first_202="${ret_trim10_v0}"
    local command_12
    command_12="$(printf "%s" "${p_201}" | cut -c2-)"
    __status=$?
    trim__10_v0 "${command_12}"
    local rest_203="${ret_trim10_v0}"
    lowercase__11_v0 "${first_202}"
    local ret_lowercase11_v0__7_14="${ret_lowercase11_v0}"
    ret_pascal_to_camel66_v0="${ret_lowercase11_v0__7_14}${rest_203}"
    return 0
}

# is_module_pascal_name(name: Text)
is_module_pascal_name__72_v0() {
    local name_172="${1}"
    trim__10_v0 "${name_172}"
    local ret_trim10_v0__9_24="${ret_trim10_v0}"
    match_regex__19_v0 "${ret_trim10_v0__9_24}" "^[A-Z][a-zA-Z0-9]*\$" 0
    ret_is_module_pascal_name72_v0="${ret_match_regex19_v0}"
    return 0
}

# prompt_pascal_module_with_caption(caption: Text)
prompt_pascal_module_with_caption__73_v0() {
    local caption_182="${1}"
    while :
    do
        printf "%s" "${caption_182}"
        __status=$?
        local line_183=""
        read -r line_183
        __status=$?
        trim__10_v0 "${line_183}"
        local n_184="${ret_trim10_v0}"
        if [ "$([ "_${n_184}" != "_" ]; echo $?)" != 0 ]; then
            log_warning__51_v0 "Module name cannot be empty"
            continue
        fi
        is_module_pascal_name__72_v0 "${n_184}"
        local ret_is_module_pascal_name72_v0__22_12="${ret_is_module_pascal_name72_v0}"
        if [ "${ret_is_module_pascal_name72_v0__22_12}" != 0 ]; then
            ret_prompt_pascal_module_with_caption73_v0="${n_184}"
            return 0
        fi
        log_warning__51_v0 "Invalid name: use PascalCase — uppercase first letter, then only letters and numbers"
    done
}

# require_module_pascal_name(name: Text, empty_message: Text)
require_module_pascal_name__76_v0() {
    local name_168="${1}"
    local empty_message_169="${2}"
    trim__10_v0 "${name_168}"
    local n_170="${ret_trim10_v0}"
    if [ "$([ "_${n_170}" != "_" ]; echo $?)" != 0 ]; then
        log_error__52_v0 "${empty_message_169}"
        exit 1
    fi
    is_module_pascal_name__72_v0 "${n_170}"
    local ret_is_module_pascal_name72_v0__54_8="${ret_is_module_pascal_name72_v0}"
    if [ "${ret_is_module_pascal_name72_v0__54_8}" != 0 ]; then
        ret_require_module_pascal_name76_v0="${n_170}"
        return 0
    fi
    log_error__52_v0 "Invalid module name: use PascalCase (e.g. MyModule)"
    exit 1
}

# resolve_old_pascal(args: [Text])
resolve_old_pascal__79_v0() {
    local args_167=("${!1}")
    local __length_13=("${args_167[@]}")
    if [ "$(( ${#__length_13[@]} >= 3 ))" != 0 ]; then
        trim__10_v0 "${args_167[1]?"Index out of bounds (at src/change-name.ab:26:23)"}"
        local ret_trim10_v0__26_13="${ret_trim10_v0}"
        require_module_pascal_name__76_v0 "${ret_trim10_v0__26_13}" "Current module name cannot be empty."
        ret_resolve_old_pascal79_v0="${ret_require_module_pascal_name76_v0}"
        return 0
    fi
    prompt_pascal_module_with_caption__73_v0 "Current module name (PascalCase, e.g. MyModule): "
    ret_resolve_old_pascal79_v0="${ret_prompt_pascal_module_with_caption73_v0}"
    return 0
}

# resolve_new_pascal(args: [Text])
resolve_new_pascal__80_v0() {
    local args_188=("${!1}")
    local __length_14=("${args_188[@]}")
    if [ "$(( ${#__length_14[@]} >= 3 ))" != 0 ]; then
        trim__10_v0 "${args_188[2]?"Index out of bounds (at src/change-name.ab:38:23)"}"
        local ret_trim10_v0__38_13="${ret_trim10_v0}"
        require_module_pascal_name__76_v0 "${ret_trim10_v0__38_13}" "New module name cannot be empty."
        ret_resolve_new_pascal80_v0="${ret_require_module_pascal_name76_v0}"
        return 0
    fi
    prompt_pascal_module_with_caption__73_v0 "New module name (PascalCase, e.g. MyModule): "
    ret_resolve_new_pascal80_v0="${ret_prompt_pascal_module_with_caption73_v0}"
    return 0
}

# rename_module_files_for_rename(old_pascal: Text, new_pascal: Text, old_camel: Text, new_camel: Text, old_lower: Text, new_lower: Text)
rename_module_files_for_rename__81_v0() {
    local old_pascal_288="${1}"
    local new_pascal_289="${2}"
    local old_camel_290="${3}"
    local new_camel_291="${4}"
    local old_lower_292="${5}"
    local new_lower_293="${6}"
    log_info__39_v0 "Renaming files..."
    local command_15
    command_15="$(find . -type f -not -path "*/.*" -not -path "*/vendor/*")"
    __status=$?
    local raw_294="${command_15}"
    trim__10_v0 "${raw_294}"
    local ret_trim10_v0__57_34="${ret_trim10_v0}"
    split_lines__5_v0 "${ret_trim10_v0__57_34}"
    local ret_split_lines5_v0__57_22=("${ret_split_lines5_v0[@]}")
    for path_line_295 in "${ret_split_lines5_v0__57_22[@]}"; do
        trim__10_v0 "${path_line_295}"
        local fp_296="${ret_trim10_v0}"
        if [ "$([ "_${fp_296}" != "_" ]; echo $?)" != 0 ]; then
            continue
        fi
        local command_18
        command_18="$(basename "${fp_296}")"
        __status=$?
        local filename_297="${command_18}"
        local command_19
        command_19="$(dirname "${fp_296}")"
        __status=$?
        local directory_298="${command_19}"
        trim__10_v0 "${filename_297}"
        local fn_299="${ret_trim10_v0}"
        renamed_file_basename__57_v0 "${fn_299}" "${old_pascal_288}" "${new_pascal_289}" "${old_camel_290}" "${new_camel_291}" "${old_lower_292}" "${new_lower_293}"
        local newname_307="${ret_renamed_file_basename57_v0}"
        if [ "$([ "_${newname_307}" == "_${fn_299}" ]; echo $?)" != 0 ]; then
            log_warning__41_v0 "Renaming: ${fn_299} -> ${newname_307}"
            trim__10_v0 "${directory_298}"
            local ret_trim10_v0__77_33="${ret_trim10_v0}"
            local dest_path_308="${ret_trim10_v0__77_33}/${newname_307}"
            move_file__58_v0 "${fp_296}" "${dest_path_308}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_rename_module_files_for_rename81_v0=''
                return "${__status}"
            fi
        fi
    done
}

typeset -r args_3=("$0" "$@")
test -n "${args_3[0]?"Index out of bounds (at src/change-name.ab:84:35)"}">/dev/null 2>&1
__status=$?
command_21="$(pwd)"
__status=$?
trim__10_v0 "${command_21}"
modules_dir_8="${ret_trim10_v0}"
resolve_old_pascal__79_v0 args_3[@]
old_pascal_186="${ret_resolve_old_pascal79_v0}"
resolve_new_pascal__80_v0 args_3[@]
new_pascal_189="${ret_resolve_new_pascal80_v0}"
trim__10_v0 "${old_pascal_186}"
ret_trim10_v0__90_8="${ret_trim10_v0}"
trim__10_v0 "${new_pascal_189}"
ret_trim10_v0__90_28="${ret_trim10_v0}"
if [ "$([ "_${ret_trim10_v0__90_8}" != "_${ret_trim10_v0__90_28}" ]; echo $?)" != 0 ]; then
    log_error__42_v0 "Old and new module names are the same."
    exit 1
fi
lowercase__11_v0 "${old_pascal_186}"
ret_lowercase11_v0__95_28="${ret_lowercase11_v0}"
trim__10_v0 "${ret_lowercase11_v0__95_28}"
old_lower_194="${ret_trim10_v0}"
lowercase__11_v0 "${new_pascal_189}"
ret_lowercase11_v0__96_28="${ret_lowercase11_v0}"
trim__10_v0 "${ret_lowercase11_v0__96_28}"
new_lower_195="${ret_trim10_v0}"
pascal_to_camel__66_v0 "${old_pascal_186}"
old_camel_204="${ret_pascal_to_camel66_v0}"
pascal_to_camel__66_v0 "${new_pascal_189}"
new_camel_205="${ret_pascal_to_camel66_v0}"
module_root_206="${modules_dir_8}/${old_lower_194}"
test -d "${module_root_206}"
__status=$?
if [ "${__status}" != 0 ]; then
    log_error__42_v0 "Module directory not found: ${module_root_206}"
    log_warning__41_v0 "Run this from the PrestaShop \`modules\` folder (current: ${modules_dir_8})."
    exit 1
fi
target_path_209="${modules_dir_8}/${new_lower_195}"
test -e "${target_path_209}"
__status=$?
exists_code_210="${__status}"
    if [ "$(( exists_code_210 == 0 ))" != 0 ]; then
        log_error__42_v0 "Target path already exists: ${target_path_209}"
        exit 1
    fi
log_info__39_v0 "Renaming module:"
log_warning__41_v0 "- From: ${old_pascal_186} (${old_lower_194})"
log_warning__41_v0 "- To:   ${new_pascal_189} (${new_lower_195})"
log_warning__41_v0 "- Root: ${module_root_206}"
cd "${module_root_206}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_info__39_v0 "Replacing PascalCase in file contents..."
replace_text_in_files__56_v0 "${old_pascal_186}" "${new_pascal_189}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_info__39_v0 "Replacing camelCase in file contents..."
replace_text_in_files__56_v0 "${old_camel_204}" "${new_camel_205}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
log_info__39_v0 "Replacing lowercase in file contents..."
replace_text_in_files__56_v0 "${old_lower_194}" "${new_lower_195}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
rename_module_files_for_rename__81_v0 "${old_pascal_186}" "${new_pascal_189}" "${old_camel_204}" "${new_camel_205}" "${old_lower_194}" "${new_lower_195}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
cd "${modules_dir_8}"
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
mv -- "${old_lower_194}" "${new_lower_195}"
__status=$?
if [ "${__status}" != 0 ]; then
    log_error__42_v0 "Failed to rename module directory"
    exit 1
fi
new_root_311="${modules_dir_8}/${new_lower_195}"
log_success__40_v0 "Module renamed to ${new_root_311}"
