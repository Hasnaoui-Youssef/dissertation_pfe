# Section 4.1.1 Global Architecture: 30 candidates

The previous set was 15 rewordings of one paragraph. These are 30 different
jobs the section can do. Each is complete and paste-ready. The figure block
below goes at the end of whichever is chosen.

```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=\linewidth]{fig_global_architecture.pdf}
    \caption{Global architecture of the solution}
    \label{fig:global_arch}
\end{figure}
```

Facts held constant: frontend and engine are separate programs joined by DAP.
The debug server is linked inside the engine. It is the only component that
acts on the device. USB to the probe, SWD to the target. Trace returns over
that same link. No RSP.

---

# Structure

## 1. Roles, nothing else

The frontend presents the debug session to the developer. The engine implements the debug logic and holds the debug server that drives the hardware. The debug probe is reached from the host over USB and reaches the target over SWD. The target executes the program under examination.

## 2. Roles plus the one boundary

The frontend presents the debug session to the developer. The engine implements the debug logic. The debug probe is reached from the host over USB and reaches the target over SWD. The target executes the program under examination.

The frontend and the engine are separate programs. The Debug Adapter Protocol of Section \ref{subsec:dap} joins them, and it is the only boundary in the system that separates one program from another. The debug server is linked into the engine, so no second process runs on the host.

## 3. Definition list

The elements of the system are defined as follows and are named this way for the rest of the report.

```latex
\begin{description}
    \item[Frontend] The program that presents the debug session and renders what it is sent. It holds no debug logic.
    \item[Engine] The program that implements every debug capability. It contains the debug server.
    \item[Debug server] The component that performs every access to the device. It is linked into the engine as a library.
    \item[Debug probe] The hardware that converts the USB connection from the host into SWD.
    \item[Target] The device that executes the program under examination.
\end{description}
```

Figure \ref{fig:global_arch} shows the links between them.

## 4. Layers

The system is a stack of four levels. Presentation is the frontend. Debug logic is the engine. Device access is the debug server, which the engine contains. Hardware is the probe and the target.

Each level is reached only through the one above it. The frontend never reaches the debug server, and no level below the engine is aware of the protocol spoken above it.

# Deployment

## 5. What runs where

Two programs run on the host computer. The frontend is one. The engine is the other, and the debug server is linked into it rather than run as a separate process.

The frontend and the engine communicate over the Debug Adapter Protocol of Section \ref{subsec:dap}. Everything below the engine is hardware, reached over a USB connection to the debug probe and an SWD connection from the probe to the target.

## 6. Host side and device side

On the host: a frontend that presents the session, and an engine that decides what every debug operation means. They are separate programs joined by the Debug Adapter Protocol of Section \ref{subsec:dap}.

On the device side: a debug probe reached over USB, and a target reached by the probe over SWD.

The debug server that drives the hardware is inside the engine, not between the two sides.

## 7. Ownership of the device connection

One component owns the connection to the device. That component is the debug server, and it is linked into the engine as a library. Every read, every write, every halt and every trace capture passes through it.

Above it, the engine implements the debug logic and answers the frontend over the Debug Adapter Protocol of Section \ref{subsec:dap}. Below it, a USB connection reaches the debug probe and SWD reaches the target.

# The connection

## 8. One link carries everything

A single connection joins the host computer to the target. It runs over USB to the debug probe and over SWD from the probe to the device. Run control, memory access and captured instruction trace all travel on it.

On the host, the engine holds the debug logic and the debug server that drives that connection. The frontend is a separate program and holds no debug logic, reached over the Debug Adapter Protocol of Section \ref{subsec:dap}.

## 9. Protocol at each junction

Each junction in the system is governed by a protocol.

The frontend reaches the engine over the Debug Adapter Protocol of Section \ref{subsec:dap}, whose extension mechanism carries the capabilities it does not define.

The engine reaches the debug probe over USB, driven by the debug server linked into it. The probe reaches the target over SWD.

## 10. What the connection carries

The connection between the host and the target carries three kinds of traffic. Run control halts, resumes and steps the processor. Memory access reads and writes the address space of the device. Extraction reads the buffer that holds captured trace.

