# Internship recall form

Purpose: recover the work that never reached the report. Almost every question is
recognition rather than recall, so read the options and tick or strike them rather
than trying to remember from a blank page.

How to use it:

- Answer in any order, over several sittings. Partial answers are useful.
- `[x]` yes, `[-]` no, `[?]` cannot remember. Leave blank if not applicable.
- Where a line says **A:** write freely. One line is often enough.
- Rough is fine. "Early on", "after the drivers worked", "near the end" are valid.
- If a question is wrong or makes no sense for what you did, strike it and say why.
  A wrong assumption on my side is itself information.

Sections A and B are worth the most. If you only do two, do those.

---

## A. The commercial toolchain and probe evaluation

This is the single largest body of work missing from the report. Chapter 1 asserts
what IAR, Keil, Arm and SEGGER support, and cites nothing. You evaluated them
first-hand with three trace probes. That evaluation is a legitimate source, and it
converts the weakest chapter into one backed by direct evidence.

### A1. What did you actually run?

Tick every combination you personally got as far as a working debug session.

| Toolchain | ST-LINK | I-jet Trace | ULINK Pro | J-Trace Pro |
|---|---|---|---|---|
| IAR Embedded Workbench / C-SPY | [x] | [x] | [-] | [x] |
| Keil MDK / µVision | [x] | [-] | [x] | [x] |
| SEGGER Ozone | [-] | [-] | [-] | [x] |
| Arm Development Studio | [-] | [-] | [-] | [-] |
| STM32CubeIDE | [-] | [-] | [-] | [-] |
| OpenOCD (stock) | [x] | [-] | [-] | [-] |
| pyOCD | [-] | [-] | [-] | [-] |
| Other: | | | | |

Note: As you already know, stlink doesn't produce trace, and even on-chip trace sinks aren't supported using ST-Link on anything beyond ArmDS which I didn't use.

**A2. Which boards and MCUs did you use for these evaluations?**
The report only ever names the NUCLEO-H7S3L8. If the trace probes were used on a
different board, that matters, because a trace probe needs a trace connector.

A: Boards I used: NUCLEO-H563ZI, STM32H757I-EVAL, NUCLEO-N657X0-Q, NUCLEO-H743ZI.

**A3. For each combination that produced instruction trace, what did you actually see?**
Free text per row. What the view was called, what it showed, how much history,
whether it was continuous or a window.

A: Same view for all of them, which is the same view I implemented, a "sheet" like view with columns for instruction address, mneumonic, potentially source code and timestamp if present.

**A4. Did any of them capture through the on-chip buffer (the ETF), or only through the trace pins?**
This is the crux of the whole report. If a vendor tool ever drained the ETF, the
report's claim needs narrowing. If none did, say so plainly, because that is the
finding.

A: They all support on-chip buffers (for the love of God, always refer to it as TMC, never a specific configuration) unless talking about a specific chip. The issue is, the support is only offered when using the debug probe of that IDE, so ST-Link can't be used for example (except on ArmDS but I can't guarantee that either, actually remove ArmDS as I don't even have enough information to talk about it).

**A5. Did any tool overwrite trace configuration you had set yourself?**
The report claims vendor IDEs write preset values into the CoreSight registers on
session start. Did you observe that, and how? Reading registers back before and
after? A visible reset of your settings?

A: This will be a full explanation on how the configuration generally works in vendor IDEs, suppose you want to activate a feature, like for example instruction trace, you tick some boxes in the GUI, and whenever you then halt/reset/run the device, that configuration is re-applied, I guess this is to keep settings consistent? IDK.
Next, we have scripting languages, IAR has MAC files, SEGGER has the jlinkscript file, and keil has an amalgamtion using a .ini script file with C like syntax as well as the dbgconf and pdsc files. They all define some "callback"/"prototype" for specific events, they're basically event handlers that you can override/compose on top of(depends on the IDE and not really relevant detail), kind of like openocd's TCL interface with examine-end and all, but they don't expose the full configuration in these handlers, and you cannot describe components explicitly especially in the GUI, they rely on "high level" text indications like enable trace, timestamps or whatever, but do not allow register level configuration of components (you can still do that in the scripting interface because you have access to the device's address space).

**A6. What did you want to configure and could not?**
Table 1.3 lists conditional tracing, event tracing and cross-trigger awareness. Was
that list produced from these evaluations or from reading the specifications?
What else was refused, greyed out, or absent from the UI?

