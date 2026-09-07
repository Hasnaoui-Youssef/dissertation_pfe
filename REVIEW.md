# Technical Jury Review

**Document reviewed:** *Design and Implementation of a Debugger with Instruction Trace Capabilities*, Youssef HASNAOUI, STMicroelectronics / 2025-2026.
**Build reviewed:** `aux/main.pdf`, 118 pages, rebuilt from the working tree on 2026-09-02 with `pdflatex -output-directory=aux` (three passes plus `biber`). Page numbers below are printed page numbers.
**Evidence used:** the report sources; the implementation in `~/projects/cpp_projects/trailer_vibes` (engine, VS Code extension, and the OpenOCD fork at `engine/external/openocd`); Arm DDI0403E.e, DDI0461B, DDI0489D, DDI0494D, IHI0029G, IHI0031H, IHI0064H.b; ST RM0477 Rev 9, RM0433, RM0468, RM0481, RM0456, RM0090, AN4989 Rev 4, DS14359, UM3276 Rev 2; the supplied papers and books; `Academic-Writing-Skills-1754521580.pdf` and `Rapport_Template_ISI.pdf`.

**On confidentiality.** The application note is confidential. Section 5.2 describes its audience, scope and structure without reproducing its content, and Section 5.3.7 states that ROM-table discovery is deferred without giving a cause. Both are handled correctly and nothing in this review asks for disclosure. Where a claim in the report would need the note as its evidence, the finding is recorded as *insufficiently supported in the report*, not as an error, and the correction offered is always a correction that can be made with public sources.

---

# PART 1 — EXECUTIVE JURY ASSESSMENT

## Technical quality

High, and higher than the report itself makes visible. Every architectural and register-level claim I was able to check against Arm and ST documentation held: the component base addresses on the target (trace funnel `0xE00F3000`, ETF `0xE00F4000`, TPIU `0xE00F5000`, RM0477 Table 776), the 2-Kbyte ETF (RM0477 §66.6.10 and `ETF_RSZ` reset value `0x200`), the TMC configuration and mode tables (DDI0461B §1.1.2, §1.3.1), the DWT comparator count and its `CMPMATCH` connection to the ETM (DDI0403E), local-reset and vector-catch semantics (DDI0403E), the 16-byte formatter frame and the exact conditions under which formatting may be bypassed (IHI0029G §D4.1), the P0-element generation rules (IHI0064H.b §2.2), and the board and device facts (UM3276 Table 7, DS14359). I found two register-level errors in the whole of Chapter 2, both narrow.

The implementation is real, substantial and correctly described at the abstraction level the report chose. I checked ten specific implementation claims against source and all ten held, including the identity checks in both drivers, the capability-gated commit ordering, the non-incrementing buffer read, the wrapped-buffer handling, the 16-byte synchronization barrier, the run-state event coupling, the `gdb_resync` command and event added to OpenOCD, the loopback wake service, the guarded-exit containment, and the frontend's increment-index check.

## Technical credibility

Good in the design chapters, weak in two specific places that a jury will find.

The credibility problem is not the engineering, it is the evidence. The headline quantitative result rests on **one** capture of **one** deterministic startup sequence, and the number quoted for it counts sixteen bytes the host inserted itself as if the device had produced them. The correctness of the reconstruction is asserted against a baseline the implementation generated on its own first run, which the report calls an "oracle". Both are recoverable in a few hours of work. Left as they are, they convert the strongest claim in the report into the easiest one to attack.

## Clarity

Chapters 2 to 5 are clear, disciplined and unusually well organised. Chapter 1 and the general introduction are of visibly lower quality and read as older text: comma splices, contractions, two spelling errors, one broken sentence, and one first-person plural. The gap between Chapter 1 and Chapter 2 is wide enough that a jury will notice it.

One stylistic pattern dominates the whole report: about thirty-one paragraphs open by announcing how many items follow ("Four principles governed", "Two components take part", "Six limitations are stated here"). It is monotonous, and it is the one thing that makes competent English read as mechanical.

## Completeness

The report covers problem, theory, requirements, architecture, implementation, validation and limitations, in that order, with a coherent thread running through it. What is missing is a state of the art with sources, an experimental method for the one measurement given, and any planning or scheduling view of a six-month internship.

## Quality of validation

This is the weakest part of the report. Three tiers of testing are described honestly, and the report itself states the central weakness in Section 5.5.3. But Table 5.4 describes one test as covering three transforms when it covers two, omits five of the fifteen test files that exist (four of them tier two), and Table 5.6 marks thirteen functional requirements "Met" without distinguishing what an automated test established from what was observed by hand.

## Quality of visuals

Strong material, weakened by two defects and one omission.

The diagrams are consistent in style, mostly correct and mostly well chosen. Figure 5.3 (bytes to elements) is the best figure in the report and is worth defending on its own. Against that: **no figure in the report is cross-referenced from the text**. Thirty-three of the thirty-seven figures and ten of the thirty tables carry a `\label` that is never used by a `\ref`. Figure 4.1, the first architecture figure a jury sees, draws the captured trace travelling from the target to the host along a path that bypasses the debug probe, which contradicts the report's central claim.

## Suitability for the intended jury

Good, with reservations. The heavy use of tables suits a reader with weak English well, and the sentences in Chapters 2 to 5 are short and single-idea. Three things work against that audience: figures that the text never points to; the acronym **DAP** used for three different things (Debug Access Port, Debug Adapter Protocol, CMSIS-DAP) including on two figure arrows; and the absence of any figure at all in Section 5.3.1, which is the most technical and most defensible part of the contribution.

## Major risks to the final evaluation

1. **The 144-byte figure.** It appears in both abstracts, in the conclusion, in Table 5.7 and in Figure 5.3. Figure 5.3 shows on its own face that frame 0 is the host-inserted barrier. A jury member who reads the figure and the table together will see the discrepancy without any outside evidence.
2. **The "frozen oracle".** The word claims independent ground truth; the test is a regression baseline. Section 5.5.3 admits this, Tables 5.4 and 5.6 do not.
3. **An unsourced state of the art.** Chapter 1 carries one citation in six pages. The bibliography contains no peer-reviewed paper, while two directly on-topic papers were available and uncited.
4. **The broken chapter contents pages.** Chapters 4 and 5 open with the wrong chapter's contents list; Chapters 1 to 3 have none. This is visible in the first second of opening either chapter.

No numerical grade is offered: no grading rubric was supplied, so a number would be invented.

---

# PART 2 — CRITICAL FINDINGS

---

### F1 — The capture size counts sixteen bytes the host inserted

- **Severity:** CRITICAL
- **Category:** A (objectively incorrect) with a D (misleading) consequence
- **Location:** Table 5.7 "Measured figures for one capture" (p. 96); §5.5.6 (p. 96); Conclusion (p. 98); English abstract and French abstract (`global_config.tex`); Figure 5.3 (p. 75)

**Finding.** Table 5.7 states "Capture size: 144 bytes, nine formatter frames" and derives "Executed instructions per byte captured: 0.79" and "the two kilobytes of the sink hold on the order of sixteen hundred executed instructions". The device produced 128 bytes. The first sixteen bytes are the frame-synchronization barrier that the extraction driver emits ahead of every payload on the host side.

**Why it is a problem.** The number is the report's headline result and appears in both abstracts. It attributes to the on-chip trace buffer sixteen bytes that never occupied it. Every derived figure is wrong in the conservative direction, so the report also understates its own result by about thirteen per cent.

**Evidence — confirmed.**
- `engine/test_resources/etm_dump.bin` is exactly 144 bytes. Its first sixteen bytes are `ff ff ff 7f` repeated four times.
- `engine/external/openocd/src/target/arm_tmc.c:57` defines `tmc_fsync_barrier` as that exact 16-byte pattern; `tmc_output_write` (lines 336-370) emits the barrier to the callback, the file and the TCP connection **before** the payload.
- `TraceManager::OnCapture` (`modules/core/src/components/trace_manager.cc:170`) accumulates the barrier into `pending_` and appends the payload to it, so the block handed to the decoder is barrier + payload.
- `openocd_provider_hw_test.cc:166-180` asserts "exactly 2 callback invocations", the first being the 16-byte barrier and the second the capture data. The report itself states this in §5.5.3.
- **The report's own Figure 5.3 shows it**: the "Frames" box reads "frame 0  four frame-synchronization patterns, the barrier", inside a capture the same figure labels "144 bytes in all, nine frames".

**Required correction.** Report the device-produced payload separately from the host-inserted barrier. Suggested Table 5.7 rows: "Trace produced by the device: 128 bytes, eight formatter frames"; "Host-inserted synchronization barrier: 16 bytes, one frame"; "Executed instructions per byte produced by the device: 0.89"; and revise the extrapolation to "on the order of eighteen hundred". Correct the same number in both abstracts and in the conclusion.

**Kind of work:** rewriting plus arithmetic. No new experiment needed.

---

### F2 — The "frozen oracle" is a regression baseline, not an oracle

- **Severity:** CRITICAL
- **Category:** B (factually unsupported), presented as verification
- **Location:** Table 5.4 row `trace_provider_test` (p. 91); Table 5.6 row FR5 (p. 95); §5.5.3 (p. 91)

**Finding.** Table 5.4 says the test verifies "the whole offline pipeline against the frozen oracle of Table 5.7" and Table 5.6 records FR5 as Met on that basis. The expected values were produced by the implementation under test on its own first successful run.

**Why it is a problem.** An oracle is an independent statement of the correct answer. A value captured from the implementation's first green run can only detect a later regression; it cannot establish that the first run was right. FR5 is "Reconstruct the sequence of executed instructions" — the single most important functional requirement in the report — and its cited evidence is circular.

**Evidence — confirmed.** `modules/providers/trace/trace_provider/test/trace_provider_test.cc`, header comment: *"Counts below were frozen from this test's first green run against test_resources/etm_dump.bin."* The assertions are `instructions.size() != 114`, `function_blocks.size() != 6`, `gaps.size() != 2`.

**Mitigating fact, in the author's favour.** §5.5.3 already states this weakness plainly and identifies the fix: *"The stretch of execution from reset to the entry of the main function is fixed startup code and is therefore known in advance, which makes it an exact oracle for a reconstructed instruction sequence. The tests assert an instruction count and a set of general properties rather than that literal sequence."* That paragraph is the most credible thing in Section 5.5 and should be the frame for the whole section, not a footnote to it.

**Required correction.** Either (a) close it — the independent oracle exists and is cheap: disassemble the startup code from the same ELF and derive the executed sequence by hand or by a short script that does not use the trace pipeline, then assert the literal address sequence; or (b) stop calling it an oracle. Rename the row to "regression baseline", and change Table 5.6's FR5 evidence to a plain statement of what was actually checked: every reconstructed address resolves to an instruction in the image, at least one function block carries a resolved name, and the counts have not changed since the baseline was taken. Option (a) is worth the few hours it costs; it converts the weakest claim in the report into the strongest.

**Kind of work:** (a) technical work plus additional evidence; (b) rewriting only.

---

### F3 — `transform_test` does not cover the third transform

- **Severity:** HIGH
- **Category:** A (confirmed mismatch between the report and the implementation)
- **Location:** Table 5.4 row `transform_test` (p. 91); Table 5.6 row FR7 (p. 95); §5.3.5.3 (p. 78)

**Finding.** Table 5.4 states that `transform_test` verifies "the three reconstruction transforms over a record sequence". It exercises two of the three. The gap transform is not included and not exercised, and the capture-boundary gap is exercised by no automated test at all.

**Evidence — confirmed.**
- `modules/providers/trace/trace_transform/test/transform_test.cc` includes only `reconstructed_instruction_transform.hpp` and `function_block_transform.hpp`. `trace_gap_transform.hpp` appears nowhere in the file. Its own header comment lists its cases: the `last_instr_executed` case, the inline-chain split and same-function merge case, the assembly-file case, and a concept-rejection case. No gap case.
- The capture-boundary gap is emitted in `trace_session.cc` only when `impl_->capture_count > 0`. `trace_provider_test.cc` calls `session.Append(...)` exactly once, so that branch never executes in any test.

