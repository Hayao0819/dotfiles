" set up the dein.vim directory
let s:dein_dir = expand('~/.nvim/')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
let g:rc_dir = expand('~/.vim')

" automatic installation of dein.vim
if !isdirectory(s:dein_repo_dir)
    execute '!git clone <https://github.com/Shougo/dein.vim>' s:dein_repo_dir
endif
execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')

if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    " load the file which contain the plugin list
    let s:toml      = g:rc_dir . '/dein.toml'
    let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

    call dein#load_toml(s:toml, {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif

" automatically install any plug-ins that need to be installed.
if dein#check_install()
    call dein#install()
endif