A: It's basically just absent from the UI, the ETM implementation in the STM32 families I remember working with implement no comparators themselves, however they can interface with the CPU comparators (DWT) for filtering (aka conditional trace), while the IDEs offer "tracepoints", they fail to be set on these devices, which I'm assuming is because they are checking for ETM comparators instead of DWT comparators. For CTI, the issue is that there's no notion of CTI concept at all in the Keil and IAR (I will be focusing on these from now on because they are the ones I worked on the most), while it's generally associated with multi-core setups, the CTI has trigger events related to trace components as well, and has ones that are even linked to interrupts, even on multi-core devices, you can configure the CTI completely from the scripting interface to synchronize halt events between cores, and theoratically you can do the same using trace events (depends on the core and MCU), but that's backwards of the way they try to enforce control over the GUI. For event tracing, the ETM can generate events, based on multiple conditions, which can be tracked by the event number, I believe Keil has this interface, but I didn't fully investigate the capabilities, however IAR doesn't.

**A7. Which of these did you attempt?**

- [-] Setting ETM address comparators / start-stop regions from a vendor IDE: This works fine on devices with comparators of the ETM if implemented, but doesn't use DWT comparators.
- [-] Filtering trace to one function or address range : Follows the earlier answer
- [x] Exporting or saving a raw trace capture from a vendor tool to a file: Works only with J-Trace, not supported in keil/iar
- [x] Re-opening a saved capture without a live target attached: Not possible
- [x] Scripting a trace configuration (IAR macros, Keil script, Ozone JS)
- [-] Using the ITM / SWO alongside instruction trace
- [-] Using the DWT for PC sampling or watchpoint trace
- [x] Cross-triggering (CTI) between components
- [x] Reading the ETM or TMC registers directly from the IDE's memory view
- Other:

**A8. Versions.**
Any version numbers you can recall or find in a screenshot or install folder, even
approximate. Needed so the tables can be captioned honestly.

A: 9.70 IAR, 5.43 Keil

**A9. Slide 29 of your presentation says IAR supports trace with "I-Jet/J-Trace (Partially)".**
What does *partially* mean? That is a first-hand observation and it belongs in the
report, but only if you can say what the limitation was.

A: Supports ETMv3 but not ETMv4

**A10. SEGGER Ozone and J-Trace Pro are not on slide 29 at all, yet you used them.**
Deliberate omission or an oversight? What did Ozone do that the others did not, or
fail to do?

A: So here's a bit of a story, the internship at first didn't have any development plans, no debugger no PoC no nothing, I was just supposed to author an application note about how to use instruction trace on STM32 devices, the plan was to just use vendor IDEs and explore configuration/setup, features, output etc... However it turned out to be very basic and limited, not something that can be turned into a graduation project. The full content of the application note is done in like 3 days. We started then by exploring SEGGER's ecosystem, and while it's in my personal opinion way more interesting that the other two, my mentor decided that we won't dig much into it for whatever reason (don't put this into record he's just a bit stiff).

**A11. Did you try any open-source or third-party trace tooling?**

