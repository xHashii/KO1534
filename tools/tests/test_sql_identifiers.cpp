// ---------------------------------------------------------------------------
//  test_sql_identifiers.cpp - unit test for shared/database/SqlIdentifiers.h.
//
//  Two things matter here:
//    1. RANGE (and any other reserved word) comes out quoted, so the SELECT
//       that MySqlRecordset::Read() builds is valid MySQL.
//    2. quoting never changes the number or order of the columns: the Fetch*
//       calls read by position, so a mangled list would silently load the
//       wrong field into the wrong struct member.
//
//      g++ -std=c++14 -Wall -Wextra -o /tmp/test_sql_identifiers
//          tools/tests/test_sql_identifiers.cpp && /tmp/test_sql_identifiers
//
//  Runs on Linux using the portable tstring.h (TCHAR = char, _T(x) = x).
// ---------------------------------------------------------------------------

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

#include "../../shared/tstring.h"
#include "../../shared/database/SqlIdentifiers.h"

static int failures = 0;

static void Equal(const std::string & actual, const std::string & expected, const char * what)
{
	if (actual == expected)
	{
		printf("  ok    %s\n", what);
		return;
	}

	failures++;
	printf("  FAIL  %s\n        expected: %s\n        actual:   %s\n",
		what, expected.c_str(), actual.c_str());
}

static void Count(const tstring & list, const char * what)
{
	// The quoted list must contain exactly as many items as the original.
	size_t before = 1, after = 1;
	for (size_t i = 0; i < list.size(); i++)
		if (list[i] == ',') before++;

	tstring quoted = ko_sql::QuoteIdentifierList(list);
	for (size_t i = 0; i < quoted.size(); i++)
		if (quoted[i] == ',') after++;

	if (before != after)
	{
		failures++;
		printf("  FAIL  %s: %d columns became %d\n        %s\n",
			what, (int)before, (int)after, quoted.c_str());
		return;
	}

	printf("  ok    %s (%d columns)\n", what, (int)before);
}

int main()
{
	printf("quoting\n");
	Equal(ko_sql::QuoteIdentifier("Range"), "`Range`", "reserved word is quoted");
	Equal(ko_sql::QuoteIdentifier("  Range  "), "`Range`", "surrounding spaces are dropped");
	Equal(ko_sql::QuoteIdentifier("strName"), "`strName`", "ordinary name is quoted");
	Equal(ko_sql::QuoteIdentifier("`Range`"), "`Range`", "already quoted is left alone");
	Equal(ko_sql::QuoteIdentifier("[Level]"), "`Level`", "T-SQL brackets converted");
	Equal(ko_sql::QuoteIdentifier("COUNT(*)"), "COUNT(*)", "expression is left alone");
	Equal(ko_sql::QuoteIdentifier("*"), "*", "star is left alone");
	Equal(ko_sql::QuoteIdentifier("2ndPlace"), "2ndPlace", "not an identifier");

	printf("\ncolumn lists\n");
	Equal(ko_sql::QuoteIdentifierList("Num, Range, Weight"),
		"`Num`, `Range`, `Weight`", "list is quoted item by item");
	Equal(ko_sql::QuoteIdentifierList("[Level], [Exp]"),
		"`Level`, `Exp`", "bracket list converted");
	Equal(ko_sql::QuoteIdentifierList("Num,Range,Weight"),
		"`Num`, `Range`, `Weight`", "spacing is normalised");
	Equal(ko_sql::QuoteIdentifierList("MagicNum, BeforeAction, TargetAction, SelfEffect, "
		"FlyingEffect, TargetEffect, Moral, SkillLevel, Skill, Msp, HP, ItemGroup, UseItem, "
		"CastTime, ReCastTime, SuccessRate, Type1, Type2, Range, UseStanding, Etc"),
		"`MagicNum`, `BeforeAction`, `TargetAction`, `SelfEffect`, `FlyingEffect`, "
		"`TargetEffect`, `Moral`, `SkillLevel`, `Skill`, `Msp`, `HP`, `ItemGroup`, `UseItem`, "
		"`CastTime`, `ReCastTime`, `SuccessRate`, `Type1`, `Type2`, `Range`, `UseStanding`, `Etc`",
		"the MAGIC list that failed at startup");

	printf("\nno column is lost in the real lists\n");
	Count("Num, strName, Kind, Slot, Race, Class, Damage, Delay, Range, Weight, Duration, "
		"BuyPrice, SellPrice, Ac, Countable, Effect1, Effect2, ReqLevel, ReqLevelMax",
		"ITEM list");
	Count("MagicNum, BeforeAction, TargetAction, SelfEffect, FlyingEffect, TargetEffect, "
		"Moral, SkillLevel, Skill, Msp, HP, ItemGroup, UseItem, CastTime, ReCastTime, "
		"SuccessRate, Type1, Type2, Range, UseStanding, Etc", "MAGIC list");
	Count("iNum, Type, HitRate, Hit, AddDamage, Delay, ComboType, ComboCount, ComboDamage, Range",
		"MAGIC_TYPE1 list");
	Count("Level, Exp", "LEVEL_UP list");
	Count("byNation", "single-column list");

	printf(failures == 0 ? "\nOK: identifier quoting\n" : "\nFAIL: %d check(s)\n", failures);
	return failures == 0 ? 0 : 1;
}
