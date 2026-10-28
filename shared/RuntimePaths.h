#pragma once

// ---------------------------------------------------------------------------
//  RuntimePaths.h - let the servers find their data however they are started.
//
//  Every runtime file is opened with a path relative to the working directory:
//      ./GameServer.ini   (and the .ini of the other two servers)
//      ./map/             (MAP_DIR, the .smd zone files)
//      ./Quests/          (LUA_SCRIPT_DIRECTORY, the quest scripts)
//      ./Logs/            (created on startup)
//
//  That works when the process is started in the right directory, but a
//  double-click on bin\Debug\Win32\GameServer.exe makes the working directory
//  the executable's folder, and a shell started elsewhere gives yet another one.
//
//  SelectRuntimeDirectory() therefore looks for a usable directory and makes it
//  the working directory before the server reads anything:
//
//      1. the current working directory, if it already has Map and Quests
//      2. the directory holding the .exe          (all files deployed beside it)
//      3. those two, each followed by \data       (repo\data\Map, repo\data\Quests)
//      4. up to five parent directories of the .exe, each with and without
//         \data, so a build in bin\Debug\Win32 still finds <repo>\data
//
//  The login server reads no map data, so it passes requireData = false and the
//  first directory holding its own .ini wins.
//
//  A directory that also contains the server's .ini is preferred over one that
//  only has the map data.  Nothing is copied, no registry or environment
//  variable is consulted: only the process's current directory changes, and the
//  chosen path is printed so the log shows where the files came from.
// ---------------------------------------------------------------------------

#if defined(KO_RUNTIME_NO_WINDOWS)
	// Nothing from <Windows.h> is available; the Win32 paths below are skipped.
#elif defined(KO_RUNTIME_WIN32_SHIM)
	// tools/tests supplies the few declarations used here, so that the real
	// code paths can be compiled and run on a machine without Windows.
#else
#	include <Windows.h>
#endif

#include <cstring>
#include <string>
#include <cstdio>

namespace ko_runtime
{
	inline bool DirectoryExists(const std::string & path)
	{
		if (path.empty())
			return false;

		DWORD attributes = GetFileAttributesA(path.c_str());
		return attributes != INVALID_FILE_ATTRIBUTES
			&& (attributes & FILE_ATTRIBUTE_DIRECTORY) != 0;
	}

	inline bool FileExists(const std::string & path)
	{
		if (path.empty())
			return false;

		DWORD attributes = GetFileAttributesA(path.c_str());
		return attributes != INVALID_FILE_ATTRIBUTES
			&& (attributes & FILE_ATTRIBUTE_DIRECTORY) == 0;
	}

	// A directory is usable when both map folders are in it.
	inline bool HasRuntimeData(const std::string & path)
	{
		if (path.empty() || !DirectoryExists(path))
			return false;

		std::string prefix = path;
		if (!prefix.empty() && prefix[prefix.length() - 1] != '\\')
			prefix += "\\";

		return DirectoryExists(prefix + "Map") && DirectoryExists(prefix + "Quests");
	}

	inline std::string ExecutableDirectory()
	{
		char modulePath[MAX_PATH] = { 0 };
		DWORD length = GetModuleFileNameA(nullptr, modulePath, MAX_PATH);
		if (length == 0 || length == MAX_PATH)
			return std::string();

		std::string path(modulePath, length);
		size_t slash = path.find_last_of("\\/");
		if (slash == std::string::npos)
			return std::string();

		return path.substr(0, slash);
	}

	inline std::string Parent(const std::string & path)
	{
		size_t slash = path.find_last_of("\\/");
		if (slash == std::string::npos || slash == 0)
			return std::string();

		std::string parent = path.substr(0, slash);

		// Keep a drive root ("C:\") intact.
		if (parent.length() == 2 && parent[1] == ':')
			parent += "\\";

		return parent;
	}

