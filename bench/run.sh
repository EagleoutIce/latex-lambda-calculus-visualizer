#!/bin/sh
# Writes bench/bench-results.tex, one pdfTeX run per case of bench/cases.txt.
# LC_BENCH_RUNS sets how often a case is timed (default 5).
set -eu
cd "$(dirname "$0")/.."

runs=${LC_BENCH_RUNS:-5}
pool_size=${pool_size:-60000000}
max_strings=${max_strings:-6000000}
hash_extra=${hash_extra:-6000000}
export pool_size max_strings hash_extra
out=bench/bench-results.tex
rows=bench/rows.tmp

cases=$(grep -cve '^#' -e '^$' bench/cases.txt)
: > "$rows"
i=0
while [ "$i" -lt "$cases" ]; do
   i=$((i + 1))
   pdflatex -interaction=nonstopmode -halt-on-error -output-directory=bench \
      -jobname=measure \
      "\\def\\lcbenchruns{$runs}\\def\\lcbenchonly{$i}\\input{bench/measure.tex}" \
      > /dev/null
   cat bench/bench-row.tex >> "$rows"
done

{
   echo '% written by bench/run.sh, do not edit'
   echo '\begin{tabular}{@{}lrrrrrr@{}}'
   echo '   \toprule'
   echo '   \textbf{Term} & \textbf{Rows} & \textbf{Reduce} & \textbf{Typeset} & \textbf{Min} & \textbf{Max} & \textbf{Cached} \\'
   echo '   \midrule'
   cat "$rows"
   echo '   \bottomrule'
   echo '\end{tabular}'
} > "$out.new"
mv "$out.new" "$out"
rm -f "$rows" bench/bench-row.tex bench/lc-bench-*.tex
echo "wrote $out"
