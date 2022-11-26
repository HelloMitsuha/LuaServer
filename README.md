## LuaServer
一个基于AndroLua的简易伪服务器实现，支持执行Lua脚本和输出简单的静态页面资源
### 原理
通过创建ServerSocket以获取客户端的消息，然后用其输出流向客户端返回数据.
### 一些问题
* 不支持php，因为没有可用的解析器或者对接
* 下载文件会报未知错误(ADM)，但是已经下载好了，不需要管
* 可能掉线
### 如果你有更好的建议，欢迎在[Issues](https://github.com/HelloMitsuha/LuaServer/issues)中提出
