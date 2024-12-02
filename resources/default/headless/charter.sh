#!/usr/bin/env bash

# env variables - chart options
CHART_TYPE=${CHART_TYPE:-"double-line"}
CHART_TITLE=${CHART_TITLE:-"Example title"}
GERRIT_ACTION=${GERRIT_ACTION:-""}
# env variables - paths
OUTPUT_FOLDER=${OUTPUT_FOLDER:-"/tmp"}
DATASET_FILE_CSV=${DATASET_FILE_CSV:-"/tmp/dataset.csv"}
DATASET_FILE_JSON="${DATASET_FILE_CSV%.csv}.json"

# costants
GIT_COLORS=("'#0077b6'"  "'#a2d2ff'" "'#5D8AA8'")
REST_COLOR=("'#f4d58d'" "'#ffa200'" "'#f7a072'" "'#ff7f51'" "'#ce4257'")
REST_COLORS=("${REST_COLOR[@]}" "${REST_COLOR[@]}" "${REST_COLOR[@]}" "${REST_COLOR[@]}" "${REST_COLOR[@]}" "${REST_COLOR[@]}")
STATIC_COLORS=("'#edede9'" "'#d6ccc2'" "'#f5ebe0'" "'#e3d5ca'" "'#d5bdaf'" "'#edede9'")
CURR_PATH=$(dirname "$(realpath "$0")")
CHARTS_PATH="$CURR_PATH/../../../templates"

function get_colors(){
    sliced_git=("${GIT_COLORS[@]:0:$1}")
    sliced_rest=("${REST_COLORS[@]:0:$2}")
    sliced_static=("${STATIC_COLORS[@]:0:$3}")
    combined_string=$(IFS=','; printf '%s' "${sliced_git[*]},${sliced_rest[*]},${sliced_static[*]}")
    echo $combined_string
}

function trim_to_camel_case_capitalized(){
    words=$(echo $1 | tr " " "\n")
    local input="$1"
    local output=""
    local prev_char=""
    # Remove all whitespaces and delimiter the string split by them
    for word in $words; do
        # Capitalize the first character of each word except the first one
        word="$(tr '[:lower:]' '[:upper:]' <<< ${word:0:1})${word:1}"
        output+="$word"
    done
    echo "$output"
}

function convert_csv_to_json(){
    node "$CURR_PATH/../../../csv2json/src/csv2json.js" --csv $DATASET_FILE_CSV --json $DATASET_FILE_JSON
}

