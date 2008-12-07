" vim: ts=4 shiftwidth=4 expandtab fdm=marker
" author: tocer tocer.deng@gmail.com
" version: 0.5
" lastchange: 2008-12-07



if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif
if exists("g:loaded_pyjumper")
    finish
endif

let g:loaded_pyjumper=1
set includeexpr=ImportModule(v:fname)

noremap gf           gf:silent normal <C-R>=GoSomewhere()<cr><cr>
noremap <C-W>f       <C-W>f:silent normal <C-R>=GoSomewhere()<cr><cr>
noremap <C-W><C-F>   <C-W><C-F>:silent normal <C-R>=GoSomewhere()<cr><cr>
noremap <C-W>gf      <C-W>gf:silent normal <C-R>=GoSomewhere()<cr><cr>

function GoSomewhere()
    return s:jump_cmd
endfunction

function ImportModule(modname)
    execute "py pyjumper.jump('" . a:modname . "')"
    return s:filename
endfunction

" the following is python code {{{
python << END

import vim
import inspect

class PyJumper(object):
    def importmod(self, modname):
        modlist = modname.split('.')
        _modname = modlist[0]
        mod = __import__(_modname, {})
        if len(modlist) > 1:
            for m in modlist[1:]:
                if hasattr(mod, m):
                    mod = getattr(mod, m)
                else:
                    break
        return mod

    def locate(self, mod):
        fname = inspect.getsourcefile(mod)
        _, linenum = inspect.getsourcelines(mod)
        return fname, linenum

    def jump(self, modname):
        try:
            mod = self.importmod(modname)
            fname, linenum = self.locate(mod)
            if fname:
                jump_cmd = str(linenum+1) + 'Gzz'
            vim.command("let s:filename='%s'" % fname)
            vim.command("let s:jump_cmd='%dGzz'" % (linenum+1))
        except:
            vim.command("let s:filename='%s'" % modname)
            vim.command("let s:jump_cmd=''")

pyjumper = PyJumper()

END
" }}}
