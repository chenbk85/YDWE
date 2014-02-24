#pragma once

#include <string>
#include <base/config.h>
#include <base/util/string_ref.h>
#include <cstdint>

namespace base { namespace util {
	class conv_method
	{
	public:
		enum
		{
			stop            = 0 << 16,
			skip            = 1 << 16,
			replace         = 2 << 16,
		};

		conv_method(uint32_t value)
			: value_(value)
		{ }

		uint32_t type() const 
		{
			return value_ & 0xFFFF0000;
		}

		uint16_t default_char() const 
		{
			return value_ & 0x0000FFFF;
		}

	private:
		uint32_t value_;
	};

	_BASE_API std::wstring u2w(boost::string_ref  const& from, conv_method how = conv_method::stop);
	_BASE_API std::string  w2u(boost::wstring_ref const& from, conv_method how = conv_method::stop);
	_BASE_API std::wstring a2w(boost::string_ref  const& from, conv_method how = conv_method::stop);
	_BASE_API std::string  w2a(boost::wstring_ref const& from, conv_method how = conv_method::stop);
	_BASE_API std::string  u2a(boost::string_ref  const& from, conv_method how = conv_method::stop);
	_BASE_API std::string  a2u(boost::string_ref  const& from, conv_method how = conv_method::stop);

	_BASE_API bool is_utf8(const char *source);
}}