- [-] `orbuculum` / orbtrace
- [-] `perf` / CoreSight support on Linux hosts: We are working with STM32 MICROCONTROLLERS COME ON
- [-] Lauterbach TRACE32 (even a demo)
- [-] SEGGER SystemView: Not in the same scope
- [-] Percepio Tracealyzer
- [-] pyOCD's trace features
- [-] OpenOCD's existing `etm` / `etb` / `tpiu` commands: etm is etmv1 no device in STM32 families implements it, etb is the older "CoreSight ETB" component which is then replaced by the TMC, and TPIU, there's no point because no supported probe (except for J-Trace, in which case its trace API isn't supported).
- Other:

Notes:

---

## B. Approaches tried and abandoned

The report's chronology section says several design decisions came from discovering
that an earlier arrangement did not work. It names almost none of them. Abandoned
approaches are defence material, because they show the decision was reasoned.

**B1. Which of these did you try before the final arrangement?**
Tick, then say in one line why it was dropped.

- [x] Capturing over the trace pins and a TPIU, on this board or another
      Why dropped: It isn't dropped, using a TPIU requires a dedicated probe, which can't be driven without the IDE, except for the case of the J-Trace, and I wanted to work on it but again my mentor is a bit of a degenerate, so I couldn't, and IDEs are already locked, there's nothing extra I could have done or expanded upon, they give you already decoded trace data, they don't allow you to interact with raw trace, and they don't offer post-mortem decoding. So we just explored everything we can do with what we have.
- [ ] SWO / ITM as the route off chip instead of the ETF
      Why dropped: You are being a bit of an idiot for asking this, SWO has nothing to do with ETM, and ITM is instrumentation trace.
- [x] The ETR configuration, tracing into system RAM instead of the internal buffer
      Why dropped: It isn't dropped, for the love of GOD READ THE FUCKING TMC REFERENCE MANUAL YOU ABSOLUTE IDIOT. THE ETR IS THE SAME COMPONENT AS AN ETF THEY ARE BOTH CONFIGURATIONS OF THE TMC. IT JUST DEPENDS ON WHAT DEVICE DO YOU HAVE, BUT BOTH OF THEM HAVE THE SAME INTERFACE. EXACT SAME INTERFACE. AND IF YOU LOOK AT THE TMC MODULE IN MY OPENOCD FORK YOU CAN ALREADY FIND SUPPORT FOR ETR CONFIGURATION YOU very amazing beautfil robotic idiot.
- [x] Running OpenOCD as a separate process and talking to it over a socket
      Why dropped: This created a lot of ownership problems when setting up the debugging instance, for example, I wouldn't have access to openocd state, I would have to talk to it over TCL because the RSP interface serves a single client and that would be LLDB, the TCL interface is slow, and I would have to use another IPC mechansim to get trace data between the two processes, also the vs-code extension's stderr would then somehow have to keep track of LLDB, openocd, and the debugger's output, and then remains the question of who runs openocd the frontend, backend, or the user, and then how do I discover what interface to talk to, and I have to keep an idle loop in my program until I can discover the openocd process that I am looking for.
- [x] Driving everything through the GDB remote protocol, including `monitor` commands
      Why dropped: monitor command requires an extension plugin in LLDB, which I don't want to add to the basic LLDB SB API, further more, it is just slower.
- [x] GDB instead of LLDB
      Why dropped: Nothing similar to LLDB's SB API, meaning I would have to implement things in either GDB's source code or the MI interface which isn't intended for this.
- [x] Writing your own trace decoder instead of using OpenCSD
      Why dropped: Too much work for something that's not really revolutionary, although I agree that I could've written my own "decoder" (openocd does processing which is raw data->etmv4 atoms/packets, and decoding etmv4 atoms -> generic packets), which would allow me to expand more and have more control, but for this simple implementation, there was really no need for that, but is something I want to implement in the future, because for example, OpenCSD's decoder doesn't support conditional instruction atoms things like instructions inside IT blocks.
- [x] pyOCD instead of OpenOCD
      Why dropped: The plan was to add support for ETM and TMC in all 3 major open-source OCDs (pyOCD, openOCD, and probe-rs), I just didn't have enough time.
- [-] The ST-LINK GDB server instead of OpenOCD
      Why dropped: Because I can't expand on it and didn't have access to the source code.
- [x] Streaming trace out over the TCP service instead of the callback
      Why dropped: Slower.
- [x] A standalone command-line tool as the final product
      Why dropped: it is possible but my mentor is just a whine baby and is afraid of the terminal so he just wants his fancy GUI.
- [-] A different frontend: a GUI of your own, a TUI, a web page, a GDB/LLDB plugin
      Why dropped: frontend was never even something important just a way to have visual output so my mentor stops crying that the solution isn't usable.
- [x] Patching an existing debug adapter rather than writing one
      Why dropped: ?????????? Didn't drop? Literally copied LLDB-DAP directly and modified it, I think you can find the comments and licenses. Are you sure you read the code?
- Other approaches:

**B2. The presentation and the driver disagree on how the buffer is read.**
Slide 45 says the RAM Read Data register is read continuously "until the value is
`0xFFFFFFFF`". The driver in the repository computes the fill level first and reads
exactly that many words. Was the sentinel approach an earlier attempt that was
replaced? If so, why did it fail?

A: Yes, it was an earlier approach, it didn't fail, it's just that the current way is more optimal, the sentinel approach relies on continuously issuing a single read atomically before getting the next one, and since all of the processing we're doing oon the host machine is really light-weight, the sole bottleneck is the physical link between the device and the host machine, so in the case of reading the sentinel, each read comes with the overhead of a USB transfer, where as using the second method offers some sort of "bulk" transfer (read the ST-Link usb driver in openocd if you want more details, as well as the mem ap mem read/write api).

**B3. Was there anything you got working that is not in the final result?**
Features that existed at some point and were removed, or that worked on the bench
and were never wired into the engine.

A: Yes offline decoding ironically, it was a standalone CLI tool, I can just give it the information needed (trace dump, firmware image, etm regs and ISA), and it would just decode the etm trace. Just because the terminal is scare, so now there's no offline decoding in vs-code nor is there a cli tool for it (although can easliy be restored at some point in the commit history, you may check it but don't bring it back).

