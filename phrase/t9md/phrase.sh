# Phrase: logging_execute                                              
#======================================================================
function do_log()
{
  echo $@
}

function do_report_time(){ #{{{
  local start=$1
  local finish=$2
  local ss=""
  local hh=""
  local mm=""

  ss=$(expr ${finish} - ${start})
  hh=$(expr ${ss} / 3600)
  ss=$(expr ${ss} % 3600)
  mm=$(expr ${ss} / 60)
  ss=$(expr ${ss} % 60)
  printf "%02d:%02d:%02d" ${hh} ${mm} ${ss}
} #}}}

function logging_exe()
{
  local start finish subject
  local subject=$1 cmd=$2
  start=$(date +%s) ; do_log "${subject} start"
  if [ ! -z ${NOOP} ]; then
    echo $cmd
  else
    eval $cmd
  fi
  finish=$(date +%s); do_log "${subject} finish takes $(do_report_time ${start} ${finish})"
}

function main()
{
  logging_exe "Phase1" "sleep 1"
  logging_exe "Phase2" "sleep 2"
}

logging_exe "Main" "main"

# Phrase: read configuration to array                                  
#======================================================================
function read_conf()
{
  arg=( $(cat test.conf | grep -E -v '#' ) )
  echo ${arg[*]}
}
val=( $(read_conf) )
for v in ${val[@]}
do
  echo $v
done

# Phrase: Basic                                                        
#======================================================================
export -f O-
function O-(){
  echo "# $1"
}
function O--(){
  echo "-- $1"
}
# export function with "-f"

O- 数値演算
num=1
echo $num
echo ${num}
num=$(($num+1))
echo $num
num=$[$num+1]
echo $num
let num=num+1
echo $num

O- 配列
a=(a b c d)
echo ${a[@]}
echo ${a[*]}
O-- size
echo ${#a[@]}
echo ${#a[*]}
O-- 一括代入
files=(`ls`)
echo ${files[@]}
echo ${#files[@]}
for file in ${files[@]}
do
  echo $file
done

# Phrase: predefined variable
#===============================================
function print_var()
{
    local VARNAME=$1
    eval "local VALUE=\$${VARNAME}"
    printf "$%-10s => %s\n" $VARNAME $VALUE
}
DATE="$(date +%Y%m%d_%Y%M%S)"
VARLIST=(
EDITOR 
DIRSTACK
EUID
UID
FUNCNAME   # effect when refered in function
GLOBIGNORE
IFS  ## Input Field Separator (default: space tab newline)
LINENO
OLDPWD
OSTYPE
PATH
PIPESTATUS
PPID
SHELLOPT
MACHTYPES
PWD
PS1
# list of group number
{GROUPS[0]}
{GROUPS[1]}
{GROUPS[2]}
SECONDS            # num of sec the script has been running
{BASH_VERSINFO[0]} # Major ver no
{BASH_VERSINFO[1]} # Minor ver no.
{BASH_VERSINFO[2]} # Patch level.
{BASH_VERSINFO[3]} # Build version.
{BASH_VERSINFO[4]} # Release status.
{BASH_VERSINFO[5]} # Architecture (same as $MACHTYPES)
)
for v in ${VARLIST[@]} # process each element
do
    print_var $v
done
exit

# Phrase: tmpfile mktemp tmpdir [ mktmp(1) ]
#===============================================
# tmpfile
tempfoo=`basename $0`
TMPFILE=`mktemp /tmp/${tempfoo}.XXXXXX` || exit 1
echo "program output" >> $TMPFILE

tempfoo=`basename $0`
TMPFILE=`mktemp -t ${tempfoo}` || exit 1
echo "program output" >> $TMPFILE

# Phrase: arithmethic expression
#===============================================
# $(())
A=10; B=100; C=1000
ANSWER=$((A+B+C))
echo ${ANSWER}

# random
DICE=$((($RANDOM%6) + 1))
echo ${DICE}

# Phrase: String manupilation
# http://www.linuxtopia.org/online_books/advanced_bash_scripting_guide/refcards.html
#===============================================
${#string}                       #  Length of $string
${string:position}               #  Extract substring from $string at $position
${string:position:length}        #  Extract $length characters substring from $string at $position
${string#substring}              #  Strip shortest match of $substring from front of $string
${string##substring}             #  Strip longest match of $substring from front of $string
${string%substring}              #  Strip shortest match of $substring from back of $string
${string%%substring}             #  Strip longest match of $substring from back of $string
${string/substring/replacement}  #  Replace first match of $substring with $replacement
${string//substring/replacement} #  Replace all matches of $substring with $replacement
${string/#substring/replacement} #  If $substring matches front end of $string, substitute $replacement for $substring
${string/%substring/replacement} #  If $substring matches back end of $string, substitute $replacement for $substring
expr match "$string" '$substring'       #  Length of matching $substring* at beginning of $string
expr "$string" : '$substring'           #  Length of matching $substring* at beginning of $string
expr index "$string" $substring         #  Numerical position in $string of first character in $substring that matches
expr substr $string $position $length   #  Extract $length characters from $string starting at $position
expr match "$string" '\($substring\)'   #  Extract $substring* at beginning of $string
expr "$string" : '\($substring\)'       #  Extract $substring* at beginning of $string
expr match "$string" '.*\($substring\)' #  Extract $substring* at end of $string
expr "$string" : '.*\($substring\)'     #  Extract $substring* at end of $string

# Phrase: boolean condition check by grouping exp with \(\)
#===============================================
a=5; b=20
if [ \( $a -gt 0 -a $a -lt 10 \) -o \( $b -gt 0 -a $b -lt 20 \) ]; then
   echo "TRUE"
else
  echo "FALSE"
fi
# Phrase: read input is parsed by white space
#===============================================
read a b c # $a=How, $b=do, $c="you do?"
echo "\$a => $a"
echo "\$b => $b"
echo "\$c => $c"
# Your Input:
#    How do you do?
# Result:
#    $a => How
#    $b => do
#    $c => you do?

# Phrase: shift args
#===============================================
# when called with arg1 arg2 arg3
echo $*  # all arg "arg arg2 arg3"
echo $#  # num_of_arg = 2
shift    # $1=arg2,$2=arg3
echo $#  # num_of_arg = 1
# Phrase: process all args with shift
#===============================================
while [ $# -ne 0 ]
do
    echo $1
    shift
done
# Phrase: ${var:XXXX} example
#===============================================
var=assigned
#echo ${var:-string} # Use var if set, otherwise use string  
#echo ${var:=string} # Use var if set, otherwise use string and assign string to var  
#echo ${var:?string} # Use var if set, otherwise print string and exit
#echo ${var:+string} # Use string if var if set, otherwise use nothing  
echo --
echo $var
