#include "ist.h"
#include "ComObject.h"
#include "ComModule.h"

void ComObjectBase::LockModule()
{
	ASSERT(Module::Instance != nullptr);
	Module::Instance->Lock();
}

void ComObjectBase::UnlockModule()
{
	ASSERT(Module::Instance != nullptr);
	Module::Instance->Unlock();
}
