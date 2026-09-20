@default_files = ('example.tex', 'visualizer-doc.tex');
$pdf_mode = 1;
$pdf_update_method = 1;
$out_dir = 'build';
$postscript_mode = 0;
$max_repeat = 8; # index, hyperref and the tikz marks need a few rounds from cold
$dvi_mode = 0;
$pdflatex = 'pdflatex %O -shell-escape %S';ensure_path('TEXINPUTS', './xlistings//');
