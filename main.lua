require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
require "stringpro"
require "cjson"

activity.setTheme(R.deep)

local _ENV_print=print

function print(...)
  return _ENV_print(os.date("\n%H：%M：%S "),...)
end

_ENV_print("\nAuthor：Dream 暂不支持php\n\n下载文件还有点问题，ADM会提示未知错误，忽略即可\n")

require "Socket"

function 读(k)
  return activity.getSharedData(k)
end

function 写(k,v)
  activity.setSharedData(k,v)
end

function 停止()
  if 开
    print("服务器已停止")
    pcall(function()
      s.close()--关闭Socket
      t.quit()--退出线程
      ts.close()--关闭Socket
      tt.quit()--退出线程
    end)
    开=false
  end
end

function 启动()
  if !开
    print("服务器已启动")
    --返回一个线程和Socket
    tt,ts=TCPServer(5900,function(info,output)
      print("TCP:"..info)
      OutUtil()
      .setOutput(output)
      .sendText("操你妈")
    end)
    t,s=HTTPServer(tointeger(读("LS+端口")),读("LS+工作路径"),
    function(header,path,output)--请求头，工作路径，OutputStream
      --print(dump(luajava.astable(header)))
      print("HTTP:请求链接："..header._URL.."\n\n方法："..header._TYPE)
      local 请求资源=header._URL
      local 路径=path..请求资源
      if File(路径).isFile()--文件
        HTTPUtil()
        .setCode("200")
        .setOutput(output)
        .sendFile(路径)--输出文件，自带类型判断
       elseif File(路径).isDirectory()--文件夹
        if File(路径.."index.html").isFile()--优先查看index.html
          HTTPUtil()
          .setCode("200")
          .setOutput(output)
          .sendFile(路径.."index.html")
         elseif File(路径.."index.lua").isFile()
          HTTPUtil()
          .setCode("200")
          .setOutput(output)
          .sendFile(路径.."index.lua")
         else--没有index.lua和index.html
          HTTPUtil()
          .setCode("404")
          .setOutput(output)
          .sendText("抱歉，页面不存在~".."\n你访问的资源是:"..请求资源)
        end
       else--文件不存在
        HTTPUtil()
        .setCode("404")
        .setOutput(output)
        .sendText("抱歉，页面不存在~".."\n你访问的资源是:"..请求资源)
      end
    end)
    开=true
  end
end

function onDestroy()
  停止()
end

if 读("LS+工作路径") 启动() else print("请设置工作路径和端口") 写("端口","8080") end

function onOptionsItemSelected(item)
  local choice=item.Title
  switch choice
   case "重启"
    pcall(function()
      s.close()--关闭Socket
      t.quit()--退出线程
      ts.close()--关闭Socket
      tt.quit()--退出线程
    end)
    Thread.sleep(10)
    activity.recreate()
   case "启动"
    启动()
   case "停止"
    停止()
   case "工作路径"
    AlertDialog.Builder(this)
    .setTitle("设置工作路径")
    .setView(loadlayout({
      EditText;
      hint="路径";
      layout_width="match_parent";
      id="edit";
    }))
    .setPositiveButton("确定",{onClick=function(v)
        写("LS+工作路径",edit.Text)
      end})
    .setNegativeButton("取消",nil)
    .create()
    .show()
    edit.Text=读("LS+工作路径") or ""
   case "端口"
    AlertDialog.Builder(this)
    .setTitle("设置端口")
    .setView(loadlayout({
      EditText;
      hint="端口";
      layout_width="match_parent";
      id="edit";
    }))
    .setPositiveButton("确定",{onClick=function(v)
        写("LS+端口",edit.Text)
      end})
    .setNegativeButton("取消",nil)
    .create()
    .show()
    edit.Text=读("LS+端口") or ""
   case "关于"
    AlertDialog.Builder(this)
    .setTitle("关于")
    .setMessage("本软件仅供学习使用，无实际意义\n\n可以配合内网穿透实现真正意义上的\"服务器\"\n\n本软件基本原理是ServerSocket")
    .setNegativeButton("关闭",nil)
    .create()
    .show()
  end
end

function onCreateOptionsMenu(menu)
  import "android.graphics.drawable.BitmapDrawable"
  loadmenu(menu,{
    {
      MenuItem;
      title="重启";
    };
    {
      MenuItem;
      title="启动";
    };
    {
      MenuItem;
      title="停止";
    };
  },{},4)
  menu.add("工作路径")
  menu.add("端口")
  menu.add("关于")
end