	// Prints the executable's own timestamp.  A log that says
	//
	//     GameServer.exe build 2026-10-28 14:02:11
	//
	// answers "is this the build with the fix?" without guessing: compare it
	// with the time of the last source change.  MSVC writes the .exe when the
	// link finishes, so this is the build time, not the source time.
	inline void PrintBuildInfo()
	{
#if defined(KO_RUNTIME_NO_WINDOWS)
		return;
#else
		char modulePath[MAX_PATH] = { 0 };
		DWORD length = GetModuleFileNameA(nullptr, modulePath, MAX_PATH);
		if (length == 0 || length == MAX_PATH)
			return;

		const char * slash = strrchr(modulePath, '\\');
		const char * name = (slash != nullptr) ? slash + 1 : modulePath;

		SYSTEMTIME local = {};
		HANDLE file = CreateFileA(modulePath, GENERIC_READ,
			FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
			nullptr, OPEN_EXISTING, 0, nullptr);

		if (file != INVALID_HANDLE_VALUE)
		{
			FILETIME written = {};
			FILETIME localFileTime = {};

			if (GetFileTime(file, nullptr, nullptr, &written)
				&& FileTimeToLocalFileTime(&written, &localFileTime))
			{
				FileTimeToSystemTime(&localFileTime, &local);
			}

			CloseHandle(file);
		}

		if (local.wYear != 0)
		{
			printf("%s build %04d-%02d-%02d %02d:%02d:%02d\n", name,
				local.wYear, local.wMonth, local.wDay,
				local.wHour, local.wMinute, local.wSecond);
		}
		else
		{
			printf("%s (build time unavailable)\n", name);
		}
#endif
	}

	inline std::string JoinPath(const std::string & path, const char * leaf)
	{
		if (path.empty())
			return std::string(leaf);

		std::string joined = path;
		if (joined[joined.length() - 1] != '\\')
			joined += "\\";

		return joined + leaf;
	}

	// name is the server's own config file ("GameServer.ini").
	// requireData is true for the servers that read map/zone data (Game and AI)
	// and false for the login server, which only needs its own .ini - forcing it
	// to find Map\ would make a login-only deployment impossible.
	inline bool SelectRuntimeDirectory(const char * name, bool requireData = true,
	                                  bool verbose = true)
	{
		const int MaxCandidates = 16;
		std::string candidates[MaxCandidates];
		int count = 0;

		const std::string current = ".";
		const std::string exeDirectory = ExecutableDirectory();

		// Build the list of directories worth a look: the working directory,
		// the executable's directory, and then each parent of the executable.
		// Every entry is tried both as-is and with a data\ suffix, because the
		// repository keeps the assets in <repo>\data.
		const std::string bases[7] = { current, exeDirectory, "", "", "", "", "" };
		std::string walking = exeDirectory;

		for (int i = 0; i < 7; i++)
		{
			std::string base;
			if (i < 2)
				base = bases[i];
			else
			{
				walking = Parent(walking);
				base = walking;
			}

			if (base.empty())
				continue;

			if (count < MaxCandidates)
				candidates[count++] = base;
			if (count < MaxCandidates)
				candidates[count++] = JoinPath(base, "data");
		}

		// Pass 0 wants a directory with the .ini; pass 1 accepts data alone, in
		// which case the server reports the missing .ini itself.
		std::string chosen;
		for (int pass = 0; pass < 2 && chosen.empty(); pass++)
		{
			for (int i = 0; i < count; i++)
			{
				const std::string & candidate = candidates[i];

				if (requireData ? !HasRuntimeData(candidate) : !DirectoryExists(candidate))
					continue;

				if (pass == 0 && !FileExists(JoinPath(candidate, name)))
					continue;

				chosen = candidate;
				break;
			}
		}

		if (chosen.empty())
		{
			printf("ERROR: could not find the server data directory.\n");
			printf("Each server needs Map\\ and Quests\\ in its working directory.\n");
			printf("Looked in the current directory and in:\n");
			for (int i = 0; i < count; i++)
				printf("    %s\n", candidates[i].c_str());
			printf("\nStart the servers with:\n");
			printf("    powershell -ExecutionPolicy Bypass -File tools\\dev_run.ps1\n");
			return false;
		}

		// "." needs no change; anything else becomes the working directory.
		if (chosen != ".")
			SetCurrentDirectoryA(chosen.c_str());

		if (verbose)
		{
			char fullPath[MAX_PATH] = { 0 };
			GetCurrentDirectoryA(MAX_PATH, fullPath);
			printf("Working directory: %s\n", fullPath);
			if (!FileExists(name))
				printf("WARNING: %s not found there; copy it from config\\ next to the .exe.\n", name);
		}

		return true;
	}

} // namespace ko_runtime