**Why it is a problem.** FR7 ("Represent a discontinuity in the capture explicitly, rather than joining the two sides of it") is a distinctive requirement — it is the property that separates this record from a naive concatenation — and the boundary case is the one the requirement was written for. Its verification row cites a test that does not reach it.

**Required correction.** Add gap cases to `transform_test` (overflow, trace-on, loss of synchronization) and a two-`Append` case to `trace_provider_test` that asserts a `kCaptureBoundary` gap at the right instruction index. Then correct Table 5.4's description and Table 5.6's FR7 evidence. If the tests are not added before submission, correct the two table rows and say plainly that the boundary case is verified by observation in the frontend only.

**Kind of work:** technical work, then rewriting. The rewriting alone is mandatory.

---

### F4 — The justification for the two-path architecture misattributes the constraint

- **Severity:** HIGH
- **Category:** A (objectively incorrect as stated), affecting the central design decision
- **Location:** §4.3.4.2 "The Direct Server Path" (p. 58); §4.3.4.3 (p. 58)

**Finding.** The report states: *"That protocol cannot express what the trace pipeline needs. Configuring trace components, draining a trace buffer and reading memory while the processor is running have no equivalent among its operations."* Two of the three items are not properties of the GDB Remote Serial Protocol.

**Why it is a problem.** This paragraph is the entire stated justification for driving two systems against one device, which is the defining decision of the engine and the source of the reset conflict, the concurrency model and the attach-mode limitation. If the justification is wrong, a jury will ask whether the whole two-path design was necessary. It was — but for a different reason than the one given.

**Evidence — confirmed.**
- The project's own architecture documentation contradicts the memory claim: `engine/docs/architecture/04-event-dataflow.md`, "Threading takeaway": *"they read through `OpenOcdProvider` directly, not through LLDB at all, specifically so they keep working regardless of whether the target is halted (**LLDB access requires a stopped process; OpenOCD's GDB Remote path doesn't**)."* The halt requirement belongs to LLDB's process model, not to the protocol.
- The protocol carries `qRcmd` (the `monitor` command), which transports an arbitrary server command as text and is the ordinary way tools drive OpenOCD-specific features. LLDB exposes it as `process plugin packet monitor`. So "configuring trace components has no equivalent among its operations" is overstated: an equivalent exists, it is simply untyped text with unstructured replies.

**Required correction.** Restate the justification in terms that survive scrutiny. Three accurate reasons are available and are all stronger than the one given: the debugger library's embedding interface exposes memory only through a process object that must be stopped; the protocol's escape hatch returns unstructured text, whereas the engine needs typed results (registers, capability sets, capture buffers) to configure the decoder from the hardware; and the trace callback is a push from the server, which the protocol has no way to deliver. Keep the sentence about reads being performed by the debug hardware rather than by the processor — that one is correct and is the good half of the paragraph.

**Kind of work:** rewriting, informed by the project's own architecture notes.

---

### F5 — Figure 4.1 routes the captured trace around the debug probe

- **Severity:** HIGH
- **Category:** A for the diagram; D in effect
- **Location:** Figure 4.1 "Global architecture of the solution" (p. 46); source `img/gen_fig/fig_global_architecture.tex`

**Finding.** A grey arrow labelled "captured trace" is drawn from the bottom of the *Target device* box, down and to the left, into the bottom of the *Host computer* box. It does not pass through the *Debug probe*.

**Why it is a problem.** The claim the whole project rests on is that the trace comes back over the ordinary debug connection with no extra hardware. This figure shows it arriving by some other route. It is the first architecture figure in the report, and it contradicts Figure 4.4 (which routes the trace correctly through the access port), §4.2.3, and NFR1. A jury reading figures rather than English will take away the opposite of the thesis.

**Evidence — confirmed.** `fig_global_architecture.tex`, last drawing command: `\draw[tr] (tg.south) -- ++(0,-9mm) -| node[lbl,pos=0.25,below]{captured trace} (host.south);`. The probe node `(pr)` is not on that path.

**Required correction.** Route the trace arrow back through the probe, along the SWD link and the direct path, so that it visibly reuses the same connection. One line of TikZ. Consider labelling it "captured trace, over the same connection" so the point is made without a sentence.

**Kind of work:** presentation change only, but it is not optional.

---

### F6 — Chapter contents pages are wrong or missing

- **Severity:** HIGH
- **Category:** G (formatting)
- **Location:** chapter title pages; visible on PDF pages 62 and 83 of the rebuilt document

**Finding.** Chapters 1, 2 and 3 open with no chapter contents list. Chapter 4 opens with a list headed "Contents" containing *Host Organization / Project Context / Conclusion* — the sections of Chapter 1. Chapter 5 opens with the sections of Chapter 2.

**Why it is a problem.** It is wrong on the first page of the two chapters that carry the contribution, and it is exactly the kind of defect that reads as carelessness whatever the quality of the content.

**Evidence — confirmed.** Reproduced in a clean three-pass rebuild with `biber`, and present identically in the previously committed `main.pdf` (its pages 63 and 78), so it is not an artefact of the rebuild. `aux/` contains `main.mtc` through `main.mtc11`, which is more minitoc files than there are chapters.

**Required correction.** The class calls `\minitoc` from inside `\@makechapterhead` and `main.tex` uses `\input` plus `\clearpage` for each chapter rather than `\include`. Either switch the chapter inclusions to `\include`, or place an explicit `\minitoc` (or `\adjustmtc`) per chapter, and verify on a clean `aux/` that each chapter's list matches its own sections. If it cannot be made correct quickly, suppress the chapter contents lists entirely with `\dominitoc` removed — no list is far better than the wrong list.

**Kind of work:** presentation change.

---

### F7 — The state of the art has no sources

- **Severity:** HIGH
- **Category:** B (factually unsupported)
- **Location:** Introduction (p. 1); §1.2.2, §1.2.3 (pp. 5-7); Tables 1.1, 1.2, 1.4

**Finding.** Citation counts per file: introduction 0, Chapter 1 **1**, Chapter 2 96, Chapter 3 8, Chapter 4 **0**, Chapter 5 **0**, conclusion 0. The single Chapter 1 citation supports the company's global presence, not any technical claim. Tables 1.1 (IDE vendors), 1.2 (debugger features) and 1.4 (probe limitations) — the whole competitive analysis on which the project's motivation rests — carry no source at all.

**Why it is a problem.** The report asserts what four commercial toolchains do and do not support, and closes §1.2.3 with a universal negative: *"no IDE provides support for On-Chip trace solutions on hardware probes beyond their proprietary ones"*. A jury is entitled to ask how that was established. Chapter 2, by contrast, cites almost every sentence, which makes the contrast within one document impossible to miss.

**Required correction.** Cite the vendor documentation behind each row of Tables 1.1, 1.2 and 1.4 (IAR C-SPY and I-jet documentation, Keil µVision and ULINK documentation, Arm Development Studio, SEGGER J-Link and Ozone manuals), or state in the table caption that the entries come from the author's own evaluation of the tools during the internship and give the versions tested. Soften the universal negative to what can be shown: "the tools examined during this work do not expose on-chip trace capture through a probe other than their own". Both routes are acceptable; leaving it as it stands is not.

**Kind of work:** additional evidence and rewriting.

---

### F8 — Table 2.9 is uncited, incomplete, and hides the ETM version

- **Severity:** HIGH
- **Category:** B and C
- **Location:** Table 2.9 "Trace capability of the STM32 families" (p. 36)

**Finding.** The table asserts, for seven family groups, which implement a trace unit and which implement an on-chip trace sink. It carries no citation. It omits STM32L1, STM32WB, STM32WBA, STM32WL and STM32MP. The "C5" entry cannot be verified from any document supplied with the project. Most importantly, the "Instruction trace ✓" column does not distinguish ETMv3 from ETMv4.

**Why it is a problem.** Three separate consequences.
1. The only supplied source that covers this ground, AN4989 Rev 4 Appendix D Table 7, spans just L0/F0, F1/L1/F2, F3/F4/L4 and F7/H7. Everything else in the table is unsupported by the material available to the reader.
2. The report's implementation supports ETMv4 only (§5.3.7). A reader who takes Table 2.9 at face value will conclude the drivers reach every family with a ✓ in that column, which is not true for the ETMv3 families.
3. The omissions are not random: the wireless families are a substantial part of the range.

**Evidence.** Verified positively where documents exist: RM0433 §60.5.5 (STM32H743/753, 4-Kbyte ETF), RM0468 §65.5.4 (STM32H723/730, 2-Kbyte ETF), RM0477 §66.6.10 (STM32H7RS, 2-Kbyte ETF), and the absence of any ETF section in RM0481 (STM32H5) and RM0456 (STM32U5) — all consistent with the report. Unverifiable from supplied material: the C5, U3, G4, L4+, U0 and N6 rows.

**Required correction.** Add a fourth column, "Trace unit architecture" (ETMv3 / ETMv4), which immediately tells the reader which families the drivers of Chapter 5 could serve. Cite each row to its reference manual or to AN4989. Add L1 and the wireless families, or narrow the caption to the families the survey actually covered and say why the others are excluded. This table is also the single best place in the report to state, once, the fact that carries the whole scope decision: no STM32 device implementing ETMv3 carries an on-chip trace buffer, so the on-chip route and ETMv4 coincide exactly.

**Kind of work:** additional evidence and a table revision. High value for the effort: it converts a liability into the strongest argument for the scope of the work.

---

### F9 — Every quantitative result comes from one capture, with no stated method

- **Severity:** HIGH
- **Category:** B (factually unsupported), experimental methodology
- **Location:** Table 5.7 (p. 96); §5.5.6; both abstracts

**Finding.** Eleven measured quantities are reported. All eleven come from one 144-byte capture of one deterministic startup sequence in one firmware image. "Decode and reconstruction time: 0.112 ms" is given with no host machine, no build configuration, no repetition count, no variance, and no statement of whether the one-off disassembly of the program image is inside or outside the measurement.

**Why it is a problem.** "In a tenth of a millisecond" is quoted in both abstracts and in the conclusion. It is not reproducible from anything in the report, and nothing in the test suite prints a time, so the reader cannot even locate where it came from.

**Evidence.** `trace_provider_test.cc` prints instruction, block and gap counts and nothing else; no timing instrumentation exists in `trace_session.cc` or `trace_decoder.cc`. Table 3.7 lists host platforms but no machine.

**Required correction.** Two options, in order of preference.
(a) Take three or four captures instead of one — the same startup interval, plus an interval inside the application, plus one long enough to wrap the buffer — and report density and time per capture. This also produces the wrapped-buffer and multi-capture-boundary evidence that F3 and F25 need, and it is the difference between "the pipeline worked once" and "the pipeline works".
(b) At minimum, add one paragraph before Table 5.7 stating the host CPU, the build configuration, how many times the measurement was repeated, what the reported value is (mean, median, single run), and what is included in it. Then label the table "figures for one capture, indicative only" in the text as well as the caption.

**Kind of work:** (a) additional experiments, one afternoon; (b) rewriting. (b) is the minimum acceptable.

---

### F10 — No figure in the report is referenced from the text

- **Severity:** HIGH
- **Category:** G (formatting), with a comprehension cost for this jury
- **Location:** throughout

**Finding.** Thirty-three of the thirty-seven figures carry a `\label` that no `\ref` in the document uses. The four exceptions are Figures 1.2, 2.7, 3.1 and 5.3. Ten tables are likewise never referenced, including seven of the eight tables in Chapter 3 and Tables 1.1, 1.2 and 1.4 in Chapter 1.

**Why it is a problem.** Every figure uses `[H]` placement, so each sits exactly where it was written and is never named by the surrounding paragraph. A reader with weak English who has just failed to parse a paragraph has no signal telling them that the picture immediately below is the same idea. For this jury the figures are the primary channel, and they are all unlabelled in the prose.