All three are issued by the debug server inside the engine, over USB to the debug probe and SWD to the target. Nothing else on the host addresses the device.

# Constraint

## 11. The trace port constraint

Chapter \ref{ch:specification} required instruction trace without a trace port. That requirement fixes the shape of the system. Trace is stored in a buffer on the device and read back over the debug connection already present, which is USB to the probe and SWD to the target.

The component that performs that read is a debug server linked into the engine, and the same server serves every other access to the device. The frontend remains a separate program, joined to the engine by the Debug Adapter Protocol of Section \ref{subsec:dap}.

## 12. The probe constraint

The probe fitted to the board has no instruction trace capability, as Section \ref{subsec:probe} stated. Trace therefore has to be stored on the device and read back over the ordinary debug connection.

The architecture follows from that. A debug server, linked into the engine, drives a USB connection to the probe and an SWD connection to the target, and performs the read. The engine holds the debug logic above it. The frontend, a separate program, presents the session over the Debug Adapter Protocol of Section \ref{subsec:dap}.

## 13. The reuse constraint

Two mature components already existed: a debug server able to drive the probe, and a debugger library able to interpret a program image. Neither supports instruction trace on this device. The work of the project is therefore concentrated in the engine, which extends and combines them.

That decision places the debug server inside the engine as a library. The frontend stays outside as a separate program, joined by the Debug Adapter Protocol of Section \ref{subsec:dap}, and the hardware is reached over USB to the probe and SWD to the target.

# Contrast

## 14. Against the usual arrangement

A debug session is normally assembled from three programs on the host: an editor, a debug adapter, and a debug server reached over a network socket.

The solution keeps the first separation and removes the second. The frontend and the engine remain separate programs joined by the Debug Adapter Protocol of Section \ref{subsec:dap}. The debug server is linked into the engine as a library, because instruction trace requires operations the socket interface does not express and requires a capture to be delivered at the moment a halt occurs.

Below the engine the arrangement is conventional: USB to the debug probe, SWD to the target.

## 15. What changed and what did not

The chain of Section \ref{subsec:anatomy} is preserved. What changed is where the debug server sits.

In the conventional arrangement the server is a separate process reached over a socket. Here it is linked into the engine, which makes the engine the single program that acts on the device. The frontend is unaffected by that decision and remains a separate program speaking the Debug Adapter Protocol of Section \ref{subsec:dap}.

# Figure-led

## 16. Figure states it, prose adds what it cannot

Figure \ref{fig:global_arch} shows the elements and the links between them.

Three properties of that arrangement are not visible in the drawing. The debug server is linked into the engine as a library, so the engine and the server are one process. The frontend contains no logic that decides what a debug operation means. The link that returns captured trace is the link that already carries run control and memory access, which is what removes the need for a trace port.

## 17. Figure first, terse annotation

Figure \ref{fig:global_arch} states the architecture.

The frontend and the engine are separate programs, joined by the Debug Adapter Protocol of Section \ref{subsec:dap}. The engine and the debug server are one program. Captured trace returns over the connection that already carries every other operation.

# Contribution

## 18. Adopted and written

The frontend is an extension for an existing development tool. The debug server and the debugger library inside the engine are existing open-source projects. Written for this project are the trace pipeline, the components that constitute the engine, and the drivers added to the server.

The engine is therefore where the contribution sits. It holds the debug logic, contains the debug server, and reaches the device over USB to the probe and SWD to the target. The frontend is joined to it by the Debug Adapter Protocol of Section \ref{subsec:dap}.

## 19. The engine is the subject

The engine is the deliverable of the project. It implements every debug capability, contains the debug server that drives the hardware, and holds the pipeline that turns captured trace into a record expressed in source terms.

Everything else is context. The frontend is a separate program that presents the session and decides nothing, reached over the Debug Adapter Protocol of Section \ref{subsec:dap}. The debug probe converts USB into SWD. The target executes the program under examination.

# Flow

## 20. A request down and back

A request begins at the frontend and travels over the Debug Adapter Protocol of Section \ref{subsec:dap} to the engine. The engine decides what the request means and calls the debug server linked into it. The server issues the access over USB to the debug probe, which issues it over SWD to the target. The result returns along the same path.

