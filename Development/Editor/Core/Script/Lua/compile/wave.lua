require "sys"
require "filesystem"
require "util"

wave = {}
wave.path                = fs.ydwe_path() / "plugin" / "wave"
wave.exe_path            = wave.path / "Wave.exe"
wave.sys_include_path    = wave.path / "include"
wave.plugin_include_path = fs.ydwe_path() / "plugin"
wave.jass_include_path   = fs.ydwe_path() / "jass"
wave.force_file_path     = wave.sys_include_path / "WaveForce.i"

-- 预处理代码
-- op.input - 输入文件路径
-- op.option - 预处理选项，table，支持的值有
-- 	runtime_version - 表示魔兽版本
-- 	enable_jasshelper_debug - 布尔值，是否是调试模式
--	enable_yd_trigger - 布尔值，是否启用YD触发器
-- 返回：number, info, path - 子进程返回值；预处理输出信息；输出文件路径
function wave:do_compile(op)
	local cmd = ''
	cmd = cmd .. '--autooutput '
	cmd = cmd .. string.format('--sysinclude="%s" ', self.sys_include_path:string())
	cmd = cmd .. string.format('--sysinclude="%s" ', self.plugin_include_path:string())
	cmd = cmd .. string.format('--include="%s" ',    self.jass_include_path:string())
	cmd = cmd .. string.format('--define=WARCRAFT_VERSION=%d ', 100 * op.option.runtime_version.major + op.option.runtime_version.minor)
	cmd = cmd .. string.format('--define=YDWE_VERSION_STRING=\\"%s\\" ', tostring(ydwe_version))
	if op.option.enable_jasshelper_debug then
		cmd = cmd .. '--define=DEBUG=1 '
	end
	if global_config:get_integer("ScriptInjection.Option", 0) == 0 then
		cmd = cmd .. "--define=SCRIPT_INJECTION=1 "
	end
	if not op.option.enable_yd_trigger then
		cmd = cmd .. '--define=DISABLE_YDTRIGGER=1 '
	end
	if fs.exists(self.force_file_path) then
		cmd = cmd .. string.format('--forceinclude=%s ', self.force_file_path:filename():string())
	end
	cmd = cmd .. "--extended --c99 --preserve=2 --line=0 "

	local command_line = string.format('"%s" %s "%s"', self.exe_path:string(), cmd, op.input:string())
	-- 启动进程
	local proc, out_rd, err_rd, in_wr = sys.spawn_pipe(command_line, nil)
	if proc then
		local out = out_rd:read("*a")
		local err = err_rd:read("*a")
		local exit_code = proc:wait()
		proc:close()
		proc = nil
		return exit_code, out, err
	else
		return -1, nil, nil
	end
end

function wave:compile(op)
	log.trace("Wave compilation start.")		
	
	local map_script_file = io.open(op.input:string(), "a+b")
	if map_script_file then
		map_script_file:write("/**/\r\n")
		map_script_file:close()
	end
	
	-- 输出路径
	op.output = op.input:parent_path() / (op.input:stem():string() .. ".i")
	
	local exit_code, out, err = self:do_compile(op)
	
	-- 退出码0代表成功
	if exit_code ~= 0 then
		if out and err then
			local message = string.format(_("Preprocessor failed with message:\nstdout:%s\nstderr: %s"), out, err)
			gui.message_dialog(nil, message, _("Error"), bit32.bor(gui.MB_ICONERROR, gui.MB_OK))
		else
			gui.message_dialog(nil, _("Cannot start preprocessor process."), _("Error"), bit32.bor(gui.MB_ICONERROR, gui.MB_OK))
		end
		return false
	end

	return true
end