**Evidence — confirmed.** Mechanical check over all `\label`/`\ref` pairs in the sources. Sample of unreferenced figure labels: `fig:anatomy`, `fig:breakpoints`, `fig:three_reps`, `fig:addrmap`, `fig:dap`, `fig:loop_elements`, `fig:global_arch`, `fig:pipeline`, `fig:on_target`, `fig:drain`, `fig:e2e`, `fig:trace_model`, `fig:trace_life`, `fig:layers`, `fig:context`, `fig:providers`, `fig:division`, `fig:eventflow`, `fig:req_wire`, `fig:frontend`, `fig:chronology`, `fig:extraction`, `fig:termination`, `fig:cmdqueue`, `fig:session`, `fig:resync`, `fig:bpdecision`, `fig:periprace`, `fig:trace_views`, `fig:mem_periph_views`.

**Required correction.** Add one sentence per figure that names it and says what to look at, in the paragraph that introduces it. "Figure 4.4 shows the path the trace takes on the device, and the separate path by which the host configures the two components." This is roughly forty short sentences and it is the single highest-value change available for this jury.

**Kind of work:** rewriting, mechanical, no technical risk.

---

### F11 — DHCSR `C_HALT` is described as a status bit

- **Severity:** MEDIUM
- **Category:** A (confirmed error)
- **Location:** Table 2.3 "Registers governing halting debug", DHCSR row (p. 28)

**Finding.** The table's Effect column for `C_HALT` reads "Set when the processor is halted."

**Evidence — confirmed error.** Arm DDI0403E.e, C1.6: *"C_HALT, bit[1]  Processor halt bit. The effects of writes to this bit are: 0 Causes the processor to leave Debug state, if in Debug state. 1 ..."*. It is a control bit written by the debugger to request a halt or a resume. The status bit is `S_HALT`, bit[17]: *"Indicates whether the processor is in Debug state ... This bit is read-only."* `S_HALT` does not appear in the table at all.

**Why it is a problem.** The table is titled "Registers governing halting debug" and its columns are Control and Effect. Describing the halt *request* as a status reading is the one error in that table that would let a jury member conclude the author has not read the register description.

**Required correction.** Change the `C_HALT` effect to "Requests a halt when written as one, and a resume when written as zero. The processor also sets it on entry to Debug state." Add an `S_HALT` row: "Reports that the processor is in Debug state. Read-only."

**Kind of work:** rewriting, two lines.

---

### F12 — RM0477 is cited for DBGMCU controls it does not contain

- **Severity:** MEDIUM
- **Category:** B (the citation does not support the claim)
- **Location:** §2.9.2.3 "Trace Pin and Clock Control" (p. 37)

**Finding.** The report states: *"It assigns the trace pins, enables the trace clock, and enables trace itself \cite{rm0477}. On devices that separate them, it further controls the power domains of the debug and trace logic \cite{rm0477}."*

**Evidence — confirmed.** RM0477 Rev 9, DBGMCU_CR at offset `0x004`, carries exactly: `TRGOEN` (bit 28, trigger pin direction), `DBGCKEN` (bit 21, debug clock enable), `TRACECLKEN` (bit 20, trace port clock enable), `DCRT` (bit 16), and `DBG_STANDBY`/`DBG_STOP`/`DBG_SLEEP` (bits 2:0). There is no trace-pin assignment control and no trace enable. Trace pin assignment on this board is ordinary GPIO alternate-function configuration (UM3276 Table 7: PE2, PE3, PG14, PD2, PC12). The controls the sentence describes are `TRACE_IOEN` and `TRACE_MODE[1:0]` — RM0090 names them *"Trace pin assignment control"* — and they belong to the F2/F4/F7 DBGMCU. On H7 and H7RS the per-domain controls are debug **clock** enables (`D1DBGCKEN`, `D3DBGCKEN` in RM0433), not power-domain controls.

**Mitigating fact.** The paragraph closes with "Which of these are present is a property of the family", which is the right hedge. The problem is the citation, which points at the one family that has none of them.

**Required correction.** Split the sentence by family. Cite RM0090 or RM0410 for trace-pin assignment and trace enable, cite RM0477 for the trace clock enable, and replace "power domains" with "the debug clocks of each power domain" citing RM0433.

**Kind of work:** rewriting plus two citations.

---

### F13 — `TRCVIPCSSCTLR` is named the context comparator control

- **Severity:** MEDIUM
- **Category:** A (terminology error)
- **Location:** the sentence after Table 5.2 (p. 71)

**Finding.** *"The remaining registers of the override path, namely the stall control, the include and exclude control, the start and stop control and the context comparator control..."*

**Evidence — confirmed.** In `arm_etmv4.c` the fourth of those is `ETMV4_TRCVIPCSSCTLR`, written under `if (caps->numpc)`. `numpc` is `TRCIDR4.NUMPC`, the number of **PE comparator** inputs. IHI0064H.b names the register the *ViewInst Start/Stop PE Comparator Control Register*. Context-ID comparators are a different resource (`TRCIDR4.NUMCIDC`, parsed into `caps->numcidc` at `arm_etmv4.c:257`) with different registers.

**Required correction.** "the start and stop control for the PE comparators".

**Kind of work:** rewriting, one phrase.

---

### F14 — "Component discovery" means two different things

- **Severity:** MEDIUM
- **Category:** E (technically correct, poorly presented)
- **Location:** §5.3.7 first limitation (p. 78) against Table 5.6 row FR1 (p. 95)

**Finding.** §5.3.7: *"Component discovery is not implemented."* Table 5.6, FR1: *"Component discovery and register readback against the device — Met."*

**Why it is a problem.** The two uses are eleven pages apart in the same chapter and appear to contradict each other. One means reading the ROM tables to find components on an unknown device; the other means enumerating the objects a configuration script created. A jury will read the second and remember the first.

**Required correction.** Reserve "component discovery" for the ROM-table sense. In Table 5.6 write "Trace source and sink located and their registers read back against the device".

**Kind of work:** rewriting, one table cell.

---

### F15 — The test inventory omits a third of the tests, including four tier-two tests

- **Severity:** MEDIUM
- **Category:** C (incomplete), and it undersells the work
- **Location:** Table 5.4 "Test inventory" (p. 91); §5.5.1

**Finding.** The text says "Table 5.4 lists the tests of the first two tiers". The table lists ten. Fifteen test files exist. The five omitted are `handshake_test.py`, `attach_smoke_test.py`, `launch_smoke_test.py`, `stepping_smoke_test.py` and `peripheral_smoke_test.py`.

**Why it is a problem.** §5.5.1 defines tier two as protocol-level tests driven by a script against a device, covering "launching, attaching, stepping, breakpoints, peripheral access and trace". Those tests exist — they are exactly the five omitted files — and the table shows only one tier-two entry. As a result Table 5.6 verifies FR9, FR11 and FR12 by assertion when automated evidence for them is sitting in the repository.

**Evidence — confirmed.** File listing under `engine/modules/**/test/`. `PROJECT_STATUS.md` lists all five under "Tests".

**Required correction.** Add the five rows. Then rewrite the FR9, FR11 and FR12 rows of Table 5.6 to name the script that establishes each.

**Kind of work:** rewriting. Pure gain: it strengthens the validation section at no cost.

---

### F16 — Figure 4.9 draws one dependency backwards

- **Severity:** MEDIUM
- **Category:** A for the diagram
- **Location:** Figure 4.9 "Module dependency graph" (p. 55); source `img/gen_fig/fig_module_layers.tex`

**Finding.** The arrow from *Protocol transport* to *Handlers* points downward, which in a dependency graph reads "the transport depends on the handlers". The dependency runs the other way.

**Evidence — confirmed.** `engine/docs/architecture/01-modules-and-layers.md` extracts the link graph from CMake: `dap_handlers --> dap_core`, `dap_handlers --> core`, `dap_core --> dap_protocol`, `core --> dap_protocol`. `dap_core` does not link `dap_handlers`. The `ln` style in `fig-preamble.tex` is a single-headed Stealth arrow, so direction is asserted, not neutral.

**Note.** The other three arrows in the same figure are correct, so the figure mixes "depends on" with "hands work to". Either semantics can be drawn; only one can be labelled "dependency graph".

**Required correction.** Reverse the transport-to-handlers arrow, or relabel the figure "Layers and the direction of dependency" and use a second line style for the runtime dispatch direction.

**Kind of work:** presentation change.

---

### F17 — "49 protocol handlers" counts two handlers the table does not

- **Severity:** MEDIUM
- **Category:** C
- **Location:** §5.4.10 (p. 87) and §5.5.6 (p. 94); Table 5.3 (p. 88)

**Finding.** The figure 49 is literally correct but includes `UnknownRequestHandler`, the catch-all for unrecognised requests, and `TestGetTargetBreakpointsRequestHandler`, a test-only handler. Table 5.3 enumerates 47 request names and includes neither.

**Evidence — confirmed.** `modules/dap/src/handlers/register_handlers.cc` performs 49 `Register<...>` calls; the last is `UnknownRequestHandler`.

**Why it is a problem.** The number is quoted twice, once as a *result*. A count of registered handler classes is a weak result in any case, and a jury that opens `register_handlers.cc` will find that two of the forty-nine implement no protocol request.

**Required correction.** Say "forty-seven protocol requests, listed in Table 5.3, together with a catch-all handler for unrecognised requests". Better still, drop the number from the Results section: the useful statement is which capabilities exist, which Table 5.3 already gives.

**Kind of work:** rewriting.

---

### F18 — Scope exclusions are stated without their reasons

- **Severity:** MEDIUM
- **Category:** C (incomplete)
- **Location:** §5.3.7, limitations two and three (p. 78)

**Finding.** *"Only one trace protocol version is supported ... the earlier version is not implemented."* and *"Only one trace source and one sink are used ... multiple-core tracing is not supported."* Both are stated as bare absences.

**Why it is a problem.** Both are defensible scope decisions with sound reasons, and both read as gaps without them. Not supporting ETMv3 costs nothing, because no STM32 device that implements ETMv3 carries an on-chip trace buffer — the on-chip route the project took and the ETMv4 devices are the same set. Multi-core tracing is outside what a proof of concept on a single-core target needs to establish. Stating the reason turns each from a weakness into a boundary the author chose deliberately.

**Required correction.** One clause on each. "The earlier version is not implemented, and no capability is lost by that, since no STM32 device implementing it carries an on-chip trace sink." "Multiple-core tracing is outside the scope of a proof of concept on a single-core target."

**Kind of work:** rewriting. Two sentences, disproportionate defence value.

---

### F19 — The error model overstates what survives a contained termination

- **Severity:** MEDIUM
- **Category:** C (incomplete)
- **Location:** §4.4.1 "Error Model" (p. 64); §5.4.1.2 "Containing Process Termination" (p. 79)

**Finding.** §4.4.1 states the rule as *"a failed operation produces an error response and never terminates the session"*. §5.4.1.2 names one consequence, that destructors do not run on the abandoned call chain. The stronger consequence is not stated: a non-local jump out of the middle of a C library leaves that library's own heap allocations and internal state in an undefined condition, so continuing the session afterwards is not free.

**Evidence.** `modules/providers/openocd_provider/src/openocd_jmp.h`, the author's own comment: *"No cleanup runs for any C++ object still in scope on the aborted call chain when that happens — **by design, this is only ever meant to precede terminating the whole engine**."* Yet every provider entry point converts an escape into an error string and continues: `openocd_provider.cc:230, 244, 250, 255, 297`, each returning `std::unexpected("openocd_exit(...) during ...")`.

**Why it is a problem.** The report describes the recovery as complete. The implementation's own documentation describes the mechanism as a last resort before shutdown. Whichever is right, the report should say which, because a jury member who has written `longjmp` out of C will ask.

**Required correction.** Add one sentence to §5.4.1.2: the session survives and the failure is reported, but the server's internal state after such an escape is not guaranteed, so the mechanism is a containment of the last resort rather than an ordinary error path. Then soften §4.4.1's rule to "a failed operation produces an error response rather than ending the process".

**Kind of work:** rewriting. Consider also reconciling the header comment with the actual use, which is a code change outside the report.

---

### F20 — Table 1.4's capture column is undefined and marks two probes wrongly