**B4. What took the longest, and what surprised you?**
Not for the chronology. For the defence. The question "what was the hardest part"
is nearly certain to be asked.

A: This is not a concern of the report. The peripheral view funnily enough because XML is just the devil's son.

**B5. Did you ever have the trace pipeline working end to end on a device other than the H7RS?**

A: Yes, STM32N657, STM32H757, and others I won't name, just these two is enough.

---

## C. Reading and sources

**C1. Which documents actually changed a decision?**
Not everything you read. The ones where a specific sentence or table settled a
question. Name the document and, if you can, what it settled.

A:

**C2. Which of these did you read enough of to cite honestly?**

- [x] Arm ETMv4 architecture specification (IHI0064)
- [x] Arm CoreSight architecture specification (IHI0029)
- [x] Arm Trace Memory Controller TRM (DDI0461)
- [x] Arm Debug Interface (IHI0031)
- [x] ARMv7-M architecture reference manual (DDI0403)
- [ ] Cortex-M7 TRM / CoreSight ETM-M7 TRM
- [x] CoreSight SoC-400 TRM
- [-] AMBA ATB protocol specification
- [x] "Understanding Trace" / the Arm CoreSight learn-the-architecture guide
- [x] RM0477 (H7RS), and which other reference manuals
- [ ] AN4989, the STM32 debug toolbox
- [-] UM3276, the NUCLEO-H7S3L8 board manual
- [x] OpenCSD documentation or source
- [-] The Debug Adapter Protocol specification
- [-] The GDB remote serial protocol documentation
- [x] DWARF 5
- [x] LLDB / LLVM documentation
- Other:

**C3. Which papers or theses did you actually read, and did any influence the work?**
FrankenTrace, Ninja, the hardware runtime verification paper, the OpenOCD thesis,
and anything else. Honest answer wanted: "downloaded, skimmed, not used" is a fine
answer and stops me citing something you cannot discuss.

A: Basically skimmed through all of them without thoroughly reading any.

**C4. What information was hardest to find, or wrong, or missing from the documentation?**
This is the justification for the application note existing, and it is currently
asserted rather than evidenced.

A: Here's what my mentor said: I want this document so that anyone without any idea about what trace is, can read it understand it and work with it. Basically he wanted me to summarize all the documents already available into a single one with screenshots on IAR and Keil. I'll be honest here, I am the type of person that cannot work on something he isn't convinced with, and having to do the job of a secretary in an engineering internship is one of these moments, he basically was just too lazy to have 4-5 documents open, and this in case you wanted to thoroughly understand instruction trace. Which I did, but then guess what, he told me that this is too detailed, and he just wanted to have very basic definitions and then just how to use them, "and how to interpret the results", basically what the user guide for iar's C-SPY and keil's debugger already do, he wanted me to do come up with an example problem where intrusive debugging doesn't work, but I'm not allowed to do anything except for use a dev-board, and I am not allowed to use complex projects because then it would be too hard to follow, basically how to debug a toggle led project with trace which just isn't even sensible.

**C5. Did you use any non-document source?**
Forum threads, mailing lists, the OpenOCD or OpenCSD issue trackers, vendor support,
colleagues, existing open-source code you read for reference.

A: There was the mailing list for gdb which had some attempts for integrating ETM data and decoding as a primitive but nothing beyond that really. For colleagues, yes, but that's a useless information I obviously worked with a team and sometimes we'd discuss what everyone's doing and they'd suggest things or idk.

---

## D. The application note

The report describes its audience, scope and structure. Nothing about how it was
produced. Its content stays confidential, the process does not.

**D1. Who asked for it, and who was the intended reader inside or outside ST?**

