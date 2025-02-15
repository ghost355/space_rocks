# Finite State Machine

```mermaid
graph TD 

Init -->|start game| Alive
Alive -->|lives == 0| Dead 
Dead -->|play again| Init
Alive -->|hit| Invuln 
Invuln -->|timeout| Alive
```