- **Severity:** MEDIUM
- **Category:** D (misleading)
- **Location:** Table 1.4 "Debug Probe Limitations" (p. 7)

**Finding.** The column "Trace Stream Capture" marks ST-LINK and CMSIS-DAP with ✗. Both capture a trace stream: ST-LINK V2 and V3 capture SWO, and CMSIS-DAP v2 defines SWO streaming endpoints. If the column means capture of the parallel trace port, it does not say so.

**Why it is a problem.** The report elsewhere is careful about exactly this distinction — §3.3.3 says correctly "The probe has no *instruction trace* capability", which is the precise claim. Table 1.4 states a broader claim that is not true.

**Required correction.** Rename the column "Parallel trace port capture", or "Instruction trace capture". One word fixes it.

**Kind of work:** presentation change.

---

### F21 — Table 1.1 lists debug servers in the Debugger column

- **Severity:** MEDIUM
- **Category:** E
- **Location:** Table 1.1 "Embedded Systems IDE Vendors" (p. 6)

**Finding.** The free row gives "OpenOCD/PyOCD" as the Debugger. Both are on-chip debug servers. The debugger in that stack is GDB or LLDB. The ST row gives "ST-OpenOCD" in the same column, where the debugger is GDB driven through the ST-LINK GDB server.

**Why it is a problem.** §2.1.2 draws exactly this distinction, carefully, six pages later. A table that blurs it in Chapter 1 undermines the section that defines it in Chapter 2.

**Required correction.** Either split the column into "Debugger" and "Debug server", which also improves the table (it makes the free stack look like a stack rather than a gap), or put "GDB/LLDB with OpenOCD or pyOCD" in the cell.

**Kind of work:** presentation change.

---

### F22 — OpenOCD's existing trace support is never acknowledged

- **Severity:** MEDIUM
- **Category:** B, and a defence exposure
- **Location:** §1.2.3 closing claim (p. 7); §5.3.1 opening sentence (p. 70)

**Finding.** §5.3.1 opens *"The debug server used provides no support for the trace components required."* OpenOCD ships `src/target/etb.c` (an Embedded Trace Buffer driver) and `src/target/etm.c` (ETMv1 to ETMv3), both present in the fork, plus `arm_tpiu_swo.c`.

**Why it is a problem.** The sentence as written is true only when scoped to ETMv4 and the Trace Memory Controller, which is what the author means. But a jury member who opens the OpenOCD tree — which is a plausible thing for an examiner of this project to do — will find `etb.c` and `etm.c` and conclude the report overstated the gap. The correctly scoped claim is *stronger*, because it says precisely what was missing and why the existing drivers do not help: `etm.c` targets ARM7 and ARM9 cores, and `etb.c` targets the legacy CoreSight ETB, not the TMC.

**Required correction.** Rewrite the opening as: "The debug server implements the earlier trace macrocell and the legacy embedded trace buffer, for ARM7 and ARM9 cores. Neither reaches an ETMv4 trace unit nor a Trace Memory Controller, so two drivers were written." Apply the same scoping to the §1.2.3 universal negative (see F7).

**Kind of work:** rewriting.

---

### F23 — Figure 2.1 places the GDB RSP inside a single process

- **Severity:** MEDIUM
- **Category:** D
- **Location:** Figure 2.1 (p. 10); §2.1.2 (p. 9)

**Finding.** The figure draws one *Backend* box containing *Program representation* and *Target interaction*, with "RSP" labelling the link between them. §2.1.2 says the protocol runs "between the target driving interface of a debugger, and the rest of the backend".

**Why it is a problem.** The RSP is a remote protocol between a debugger and a stub or server in a different process. There is no version of the architecture in which it is the seam between two halves of one backend. In this project specifically it runs between LLDB and OpenOCD, both of which the report elsewhere treats as separate systems (§4.3.4). The figure therefore contradicts the report's own later architecture.

**Required correction.** Move the RSP label to the link between the backend and a *Debug server* box, and put the probe beyond that. This also makes Figure 2.1 prefigure Figure 4.1 rather than conflict with it.

**Kind of work:** presentation change.

---

### F24 — Trace generated during a single step is lost, and the report does not say so

- **Severity:** MEDIUM
- **Category:** C
- **Location:** §5.3.1.5 "Coupling Trace Control to the Target Run State" (p. 72)

**Finding.** The report states: *"A step is treated differently by the two drivers. The source is started before the step is taken and the sink afterwards, so that the sink is not armed while the processor is momentarily running under the control of the debugger."* The consequence is not stated: with the source running and the sink not capturing, the trace produced by the stepped instruction is discarded.

**Evidence — confirmed.** `arm_etmv4.c` arms on `TARGET_EVENT_STEP_START` and stops on `TARGET_EVENT_HALTED`; `arm_tmc.c` arms on `TARGET_EVENT_STEP_END`. OpenOCD's Cortex-M step raises `TARGET_EVENT_HALTED` from inside the step, before `TARGET_EVENT_STEP_END`, so the trace unit runs and then stops with the sink still disabled.

**Why it is a problem.** The report presents the asymmetry as a design decision that avoids a hazard, without saying what it costs. A developer single-stepping through code and watching the trace view would reasonably expect the stepped instruction to appear.

**Required correction.** Add the consequence in one sentence, and say whether it matters: a step advances by one instruction that the developer is watching directly, so nothing useful is lost. If instead the asymmetry exists for a hardware reason, state that reason, because as written the stated rationale does not obviously follow from the ordering.

**Kind of work:** rewriting; a short check against the hardware behaviour would let the author state the reason with confidence.

---

### F25 — Both reported gaps are start-of-capture artefacts

- **Severity:** MEDIUM
- **Category:** D
- **Location:** Table 5.7 row "Gaps: 2" (p. 96); Table 5.6 row FR7

**Finding.** The two gaps counted in the measured figures are the loss-of-synchronization and the trace-on records that every capture begins with, because the host's own barrier resets the decoder. They are not discontinuities in the program's execution.

**Evidence — confirmed.** Figure 5.3's own "Packets" box shows the capture opening with `I_NOT_SYNC` at offset `0x10` and `I_TRACE_ON` at `0x24`. `trace_gap_transform.hpp` emits one gap for each `kNoSync` and each `kTraceOn` record. `trace_session.cc` adds a capture-boundary gap only when `capture_count > 0`, and this capture is the first.

**Why it is a problem.** In a table headed "Measured figures for one capture", "Gaps: 2" reads as "the program's execution had two holes in it". It did not.

**Required correction.** Either annotate the row — "Gaps: 2, both marking the start of the capture" — or split it into "start-of-capture markers: 2" and "discontinuities in the traced execution: 0". The second is better, because zero discontinuities in an unwrapped 128-byte capture is the correct and reassuring result.

**Kind of work:** rewriting.

---

### F26 — DAP denotes three different things

- **Severity:** MEDIUM
- **Category:** E, with a comprehension cost
- **Location:** §2.7.1 and Figure 2.5 (Debug Access Port); Figures 2.1 and 4.1 and Table 3.8 (Debug Adapter Protocol); Tables 1.1 and 1.4 (CMSIS-DAP)

**Finding.** The acronym list gives two expansions under one entry. A third, CMSIS-DAP, appears in Chapter 1 without comment. Two figure arrows are labelled "DAP" meaning the protocol, in a report whose Figure 2.5 is captioned "Structure of a Debug Access Port".

**Why it is a problem.** For a jury reading figures rather than paragraphs, an arrow labelled DAP between the frontend and the engine, in a document that has just spent two pages on the Debug Access Port, is a genuine trap.

**Required correction.** Never abbreviate the Debug Adapter Protocol. Label the arrows in Figures 2.1 and 4.1 "Debug Adapter Protocol" and write it out in Table 3.8. Keep DAP for the Debug Access Port only, and split the acronym-list entry into "DAP — Debug Access Port" and "CMSIS-DAP — the probe interface standard".

**Kind of work:** presentation change.

---

### F27 — Chapter structure is not uniform

- **Severity:** MEDIUM
- **Category:** G
- **Location:** Chapter 1; all chapters

**Finding.** Chapters 2 to 5 open with an unnumbered `Introduction` section and close with a numbered `Conclusion` section. Chapter 1 has no Introduction at all and closes with a numbered `1.3 Conclusion`. So the table of contents shows a numbered Conclusion in every chapter and never shows an Introduction.

**Required correction.** Add an Introduction to Chapter 1 and make Introduction and Conclusion consistently unnumbered (`\section*`) with `\addcontentsline` if they should appear in the contents, or consistently numbered. The `Rapport_Template_ISI.pdf` supplied with the project shows both as unnumbered headings within each chapter.

**Kind of work:** presentation change.

---

### F28 — The general introduction does not announce the plan of the report

- **Severity:** MEDIUM
- **Category:** G
- **Location:** `introduction.tex` (p. 1)

**Finding.** The introduction gives context, problem and proposed direction, then stops. It never tells the reader what the five chapters contain.

**Evidence.** `Rapport_Template_ISI.pdf`, "Introduction générale": *"elle s'achève sur une présentation claire du plan adopté pour la suite du corps du rapport. L'annonce du plan se fait au futur et doit être rédigée en entier."*

**Caveat.** That template is for a different institution and specialty than the one on the cover page, so treat it as a strong convention rather than a binding rule. It is a convention this jury will expect regardless.

**Required correction.** One paragraph of five sentences at the end of the introduction, one per chapter.

**Kind of work:** rewriting.

---

### F29 — The introduction and Chapter 1 contain grammatical and spelling errors

- **Severity:** MEDIUM (HIGH in the aggregate impression it creates)
- **Category:** G
- **Location:** `introduction.tex`; `chap_01.tex`; `remerciement.tex`

**Finding.** These two files read as an earlier draft that the revision of Chapters 2 to 5 never reached. Instances are listed in Part 7. The most damaging are a sentence with no working predicate (*"The gap between what a chip provides do and what the developer can actually reach is the central concerns of this project"*), two contractions (*won't*, *doesn't*), two misspellings (*targetted*, *ommitted*), a first-person plural (*when we move to*), and three comma splices with a capitalised word mid-sentence.

**Why it is a problem.** The problem statement is the paragraph the jury reads most carefully. Its central sentence does not parse.

**Required correction.** Rewrite `introduction.tex` and §1.2 to the standard of Chapter 2. Replacement wording for the worst passages is given in Part 7.

**Kind of work:** rewriting.

---

### F30 — Count-announcing openers, about thirty-one of them

- **Severity:** MEDIUM
- **Category:** G / E
- **Location:** Chapters 2, 4 and 5 throughout

**Finding.** Paragraphs opening with a bare count: thirteen in Chapter 2, nine in Chapter 4, nine in Chapter 5. "Four principles governed the decomposition." "Two components take part." "Three transformations are then applied." "Six limitations are stated here." "Two results carry beyond the project."

**Why it is a problem.** It is not an error, but it is the single most repetitive feature of the writing, and repetition of a sentence *shape* is more noticeable to a reader than repetition of a word. It also front-loads a number the reader has no use for before they know what is being counted.

**Required correction.** Convert most of them to a statement of the first item, or to a sentence that says what the items are for. "The decomposition follows from four principles" is no better. "The engine holds every debug capability, and the frontend none" is. Where the items are genuinely a set, a short list or a table is the better form.

**Kind of work:** rewriting, spread thinly across three chapters. Doing half of them would remove the impression.

---

### F31 — A chapter label is referenced as a section

- **Severity:** LOW
- **Category:** G
- **Location:** `chap_04.tex:236`, in §4.3.4.3 (p. 58)

**Finding.** `Section \ref{ch:implementation}` renders as "Section 5". It should read "Chapter 5".

**Kind of work:** presentation change, one word.

---

### F32 — `\hfuzz=100pt` hides overfull boxes

- **Severity:** LOW
- **Category:** G
- **Location:** `main.tex:4`

**Finding.** Overfull horizontal boxes are not reported until they exceed 100 pt, about 3.5 cm. The build reports five overfull boxes; the true number is unknown.

**Required correction.** Set `\hfuzz` to a normal value for one build, inspect what appears, fix the genuine cases (most will be wide table cells), and restore the setting only if some remain that cannot be fixed.