A: It was just the laziest least researched project idea at ST, my mentor watched an introductory 8 min video on a confidential platform about coresight and instruction trace and was like how come there was this debugging method I wasn't aware of. And there comes the project idea without any further research, that video somehow mentioned that ETM produces N/E atoms and that's all that my mentor remembers and kept repeating to me for 6 months.

**D2. Was it reviewed? By whom, in what role, and how many rounds?**

A: No clue.

**D3. What is its current status?** Draft, reviewed, approved, published, internal only.

A: No clue.

**D4. Roughly how long is it, and what does it contain besides prose?**
Register tables, code, configuration scripts, screenshots, a worked example.
Counts and kinds are not confidential content.

A: 20-ish pages, debug infrastructure diagrams, structures of how debugging elements in Keil and IAR work (the full elements you can control to configure your debug session). Tables with all the STM32 MCU debug capabilities, a pseudo code algorithmic description of the PoC. Non of which I can retrieve because not even I have access to it right now.

**D5. Did writing it change the implementation?**
Did documenting a procedure expose something that then got fixed in the drivers?

A: Nope the app note was long done before any development even came to light.

**D6. What was cut from it, and why?**

A: Any details about trace components.

---

## E. Testing, validation and measurement you did by hand

The report's validation section is its weakest part. Almost certainly you checked
more than is written down. Anything here that you actually did can be reported.

**E1. Did you ever compare your reconstructed trace against a vendor tool's trace of the same program?**
If yes, this is the strongest single piece of evidence in the whole project and it
is not in the report at all. What matched, what did not.

A: Everything matched, if you aren't aware, the etmv4 arch spec already provides the algorithm on how to process/decode etm trace data (well we also need to deformat the coresight formatter), so it's not like there's resemblance, it either matches or doesn't it's meant to be deterministic.

**E2. Did you ever check the reconstruction against single-stepping?**
Stepping through the same code and confirming the addresses agree.

A: Yes. It works.

**E3. Which of these did you observe on hardware, even informally?**

- [x] The buffer wrapping, and the driver reporting it full
- [x] An overflow reported by the trace unit
- [x] More than one capture accumulating across several halts
- [x] A capture boundary appearing as a gap in the view
- [x] Trace surviving or not surviving a device reset: We explicitly destroy it I believe.
- [x] Trace during single-stepping, and whether the stepped instruction appeared: It does
- [x] A program with a known loop count, reconstructed and counted: Even while loops, they appear.
- [x] A deliberately wrong ELF, to see the reconstruction fail: Accidentally by passing the wrong ELF to the disassembly, it still spits out instructions, it just is broken.
- [-] A capture taken with the trace unit misconfigured, to see what happens
- [x] Two devices or two boards giving the same result: it is meant to be deterministic, and trying using multiple boards produces the same result
- Notes:

**E4. Where did the 0.112 ms decode time come from?**
Timed by hand, printed by a build you no longer have, measured with a stopwatch,
estimated? On what machine? There is no timing code anywhere in the repository, so
I cannot reconstruct it.

A: An AI hallucinated it. At some point I also used perf, but I am not sure I used it on tests, anyway I did use perf throughout the project for profiling the debugger, while using claude maybe it found the perf file and read it.

**E5. Which of the numbers in Table 5.7 did you write down at the time, and which were read off later?**

A: The reset handler trace reconstruction was basically the baseline I used for testing, so not sure I udnerstand the question.

**E6. What did you test that never made it into a test file?**
Manual checks, one-off scripts you deleted, things you verified in the debugger.

A: Not sure if there's any mention of ASAN and threadsanitizer in the report, using the arm snapshot format for off-line trace decoding, and a trace dump captured by J-Trace instead of openocd.

**E7. Beyond the six defects in Table 5.5, what else broke and got fixed?**
Anything where the cause was more interesting than the symptom.

A: The table seems full of shit currently, so I would like you to attempt harder at questioning because my mind is blank but there was I am sure.

---

## F. Bench, hardware and environment

**F1. List every board you used, and what each was for.**

