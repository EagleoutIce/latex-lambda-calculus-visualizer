-- Loaded by build.lua, not part of the release.

-- l3build's own '--dry-run' is not offline: it only skips the second POST, the
-- archive is still sent to CTAN's validate endpoint (and '--debug' posts it to
-- httpbin.org). The 'curl_debug' switch that would suppress this is a local
-- captured before build.lua is read, so it cannot be set from here. Instead we
-- wrap 'upload': under '--dry-run' we build the very same curl request, which
-- runs all of l3build's field validation and writes the .curlopt file, and
-- print it rather than send it. A plain 'l3build upload' is left untouched.
-- Note that redefining the global 'upload' is not enough: 'l3build-stdmain'
-- captures the function into 'target_list' before build.lua is read, so the
-- entry in that table has to be replaced as well.
local l3build_upload = target_list.upload.func
function upload(tagnames)
  if not options["dry-run"] then
    return l3build_upload(tagnames)
  end
  local uploadfile = ctanzip .. ".zip"
  if not fileexists(uploadfile) then
    error("Missing zip file '" .. uploadfile .. "'. \z
      Maybe you forgot to run 'l3build ctan' first?")
  end
  -- the same fields 'upload()' fills in before it validates
  uploadconfig.announcement = options["message"] or uploadconfig.announcement
    or file_contents(uploadconfig.announcement_file)
  uploadconfig.note = uploadconfig.note or file_contents(uploadconfig.note_file)
  uploadconfig.email = options["email"] or uploadconfig.email
  uploadconfig.version = (tagnames or {})[1] or uploadconfig.version
  print("Dry run: validating locally, nothing is sent to CTAN.")
  local request = construct_ctan_post(uploadfile)
  print("Would have posted:")
  print(request .. "https://ctan.org/submit/validate")
  print("Dry run finished, no request was sent.")
  return 0
end
target_list.upload.func = upload

-- The version a package declares, so that 'l3build upload' needs no argument
-- and each package is uploaded with its own version.
function package_version(file, pattern)
  local input = assert(io.open(file, "r"))
  local content = input:read("a")
  input:close()
  return assert(string.match(content, pattern), "no version found in " .. file)
end
