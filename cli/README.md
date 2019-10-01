
For neovim/vim plugins.

Because of the use of submodules for neovim/vim plugins this repository should be clone recursively to use the plugins.

Using pathogen plugins are installed by cloning a git repository to the bundle directory in the neovim/vim configuarion. To include these plugins in git they must be added as sobmodules.   This can be done with `git submodle add '/absolute/path/bundle/plugin-name'`.vim 

If git add is called on the entire git repository before this is done, only the folders will be added and not their contents. If this happens then a submodule may not be directly added ebecause it will conflict with the existing empty directory. To fix that the empty folder must be removed from the git cach, this can be done with `git rm --cached '/path/to/plugin-name.vim'`. After the cached folder is remove the submodule may be added with the first commadn.
