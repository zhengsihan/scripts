echon()
{
    echo "$*" | awk '{ printf "%s", $0 }'
}

echon()
{
    printf "%s" "$*"
}

echon()
{
    echo "$*" | tr -d '\n'
}