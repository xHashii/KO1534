#pragma once

#include <string>
#include "../tstring.h"

// ---------------------------------------------------------------------------
//  SqlIdentifiers.h - quote column and table names for MySQL.
//
//  The *Set classes keep their column lists as plain text ("Num, Range,
//  Weight"), because that is how they were written for SQL Server, where RANGE,
//  RANK and LEVEL are not reserved.  MySQL 8 reserved RANGE, so the same list
//  makes the server fail with
//
//      ERROR : ... near 'Range, Weight, Duration, ... FROM ITEM'
//
//  GetColumns() therefore writes `Range` itself, and every list is quoted again
//  on the way into the statement, so a name that is missed in one place still
//  cannot break the query.  Nothing else in a SELECT list is touched:
//
//      "Num, Range, Weight"     -> "`Num`, `Range`, `Weight`"
//      "Level, Exp"             -> "`Level`, `Exp`"
//      "[Level], [Exp]"         -> "`Level`, `Exp`"    (T-SQL spelling)
//      "COUNT(*)"               -> "COUNT(*)"          (not a plain name)
//      "`Range`"                -> "`Range`"           (already quoted)
// ---------------------------------------------------------------------------
namespace ko_sql
{
	inline tstring Trim(const tstring & value)
	{
		size_t begin = value.find_first_not_of(_T(" \t\r\n"));
		if (begin == tstring::npos)
			return tstring();

		size_t end = value.find_last_not_of(_T(" \t\r\n"));
		return value.substr(begin, end - begin + 1);
	}

	// Letters, digits and '_' only, and not starting with a digit.
	inline bool IsPlainIdentifier(const tstring & token)
	{
		if (token.empty())
			return false;

		if (token[0] >= _T('0') && token[0] <= _T('9'))
			return false;

		for (size_t i = 0; i < token.length(); i++)
		{
			TCHAR c = token[i];

			bool letter = (c >= _T('a') && c <= _T('z'))
				|| (c >= _T('A') && c <= _T('Z'));
			bool digit = (c >= _T('0') && c <= _T('9'));

			if (!letter && !digit && c != _T('_'))
				return false;
		}

		return true;
	}

	inline tstring QuoteIdentifier(const tstring & token)
	{
		tstring name = Trim(token);

		// T-SQL bracket quoting is not valid MySQL: [Level] -> `Level`
		if (name.length() >= 2 && name[0] == _T('[') && name[name.length() - 1] == _T(']'))
			name = Trim(name.substr(1, name.length() - 2));

		// Expressions, *, and names that are already quoted are passed through.
		if (!IsPlainIdentifier(name))
			return token;

		return _T("`") + name + _T("`");
	}

	// Quotes each comma-separated name in a column list.  Keeps the original
	// spacing of the empty items so a trailing comma stays visible instead of
	// being silently repaired.
	inline tstring QuoteIdentifierList(const tstring & columns)
	{
		tstring result;
		size_t begin = 0;

		while (begin <= columns.length())
		{
			size_t comma = columns.find(_T(','), begin);
			if (comma == tstring::npos)
				comma = columns.length();

			if (!result.empty())
				result += _T(", ");

			result += QuoteIdentifier(columns.substr(begin, comma - begin));

			if (comma == columns.length())
				break;

			begin = comma + 1;
		}

		return result;
	}
}