**Kind of work:** presentation change.

---

### F33 — Outstanding artwork

- **Severity:** noted once, as the author's own known state
- **Location:** §5.5.2 (p. 91)

The `\needshot{Hardware test bench}` placeholder still renders as a visible box in the compiled PDF. It must not survive to submission, but it is the author's plan, not a defect.

**On the decision behind it**, which is the reviewable part: the described content is right and the figure is more important than its position in the report suggests. It is the *only* direct evidence for NFR1 and for the claim that carries both abstracts. Make sure the photograph shows the MIPI20 connector (CN1) visibly empty, the single USB-C cable, and nothing else attached, and annotate those two points. A photograph with those two annotations settles NFR1 in one glance for a jury that will not read §5.5.2.

---

# PART 3 — CHAPTER-BY-CHAPTER REVIEW

## Introduction (p. 1)

**Technical content.** Correct in substance. The framing — hardware capability present, tooling access absent — is the right framing and survives the whole report.

**Problems.**
- No citations at all, for claims about the ecosystem that are not self-evident (F7).
- No announcement of the plan (F28).
- Language: comma splice in sentence one ("*asynchronous external events, this makes them*"); "*However, Despite the sophistication*" — redundant connective and a capital mid-sentence; "ARM" where the rest of the report writes "Arm" (F30 in Part 8).
- "*intrusive enough to perturb the behavior*" is an odd construction: intrusive **enough** reads as sufficiency where insufficiency is meant.

**Satisfactory.** Length and scope are right. The paragraph naming OpenCSD and describing the fragmented workflow is a good, concrete motivation.

## Chapter 1 — Context & Problem Statement (pp. 2-7)

**§1.1 Host Organization.** Adequate and conventional. Two observations. §1.1.5 is a single unbroken 130-word paragraph and should be split. Figures 1.1 to 1.3 are decorative; the supplied ISI template explicitly advises against repeating company imagery inside the body since it is already on the cover. Not a defect, but the three of them consume most of two pages that Chapter 1 could use for the state of the art.

**§1.2.1 Problem Statement.** The central sentence does not parse (F29). The argument underneath it is good and is the right argument: the common abstraction layer works for primitives and fails for anything vendor-specific. Rewrite it, do not shorten it.

**§1.2.2 State of the Art.** The weakest section in the report. Three comparison tables, no sources (F7), and a Debugger column that mixes debuggers with debug servers (F21). No academic work is surveyed at all, in a section titled State of the Art, while two directly relevant peer-reviewed papers were available (Part 6).

**§1.2.3 Critique.** Table 1.3 (capabilities unreachable through vendor tools) is the best thing in the chapter — it is specific, it is the actual argument for the project, and it is the only table here with a `\ref` from the text. Against that, Table 1.4's capture column is wrong as labelled (F20), and the closing universal negative is unsupported and exposed (F7, F22).

**§1.2.4 Proposed Solution.** Two sentences, one of them broken: "*adding support for the CoreSight components responsible for instruction trace open-source debuggers*" is missing a preposition. This paragraph is where a reader decides whether to keep reading; it deserves more than two sentences and should name the three deliverables that Chapter 3 will state.

**§1.3 Conclusion.** Generic. It says the chapter introduced the organization and the context, which the reader knows. Replace with the one sentence that carries forward: the hardware implements the capability, and the tooling does not expose it.

## Chapter 2 — Theory and Key Concepts (pp. 8-37)

This chapter is the strongest sustained writing in the report and is largely correct. Thirty pages of ninety-seven body pages is a lot, but the material is load-bearing: nearly every section is referred back to from Chapters 4 and 5, which is the right test and which the cross-reference counts confirm (`sec:primitives` is referenced fourteen times, `subsec:dwarf` ten, `sec:coresight` eight, `sec:arm_debug` nine).

**§2.1 Debugging Fundamentals.** Good. The frontend/backend/probe decomposition earns its place. Figure 2.1 misplaces the RSP (F23). The DAP subsection is accurate against the specification.

**§2.2 Debug Primitives.** Accurate. The software/hardware breakpoint distinction and its dependence on the memory map is set up here and paid off in §5.4.5 and in the defect table, which is good construction. Figure 2.2 is correct, including the instruction lengths.

**§2.3 Classes of Debugging.** §2.3.1 (intrusive) and §2.3.4 (run-control versus trace) are referenced later and earn their place. §2.3.2 (halt versus monitor mode) and §2.3.3 (live versus post-mortem) are never referred to again and describe mechanisms the project does not use. If length ever needs to come out of this chapter, these two subsections are the first candidates. This is a judgement call, not a defect: both are legitimate background for a report about a debugger.

**§2.4 Program Representation.** Excellent, and the best-motivated background in the report, because §2.4.4 on instruction decoding and mapping symbols is exactly what §5.3.4 implements. Figure 2.3 is a well-chosen figure. The claim in §2.4.4.1 that "the Arm architecture supports more than one instruction set within a single program" sits oddly two pages after §2.6.2 says the M-profile executes Thumb only; a clause scoping it to the architecture as a whole would remove the apparent contradiction.

**§2.5 Microcontrollers.** Short and correct. §2.5.1's point about read-side-effect registers is paid off in §5.4.7, which is good.

**§2.6 The Arm Cortex-M Architecture.** Correct. Figure 2.4 matches the ARMv7-M default map including the position of the PPB within the System region. Table 2.2 (AMBA buses) is accurate and well cited.

**§2.7 The Arm Debug Architecture.** Accurate against IHI0031H and the CoreSight guide. One confirmed error in Table 2.3 (F11). Figure 2.5 is a device-specific diagram in a section about a generic specification, and it duplicates the top-left corner of Figure 3.1; see Part 4.

**§2.8 The CoreSight Trace Architecture.** The core of the chapter and technically sound. Verified against IHI0064H.b, IHI0029G and DDI0461B: the element list, the address-omission principle, the formatter frame size, the bypass condition, the TMC configurations, the TMC modes, and the ETB/ETF memory range. Minor incompleteness in the element list (F35 in Part 8). Figure 2.6 is correct: three taken atoms and one not-taken for four iterations, sixteen reconstructed instructions.

**§2.9 STM32 Debug and Trace Infrastructure.** Table 2.9 is the problem (F8). §2.9.2.3 mis-cites (F12). The peripheral-freeze and low-power subsections are correct and well cited to AN4989.

**§2.10 Conclusion.** Genuinely good. The two-results framing — trace gives addresses, DWARF gives meaning, neither suffices alone — is the intellectual spine of the report and is stated better here than anywhere else. Consider promoting this paragraph, or a version of it, into the general introduction.

## Chapter 3 — Objectives Specification and Work Environment (pp. 38-44)

Compact, well organised, and the clearest statement of what the project set out to do. All device and board facts verified correct against DS14359 and UM3276.

**Problems.**
- Seven of the eight tables in this chapter are never cross-referenced from the text (F10).
- Table 3.6 lists four trace components and omits the ITM, the SWO, the replicator, the cross-trigger interface and the two system ROM tables. RM0477 §66.6 states the ETF captures from *two* sources, the ETM and the ITM. A row for the ITM would cost one line and would prevent the obvious question of what else shares the sink.
- No use-case view, no actor identification, and no planning or Gantt view of a six-month internship. Figure 5.1 partially covers the last of these, but with no time axis. See F42.
- NFR2 ("Operate on Windows and on Linux") is stated but no requirement covers the reproducibility of a capture, which is the property the whole trace pipeline depends on.

**Satisfactory.** The requirements are well formed, individually testable, and the traceability table is a genuine engineering artefact rather than a formality. §3.5's closing statement — that the two-kilobyte sink is the constraint the results are read against — is exactly the right thing to say at that point.

## Chapter 4 — Architecture (pp. 45-65)

The best-structured chapter in the report. Every claim I checked against the source held, at the abstraction level the chapter chose. The layered decomposition, the provider inventory, the ownership model, the concurrency model, the event bus, the error model and the teardown ordering are all faithful to the implementation.

**Problems.**
- F4 (the justification for the two-path design) is in this chapter and is its most serious defect.
- F5 (Figure 4.1) and F16 (Figure 4.9).
- Table 4.1 (Thread inventory) omits the CMSIS-SVD parsing task and the progress-reporting thread, which is a contradiction with §5.4.7's own statement that parsing runs on a background thread (F36).
- §4.2.3 "Trace Extraction" opens with "Three properties of the design deserve statement" and then does not number them, so the reader must work out which three. This is the count-announcing habit doing active harm.

**Satisfactory.** §4.2.7 (trace lifecycle), §4.3.5 (concurrency), §4.4.2 (module boundaries) and §4.4.3 (teardown ordering) are all accurate, well motivated and honest. The RTTI incompatibility between the compiler library and the trace decoder is a real constraint that shaped a real design decision, and the report explains it correctly.

## Chapter 5 — Implementation (pp. 66-97)

Substantial, honest and mostly accurate. The chronology section is a good idea, well executed: stating that decisions came from discovering an earlier arrangement did not work is more credible than presenting the final design as foreseen.

**§5.1 Chronology.** Good. Figure 5.1 has no time axis (Part 4).

**§5.2 Application Note.** Handled correctly under the confidentiality constraint. Structure and audience are described; content is not reproduced. §5.2.4's three failure conditions — a locked component silently rejecting writes, a component configured while running, an image that does not match the capture — are the most useful three sentences in the section and are the right kind of detail to include.

**§5.3 Instruction Trace Implementation.** The strongest technical section and the one that most needs a figure (see Part 4). Problems: F22 (the opening sentence), F13 (register name), F18 (unexplained exclusions), F24 (step handling). Table 5.2 is accurate against `etmv4_commit_config`, including the capability gating on each row, which is the sort of detail that is hard to get right and is right here.

**§5.4 The Debugger.** Accurate. §5.4.1 (in-process OpenOCD), §5.4.4 (reset resynchronization) and §5.4.5 (breakpoints) are all confirmed against source and against the fork's commits. F17 and F19 apply. §5.4.7's race description is imprecise (Part 8).

**§5.5 Testing and Validation.** The weakest section, and the one a jury will press on. F2, F3, F9, F15 all live here. Table 5.5 (defects found on hardware) is nonetheless one of the best things in the report: six real defects, each with a cause rather than a symptom, three of them predicted by the theory chapter. That table is defence material and should be pointed at during the presentation.

**§5.5.7 Limitations.** Honest and matches the project's own `docs/architecture/05-known-characteristics.md`, including the concurrency gap that a less scrupulous report would have omitted. This is a credit to the author and should be said so during the defence rather than apologised for.

**§5.6 Conclusion.** Good.

## Conclusion (p. 98)

Well written and correctly scoped. It repeats the 144-byte figure and so inherits F1. The two closing conclusions are the right two.

---

# PART 4 — FIGURE AND TABLE AUDIT

**Totals:** 37 figures, 30 tables, 98 body pages. Thirty-three figures and ten tables are never referenced from the text (F10). All figures use `[H]` placement.

## Figures

