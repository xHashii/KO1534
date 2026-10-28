// ---------------------------------------------------------------------------
//  test_runtime_paths.cpp - exercises shared/RuntimePaths.h without Windows.
//
//  RuntimePaths.h only uses five Win32 calls, so they are re-implemented here
//  on top of POSIX and the real header is compiled unchanged.  That verifies
//  the C++ and the directory-search logic; it cannot verify the real Win32
//  behaviour, which only a run on Windows can.
//
//      g++ -std=c++14 -Wall -Wextra -o /tmp/test_runtime_paths
//          tools/tests/test_runtime_paths.cpp && /tmp/test_runtime_paths
//
//  Exit code 0 = every scenario picked the expected directory.
// ---------------------------------------------------------------------------

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <sys/stat.h>
#include <unistd.h>
#include <climits>

// --- the slice of <Windows.h> that RuntimePaths.h uses ---------------------
typedef unsigned long DWORD;
typedef int BOOL;
const DWORD INVALID_FILE_ATTRIBUTES = (DWORD)-1;
const DWORD FILE_ATTRIBUTE_DIRECTORY = 0x10;
#ifndef MAX_PATH
#define MAX_PATH 260
#endif

static std::string ToHost(const char * path)
{
	std::string p(path);
	for (size_t i = 0; i < p.size(); i++)
		if (p[i] == '\\') p[i] = '/';
	return p;
}

static DWORD GetFileAttributesA(const char * path)
{
	struct stat st;
	std::string host = ToHost(path);
	if (host.empty() || stat(host.c_str(), &st) != 0)
		return INVALID_FILE_ATTRIBUTES;
	return S_ISDIR(st.st_mode) ? FILE_ATTRIBUTE_DIRECTORY : 0;
}

static DWORD GetModuleFileNameA(void *, char * buffer, DWORD size)
{
	const char * exe = getenv("KO_TEST_EXE");
	if (exe == nullptr)
		return 0;
	size_t length = strlen(exe);
	if (length >= size)
		return size;
	memcpy(buffer, exe, length + 1);
	return (DWORD)length;
}

static BOOL SetCurrentDirectoryA(const char * path)
{
	return chdir(ToHost(path).c_str()) == 0;
}

static DWORD GetCurrentDirectoryA(DWORD size, char * buffer)
{
	char cwd[PATH_MAX];
	if (getcwd(cwd, sizeof(cwd)) == nullptr)
		return 0;
	size_t length = strlen(cwd);
	if (length >= size)
		return size;
	memcpy(buffer, cwd, length + 1);
	return (DWORD)length;
}

// --- the header under test -------------------------------------------------
#define KO_RUNTIME_NO_WINDOWS
#include "../../shared/RuntimePaths.h"

// --- tiny test scaffolding -------------------------------------------------
static int failures = 0;

static void mkdirs(const std::string & path)
{
	std::string partial;
	for (size_t i = 0; i < path.size(); i++)
	{
		partial += path[i];
		if (path[i] == '/' || i + 1 == path.size())
			mkdir(partial.c_str(), 0777);
	}
}

static void touch(const std::string & path)
{
	FILE * f = fopen(path.c_str(), "w");
	if (f != nullptr) fclose(f);
}

// Builds a fake repository:
//   root/data/Map, root/data/Quests     the asset sources
//   root/bin/Debug/Win32/GameServer.exe the executable
static std::string MakeTree()
{
	char pattern[] = "/tmp/kortestXXXXXX";
	const char * root = mkdtemp(pattern);
	if (root == nullptr)
	{
		printf("cannot create a temporary directory\n");
		exit(2);
	}

	std::string base(root);
	mkdirs(base + "/data/Map");
	mkdirs(base + "/data/Quests");
	mkdirs(base + "/bin/Debug/Win32");
	touch(base + "/bin/Debug/Win32/GameServer.exe");
	return base;
}

static void Expect(bool condition, const char * what, const std::string & detail)
{
	if (condition)
	{
		printf("  ok    %s\n", what);
		return;
	}

	failures++;
	printf("  FAIL  %s\n        %s\n", what, detail.c_str());
}

static std::string Current()
{
	char buffer[PATH_MAX] = { 0 };
	GetCurrentDirectoryA(PATH_MAX, buffer);
	return std::string(buffer);
}

int main()
{
	const std::string root = MakeTree();
	const std::string exeDir = root + "/bin/Debug/Win32";

	printf("tree: %s\n", root.c_str());

	// 1. started from the repo root: ./data has the assets
	setenv("KO_TEST_EXE", (exeDir + "/GameServer.exe").c_str(), 1);
	chdir(root.c_str());
	Expect(ko_runtime::SelectRuntimeDirectory("GameServer.ini", true, false),
		"repo root -> data\\", Current());
	Expect(Current() == root + "/data", "repo root lands in data", Current());

	// 2. started from bin\\Debug\\Win32 with everything deployed beside the .exe
	touch(exeDir + "/GameServer.ini");
	chdir(exeDir.c_str());
	Expect(ko_runtime::SelectRuntimeDirectory("GameServer.ini", true, false),
		"exe dir with data beside it", Current());
	// data\ is absent there, so it must walk up to <repo>\data
	Expect(Current() == root + "/data", "exe dir falls back to repo data", Current());

	// 3. started from an unrelated directory: the exe path decides
	chdir("/tmp");
	Expect(ko_runtime::SelectRuntimeDirectory("GameServer.ini", true, false),
		"unrelated cwd uses the exe path", Current());
	Expect(Current() == root + "/data", "unrelated cwd lands in repo data", Current());

	// 4. deployed folder (Map, Quests and the .ini next to the .exe): that wins
	mkdirs(exeDir + "/Map");
	mkdirs(exeDir + "/Quests");
	chdir("/tmp");
	Expect(ko_runtime::SelectRuntimeDirectory("GameServer.ini", true, false),
		"deployed folder is used", Current());
	Expect(Current() == exeDir, "deployed folder beside the exe wins", Current());

	// 5. current directory already correct: nothing moves
	chdir(exeDir.c_str());
	Expect(ko_runtime::SelectRuntimeDirectory("GameServer.ini", true, false),
		"cwd already correct", Current());
	Expect(Current() == exeDir, "cwd is left alone", Current());

	// 6. login server: no map data anywhere, only its own .ini beside the .exe
	std::string bare = root + "/bin/Release/x64";
	mkdirs(bare);
	touch(bare + "/LogInServer.exe");
	touch(bare + "/LogInServer.ini");
	setenv("KO_TEST_EXE", (bare + "/LogInServer.exe").c_str(), 1);
	chdir("/tmp");
	Expect(ko_runtime::SelectRuntimeDirectory("LogInServer.ini", false, false),
		"login server needs only its .ini", Current());
	Expect(Current() == bare, "login server uses the .ini folder", Current());

	printf(failures == 0 ? "\nOK: runtime directory selection\n"
	                     : "\nFAIL: %d scenario(s)\n", failures);
	return failures == 0 ? 0 : 1;
}