A: Already mentioned them in A2, all used for off-chip trace using vendor probes, minus the N6, H7/H7RS used for both (H743 only for on-chip didn't have mipi-20 connector).

**F2. Which trace connector did the boards have?**
MIPI-20, MIPI-10, a Cortex Debug + ETM header, none. This decides whether the
trace-probe evaluations were even possible on the same board as the final result.

A: All had MIPI-20

**F3. What firmware did you trace?**
The repository holds a boot ELF. Was that the only program, or did you trace others?
Was it your own or an existing example?

A: Multiple examples from STM32Cube, toggle led, applications compiled with IAR/Keil/GCC.

**F4. Did you use the on-board ST-LINK, a standalone ST-LINK, or both?**

A: On-board ST-LINK

**F5. Host operating systems, and which one the results came from.**

A: Both linux and windows obviously.

**F6. Anything about the bench that constrained the work?**
Shared hardware, a probe you only had for a week, a licence that expired, a machine
you could not install on.

A: Lack of use for interesting probes like J-Trace, or DSTREAM family and lauterbach which I couldn't get a hold on. And the fact that my work machine is windows because I hate that OS. Nothing interestingg to mention tho.

---

## G. Scope, constraints and decisions made for you

**G1. What was the original brief, in one or two sentences, as it was given to you?**

A: Make an application note so that anyone can pick up instruction trace.

**G2. What changed about the objective during the internship, and why?**

A: Going from an application note to developing the PoC and later the debugger. Because the application note was humiliating as a graduation project.

**G3. Which decisions were yours, and which were imposed?**
Target device, tooling, open-source base, the deliverables, the frontend choice.

A: Everything about the debugger PoC was mine, everything about the application note was my mentor, so the use of vendor probes, windows, etc....

**G4. Why the H7RS specifically?**
Availability, a mandate, the only STM32 with an on-chip buffer to hand, something else.

A: Just because it was the first MCU I found when looking in the inventory that had both on-chip and off-chip trace sinks.

**G5. Was anything ruled out for a reason that cannot go in the report?**
Say so here and I will keep it out. Knowing it exists stops me proposing a fix that
walks into it.

A: Anything mentioned above that has to do with my mentor being a dick, mainly the use of SEGGER/ArmDS/Lauterbach, requiring windows on the work machine, the application note being restricted to configuration/setup for IAR/Keil before adding the PoC.

---

## H. The result, as you would defend it

**H1. What are you actually claiming as your contribution?**
In your own words, one paragraph, no report language. The report never states this
in one place and it is the paragraph the defence rests on.

A: Authored application note, added etmv4/tmc modules to openocd, created an instruction trace decode pipeline and created a "debugger" that uses lldb's sb api and made openocd as a library to be able to integrate everything together into a single project.

**H2. Slide 30 lists a gap the report does not: "No trace decoding is possible outside of a debug session."**
Slide 34 repeats it as a reason for a new debugger. The report never claims it.
Is offline decoding a real capability of your result, and did you demonstrate it?
If so it belongs in Chapter 1 and in the results.

A: Yes, an earlier commit already had it, I just deleted it out of spite, but it is very possible, also, yes IAR/Keil leave the debug session the moment a device disconnects, so trace data is lost.

**H3. Slide 59 lists "Graphical Configuration Interface" as future work. The report does not.**
Deliberate, or dropped by accident?

A: IDK to be honest I thought about it, very plausible.

**H4. What would you do next if the internship continued for another month?**

A: I would probably add more features to the trace part of the debugger and change how openocd implements DWT resources so that I can add the comparators as useable by the ETM for filtering.

**H5. What do you consider the weakest part of the work?**
Your answer, not mine. It will be asked, and a prepared honest answer is worth more
than a defended one.

A: Application note, because it's just a bullshit document. And the way to go around this is to talk about it the bare minimum amount.

---

## I. Loose ends

**I1. Anything you did that none of the above asked about.**
Meetings, training, a side task, tooling you built for yourself, something you
automated, a demo you gave, help you gave someone else.

A: I basically worked a full time job there solving some real problems, helping people, meeting with confidential clients, finding errratas on devices I cannot even disclose, a "translator" built based on an AST transpiler so that I can write a single script and it translates it back to all scripting interfaces of vendor IDEs (keil/iar/segger), dropped it because it was too much work that I couldn't afford and I had no access to the full grammar of these languages. and IDK if that even can go into the report.

**I2. Anything in the report you are not sure is true.**
Claims you would rather not have to defend. Flag them and I will check each one
against the sources.

A: I am not sure right now.

**I3. Anything you were told during the internship that contradicts something in the report.**

A: More questioning needed
