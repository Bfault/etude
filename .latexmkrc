$pdf_mode = 4;
# $out_dir = '';
$aux_dir = 'build';

$latex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';

$clean_ext = join(' ',
    qw(
        aux bbl blg brf idx ilg ind lof log lot out toc
        fls fdb_latexmk synctex.gz
        nav snm vrb
        acn acr alg glg glo gls ist
        dvi ps
    )
);

warn "=== LaTeXMKRC settings load ===\n";