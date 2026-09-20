#!/bin/sh
# Writes bench/bench-results.tex, one pdfTeX run per case of bench/cases.txt.
# LC_BENCH_RUNS sets how often a case is timed (default 5).
set -eu
cd "$(dirname "$0")/.."

runs=${LC_BENCH_RUNS:-5}
pool_size=${pool_size:-60000000}
max_strings=${max_strings:-6000000}
hash_extra=${hash_extra:-6000000}
# main_memory sits in the format, only these two grow it at run time
extra_mem_top=${extra_mem_top:-40000000}
extra_mem_bot=${extra_mem_bot:-40000000}
export pool_size max_strings hash_extra extra_mem_top extra_mem_bot
out=bench/bench-results.tex
rows=bench/rows.tmp

cases=$(grep -cve '^#' -e '^$' bench/cases.txt)
: > "$rows"
i=0
while [ "$i" -lt "$cases" ]; do
   i=$((i + 1))
   if ! pdflatex -interaction=nonstopmode -halt-on-error -output-directory=bench \
      -jobname=measure \
      "\\def\\lcbenchruns{$runs}\\def\\lcbenchonly{$i}\\input{bench/measure.tex}" \
      > bench/measure.out 2>&1
   then
      echo "bench: case $i failed, last lines of bench/measure.log:" >&2
      tail -n 40 bench/measure.log >&2 || tail -n 40 bench/measure.out >&2
      exit 1
   fi
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
rm -f "$rows" bench/measure.out bench/bench-row.tex bench/lc-bench-*.tex
echo "wrote $out"