| # | Figure | Correct? | Consistent with text? | Readable? | Necessary? | Best form? | Action |
|---|---|---|---|---|---|---|---|
| 1.1 | ST activity sectors | yes | yes | yes | decorative | — | keep or cut with 1.2/1.3 |
| 1.2 | ST worldwide presence | yes | yes | yes | decorative | — | keep one of 1.1-1.3, not three |
| 1.3 | ST Tunis | yes | yes | yes | decorative | — | as above |
| 2.1 | Debugger anatomy | **no** — RSP inside the backend | contradicts §4.3.4 | yes | yes | yes | move the RSP label to a backend/server boundary (F23) |
| 2.2 | Breakpoint mechanisms | yes | yes | yes | yes | yes | reference it from the text |
| 2.3 | Three representations | yes | yes | yes | yes | yes, excellent | say in the caption that it is illustrative, not real compiler output |
| 2.4 | M-profile address map | yes, PPB correctly below Vendor_SYS | yes | yes | yes | yes | reference it |
| 2.5 | DAP structure | yes | device-specific in a generic section | small but legible | duplicates part of 3.1 | no | either redraw generically (one DP, several APs) or drop and forward-reference 3.1 |
| 2.6 | Trace elements for a loop | yes — 3×E + 1×N, 16 instructions | yes | yes | **yes, highest teaching value in Ch.2** | yes | reference it; consider repeating it in the defence slides |
| 2.7 | Formatter frame | yes | yes | yes (4204 px wide) | yes | yes | only raster figure; reproduced from IHI0029G with attribution — state permission or redraw |
| 3.1 | Target debug/trace infrastructure | yes, faithful to RM0477 | yes | small labels but legible | yes | yes | highlight the ETM→funnel→ETF→(TPIU) path used, so the reader sees which of the many boxes matter |
| 4.1 | Global architecture | **no** — trace bypasses the probe | **contradicts §4.2.3, 4.4, NFR1** | yes | yes | yes | **F5, must fix** |
| 4.2 | OpenOCD object model | yes | yes | yes | yes | yes | reference it |
| 4.3 | Four-stage pipeline | yes | yes | yes | yes | yes | the divider sits before Extraction, which straddles device and host; consider moving it |
| 4.4 | On-target dataflow | yes | yes | yes | yes | yes | this is the figure that proves the thesis; make Figure 4.1 agree with it |
| 4.5 | Buffer stop, flush, drain | mostly | "read from the write pointer" is not in §5.3.2.2 and the driver does not set RRP | yes | **duplicates Figure 5.2** | no | drop 4.5, or reduce it to three boxes; Figure 5.2 is strictly more informative |
| 4.6 | End-to-end capture | yes | yes | yes | yes | yes | reference it |
| 4.7 | Trace data model | yes | yes | yes | yes | yes | — |
| 4.8 | Trace lifecycle | yes | yes | **labels collide** at the top ("components reconfigured" / "processor resumes") | yes | yes | separate the two labels; the "components found" edge out of *Unavailable* reads oddly, since *Unavailable* means none were found |
| 4.9 | Module dependency graph | **no** — one arrow reversed | contradicts CMake | yes | yes | yes | **F16** |
| 4.10 | Debug context | yes | yes | yes | yes | yes | one association uses a hollow diamond where the others are filled; make them consistent |
| 4.11 | Provider interfaces | yes | yes | yes | partly duplicates 4.10 | — | keep, it carries the interface names 4.10 does not |
| 4.12 | Division of responsibility | yes | yes | yes | yes | yes | this is the figure that should carry the corrected F4 argument |
| 4.13 | Event dataflow | yes | yes | yes | yes | yes | — |
| 4.14 | One request, wire to wire | yes | yes | yes | yes | yes | — |
| 4.15 | Frontend structure | yes | text omits the registers view that exists in the extension | yes | yes | yes | either mention the registers view or drop it from the figure |
| 5.1 | Project chronology | yes | yes | yes | yes | yes | **no time axis** — add the internship weeks or months; this is also the report's only planning artefact |
| 5.2 | Extraction sequence | yes, faithful to `tmc_extract_data` | yes | yes | yes | yes | the empty-buffer branch in the code is not shown; add it or say the figure omits it |
| 5.3 | Bytes to elements | yes | **exposes F1** | yes | **yes, best figure in the report** | yes | keep exactly as is; correct the "144 bytes in all" annotation to distinguish the barrier |
| 5.4 | Termination containment | yes | yes | yes | yes | yes | — |
| 5.5 | Command queue and wake | yes | yes | yes | yes | yes | — |
| 5.6 | Session lifecycle | yes | yes | yes | yes | yes | — |
| 5.7 | Reset and resynchronization | yes, faithful to the `gdb_resync` commit | yes | yes | yes | yes | strong defence figure |
| 5.8 | Breakpoint placement decision | yes | yes | yes | yes | yes | — |
| 5.9 | Peripheral write and observation | yes | text is imprecise (Part 8) | yes | yes | yes | — |
| 5.10 | Trace views | yes | yes | screenshots at 92 mm height — check the smallest text at final size | yes | yes | this is the FR8 evidence; make sure a source line is legible |
| 5.11 | Memory and peripheral views | yes | yes | as above | yes | yes | — |

## Where prose is hiding a structure that should be visual

Applying the test — the information has structure that prose has to serialize, and a figure would let a paragraph be deleted:

1. **§5.3.1, the driver lifecycle (pp. 70-72).** Three pages of the most defensible technical content in the report, with no figure at all. The content is a state machine with a fixed ordering: unlock, check the architecture identifier, batch-read the capability registers, decode capabilities, stage, validate against capabilities, commit in a fixed order, arm on resume, stop and drain on halt, reconfigure on reset. That is a state diagram with annotated transitions. It would replace two paragraphs and it is the single figure most likely to win the technical part of the defence. **Highest-value addition in the report.**

2. **§2.8.6 and Table 2.8, the trace path decision.** The reader has to hold in mind three TMC configurations, three modes, two sink families and a set of hardware constraints, and then arrive at "on-chip circular ETF" as the only reachable choice on this bench. A single decision diagram — trace pins available? probe able to capture them? on-chip sink present? — ending at the configuration this project used would replace most of §2.8.5 and §2.8.6's closing paragraphs, and would tell a non-fluent reader in one glance why the project made the choice it did.

3. **§5.4.1, the four changes that made OpenOCD a library.** Build system, termination containment, embedded scripts, initialization sequence, thread affinity. Figures 5.4 and 5.5 cover two of the five. A single "before and after" panel — OpenOCD as a process beside the engine, versus OpenOCD linked into it with the five seams marked — would carry the whole section.

4. **§3.1 and §3.2, the deliverables and requirements.** Three deliverables, thirteen functional and three non-functional requirements, and a traceability table, presented as three separate tables the reader must join by hand. One diagram showing the three deliverables as columns with their requirements beneath would replace Table 3.5 entirely and would make the scope visible in one page.

Against these, one figure could be removed: Figure 4.5 duplicates Figure 5.2 (see the table above).

## Tables

The tables are the report's strongest communication asset and are well suited to this jury. All thirty follow one house style. Findings already recorded: Table 1.1 (F21), Table 1.4 (F20), Table 2.3 (F11), Table 2.9 (F8), Table 3.6 (incomplete, Part 3), Table 4.1 (F36), Table 5.2 (F13), Table 5.4 (F3, F15), Table 5.6 (F2, F3, F14, and no distinction between automated and manual evidence), Table 5.7 (F1, F9, F25).

Tables that are correct and carry real weight, with no changes needed: 2.1 (DWARF constructs), 2.2 (AMBA buses), 2.5 (trace elements), 2.6 and 2.7 (TMC configurations and modes — both verified against DDI0461B), 2.8 (on-chip versus off-chip), 3.3 and 3.4 (requirements), 4.2 (custom protocol requests), 5.1 (application note structure), **5.5 (defects found on hardware — the best table in the report)**.

---

# PART 5 — SOURCE-CODE CONSISTENCY AUDIT

## Claims verified as accurate

These were checked line by line and match the report at the abstraction level Chapter 4 declared.

| Report claim | Source | Verdict |
|---|---|---|
| Sink driver derives the TMC configuration from identification registers and cross-checks it against the reported component type | `arm_tmc.c: tmc_validate_identity` — reads `DEVID` and `DEVTYPE`, derives CONFIGTYPE, rejects a mismatch | accurate |
| Trace unit is unlocked, its architecture identifier checked, capabilities batch-read, then configuration validated against them | `arm_etmv4.c: etmv4_instance_init` → `etmv4_unlock`, `etmv4_validate_identity` (DEVARCH), `etmv4_read_capabilities`, `etmv4_validate_config` | accurate |
| Commit writes registers in a fixed order, each gated on a discovered capability | `etmv4_commit_config` — order matches Table 5.2 exactly, including `caps->numacpairs`, `caps->numrspair`, `caps->stallctl`, `caps->numpc`, `caps->syncpr_fixed` gating | accurate |
| Conditional non-branch tracing is never enabled because the decoding library rejects it | `arm_etmv4.c:455-458` comment naming `OCSD_ERR_HW_CFG_UNSUPP` | accurate |
| The unit is stopped and polled to idle rather than assumed idle | `etmv4_stop_trace_unit` writes `TRCPRGCTLR=0` then polls `TRCSTATR.IDLE` | accurate |
| Both drivers follow the target run state via event callbacks | `etmv4_target_callback_event_handler`, `tmc_target_callback_event_handler` on `RESET_END`, `RESUME_START`, `STEP_*`, `HALTED` | accurate |
| Fill level read before capture is disabled; wrapped buffer read whole | `tmc_extract_data` — comment and `TMC_STS_FULL` branch, `CTL=0` written after the drain | accurate |
| Empty buffer handled separately | `tmc_stop_and_extract` checks `TMC_STS_EMPTY` before extracting | accurate |
| Buffer read through one register with address increment suppressed | `tmc_read_trace_buff` → `mem_ap_read_buf_noincr(..., base + TMC_RRD)` | accurate |
| A 16-byte synchronization barrier precedes every payload on every destination | `tmc_fsync_barrier`, `tmc_output_write` | accurate |
| The decoder is told the stream is frame-formatted, memory-aligned, and reset by four consecutive patterns | `trace_manager.cc: BuildSession` sets `kFrameFormatted`, `kMemAligned`, `reset_on_4x_fsync = true` | accurate |
| Decoder configured from registers read from the device | `BuildSession` calls `OpenOcd()->ReadETMv4Registers(source)` | accurate |
| Five element kinds retained, everything else discarded | `trace_record.hpp` / `trace_record_sink.cc` | accurate |
| Return instructions matched on the printed form because the analysis facility does not recognise them | `program_disassembler.cc:194-211`, comment and `LooksLikeReturn` | accurate |
| Gap causes: overflow, trace-on, loss of synchronization, plus a capture boundary added outside the transform | `trace_gap_transform.hpp`; `trace_session.cc` `capture_count > 0` branch | accurate |
| Frontend validates the increment index and discards a mismatch | `trailer/src/trace-model.ts:81-86` | accurate |
| Reset resynchronization: a command arms a flag, the next resume or step is answered with the current state | OpenOCD fork commit `1fb8128`, `gdb_resync_reply`, `TARGET_EVENT_GDB_RESYNC`, `handle_gdb_resync_command` | accurate |
| A packet beginning with one letter was routed to an obsolete handler; now matched in full with an empty reply otherwise | fork commit `4cfa1e7`, `gdb_input_inner` cases `'j'` and `'J'` | accurate |
| OpenOCD's loop is woken by a registered service on a loopback port | `command_queue.cc`, `AddServiceTrampoline`, `openocd_provider_wakeup` | accurate |
| Termination calls redirected to a replacement that jumps back to a guard | `openocd_exit.c`, `openocd_jmp.h` | accurate as far as it goes (F19) |
| Attach mode has no direct path, so trace, live memory and peripheral watches are unavailable | `PROJECT_STATUS.md`; `TraceManager::Create` returns "trace requires an OpenOCD-backed launch session" | accurate |
| A Windows installer is produced carrying the engine, its resources and the server's scripts | `engine/CMakeLists.txt:167-200` — `CPACK_GENERATOR "NSIS;ZIP"`, install rules for `trailer-dap`, `resources`, `openocd/scripts` | accurate (note that `PROJECT_STATUS.md` still lists packaging as not started; the CMake is ahead of the note) |

## Discrepancies

1. **F1** — the 144-byte figure includes the host-inserted barrier.
2. **F3** — `transform_test` covers two of three transforms; the capture-boundary gap is untested.
3. **F4** — the halt constraint belongs to the debugger library, not to the protocol; the project's own `04-event-dataflow.md` says so.
4. **F15** — five test files omitted from the inventory.
5. **F17** — 49 counts a catch-all and a test-only handler.
6. **F19** — the containment mechanism's own documentation states a stronger consequence than the report does.
7. **F24** — the sink is not capturing while the trace unit runs during a step.
8. **F36** — the thread inventory omits the CMSIS-SVD parsing task and the progress thread.
9. **Table 5.4 test names** — all ten named tests exist with the names given. No fabrication.

