$pdf_mode = 4;
$recorder = 1;
$max_repeat = 3;
$bibtex_use = 2;

$clean_ext = join(' ',
    qw(
        aux bbl blg brf idx ilg ind lof log lot out toc
        fls fdb_latexmk synctex.gz
        nav snm vrb
        acn acr alg glg glo gls ist
        dvi ps
    )
);

warn "=== LaTeXMKRC settings loaded ===\n";