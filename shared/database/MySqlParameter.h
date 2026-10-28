#pragma once

#include "DbTypes.h"

// ---------------------------------------------------------------------------
//  MySqlParameter - one bound value.
//
//  Matches the old SQL Server wrapper's role: it only records what the caller
//  bound (direction, C type, address, length).  MySqlCommand renders it into a
//  literal when the statement is executed, and writes output values back into
//  the same address afterwards.
// ---------------------------------------------------------------------------
class MySqlParameter
{
public:
	MySqlParameter(SQLSMALLINT parameterType, SQLSMALLINT cDataType,
				   SQLPOINTER parameterAddress, SQLLEN maxLength = 1)
		: m_parameterType(parameterType), m_cDataType(cDataType),
		  m_parameterAddress(parameterAddress), m_maxLength(maxLength)
	{
	}

	inline SQLSMALLINT GetParameterType() const { return m_parameterType; };
	inline SQLSMALLINT GetCDataType()     const { return m_cDataType; };
	inline SQLPOINTER  GetAddress()       const { return m_parameterAddress; };
	inline SQLLEN      GetDataTypeSize()  const { return m_maxLength; };

	inline bool IsOutput() const
	{
		return m_parameterType == SQL_PARAM_OUTPUT
			|| m_parameterType == SQL_PARAM_INPUT_OUTPUT;
	}

	inline bool IsInput() const
	{
		return m_parameterType == SQL_PARAM_INPUT
			|| m_parameterType == SQL_PARAM_INPUT_OUTPUT;
	}

private:
	SQLSMALLINT m_parameterType;
	SQLSMALLINT m_cDataType;
	SQLPOINTER  m_parameterAddress;
	SQLLEN      m_maxLength;
};
