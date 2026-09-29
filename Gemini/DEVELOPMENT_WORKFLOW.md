# PROJECT_WORKFLOW.md
## CatchVault Feature Development Workflow
This document defines the mandatory, step-by-step operational workflow for launching, building, and verifying new screens or feature modules within CatchVault.

# 1.  Context & Architecture Alignment
- Audit Active Memory: Review PROJECT_MEMORY.md and PROJECT_ROADMAP.md to confirm active milestone boundaries and target feature scope.

- Validate Architectural Invariants: Check RULES.md, STYLE_GUIDE.md, and DATA_MODEL.md for layout tokens, 44pt touch geometry bounds, and SwiftData relationship rules.   
TXT

- Refresh Local Context: Run npx repomix in the project root to generate a fresh, consolidated repomix-output.xml packing all latest source code, specifications, and test states.   
XML

# 2. Pre-Implementation Review & Confirmation
- Reason First, Code Second: Reason through view state lifecycle, binding requirements, and user interactions before drafting code.

- Propose the Plan: Present a concise prose summary outlining planned view structures, local @State/@Query properties, and semantic design tokens.

- Obtain Explicit Confirmation: Wait for human approval prior to generating or writing any Swift files.

# 3. Incremental Implementation
- Create Physical Layout Files: Place files in the appropriate flattened directory structure under CatchVault/Features/<FeatureName>/<ViewName>.swift.

- Apply Semantic Tokens Only: Build layouts using CVCardContainer, semantic color tokens (surfacePrimary, brandAccent, etc.), and .cvFont() modifiers. Never hardcode hex values or default platform colors/fonts directly.

- Enforce Hit-Target Geometry: Verify that all interactive controls satisfy the 44pt minimum touch target rule.

# 4. Local Test & Visual Verification
Compile & Syntax Check: Execute build (Cmd + B) in Xcode to verify zero type mismatches or macro syntax errors.

- Run Automated Test Suite: Execute unit tests (Cmd + U) to verify zero regressions across models, delete cascades, or relationship graphs.

- Simulator Visual Inspection: Run the simulator (Cmd + R) to visually confirm Light/Dark mode contrast compliance, padding symmetry, and state transitions against real/migrated snapshot data.

# 5. Checkpoint & State Synchronization
- Git Commit: Commit changes with a clean, descriptive message (e.g., feat: implement ReservoirDetailsView layout and navigation).

- Log Checkpoint: Update PROJECT_MEMORY.md and PROJECT_ROADMAP.md in the checkpoint thread with newly completed features and state modifications.   
MD

- NotebookLM Sync (Milestone Closures Only): Re-upload updated .md files to NotebookLM only upon reaching major milestone closures to minimize manual overhead.   
MD