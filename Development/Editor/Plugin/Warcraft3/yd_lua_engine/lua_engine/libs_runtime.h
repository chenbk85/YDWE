#pragma once

#include <base/lua/state.h>

namespace base { namespace warcraft3 { namespace lua_engine {
	namespace runtime
	{
		extern int handle_level;
		extern bool sleep;
		extern bool catch_crash;

		void initialize();

		int get_err_function(lua::state* ls);

		int thread_create(lua::state* ls, int index);
		int thread_save(lua::state* ls, int key, int value);

		int handle_ud_get_table(lua::state* ls);

		int callback_push(lua::state* ls, int idx);
		int callback_read(lua::state* ls, int ref);
	}
}}}
