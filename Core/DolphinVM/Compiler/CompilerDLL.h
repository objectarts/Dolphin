#ifndef __COMPILERDLL_H_
#define __COMPILERDLL_H_

#include "ComModule.h"
#include "compiler.h"

class Compiler;

class CDolphinCompilerModule : public ComModule<Compiler>
{
private:

public :
	//DECLARE_LIBID(LIBID_CompilerLib)
	//DECLARE_REGISTRY_APPID_RESOURCEID(IDR_DOLPHINSMALLTALK, "{F797E72A-F7ED-4B65-9FD9-A850ACA48983}")
};

extern CDolphinCompilerModule _Module;

#endif //__COMPILERDLL_H_
