// Copyright 2009 The RE2 Authors.  All Rights Reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#include "util.h"
#include "valgrind.h"

namespace re2 {

int RunningOnValgrind() {
#ifdef RUNNING_ON_VALGRIND
	return RUNNING_ON_VALGRIND;
#else
	return 0;
#endif
}

}  // namespace re2
