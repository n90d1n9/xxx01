```mermaid
flowchart TD
    %% Entry Points
    UI[UI Portal]
    CLI[Scheduler CLI]
    DSLs[DSLs (Java, Python)]

    %% Iket 
    API[Iket ]

    UI --> API
    CLI --> API
    DSLs --> API

    %% Maestro Service
    subgraph Maestro Service
        CPAPI[Control Plane API]
        DB[Consul]
        TT[Time Trigger Service]
        WF[Workflow Engine]
        SS[Signal Service]
        Queue[Distributed Queue]
    end

    API --> CPAPI
    CPAPI --> DB
    DB --> WF
    WF --> TT
    WF --> SS
    TT --> Queue
    WF --> Queue
    SS --> Queue

    %% Execution Plane
    subgraph Execution Plane
        Titus[Titus]
        Genie[Genie]
        Docker[Any Docker Container]
        Jupyter[Jupyter Notebook]
    end

    %% External Systems
    Spark[Spark]
    Trino[Trino]
    Kafka[Kafka]
    ErrorSvc[Error Classification Service]

    %% Data Flow
    Queue --> Titus
    Titus --> Docker
    Titus --> Genie
    Genie --> Spark
    Genie --> Trino
    Genie --> Jupyter

    Titus --> ErrorSvc
    ErrorSvc --> Titus

    %% Kafka Consumers
    Kafka --> Alerting[Alerting Service]
    Kafka --> Warehouse[Data Warehouse]
    Kafka --> Downstream[Downstream Services]

    %% Kafka flow
    Queue --> Kafka
```