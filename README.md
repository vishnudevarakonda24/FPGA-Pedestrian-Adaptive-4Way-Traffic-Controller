# FPGA-Pedestrian-Adaptive-4Way-Traffic-Controller
"Developed an intricate finite state machine controlling red, yellow, green, and pedestrian states at fourway
intersections"
## 🎯 Motivation & Engineering Purpose
Software-based traffic microcontrollers can experience task scheduling delays under heavy traffic simulation loads, leading to unpredictable timing errors. This project transitions the intersection management pipeline into dedicated FPGA hardware logic. The system uses a synchronous FSM to ensure fixed-interval switching times, safe inter-state delays (Yellow clearance windows), and an auto-latching pedestrian crossing mechanism that prevents signal deadlocks.

## ⚙️ FSM State Routing Operational Flow
- **State 0 (S_NS_G):** North-South green light active for 30 ticks.
- **State 1 (S_NS_Y):** North-South yellow transition light active for 5 ticks. Evaluates pedestrian crossing latching flag upon exit.
- **State 2 (S_NS_P):** Dedicated Pedestrian Walk interval active for 15 ticks if an external interrupt request was latched.
- **State 3 (S_EW_G):** East-West green light active for 30 ticks.
- **State 4 (S_EW_Y):** East-West yellow transition light active for 5 ticks. Evaluates pedestrian crossing latching flag upon exit.
- **State 5 (S_EW_P):** Dedicated Pedestrian Walk interval active for 15 ticks if an external interrupt request was latched.
  
## ⚙️ Finite State Machine (FSM) Architecture Map

The system architecture utilizes a deterministic, synchronous State Machine to handle safe lane transitions and pedestrian preemption routing:

```
       ┌────────────────────────────────────────────────────────┐
       │                                                        │
       ▼                                                        │
[ State 0: S_NS_G ] ──(after 30s)──► [ State 1: S_NS_Y ]        │ (after 15s)
                                             │                  │
                                   (Is Pedestrian Latch High?)  │
                                             │                  │
                                             ├──► YES ──► [ State 2: S_NS_P ]
                                             │                  │
                                             └──► NO  ──┐       │
                                                        ▼       │
[ State 3: S_EW_G ] ◄──(after 15s)─── [ State 5: S_EW_P ]       │
       │                                     ▲                  │
  (after 30s)                                │                  │
       │                           (Is Pedestrian Latch High?)  │
       ▼                                     │                  │
[ State 4: S_EW_Y ] ─────────────────────────┼──► YES ──────────┘
       │                                     │
       └─────────────────────────► NO ───────┘
```

### 💡 Architectural Safety Controls
* **Anti-Preemption Delays:** Pedestrian inputs do not interrupt a green light state directly. Instead, they are captured safely by a synchronous hardware latch, allowing active moving vehicles a full deceleration clearance window during the Yellow state before routing to a crossing phase.
* **Deterministic Timing Blocks:** Counters reset to zero dynamically on state transitions using ternary comparison matching to eliminate timer spillover bugs across cycles.

## 🧪 Simulation and Verification
The system architecture was compiled and verified using Questa-Sim. The structural testbench drives a continuous clock cycle to observe transitions under baseline loops, followed by dynamic asynchronous interrupt insertion to check the priority routing safety lanes.