## Code observations outside the report's abstraction level

Recorded for completeness; **none of these is a report finding**.

- In the fork's `'J'` packet case, `gdb_write_smp_packet` was replaced by `gdb_read_smp_packet`, so the SMP write path no longer functions. It is dead code for this project's targets.
- `arm_tmc.h`'s prose comment block listing FFCR bit positions does not match the `#define`s below it. The defines are correct against DDI0461B; the comment is a leftover from the legacy ETB layout.
- `tmc_stop_and_extract` contains a large commented-out block that would have polled `TMCReady` before forcing a flush.

---

# PART 6 — REFERENCES AND TECHNICAL SOURCES

## Overall

Twenty-eight bibliography entries, IEEE style, correctly configured in the class. The Arm and ST entries are accurate: document numbers, issues and years all check out (DDI 0403E.e, IHI 0064H.b, IHI 0031H, IHI 0029G, DDI 0461B, DDI 0494D, DDI 0489D, RM0477 Rev 9, UM3276 Rev 2, DS14359 Rev 6, AN4989 Rev 4). Chapter 2 is densely and appropriately cited — 96 citations across 30 pages, almost all to primary architecture specifications, which is exactly right.

## Missing references

**Peer-reviewed work, none of which is cited, all of which was supplied with the project:**

- **Matraszek, Banaszek, Ciszewski, Iwanicki, "FrankenTrace: Low-Cost, Cycle-Level, Widely Applicable Program Execution Tracing for ARM Cortex-M SoC"** (University of Warsaw). This is the closest published work to the project: the same processor family, the same problem (obtaining instruction trace without expensive probes), a different solution. Not citing it is the most serious referencing gap in the report, and it is the question I would ask first at the defence. Cite it in §1.2.2 and use it in §1.2.3 to position the contribution: FrankenTrace attacks the probe cost from the hardware side; this project attacks the tooling cost from the software side, using the sink already present on the chip.
- **Ning and Zhang, "Ninja: Towards Transparent Tracing and Debugging on ARM", USENIX Security 2017.** ETM-based transparent tracing. Relevant to §2.3.1's non-intrusive argument.
- **Convent, Hungerecker, Scheffel, Schmitz, Thoma, Weiss, "Hardware-Based Runtime Verification with Embedded Tracing Units and Stream Processing."** CoreSight ETM trace consumed at runtime. Relevant to §5.5.7's future work on profiling from the same captures.
- **Rath, "Open On-Chip Debugger: Design and Implementation of an On-Chip Debug Solution for Embedded Target Systems", diploma thesis.** OpenOCD is central to the project and is cited only as a URL. The thesis is the primary source for its design and belongs in §4.1.3.

**Vendor documentation for Chapter 1's tables.** See F7.

**Documentation the report leans on without citing:** `qRcmd`/`monitor` in the GDB documentation (needed for the corrected F4 argument); RM0090 or RM0410 for `TRACE_IOEN`/`TRACE_MODE` (F12); the OpenCSD documentation for the deformatter flags described in §5.3.3.1.

## Weak references

- `dap_spec`, `gdb_rsp`, `lldb_rsp`, `llvm_mc`, `cmsis_svd`, `openocd`, `opencsd`, `lldb` are bare URLs with an access month and no version. For a report that will be read after the tools have moved on, add a version or a commit where one exists — particularly OpenCSD 1.8.3 and the OpenOCD fork, which are stated in Table 3.8 but not in the bibliography entries.
- `st_comp` is typed as `@article` and is a company presentation PDF; `@misc` or `@manual` is correct.
- Access dates read "[Accessed August 2026]", which is consistent, but `st_comp` reads "[Accessed July 2025]" with `year = 2024`. Make the convention uniform.

## Incorrect references

- **§2.9.2.3 cites RM0477 for controls RM0477 does not contain (F12).** This is the one citation in the report that does not support its claim.

## Where a primary source should replace or supplement what is there

- Table 2.9 needs a per-row citation (F8). AN4989 covers only four of its seven rows.
- §2.8.3's statement that the ETM "exists in four architecture versions" cites both `etmv3_spec` and `etmv4_spec`, which is right; but §5.3.7's ETMv3 exclusion cites nothing, and the reason for it (F18) is a hardware fact that deserves a reference to the relevant reference manuals.

## Where ARM/ST documentation should be preferred

