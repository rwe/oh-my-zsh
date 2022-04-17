# URL Tools
# Adds handy command line aliases useful for dealing with URLs
#
# Taken from:
# https://ruslanspivak.com/2010/06/02/urlencode-and-urldecode-from-a-command-line/

if [[ "${URLTOOLS_METHOD:-node}" == node ]] && (( ${+commands[node]} )); then
    function urlencode() { node -e 'console.log(encodeURIComponent(process.argv[1]))' "$1"; }
    function urldecode() { node -e 'console.log(decodeURIComponent(process.argv[1]))' "$1"; }
elif [[ "${URLTOOLS_METHOD:-python3}" == python(|3) ]] && (( ${+commands[python3]} )); then
    function urlencode() { python3 -c 'import sys; del sys.path[0]; import urllib.parse as up; print(up.quote_plus(sys.argv[1]))' "$1"; }
    function urldecode() { python3 -c 'import sys; del sys.path[0]; import urllib.parse as up; print(up.unquote_plus(sys.argv[1]))' "$1"; }
elif [[ "${URLTOOLS_METHOD:-python2}" == python(|2) ]] && (( ${+commands[python2]} )); then
    function urlencode() { python2 -c 'import sys; del sys.path[0]; import urllib as ul; print ul.quote_plus(sys.argv[1])' "$1"; }
    function urldecode() { python2 -c 'import sys; del sys.path[0]; import urllib as ul; print ul.unquote_plus(sys.argv[1])' "$1"; }
elif [[ "${URLTOOLS_METHOD:-shell}" == shell ]] && (( ${+commands[xxd]} )); then
    function urlencode() { echo $@ | tr -d '\n' | xxd -plain | sed 's/\(..\)/%\1/g' }
    function urldecode() { printf $(echo -n $@ | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g')"\n"; }
elif [[ "${URLTOOLS_METHOD:-ruby}" == ruby ]] && (( ${+commands[ruby]} )); then
    function urlencode() { ruby -r cgi -e 'puts CGI.escape(ARGV[0])' "$1"; }
    function urldecode() { ruby -r cgi -e "puts CGI.unescape(ARGV[0])" "$1"; }
elif [[ "${URLTOOLS_METHOD:-php}" == php ]] && (( ${+commands[php]} )); then
    function urlencode() { php -r 'echo rawurlencode($argv[1]); echo "\n";' "$1"; }
    function urldecode() { php -r 'echo rawurldecode($argv[1]); echo "\n";' "$1"; }
elif [[ "${URLTOOLS_METHOD:-perl}" == perl ]] && (( ${+commands[perl]} )); then
    if perl -MURI::Encode -e 1&> /dev/null; then
        function urlencode() { perl -MURI::Encode -ep 'uri_encode($ARGV[0]);' "$1"; }
        function urldecode() { perl -MURI::Encode -ep 'uri_decode($ARGV[0]);' "$1"; }
    elif perl -MURI::Escape -e 1 &> /dev/null; then
        function urlencode() { perl -MURI::Escape -ep 'uri_escape($ARGV[0]);' "$1"; }
        function urldecode() { perl -MURI::Escape -ep 'uri_unescape($ARGV[0]);' "$1"; }
    else
        function urlencode() { perl -e '$new=$ARGV[0]; $new =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg; print "$new\n";' "$1"; }
        function urldecode() { perl -e '$new=$ARGV[0]; $new =~ s/\%([A-Fa-f0-9]{2})/pack("C", hex($1))/seg; print "$new\n";' "$1"; }
    fi
else
    function urlencode() { omz_urlencode -rmp "$1"; }
    function urldecode() { omz_urldecode "$1"; }
fi

unset URLTOOLS_METHOD
