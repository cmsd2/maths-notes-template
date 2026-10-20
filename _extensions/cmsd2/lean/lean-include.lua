--- lean-include.lua: fill code blocks from source files, by line range or
--- by named snippet.
---
---   ```{.lean include="/lean/MyProject/Basic.lean" snippet="affine"}
---   ```
---
--- A path starting with "/" is relative to the Quarto project root (as with
--- Quarto's own {{< include >}}); any other path is relative to the document.
--- A snippet is the lines between "start snippet NAME" and "end snippet NAME"
--- marker comments; the comment syntax is worked out from the file extension.
--- Other attributes: start-line, end-line, dedent (strip N leading spaces).
---
--- Unlike a silent include, a missing file or snippet stops the render, so
--- a renamed Lean declaration can't leave a note quietly showing the wrong code.
---
--- Attribute names follow quarto-ext/include-code-files (MIT, Bruno Beaufils),
--- so existing documents work unchanged.

local COMMENT = {
  lean = "%-%-", lua = "%-%-", hs = "%-%-", sql = "%-%-",
  py = "#", r = "#", jl = "#", sh = "#", toml = "#", yml = "#", yaml = "#",
  js = "//", mjs = "//", ts = "//", c = "//", h = "//", cpp = "//",
  rs = "//", go = "//", java = "//", css = "/%*",
  tex = "%%", sty = "%%", m = "%%", mac = "/%*",
}

local function fail(msg)
  quarto.log.error("lean-include: " .. msg)
  error("lean-include: " .. msg, 0)
end

local function resolve(path)
  if path:sub(1, 1) ~= "/" then
    return path
  end
  local root = quarto.project.directory
  if not root then
    fail("'" .. path .. "' is project-relative, but this document is not in a Quarto project")
  end
  return pandoc.path.normalize(pandoc.path.join({ root, path:sub(2) }))
end

local function read_lines(path)
  local fh = io.open(path, "r")
  if not fh then
    fail("cannot open '" .. path .. "'")
  end
  local lines = {}
  for line in fh:lines() do
    lines[#lines + 1] = (line:gsub("\r$", ""))
  end
  fh:close()
  return lines
end

local function snippet_range(lines, path, name)
  local ext = (path:match("%.([%w]+)$") or ""):lower()
  local c = COMMENT[ext] or "%W%W?"
  local quoted = name:gsub("%p", "%%%0")
  local p_start = "^%s*" .. c .. "%s*start snippet " .. quoted .. "%s*"
  local p_end = "^%s*" .. c .. "%s*end snippet " .. quoted .. "%s*"
  local first, last
  for i, line in ipairs(lines) do
    if not first then
      if line:match(p_start) then first = i + 1 end
    elseif line:match(p_end) then
      last = i - 1
      break
    end
  end
  if not first or not last then
    fail("no snippet '" .. name .. "' in '" .. path .. "'")
  end
  return first, last
end

local function take(cb, name)
  local v = cb.attributes[name]
  cb.attributes[name] = nil
  return v
end

local function transclude(cb)
  local include = take(cb, "include")
  if not include then
    return nil
  end
  local path = resolve(include)
  local lines = read_lines(path)

  local snippet = take(cb, "snippet")
  local first = tonumber(take(cb, "start-line") or take(cb, "startLine")) or 1
  local last = tonumber(take(cb, "end-line") or take(cb, "endLine")) or #lines
  if snippet then
    first, last = snippet_range(lines, path, snippet)
  end
  local dedent = tonumber(take(cb, "dedent")) or 0

  local out = {}
  for i = first, last do
    local line = lines[i]
    if dedent > 0 then
      line = line:sub(1, dedent):gsub("^ +", "") .. line:sub(dedent + 1)
    end
    out[#out + 1] = line
  end
  if first > 1 then
    cb.attributes.startFrom = tostring(first)
  end
  return pandoc.CodeBlock(table.concat(out, "\n"), cb.attr)
end

return {
  { CodeBlock = transclude },
}
