#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include <vector>

using namespace llvm;

static LLVMContext &Context = LLVMContext();
static Module *ModuleOb = new Module("my compiler", Context);
static std::vector<std::string> FunArgs;

typedef SmallVector<BasicBlock *, 16> BBList;
typedef SmallVector<Value *, 16> ValList;

// Create global variable
GlobalVariable *createGlob(IRBuilder<> &Builder, std::string Name) {
	ModuleOb->getOrInsertGlobal(Name, Builder.getInt32Ty());
	GlobalVariable *gVar = ModuleOb->getNamedGlobal(Name);
	gVar->setLinkage(GlobalValue::ExternalLinkage);
	gVar->setAlignment(4);
	return gVar;
}

// Emit function 
Function *createFunc(IRBuilder<> &Builder, std::string Name) {
	// Argument type
	std::vector<Type *> Integers(FunArgs.size(), Type::getInt32Ty(Context));

	// Function type: return type , argument type, not vararg
	FunctionType *funcType = FunctionType::get(Builder.getInt32Ty(), Integers, false);

	Function *func = Function::Create(funcType, Function::LinkageTypes::ExternalLinkage, Name, ModuleOb);

	return func;
}

// Create Basic Block
BasicBlock *createBB(Function *fooFunc, std::string Name) {
	return BasicBlock::Create(Context, Name, fooFunc);
}

// Assign name to function arguemnt
void setFuncArgs(Function *func, std::vector<std::string> FunArgs) {
	unsigned Idx = 0;
	Function::arg_iterator AI, AE;
	for (AI = func->arg_begin(), AE = func->arg_end(); AI != AE; ++AI, ++Idx)
		AI->setName(FunArgs[Idx]);
}

Value * createArith(IRBuilder <> &Builder, Value *L, Value *R) {
	return Builder.CreateMul(L, R, "multmp");
}

Value *createIfElse(IRBuilder<> &Builder, BBList List, ValList VL) {
	Value *Condtn = VL[0];
	Value *Arg1 = VL[1];
	BasicBlock *ThenBB = List[0];
	BasicBlock *ElseBB = List[1];
	BasicBlock *MergeBB = List[2];
	Builder.CreateCondBr(Condtn, ThenBB, ElseBB);

	Builder.SetInsertPoint(ThenBB);
	Value *ThenVal = Builder.CreateAdd(Arg1, Builder.getInt32(1), "thenaddtmp");
	Builder.CreateBr(MergeBB);

	Builder.SetInsertPoint(ElseBB);
	Value *ElseVal = Builder.CreateAdd(Arg1, Builder.getInt32(2), "elseaddtmp");
	Builder.CreateBr(MergeBB);

	unsigned PhiBBSize = List.size() - 1;
	Builder.SetInsertPoint(MergeBB);
	PHINode *Phi = Builder.CreatePHI(Type::getInt32Ty(Context),
		PhiBBSize, "iftmp");
	Phi->addIncoming(ThenVal, ThenBB);
	Phi->addIncoming(ElseVal, ElseBB);

	return Phi;
}

Value *createLoop(IRBuilder<> &Builder, BBList List, ValList VL, Value *StartVal, Value *EndVal) {
	BasicBlock *PreheaderBB = Builder.GetInsertBlock();
	Value *val = VL[0];
	BasicBlock *LoopBB = List[0];
	Builder.CreateBr(LoopBB);
	Builder.SetInsertPoint(LoopBB);
	PHINode *IndVar = Builder.CreatePHI(Type::getInt32Ty(Context), 2, "i");
	IndVar->addIncoming(StartVal, PreheaderBB);
	Value *Add = Builder.CreateAdd(val, Builder.getInt32(5), "addtmp");
	Value *StepVal = Builder.getInt32(1);
	Value *NextVal = Builder.CreateAdd(IndVar, StepVal, "nextval");
	Value *EndCond = Builder.CreateICmpULT(IndVar, EndVal, "endcond");
	BasicBlock *LoopEndBB = Builder.GetInsertBlock();
	BasicBlock *AfterBB = List[1];
	Builder.CreateCondBr(EndCond, LoopBB, AfterBB);
	Builder.SetInsertPoint(AfterBB);
	IndVar->addIncoming(NextVal, LoopEndBB);
	return Add;
}