function write_chart(){
    name_prefix=$(trim_to_camel_case_capitalized "$CHART_TITLE")
    #template, tmp, output
    TEMPLATE_FILE="$CHARTS_PATH/$CHART_TYPE.template.html"
    TEMP_FILE="$OUTPUT_FOLDER/$name_prefix-$CHART_TYPE-tmp.html"
    OUTPUT="$OUTPUT_FOLDER/$name_prefix-$CHART_TYPE.html"
    if [ -e "$TEMP_FILE" ]; then rm "$TEMP_FILE" ; fi
    cp $TEMPLATE_FILE $TEMP_FILE

    case $CHART_TYPE in
            half-pie)
                convert_csv_to_json
                actions_array=$(jq -r 'map(.Action) | unique | .[]' $DATASET_FILE_JSON)
                IFS=$'\n' read -r -d '' -a actions_array <<< "$actions_array"
                #dataset
                dataset_as_json=$(< $DATASET_FILE_JSON)
                dataset_escaped=$(echo -e $dataset_as_json)
                sed -i "" "s/PH_DATASET/$dataset_escaped/" "$TEMP_FILE"
                #colors
                num_of_git_actions_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^git' | wc -l)
                num_of_rest_actions_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^rest' | wc -l)
                num_of_static_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^static' | wc -l)
                colors="$(get_colors $num_of_git_actions_array $num_of_rest_actions_array $num_of_static_array)"
                sed -i "" "s/PH_COLORS/$colors/" "$TEMP_FILE"
                #title
                sed "s/PH_TITLE/$CHART_TITLE/" "$TEMP_FILE"  > $OUTPUT
                ;;
            double-half-pie)
                convert_csv_to_json
                actions_array=$(jq -r 'map(.Action) | unique | .[]' $DATASET_FILE_JSON)
                IFS=$'\n' read -r -d '' -a actions_array <<< "$actions_array"
                #dataset
                dataset_as_json=$(< $DATASET_FILE_JSON)
                dataset_escaped=$(echo -e $dataset_as_json)
                sed -i "" "s/PH_DATASET1/$dataset_escaped/" "$TEMP_FILE"
                #colors
                num_of_git_actions_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^git' | wc -l)
                num_of_rest_actions_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^rest' | wc -l)
                num_of_static_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^static' | wc -l)
                colors="$(get_colors $num_of_git_actions_array $num_of_rest_actions_array $num_of_static_array)"
                sed -i "" "s/PH_COLORS/$colors/" "$TEMP_FILE"
                #dataset2
                git_total=$(jq '[.[] | select(.Action | startswith("GIT")) | .Total] | add' $DATASET_FILE_JSON)
                rest_total=$(jq '[.[] | select(.Action | startswith("REST")) | .Total] | add' $DATASET_FILE_JSON)
                static_total=$(jq '[.[] | select(.Action | startswith("STATIC")) | .Total] | add' $DATASET_FILE_JSON)
                dataset_aggregate=$(printf "[{value: %s, name: \"Git\"},{value: %s, name: \"Rest\"},{value: %s, name: \"Static\"}]" "$git_total" "$rest_total" "$static_total")
                sed -i "" "s/PH_DATASET2/$dataset_aggregate/" "$TEMP_FILE"
                #title
                sed "s/PH_TITLE/$CHART_TITLE/" "$TEMP_FILE"  > $OUTPUT
                ;;
            lines)
                convert_csv_to_json
                actions_array=$(jq -r 'map(.Action) | unique | .[]' $DATASET_FILE_JSON)
                IFS=$'\n' read -r -d '' -a actions_array <<< "$actions_array"
                actions_array_files=""
                dataset_transformations=""
                series=""
                for index in "${!actions_array[@]}"; do
                    echo "here ${actions_array[$index]}"
                    jq "[ .[] |select(.Action==\"${actions_array[$index]}\")]" $DATASET_FILE_JSON | jq -s '[ .[] | reduce .[] as $item ([]; . + [$item + {Cumulative: ((add.Cumulative? // 0) + $item.Total)}]) | .[] ]' > $DATASET_FILE_JSON.$index
                    echo "there"
                    actions_array_files+="$DATASET_FILE_JSON.$index "
                    tranformation=$(printf "{id: '%s', fromDatasetId: 'dataset_raw', transform: { type: 'filter', config: { dimension: 'Action', '=': '%s' }}}," "dataset_$index" "${actions_array[$index]}")
                    dataset_transformations+="$tranformation"
                    single_series=$(printf "{ type: 'line', name: '%s', datasetId: '%s', showSymbol: false, encode: { x: 'minute', y: 'Cumulative'}}," "${actions_array[$index]}" "dataset_$index")
                    series+="$single_series"
                done
                dataset_as_json=$(jq -s 'add' $actions_array_files)
                dataset_escaped=$(echo -e $dataset_as_json)
                #colors
                num_of_git_actions_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^git' | wc -l)
                num_of_rest_actions_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^rest' | wc -l)
                num_of_static_array=$(echo "${actions_array[@]}" | tr ' ' '\n' | grep -i '^static' | wc -l)
                colors="$(get_colors $num_of_git_actions_array $num_of_rest_actions_array $num_of_static_array)"
                sed -i "" "s/PH_COLORS/$colors/" "$TEMP_FILE"
                #datasets, transformations, series
                sed -i "" "s/PH_DATASETS/$dataset_escaped/" "$TEMP_FILE"
                sed -i "" "s/PH_TRANSFORMATIONS/$dataset_transformations/" "$TEMP_FILE"
                sed -i "" "s/PH_SERIES/$series/" "$TEMP_FILE"
                #title
                sed "s/PH_TITLE/$CHART_TITLE/" "$TEMP_FILE"  > $OUTPUT
                ;;
            double-line)
                convert_csv_to_json
                #dataset
                jq "[ .[] | select(.Action==\"$GERRIT_ACTION\")]" $DATASET_FILE_JSON > $DATASET_FILE_JSON.filtered
                dataset_as_json=$(< $DATASET_FILE_JSON.filtered)
                dataset_escaped=$(echo -e $dataset_as_json)
                sed -i "" "s/PH_DATASET/$dataset_escaped/" "$TEMP_FILE"
                #title
                sed "s/PH_TITLE/$CHART_TITLE/" "$TEMP_FILE"  > $OUTPUT
                ;;
            *)
                echo "chart type not supported"
                ;;
    esac
    if [ -e "$TEMP_FILE" ]; then rm "$TEMP_FILE" ; fi
}

write_chart