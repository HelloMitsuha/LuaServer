--string辅助类
function string.gsub2(...)
  return ({string.gsub(...)})[1]
end

function string.urlencode(s)
  return string.gsub(string.gsub(s, "([^%w%.%- ])", function(c)
    return string.format("%%%02X", string.byte(c)) end), " ", "+")
end

function string.urldecode(s)
  return string.gsub2(s, '%%(%x%x)', function(h)
    return string.char(tonumber(h, 16)) end)
end

function string.get(a,b)
  while b>1 do
    a=a:match(".(.*)")
    b=b-1
  end
  return a:match(".")
end

function string.tochar(v)
  v=tostring(v)
  local abc=""
  for i=1,#v do
    abc=abc..string.byte(string.get(v,i))..","
  end
  return string.gsub2(abc.."114514",",114514","")
end

function string.insert(a)
  return a:gsub2("",string.char(239))
end

function string.uninsert(a)
  return a:gsub2(string.char(239),"")
end

function string.move(v,偏移量)
  v=tostring(v)
  local abc=""
  for i=1,#v do
    abc=abc..string.char(string.byte(string.get(v,i))+偏移量)
  end
  return abc
end
