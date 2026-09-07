# Chapter 4 findings

22 pages, ~5,100 words, 15 figures, 2 tables, 35 cross-refs. Two real ideas.
Seven subsections repeated in chapter 5. Target: 8-10 pages, 5 figures, 0 tables.

## A. Wrong facts

**A1. Trace data model.** Reconstructed instructions do not carry source
locations. Line blocks do not contain instructions (location, start, end,
count). Real model: flat instruction list, function-block tree, gap list.
`fig_trace_data_model` draws two arrows that do not exist.

**A2. The debug server is inside the engine.** Linked as a library, one
process. Never stated. Chapter 2's anatomy figure shows it as a separate box.
Fix: one sentence, plus a box inside the engine in `fig_global_architecture`.

**A3. Memory path.** "Whichever path is appropriate to the session" is not a
rule. At launch the path switches to OpenOCD once and stays. Also missing:
`attach` creates no OpenOCD, so no trace, watches or peripherals.

**A4. Layers.** "Each depending only on those below it" is false and
contradicts `fig_module_layers`. Handlers depend on transport and core; core
skips transport.

**A5. Thread table.** Reader thread comes from the dispatcher, not the
transport. The dispatcher is the main thread, not a created one.

**A6. Reset.** Destroys and rebuilds the trace component. Delete the
`Armed -> Armed : reset` self-loop.

**A7. Four custom capability groups, not three** (module symbols). Trace data
event carries two start indices.

**Correct, leave alone:** buffer drain sequence, sync barrier, arm-on-resume,
five retained element kinds, precomputed instruction table, RTTI conflict,
ten components.

## B. Cut list

| Section | Words | Verdict |
|---|---|---|
| OpenOCD Object Model (4 sub) | 433 | Delete. Keep 3 sentences where used. |
| Custom Protocol Extensions | 383 | Move table to ch5. Keep 3 sentences. |
| Thread Inventory | 313 | Cut to 2 sentences. |
| Provider Layer (5 sub) | 280 | One paragraph, no headings. |
| Reconstruction and Correlation | 251 | Halve. Ch5 has 7 subsections on it. |
| Design Principles | 243 | Halve. Principles 1 and 2 are one. 4 goes nowhere. |
| Trace Lifecycle | 217 | Keep, tighten. |
| Trace Extraction | 196 | Short paragraph. Ch5 repeats all four points. |
| Generation and Capture | 194 | Keep, tighten. |
| Four-Stage Pipeline | 187 | Delete para 3, the figure says it. |
| Debug Context and Components | 185 | Halve. |
| Layered Decomposition | 182 | Keep, tighten. |
| Trace Decoding | 177 | Halve. Ch5 has the same four points. |
| Run Control and Memory | 167 | Keep, fix A3. |
| Direct Server Path | 152 | Keep. The argument. |
| Frontend Architecture | 147 | One paragraph. Ch5 has screenshots. |
| Module Boundary Rules | 143 | Keep. |
| Global Architecture | 143 | Keep, fix A2. |
| Trace Data Model | 130 | Rewrite (A1) or fold into Reconstruction. |
| Conclusion | 125 | 3 sentences. |
| Error Model | 119 | 2 sentences. Rest restates them. |
| Target Access Serialization | 101 | Merge up. Duplicates the concurrency para. |
| Event Bus | 98 | Keep, one paragraph. |
| Resource Ownership | 94 | Delete. Not architecture. |
| Introduction | 87 | Delete para 2, it lists the chapter's own TOC. |
| Capability Aggregation | 66 | One sentence. |
| Conventional Debug Path | 65 | Keep, tighten. |
| Dispatch and Cancellation | 60 | One sentence. |

**Ch4 / ch5 duplicates:** Trace Extraction, Trace Decoding, Reconstruction,
Custom Extensions + table, Frontend, Concurrency, Teardown. Ch4 = decision and
reason. Ch5 = how. Both currently do both.

## C. Diagrams

| Figure | Verdict |
|---|---|
| `fig_global_architecture` | Keep, redraw with the server inside the engine. |
| `fig_pipeline` | Keep. |
| `fig_module_layers` | Keep. |
| `fig_division_responsibility` | Keep. |
| `fig_trace_lifecycle` | Keep, drop the reset self-loop. |
| `fig_request_wire_to_wire` | Keep only if merged with the event one. |
| `fig_event_dataflow` | Delete. Four boxes and a bus. |
| `fig_openocd_model` | Delete with its section. |
| `fig_on_target_dataflow` | Delete. Ch3 `fig:target_debug` shows this path. |
| `fig_buffer_drain` | Delete. Ch5 `fig_extraction_sequence` is the same. |
| `fig_end_to_end_capture` | Delete. Third figure of one flow. |
| `fig_trace_data_model` | Delete or redraw. Wrong (A1). |
| `fig_debug_context` | Delete. A box holding ten strings. |
| `fig_provider_interfaces` | Delete. Five method lists. |
| `fig_frontend_structure` | Delete. Ch5 has screenshots. |
| Table: thread inventory | Delete. |
| Table: custom requests | Move to ch5. |

## D. Style

**13 announced counts.** four elements / four principles / four stages / two
components / two consequences / three transformations / four types / two events
/ five exist / three requirements / five kinds / three groups / three rules /
two boundaries.

**15 figure lead-ins.** Every subsection ends "Figure N states X". Delete all.

**Repeats:** "rather than" 25, "of Section \ref" 21, "states the/which" 13,
"which is what" 7, "described in Section" 7.

**35 cross-refs.** Unreadable straight through. Aim under 15 after the cuts.

## E. What is left

1. Trace is four stages, separated because each depends on one thing only:
   device, server, protocol, image. That is why the last two run offline.
2. Two systems drive one device because neither alone suffices. The library
   cannot read while running and cannot carry trace. Run control has one owner.
   Reset is the exception, and it costs a resynchronization mechanism.
