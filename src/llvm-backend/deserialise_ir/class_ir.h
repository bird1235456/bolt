#pragma once
#include <stdlib.h>

#include <string>
#include <vector>

#include "src/frontend_ir.pb.h"
#include "src/llvm-backend/deserialise_ir/type_ir.h"

struct ClassIR {
  std::string className;
  std::vector<std::unique_ptr<TypeIR>> fields;
  std::vector<std::string> vtable;
  ClassIR(const Frontend_ir::class_defn &classDefn);
};