Figure \ref{fig:global_arch} shows the elements this path crosses.

## 21. A capture upward

Instruction trace is generated by the processor and stored in a buffer on the device. When the processor halts, the debug server reads that buffer over SWD through the debug probe and over USB to the host.

The server is linked into the engine, so the capture is delivered inside the same program that decodes it. The record produced is sent to the frontend over the Debug Adapter Protocol of Section \ref{subsec:dap}. Figure \ref{fig:global_arch} shows the path.

# Responsibility

## 22. Who decides what

The frontend decides nothing. It issues requests and renders results.

The engine decides everything. It interprets the program image, resolves breakpoints, evaluates expressions and reconstructs execution from captured trace.

The debug server executes. It performs the accesses the engine asks for and reports what the device does.

The probe and the target carry no decision at all. Figure \ref{fig:global_arch} shows how they are connected.

## 23. What each element owns

The frontend owns presentation. The engine owns debug logic and the program image. The debug server, linked into the engine, owns the connection to the device. The probe owns the conversion from USB to SWD. The target owns execution.

No responsibility is shared, and the Debug Adapter Protocol of Section \ref{subsec:dap} is the only boundary crossed by a separate program.

# Negative space

## 24. What the system does not require

The architecture requires no trace port on the board, no probe able to capture one, no vendor development environment and no second process on the host.

What it does require is a device with an on-chip trace buffer, a probe capable of SWD, and a host running the engine. The engine holds the debug logic and the debug server, and the frontend is a separate program reached over the Debug Adapter Protocol of Section \ref{subsec:dap}. Figure \ref{fig:global_arch} shows the result.

## 25. Nothing between the engine and the device

No process sits between the engine and the hardware. The debug server is linked into the engine as a library, so an access issued by the debug logic reaches the USB driver without crossing a process boundary or a socket.

Above the engine, the frontend is a separate program, joined by the Debug Adapter Protocol of Section \ref{subsec:dap}. Below it, the probe converts USB into SWD.

# Short

## 26. Two sentences

The engine holds the debug logic and the debug server, and reaches the target over a USB connection to the debug probe and an SWD connection from the probe to the device. The frontend is a separate program that presents the session, joined to the engine by the Debug Adapter Protocol of Section \ref{subsec:dap}.

## 27. Three sentences

Figure \ref{fig:global_arch} shows the architecture. The frontend presents the session and holds no debug logic, reaching the engine over the Debug Adapter Protocol of Section \ref{subsec:dap}. The engine holds the debug logic and the debug server that drives the device, over USB to the debug probe and SWD to the target.

# Other angles

## 28. Signposting

The frontend presents the session. The engine holds the debug logic and, within it, the debug server that drives the device over USB to the probe and SWD to the target.

The rest of this chapter follows that division. Section \ref{sec:trace_arch} describes the trace pipeline inside the engine. Section \ref{sec:debugger_arch} describes the structure of the engine itself, and Section \ref{subsec:division} describes how the debug logic and the debug server divide the work between them.

## 29. Terminology

The terms used in this chapter are fixed as follows. Frontend means the program that presents the debug session. Engine means the program that implements the debug logic. Debug server means the component inside the engine that performs every access to the device. Probe means the hardware between the host and the target. Target means the device under examination.

The frontend and the engine are separate programs joined by the Debug Adapter Protocol of Section \ref{subsec:dap}. The probe is reached over USB, and the target over SWD. Figure \ref{fig:global_arch} shows the links.

## 30. What the shape makes possible

The shape of the system determines what it can do. Placing every debug capability in the engine allows a second frontend to be written without reimplementing any of it. Linking the debug server into the engine allows a trace capture to be delivered to the decoder at the moment a halt occurs. Using the ordinary debug connection for trace allows the technique to work on a board with no trace port.

Figure \ref{fig:global_arch} shows the elements. The frontend and the engine are separate programs joined by the Debug Adapter Protocol of Section \ref{subsec:dap}, and the probe is reached over USB and the target over SWD.
