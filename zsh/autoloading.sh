lazy_load() {
    # Act as a stub to another shell function/command. When first run, it will load the actual function/command then execute it.
    # E.g. This made my zsh load 0.8 seconds faster by loading `nvm` when "nvm", "npm" or "node" is used for the first time
    # $1: space separated list of alias to release after the first load
    # $2: file to source
    # $3: name of the command to run after it's loaded
    # $4+: argv to be passed to $3
    echo "Lazy loading $1 ..."

    # $1.split(' ') using the s flag. In bash, this can be simply ($1) #http://unix.stackexchange.com/questions/28854/list-elements-with-spaces-in-zsh
    # Single line won't work: local names=("${(@s: :)${1}}"). Due to http://stackoverflow.com/questions/14917501/local-arrays-in-zsh   (zsh 5.0.8 (x86_64-apple-darwin15.0))
    local -a names
    if [[ -n "$ZSH_VERSION" ]]; then
        names=("${(@s: :)${1}}")
    else
        names=($1)
    fi
    unalias "${names[@]}"
    . $2
    shift 2
    $*
}

group_lazy_load() {
    local script
    script=$1
    shift 1
    for cmd in "$@"; do
        alias $cmd="lazy_load \"$*\" $script $cmd"
    done
}

platform='unknown'
unamestr=`uname`

if [[ "$unamestr" == 'Linux' ]]; then
	platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
	platform='freebsd'
elif [[ "$unamestr" == 'Darwin' ]]; then
	platform='osx'
fi


#########
#  NVM  #
#########
export NVM_DIR=~/.nvm
if [[ $platform == 'osx' ]]; then
	group_lazy_load $HOME/.nvm/nvm.sh nvm node npm npx gulp vue yarn flow react-native node-debug node-inspector lock git-cz react-devtools web-ext importjs svgo gatsby now
else
	. $HOME/.nvm/nvm.sh
fi

##########
#  ruby  #
##########
if [[ $platform == 'osx' ]]; then
	# OSX has a default ruby
	group_lazy_load $ZSHA_BASE/autoloads/rbenv.sh rbenv ruby rails irb cap rake bundle sidekiq foreman
else
	. $ZSHA_BASE/autoloads/rbenv.sh
fi


#################
#  php-version  #
#################

if [ -f "$HOME/.asdf/asdf.sh" ]; then
	group_lazy_load $HOME/.asdf/asdf.sh php wp unyson-testing wordpress-drop wordpress-empty psysh
else
	group_lazy_load $ZSHA_BASE/autoloads/php-version.sh php-version php wp unyson-testing wordpress-drop wordpress-empty psysh
fi