The report already prefers primary Arm and ST sources almost everywhere in Chapter 2, which is the correct instinct. The one place where a secondary source is doing work a primary source should do is `markusson2008` (a 2008 master's thesis) as the citation for general debugger concepts in §2.2 and §2.3. It is used eleven times. It is a reasonable source, but for run control, breakpoints and Debug state the architecture reference manuals say the same things normatively, and the report already cites them elsewhere. Consider moving three or four of those citations.

---

# PART 7 — ENGLISH AND READABILITY

The English in Chapters 2 to 5 is good and is already close to what this jury needs: short sentences, one idea each, explicit subjects, precise vocabulary, no ornament. Do not make it more sophisticated. Three things need work: the two files that were not revised to that standard, one repeated sentence shape, and a handful of sentences that are longer than they need to be.

## Passages that should be rewritten

**Introduction, sentence 1.** Comma splice.
> Current: "Embedded systems operate under real-time constraints while interacting directly with hardware peripherals and asynchronous external events, this makes them inherently difficult to observe and debug."
> Suggested: "Embedded systems operate under real-time constraints. They interact directly with hardware peripherals and with asynchronous external events. Both properties make them difficult to observe and to debug."

**Introduction, paragraph 2.** Redundant connective, capital mid-sentence.
> Current: "However, Despite the sophistication of the underlying hardware, these features remain largely locked behind proprietary tooling ecosystems..."
> Suggested: "Despite the sophistication of the underlying hardware, these features remain locked behind proprietary tooling."

**§1.2.1, sentence 1.** Comma splice, capital mid-sentence.
> Current: "Debugging software is designed to offer a unified experience across a wide range of chips, vendors and architectures, for this, it relies on a common layer of abstraction that groups these heterogeneous targets behind a single conceptual model, This approach is valid for simple primitives such as memory views and breakpoints, however, the shortcomings appear when we move to more advanced features..."
> Suggested: "Debugging software offers a unified experience across many chips, vendors and architectures. It achieves this through a common layer of abstraction that presents heterogeneous targets behind a single conceptual model. The abstraction holds for simple primitives such as memory views and breakpoints. It fails for advanced features such as reconstructing execution flow, cross-triggering debug events, or recovering execution history after a failure. These features do not generalize, and each is tightly coupled to a vendor-specific implementation."

**§1.2.1, final sentence.** No working predicate. This is the report's problem statement and must be correct.
> Current: "The gap between what a chip provides do and what the developer can actually reach is the central concerns of this project."
> Suggested: "The gap between what a chip provides and what a developer can reach is the central concern of this project."

**§1.2.2, note.** Contraction.
> Current: "Note: ST's tools are specialized forks of open-source projects, therefore won't be included in the comparison"
> Suggested: "ST's tools are specialized forks of open-source projects and are therefore excluded from this comparison."

**§1.2.3, opening of the probe paragraph.** Comma splices and a subject-verb disagreement.
> Current: "It is also worth looking at the limitations behind debug probes, as a note, each toolchain vendor, that being IAR, Keil, and SEGGER provide two versions of their probes, a base model, and an extended one capable of capturing trace via dedicated trace pins."
> Suggested: "Debug probes impose limitations of their own. IAR, Keil and SEGGER each supply two versions of their probe: a base model, and an extended model that captures trace through dedicated pins."

**§1.2.3, closing sentence.** Contraction, unsupported universal, inconsistent capitalisation.
> Current: "Finally, the major limitation in the current state of the art is the fact that no IDE provides support for On-Chip trace solutions on hardware probes beyond their proprietary ones even though this feature doesn't require any dedicated hardware."
> Suggested: "The principal limitation is therefore the following. Among the tools examined, none exposes on-chip trace capture through a probe other than its own, although on-chip capture requires no dedicated hardware."

**§1.2.4.** Missing preposition.
> Current: "First, adding support for the CoreSight components responsible for instruction trace open-source debuggers."
> Suggested: "First, adding support for the CoreSight components responsible for instruction trace to an open-source debugger."

**Acknowledgements.** Subject-verb disagreement across a coordinated verb.
> Current: "his guidance and support have been invaluable, and has kept me motivated and determined to give my best effort."
> Suggested: "his guidance and support have been invaluable, and have kept me motivated throughout."

**§4.2.3.** A count announced and then never resolved, so the reader must map three properties onto three sentences.
> Current: "Three properties of the design deserve statement. The quantity of data to read is determined before reading rather than by watching for a terminating value, which requires..."
> Suggested: "The quantity of data to read is determined before reading, rather than by watching for a terminating value. This requires the fill level of the buffer to be interrogated, and it requires the wrapped case to be handled separately. The read is directed at a single register that returns successive words, so the address does not advance between reads. The result reaches the engine as a callback rather than being pulled by it, which keeps the engine free of any polling loop."

## Patterns rather than instances

- **Count-announcing openers, about thirty-one** (F30). The mechanical fix is to delete the opener and start with the first item.
- **"which is what allows / which is what makes / which is the property that"** appears repeatedly as a clause-joining device. It is correct and it is invisible once, but by the fourth chapter it is a tic. Where it can become a new sentence, let it.
- **Long noun phrases as subjects**: "the operations required by instruction trace and by live observation are not expressible in the protocol that connects a conventional debugger to a target". A reader with weak English has to hold nine words before reaching the verb. Split.

## What not to change

The passive voice is used deliberately to avoid personal pronouns, is consistent with the supplied writing guide, and does not hurt comprehension here — sentences remain short and the agent is almost always obvious. Leave it. The vocabulary is precise and unshowy. Leave that too.

---

# PART 8 — CONSISTENCY AUDIT

**Terminology**
- "ARM" (introduction ×2, Chapter 1 ×1, acronym list) versus "Arm" (Chapters 2-5, ×26 in Chapter 2 alone). Arm Ltd writes "Arm". Pick one, and if it is "Arm", note the acronym list entry.
- "Component discovery" used in two senses (F14).
- "Trace unit" and "ETM" are used interchangeably, correctly and deliberately, and this is fine — §2.8.3 defines the relation.

**Acronyms**
- **DAP** carries three meanings (F26). This is the one acronym problem that matters.
- The acronym list is otherwise complete and correctly sorted. `DBGMCU` overflows its column in the rendered list ("DBGMCU=" with no space) — one of the five reported overfull boxes.
- ELF, DWARF, CMSIS-SVD, MEM-AP, TMC, ETB/ETF/ETR, TPIU, SWO are all expanded on first use and used consistently thereafter.

**Component and product names**
- "STLink" (Chapter 1) versus "STLINK-V3EC" (Chapter 3). ST writes "ST-LINK" and "STLINK-V3EC".
- "I-Jet" (Chapter 1) versus "I-jet" (Chapter 3). IAR writes "I-jet".
- "ULink" (Chapter 1) versus "ULINKpro" (Chapter 3). Keil writes "ULINK".
- "ARMCLANG/ARMCC" in Table 1.1. Arm writes "Arm Compiler 6 (armclang)" and "armcc".
- "On-Chip" (Chapter 1) versus "on-chip" (everywhere else).

**Version numbers**
- Table 3.8 gives "Visual Studio Code 1.125". This looks ahead of the release train for the period covered; I could not verify it from the material supplied, so treat this as an item to check rather than as a confirmed error.
- OpenCSD 1.8.3, LLVM 22, Xerces-C 3.2.4, CodeSynthesis XSD 4.2.0 and "fork of OpenOCD 0.12.0" are all plausible and the last matches the fork. None of these versions appear in the corresponding bibliography entries.

**Cross-references**
- `chap_04.tex:236` renders "Section 5" for a chapter (F31).
- Thirty-three figures and ten tables are never referenced (F10).
- Forward references are used heavily and correctly; every `\ref` resolves in the final build with no undefined references.

**Tense**
- Consistent and appropriate: present for the architecture and the artefact, past for what was done. The one exception is §5.4.12 "An installer is produced for Windows" beside "The frontend is not yet distributed", which mixes a capability statement with a status statement in one paragraph.

**Notation**
- Register names are consistently `\texttt`. Addresses are consistently `0x` with uppercase hex digits. Numbers follow the stated convention (words below ten, numerals for data) with no exception I found.
- Table style is uniform across all thirty tables.

**Two further small inaccuracies**
- **§5.4.7, the peripheral race.** "an observation whose reading began before the counter advanced is discarded rather than published" describes a rule that would discard almost every observation. The implemented rule is that an observation whose read *overlapped* a completing write is discarded. `04-event-dataflow.md`: "The watch worker captures the epoch before its own read and discards the frame at emit time if the epoch moved during that read."
- **§2.8.3.3, the element list.** Omits that a P0 element is also generated on entry to Debug state, and that WFI and WFE generate one only when `TRCIDR2.WFXMODE` is 1 (IHI0064H.b §2.2). Neither affects any argument in the report; add "and, where the implementation reports it, on wait-for-interrupt and wait-for-event" if precision is wanted.

---

# PART 9 — DEFENCE QUESTIONS

Ordered by how likely they are to be asked and how much damage an unprepared answer would do.

1. **"Your abstract says a capture of 144 bytes. Your Figure 5.3 says frame 0 is a barrier your own driver inserted. How many bytes did the chip actually produce?"** — *Triggered by:* Table 5.7 against Figure 5.3. *Prepare:* the corrected numbers, and say the correction improves the result.
2. **"How do you know the 114 instructions are the right 114?"** — *Triggered by:* Table 5.6 FR5 and the word "oracle". *Prepare:* either the real oracle (F2a), or a candid statement that the test is a regression baseline and that the end-to-end correctness evidence is the reconstructed sequence matching the startup code, which is visible in the trace view.
3. **"OpenOCD already has `etm.c` and `etb.c`. What exactly was missing?"** — *Triggered by:* §5.3.1's opening sentence. *Prepare:* ETMv1-v3 for ARM7/ARM9 cores, and the legacy ETB, neither of which reaches an ETMv4 unit or a TMC.
4. **"Why could you not drive OpenOCD's trace commands through `monitor` packets over the GDB protocol?"** — *Triggered by:* §4.3.4.2 (F4). *Prepare:* the corrected justification — unstructured text replies, no push channel for captures, and LLDB's process model requiring a stopped target.
5. **"Figure 4.1 shows trace reaching the host without passing through the probe. Which is it?"** — *Triggered by:* F5.
6. **"Your Table 2.9 marks eleven families as having instruction trace. On how many of them does your implementation work?"** — *Triggered by:* F8 against §5.3.7. *Prepare:* the ETMv4 subset, and the argument that the on-chip route and ETMv4 coincide exactly.
7. **"What happens when the buffer wraps? You have a code path for it. Did you ever see it?"** — *Triggered by:* §5.3.2.2 and Figure 4.5 describe the wrapped case in detail; no result in the report exercises it. *Prepare:* run one capture long enough to wrap, before the defence. It is a ten-minute experiment and it closes the question permanently.
8. **"Two kilobytes is about sixteen hundred instructions, on your figure. At 600 MHz that is a few microseconds of execution. What is this actually useful for?"** — *Triggered by:* §5.5.6's extrapolation. *Prepare:* the honest answer — the interval before a halt, a fault or a breakpoint, which is precisely the interval a developer wants; and the filtering capability the trace unit has and the implementation does not yet expose (§5.3.7), which is what would extend it.
9. **"Your `longjmp` out of OpenOCD leaves its heap in an unknown state. Why is it safe to keep the session running?"** — *Triggered by:* §5.4.1.2 and §4.4.1 (F19).
10. **"What is the overhead of your trace on the running program? You claim non-intrusive."** — *Triggered by:* §2.3.1 and NFR1. The report never measures this. The correct answer is architectural: the trace unit observes the processor and the sink absorbs the stream, so nothing is added to the program's execution; the only intrusion is the halt that already existed. Say it that way, and say explicitly that it was not measured.
11. **"Your test inventory names ten tests. How many are there?"** — *Triggered by:* F15.
12. **"How does your work relate to FrankenTrace?"** — *Triggered by:* its absence from a chapter titled State of the Art (Part 6). This is the question that most rewards preparation and most punishes its absence.
13. **"Table 5.6 says thirteen requirements Met. Which of those were checked by a program and which by looking at the screen?"** — *Triggered by:* F15 and the undifferentiated Status column.
14. **"You single-step. Does the trace show the instruction you stepped?"** — *Triggered by:* F24.
15. **"You measured 0.112 ms. On what machine, in what build, over how many runs?"** — *Triggered by:* F9.
16. **"Your report says component discovery is not implemented, and your verification table says it was verified. Which?"** — *Triggered by:* F14.
17. **"You count forty-nine handlers. Table 5.3 lists forty-seven."** — *Triggered by:* F17.
18. **"What would it take to support the ETR configuration and trace into system memory instead of the 2-Kbyte FIFO?"** — *Triggered by:* Table 2.6 and §5.3.7. Worth preparing well, because the driver already handles the ETR configuration and the answer is a strong one.
19. **"Why LLDB rather than GDB?"** — *Triggered by:* §4.3.4.1, which justifies using *a* mature debugger library but never justifies choosing this one. The report gives no reason anywhere. Prepare one: the SB API is a supported embedding interface returning structured values, whereas GDB offers MI text or a Python layer.
20. **"Chapter 4 says the frontend contains no debug logic. Your architecture notes say several handlers drive the debugger library directly. Is the boundary held?"** — *Triggered by:* §4.3.1 against `00-overview.md`. The report is honest about the concurrency gap in §5.5.7; be equally direct here.

---

# PART 10 — FINAL ACTION LIST

## 1. MUST FIX BEFORE SUBMISSION

Correctness, credibility or comprehension is materially affected.

| # | Action | Kind |
|---|---|---|
| F1 | Separate the 16-byte host barrier from the 128 bytes the device produced. Correct Table 5.7, §5.5.6, the conclusion, and both abstracts. Recompute the density and the 2-Kbyte extrapolation. | rewriting |
| F5 | Route the "captured trace" arrow in Figure 4.1 through the debug probe. | presentation |
| F6 | Fix or remove the chapter contents pages. Chapters 4 and 5 currently show Chapters 1 and 2. | presentation |
| F3 | Correct Table 5.4's description of `transform_test` and Table 5.6's FR7 evidence. Adding the missing gap tests is better, but the correction is mandatory either way. | rewriting (+ optional technical work) |
| F2 | Stop calling the regression baseline an oracle in Tables 5.4 and 5.6, or replace it with the real one. | rewriting or technical work |
| F4 | Restate the justification for the two-path architecture in terms of the debugger library rather than the protocol. | rewriting |
| F11 | Correct the DHCSR `C_HALT` description and add `S_HALT`. | rewriting |
| F29 | Rewrite the general introduction and §1.2 to the standard of Chapter 2. Fix "targetted", "ommitted", both contractions, the first person, and the three comma splices. | rewriting |
| F33 | Produce the hardware bench photograph and remove the placeholder box from the PDF. | artwork |
| F10 | Add a sentence referencing each figure from the paragraph that introduces it. | rewriting |
| F7 | Give Tables 1.1, 1.2 and 1.4 sources, or state in their captions that they record the author's own evaluation and give the versions tested. Soften the universal negative in §1.2.3. | evidence + rewriting |
| F12 | Correct the DBGMCU citation in §2.9.2.3. | rewriting |

## 2. SHOULD FIX

Real weaknesses that a competent jury member is likely to raise.

| # | Action | Kind |
|---|---|---|
| F8 | Add an ETM-version column to Table 2.9, cite each row, and state that ETMv4 and the on-chip route coincide. | evidence + table |
| F9 | State the method behind the 0.112 ms figure, or take three more captures. | evidence or rewriting |
| F15 | Add the five missing tests to Table 5.4 and cite them in Table 5.6. | rewriting |
| F30 | Remove most of the thirty-one count-announcing openers. | rewriting |
| F22 | Scope the "no support in the debug server" claim to ETMv4 and the TMC, and acknowledge `etm.c`/`etb.c`. | rewriting |
| F18 | Give the reason for the ETMv3 and single-source exclusions. | rewriting |
| F26 | Never abbreviate the Debug Adapter Protocol; split the acronym entry. | presentation |
| F16 | Reverse the transport-to-handlers arrow in Figure 4.9. | presentation |
| F13 | "PE comparator", not "context comparator". | rewriting |
| F14 | Use "component discovery" in one sense only. | rewriting |
| F17 | Replace "49 handlers" with the request count, or drop it from the Results. | rewriting |
| F19 | State the second consequence of the containment mechanism. | rewriting |
| F20 | Rename Table 1.4's capture column. | presentation |
| F21 | Split or relabel Table 1.1's Debugger column. | presentation |
| F23 | Move the RSP label in Figure 2.1 to a backend/server boundary. | presentation |
| F24 | State what the step-time asymmetry costs. | rewriting |
| F25 | Annotate or split the "Gaps: 2" row. | rewriting |
| F27 | Give Chapter 1 an Introduction; make Introduction and Conclusion numbering uniform. | presentation |
| F28 | Add a plan-announcing paragraph to the introduction. | rewriting |
| — | Add a driver-lifecycle state diagram to §5.3.1. Highest-value figure not yet in the report. | artwork |
| — | Cite FrankenTrace, Ninja, Convent et al. and Rath in Chapter 1 and §4.1.3. | evidence |
| — | Add the ITM row to Table 3.6, since the ETF captures from two sources. | rewriting |
| F36 | Add the SVD parsing task to Table 4.1, which §5.4.7 already mentions. | rewriting |
| F31 | "Chapter 5", not "Section 5", at `chap_04.tex:236`. | presentation |

## 3. NICE TO HAVE

| # | Action |
|---|---|
| F32 | Reset `\hfuzz` for one build and fix the overfull boxes it reveals. |
| — | Add a trace-path decision diagram to §2.8.6 and delete the paragraphs it replaces. |
| — | Add a time axis to Figure 5.1, which is also the report's only planning artefact. |
| — | Drop Figure 4.5, which Figure 5.2 supersedes. |
| — | Make Figure 2.5 generic, or drop it and forward-reference Figure 3.1. |
| — | Separate the colliding labels in Figure 4.8; make the diamonds in Figure 4.10 consistent. |
| — | Unify ARM/Arm, STLink/ST-LINK, I-Jet/I-jet, ULink/ULINK, On-Chip/on-chip. |
| — | Add versions or commits to the software bibliography entries. |
| — | Reduce Figures 1.1-1.3 to one, and use the space for the state of the art. |
| — | Split §1.1.5 into two paragraphs. |
| F34 | Correct the peripheral-race wording in §5.4.7. |
| F35 | Add the two missing conditions to the P0 element list in §2.8.3.3. |
| — | Consider whether §2.3.2 and §2.3.3 earn their pages; neither is referred to again. |
| — | Mention the registers view in §5.4.11, or remove it from Figure 4.15. |
| — | Verify the Visual Studio Code version in Table 3.8. |
| F42 | Consider whether the jury expects a use-case or planning view; the supplied ISI template prescribes both, though for a different specialty than the one on the cover. |

---

## Closing assessment

This is a strong project weakened by its own reporting of it. The engineering is real, the implementation is substantial and honestly described, the theory chapter is accurate against primary sources to a degree that is uncommon at this level, and the limitations sections disclose things a less careful author would have hidden. Two CoreSight drivers, an in-process debug server, a working decode and reconstruction pipeline, and a live trace view inside an editor, obtained over a probe that cannot capture a trace port, is a defensible contribution on any reading.

What holds it back is that the two chapters carrying the contribution are supported by a validation section built on a single capture and a self-referential baseline, and introduced by a state-of-the-art chapter with one citation. Neither of those is a limitation of the work. Both are correctable in the time remaining, and the corrections make the result look stronger, not weaker, because the true numbers are better than the reported ones and the true scope decisions are better justified than the report admits.