int32_t foo(int32_t a, int32_t b)
{
	int32_t tmp = a * 16;
	if (a * 16 < 100) {
		a + 1;
	}
	else {
		a + 2;
	}
	int32_t addtmp;
	for (int32_t i = 1; i < b; i++) {
		addtmp = a + 5;
	}
	return addtmp;
}

/*
; ModuleID = 'my compiler'
source_filename = "my compiler"

@g = external global i32, align 4

define i32 @foo(i32 %a, i32 %b) {
entry:
%multmp = mul i32 %a, 16
%cmptmp = icmp ult i32 %multmp, 100
br i1 %cmptmp, label %then, label %else

then:                                             ; preds = %entry
%thenaddtmp = add i32 %a, 1
br label %ifcont

else:                                             ; preds = %entry
%elseaddtmp = add i32 %a, 2
br label %ifcont

ifcont:                                           ; preds = %else, %then
%iftmp = phi i32 [ %thenaddtmp, %then ], [ %elseaddtmp, %else ]
br label %loop

loop:                                             ; preds = %loop, %ifcont
%i = phi i32 [ 1, %ifcont ], [ %nextval, %loop ]
%addtmp = add i32 %a, 5
%nextval = add i32 %i, 1
%endcond = icmp ult i32 %i, %b
br i1 %endcond, label %loop, label %afterloop

afterloop:                                        ; preds = %loop
ret i32 %addtmp
}
*/

int main(int argc, char **argv) {
	static IRBuilder<> Builder(Context);

	// Create a global g
	createGlob(Builder, "g");

	// Create a function
	FunArgs.push_back("a");
	FunArgs.push_back("b");
	Function *fun = createFunc(Builder, "foo");
	setFuncArgs(fun, FunArgs);

	// Create a basic block for function body
	BasicBlock *entry = createBB(fun, "entry");
	Builder.SetInsertPoint(entry);

	// Mul
	Function::arg_iterator AI = fun->arg_begin();
	Value *Arg1 = AI;
	Value *constant = Builder.getInt32(16);
	Value *val = createArith(Builder, Arg1, constant);

	// Compare arg1 * 16 < 100
	Value *val2 = Builder.getInt32(100);
	Value *Compare = Builder.CreateICmpULT(val, val2, "cmptmp");

	// If-then-else
	ValList VL;
	VL.push_back(Compare);
	VL.push_back(Arg1);
	BasicBlock *ThenBB = createBB(fun, "then");
	BasicBlock *ElseBB = createBB(fun, "else");
	BasicBlock *MergeBB = createBB(fun, "ifcont");
	BBList List;
	List.push_back(ThenBB);
	List.push_back(ElseBB);
	List.push_back(MergeBB);
	createIfElse(Builder, List, VL);

	// Loop
	ValList LoopVL;
	LoopVL.push_back(Arg1);
	BBList LoopList;

	BasicBlock *LoopBB = createBB(fun, "loop");
	BasicBlock *AfterBB = createBB(fun, "afterloop");
	LoopList.push_back(LoopBB);
	LoopList.push_back(AfterBB);
	Value *StartVal = Builder.getInt32(1);
	Value *Arg2 = ++AI;
	Value *Res = createLoop(Builder, LoopList, LoopVL, StartVal, Arg2);

	// Return result
	Builder.CreateRet(Res);

	// Verify
	verifyFunction(*fun, &errs());
	verifyModule(*ModuleOb, &errs());

	// https://stackoverflow.com/questions/46367910/llvm-5-0-linking-error-with-llvmmoduledump
	ModuleOb->print(errs(), nullptr, true, true);

	// Execute
	InitializeNativeTarget();
	InitializeNativeTargetAsmPrinter();
	InitializeNativeTargetAsmParser();

	std::string errorString;
	std::unique_ptr<Module> p = std::unique_ptr<Module>(ModuleOb);
	ExecutionEngine *engine = EngineBuilder(std::move(p))
		.setErrorStr(&errorString)
		.setEngineKind(llvm::EngineKind::JIT)
		.create();

	if (engine == nullptr) {
		throw std::runtime_error(std::string("JIT failed: " + errorString));
	}

	void * fp = (void *)engine->getFunctionAddress("foo");
	auto f = reinterpret_cast<int32_t(*)(int32_t, int32_t)>(fp);

	auto a = (*f)(1, 2);
	auto b = foo(1, 2);
	printf("a = %d, b = %d, match = %d\n", a, b, a == b);

	return 0;
}
