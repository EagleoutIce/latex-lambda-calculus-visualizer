-- l3build configuration for lc-visualizer
module = "lc-visualizer"
dofile("build-upload.lua")

-- sources and documentation
sourcefiles  = {"lc-visualizer.sty"}
installfiles = {"lc-visualizer.sty"}
unpackfiles  = {}
tdsroot      = "latex"
packtdszip   = false
docfiles     = {"visualizer-doc.tex", "example.tex"}
typesetfiles = {"visualizer-doc.tex"}
typesetopts  = "-shell-escape -interaction=nonstopmode"
-- the index is a plain makeindex index, not the one of the doc package
indexstyle   = ""
textfiles    = {"README.md", "LICENSE"}

-- the manual is typeset with xlistings (git submodule) and shows the table of
-- bench/run.sh, neither is part of the release
function docinit_hook()
  if not fileexists("xlistings/xlistings.sty") then
    error("xlistings is missing: run 'git submodule update --init'")
  end
  cp("xlistings.sty", "xlistings", typesetdir)
  cp("xlistings-*.cfg", "xlistings/langs", typesetdir)
  mkdir(typesetdir .. "/bench")
  cp("bench-results.tex", "bench", typesetdir .. "/bench")
  return 0
end

-- version bookkeeping: 'l3build tag <version>' rewrites the package
-- identification; the manual reads version and date from the package
tagfiles = {"lc-visualizer.sty"}

function update_tag(file, content, tagname, tagdate)
  if string.match(file, "%.sty$") then
    return string.gsub(content,
      "\\ProvidesPackage{lc%-visualizer}%[%d%d%d%d/%d%d/%d%d v%S+",
      "\\ProvidesPackage{lc-visualizer}[" .. string.gsub(tagdate, "%-", "/")
        .. " v" .. string.gsub(tagname, "^v", ""), 1)
  end
  return content
end

-- tests
testfiledir  = "tests"
testsuppdir  = testfiledir .. "/support"
checkengines = {"pdftex"}
stdengine    = "pdftex"
checkruns    = 2

-- metadata for 'l3build upload'; ctanPath only applies to the first upload,
-- afterwards CTAN keeps the package where it put it
uploadconfig = {
  pkg               = "lc-visualizer",
  -- 'l3build upload <version>' overrides this
  version           = package_version("lc-visualizer.sty",
                        "\\ProvidesPackage{lc%-visualizer}%[%d%d%d%d/%d%d/%d%d v(%S+)"),
  author            = "Florian Sihler",
  uploader          = "Florian Sihler",
  email             = "florian.sihler@uni-ulm.de",
  license           = "mit",
  summary           = "Visualize and reduce lambda calculus terms",
  ctanPath          = "/graphics/pgf/contrib/lc-visualizer",
  repository        = "https://github.com/EagleoutIce/latex-lambda-calculus-visualizer",
  bugtracker        = "https://github.com/EagleoutIce/latex-lambda-calculus-visualizer/issues",
  support           = "https://github.com/EagleoutIce/latex-lambda-calculus-visualizer/issues",
  home              = "https://github.com/EagleoutIce/latex-lambda-calculus-visualizer",
  topic             = {"pgf-tikz", "logic"},
  update            = false,
  announcement_file = "ctan-announce.txt",
  note_file         = "ctan-note.txt",
  description       = [[
The lc-visualizer package typesets terms of the untyped lambda calculus with
TikZ. Each abstraction gets a color, and the variables it binds as well as the
range of its body are highlighted in that color. Terms can be reduced
automatically, with alpha and eta conversions, beta reductions and the
unfolding of user-defined rewriting rules, and every step of a reduction can be
shown. Terms can also be typeset with de Bruijn indices.]],
}

cleanfiles = {module .. "-ctan.curlopt", module .. "-ctan.zip"}
