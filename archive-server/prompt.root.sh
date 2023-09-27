# -------- GET THE DURATION
function timer_now {
    date +%s%N
}

# -------- START THE DURATION TIMER
function timer_start {
    timer_start=${timer_start:-$(timer_now)}
}

# -------- CREATE THE DURATION TEXT
function timer_stop {
    # get raw duration
    local delta_us=$((($(timer_now) - $timer_start) / 1000))

    # stop the timer
    unset timer_start

    # create duration text
    if ((delta_us < 1000)); then
        # display microseconds (##0us)
        local us=$((delta_us % 1000))
        timer_show=${us}us

    elif ((delta_us < 1000000)); then
        # display milliseconds (##0ms)
        local ms=$(((delta_us / 1000) % 1000))
        timer_show=${ms}ms

    elif ((delta_us < 60000000)); then
        # display seconds (#.00s)
        local s=$(((delta_us / 1000000) % 60))
        local ms=$(((delta_us / 1000) % 1000))
        timer_show=${s}.$(printf "%02d" $((ms / 10)))s

    elif ((delta_us < 3600000000)); then
        # display minutes and seconds (m:ss)
        local m=$(((delta_us / 60000000) % 60))
        local s=$(((delta_us / 1000000) % 60))
        timer_show=${m}:$(printf "%02d" ${s})

    else
        # display hours, minutes and seconds (h:mm:ss)
        local h=$(((delta_us / 3600000000)))
        local m=$(((delta_us / 60000000) % 60))
        local s=$(((delta_us / 1000000) % 60))
        timer_show=${h}:$(printf "%02d" ${m}):$(printf "%02d" ${s})
    fi
}

# -------- CREATE THE ERROR TEXT
function get_exit_text() {
    # get the exit code
    results=${EXIT}

    # check for known exit code
    case ${EXIT} in
        129) results="SIGHUP(${EXIT})";;
        130) results="SIGINT(${EXIT})";;
        131) results="SIGQUIT(${EXIT})";;
        132) results="SIGILL(${EXIT})";;
        133) results="SIGTRAP(${EXIT})";;
        134) results="SIGABRT(${EXIT})";;
        135) results="SIGBUS(${EXIT})";;
        136) results="SIGFPE(${EXIT})";;
        137) results="SIGKILL(${EXIT})";;
        138) results="SIGUSR1(${EXIT})";;
        139) results="SIGSEGV(${EXIT})";;
        140) results="SIGUSR2(${EXIT})";;
        141) results="SIGPIPE(${EXIT})";;
        142) results="SIGALRM(${EXIT})";;
        143) results="SIGTERM(${EXIT})";;
        144) results="SIGSTKFLT(${EXIT})";;
        145) results="SIGCHLD(${EXIT})";;
        146) results="SIGCONT(${EXIT})";;
        147) results="SIGSTOP(${EXIT})";;
        148) results="SIGTSTP(${EXIT})";;
        149) results="SIGTTIN(${EXIT})";;
        150) results="SIGTTOU(${EXIT})";;
        151) results="SIGURG(${EXIT})";;
        152) results="SIGXCPU(${EXIT})";;
        153) results="SIGXFSZ(${EXIT})";;
        154) results="SIGVTALRM(${EXIT})";;
        155) results="SIGPROF(${EXIT})";;
        156) results="SIGWINCH(${EXIT})";;
        157) results="SIGIO(${EXIT})";;
        158) results="SIGPWR(${EXIT})";;
        159) results="SIGSYS(${EXIT})";;
    esac

    # return results
    echo "$results"
}

# -------- CREATE THE RIGHT SIDE OF THE COMMAND PROMPT
function prompt_right() {
  # colors
  Reset='\[\e[00m\]'
  OkColor='\033[38;5;15m\033[48;5;2m'
  ErrorColor='\033[38;5;11m\033[48;5;9m'
  DateAndTimeColor='\033[0m\033[38;5;15m'
  DurationColor='\033[38;5;15m\033[48;5;5m'

  # date and time
  dateAndTime=""
  if [ $(tput cols) -gt 80 ]; then
    # only add the data/time if there are more than 80 columns
    dateAndTime="$DateAndTimeColor $(date +"%a %F  %r")"
  fi

  # exit code
  exitCode="$(get_exit_text)"
  exitCodeAndColor="$ErrorColor Error $exitCode "
  if [[ ${EXIT} == 0 ]]; then
      exitCodeAndColor="$OkColor OK "
  fi

  # duration
  durationTimer+="$DurationColor Dur $timer_show "

  # final output
  echo -e "$exitCodeAndColor$durationTimer$dateAndTime"
}

# -------- CREATE THE LEFT SIDE OF THE COMMAND PROMPT
function prompt_left() {
  # get the ip-address and user name
  hostname="$(hostname -I | cut -d " " -f1)"
  username="root"
  vLine=$'\u2502'

  # create output
  dude="\[\e[00m\]"
  dude+="\033[38;5;11m$hostname"
  dude+="\[\e[00m\] $vLine"
  dude+="\033[38;5;15m\033[48;5;9m $username \[\e[00m\]$vLine "
  dude+="\033[38;5;10m$(pwd)\033[0m"

  # final output
  echo -e "$dude"
}

# -------- REQUIRED FOR THE UBUNTU LOGIN HACK
export FIRSTTIMEERROR=1

# -------- CREATE THE COMMAND PROMPT
function prompt() {
    # this must be the first thing executed
    EXIT=${PIPESTATUS[-1]}

    # this is a hack that will display ok until any other exit result is produced
    #    ubuntu 22.04 seems to generate a ( 1 ) error when first logged in
    #    this is most likely caused by a configuration issue... but this works too
    if [ "$FIRSTTIMEERROR" -eq 1 ] && [ $EXIT -eq 1 ]; then
        EXIT=0
    else
        export FIRSTTIMEERROR=0
    fi

    # stop the duration timer
    timer_stop

    # get prompts and calculate values
    compensate=50
    if [ $(tput cols) -le 80 ]; then
        compensate=36
    fi
    p_left=$(prompt_left)
    p_right=$(prompt_right)
    p_right_len=$(expr $(expr length "$p_right") - $compensate)

    # set the prompt
    width=$(tput cols)
    len=$(expr $width - $p_right_len)
    ch=$'\u2550'
    ch2=$'\u255E'
    line=$(printf "%0.s$ch" $(seq 1 $len))$'\u2561'
    PS1="\n$line $p_right\r$p_left $ch2\n# "
}

# --------------------------------
trap 'timer_start' DEBUG
PROMPT_COMMAND=prompt