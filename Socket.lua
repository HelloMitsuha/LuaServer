require "import"
require "stringpro"
import "java.net.*"
import "java.io.*"

--Author:Dream

OutUtil=setmetatable({},{__call=function() return OutUtil end})

OutUtil.setOutput=function(o)
  OutUtil.Output=o
  return OutUtil
end

OutUtil.sendText=function(t)
  local o=OutUtil.Output
  o.write(String(t).getBytes())
  o.flush()
  o.close()
  return OutUtil
end

HTTPUtil=setmetatable({},{__call=function()HTTPUtil.Code="200" HTTPUtil.Type="text/html" return HTTPUtil end})

--设置状态码
HTTPUtil.setCode=function(c)
  HTTPUtil.Code=c
  return HTTPUtil
end

--设置输出
HTTPUtil.setOutput=function(o)
  HTTPUtil.Output=o
  return HTTPUtil
end

--设置类型(少用)
HTTPUtil.setType=function(t)
  HTTPUtil.Type=t
  return HTTPUtil
end

--向客户端返回一个文本
HTTPUtil.sendText=function(t)
  local o=HTTPUtil.Output
  o.write(String("HTTP/1.1 "..HTTPUtil.Code.." OK\nContent-Type: text/html\n\n"..t).getBytes())
  o.flush()
  o.close()
  return HTTPUtil
end

--向客户端返回一个Json文本
HTTPUtil.sendJson=function(t)
  local o=HTTPUtil.Output
  o.write(String("HTTP/1.1 "..HTTPUtil.Code.." OK\nContent-Type: application/json\n\n"..t).getBytes())
  o.flush()
  o.close()
  return HTTPUtil
end

--向客户端返回一个文件的文本，类型会自己判断
HTTPUtil.sendFile=function(p)
  local o=HTTPUtil.Output--输出
  local name=File(p).getName()--文件名
  local file,c_type
  local t=""
  local readf,def=true,false--是否输出文件内容，是否不使用Content-Type
  --读取并输出文件内容
  local ofile=function(p)
    xpcall(function()
      local fis=FileInputStream(p)
      local b=byte[1024]
      while true
        local n=fis.read(b)
        when n==-1 break
        o.write(b,0,n)
      end
      fis.close()
    end,function(e)print("写出数据失败，文件:"..p)end)
  end
  --执行Lua文件
  if name:find(".lua")
    def=true
    local aprint=print
    function print(...)
      for k,v pairs({...})
        t=t.."\n"..v
      end
    end
    xpcall(loadfile(p),function(e)
      t=""
      xpcall(function()
        def=false
        file="text/html"
        print(io.open(p,"r"):read("*a"):gsub2("<%?Lua(.-)%?>",function(code)
          xpcall(load(code),function(e)print("\n脚本错误:"..e)end)
        end))
      end,function(e2)
        print("\n脚本错误:"..e2.."\n"..e)
      end)
    end)
    print=aprint
    readf=false--不输出文件内容
    --以下均需要输出文件内容
   elseif name:find(".html")
    file="text/html"
   elseif name:find(".js")
    file="application/javascript"
   elseif name:find(".css")
    file="text/css"
   elseif name:find(".jpg") or name:find(".jpeg") or name:find(".png") or name:find(".ico")
    file="image/jpeg"
   elseif name:find(".gif")
    file="image/gif"
   else
    file="application/octet-stream"
  end
  --设置Content-Type
  if def c_type="" else c_type="Content-Type: "..file.."\n" end
  --输出响应
  o.write(String("HTTP/1.1 "..HTTPUtil.Code.." OK\n"..c_type.."\n"..t).getBytes())
  --写入缓冲
  o.flush()
  --输出文件内容，在某些文件不需要输出
  if readf ofile(p) end
  --关闭输出流，客户端完成接收
  o.close()
  return HTTPUtil
end

--向客户端返回一个自定义类型的内容
HTTPUtil.send=function(t)
  local o=HTTPUtil.Output
  o.write(String("HTTP/1.1 "..HTTPUtil.Code.." OK\nContent-Type: "..HTTPUtil.Type.."\n\n"..t).getBytes())
  o.flush()
  o.close()
  return HTTPUtil
end

--伪服务器部分

--开一个新线程以供伪服务器运行，防止卡UI
function HTTPServer(端口,工作路径,你干嘛)
  return table.unpack(({xpcall(function()
      local ss=ServerSocket(端口)--启用端口
      return {thread(function(端口,工作路径,你干嘛,ss)
          xpcall(function()
            require "import"
            require "stringpro"
            import "java.net.*"
            import "java.io.*"
            while true do
              local s=ss.accept()--等待响应请求
              local is=s.getInputStream()--获取输入流
              local isr=InputStreamReader(is,"UTF-8")
              local br=BufferedReader(isr)
              local info={}
              while true do
                local l=br.readLine()--读取一行
                if l=="" then break end
                table.insert(info,string.urldecode(l))
              end
              local infos=table.concat(info,"\n")
              local i={}
              --请求头转table
              for k,v in pairs(luajava.astable(String(infos).split("\n"))) do
                local 键=string.match(v,"(.-):")
                if 键 then
                  i[键]=string.match(v,":(.+)")
                 else
                  --请求类型
                  i["_TYPE"]=string.match(v,"(.-) /")
                  --请求路径
                  i["_URL"]="/"..string.match(v," /(.-) HTTP")
                  local _GET=string.match(i["_URL"],"?(.+)")
                  i["_URL"]=string.match(i["_URL"],"(.+)?") or i["_URL"]
                  --获取GET请求的文本
                  i["_GET"]={}
                  if _GET then
                    --转换table
                    for k,v in pairs(luajava.astable(String(_GET).split("&"))) do
                      i["_GET"][string.match(v,"(.-)=")]=string.match(v,"=(.+)")
                    end
                  end
                end
              end
              你干嘛(i,工作路径,s.getOutputStream())--回调
            end
            --s.shutdownInput()
            --s.close()
          end,function(e)if !e:find("java.net.SocketException") print("错误："..e) ss.close() end end)
        end,端口,工作路径,你干嘛,ss),ss}
    end,function(e)if e:find("java.net.BindException") print("启动失败：端口已被使用") end end)})[2] or {nil,nil})
end

--纯TCP
function TCPServer(端口,你干嘛)
  return table.unpack(({xpcall(function()
      local ss=ServerSocket(端口)--启用端口
      return {thread(function(端口,你干嘛,ss)
          xpcall(function()
            require "import"
            require "stringpro"
            import "java.net.*"
            import "java.io.*"
            while true do
              local s=ss.accept()--等待响应请求
              local is=s.getInputStream()--获取输入流
              local isr=InputStreamReader(is,"UTF-8")
              local br=BufferedReader(isr)
              local info={}
              while true do
                local l=br.readLine()--读取一行
                if l=="" or !l then break end
                table.insert(info,l)
              end
              local infos=table.concat(info,"\n")
              你干嘛(infos,s.getOutputStream())--回调
            end
            --s.shutdownInput()
            --s.close()
          end,function(e)if !e:find("java.net.SocketException") print("错误："..e) ss.close() end end)
        end,端口,你干嘛,ss),ss}
    end,function(e)if e:find("java.net.BindException") print("启动失败：端口已被使用") end end)})[2] or {nil,nil})
end
