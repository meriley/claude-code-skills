# Enum Patterns

Comprehensive enum implementations for RMS Go code.

## String Enum with Validation

```go
type Status string

const (
    StatusPending    Status = "PENDING"
    StatusInProgress Status = "IN_PROGRESS"
    StatusComplete   Status = "COMPLETE"
    StatusCancelled  Status = "CANCELLED"
)

// All valid statuses
var validStatuses = map[Status]struct{}{
    StatusPending:    {},
    StatusInProgress: {},
    StatusComplete:   {},
    StatusCancelled:  {},
}

func (s Status) String() string {
    return string(s)
}

func (s Status) IsValid() bool {
    _, ok := validStatuses[s]
    return ok
}

func (s Status) IsTerminal() bool {
    return s == StatusComplete || s == StatusCancelled
}

func (s Status) CanTransitionTo(next Status) bool {
    allowed := map[Status][]Status{
        StatusPending:    {StatusInProgress, StatusCancelled},
        StatusInProgress: {StatusComplete, StatusCancelled},
        StatusComplete:   {},
        StatusCancelled:  {},
    }
    
    for _, valid := range allowed[s] {
        if valid == next {
            return true
        }
    }
    return false
}

func ParseStatus(s string) (Status, error) {
    status := Status(s)
    if !status.IsValid() {
        return "", fmt.Errorf("invalid status: %q", s)
    }
    return status, nil
}

// MarshalJSON implements json.Marshaler
func (s Status) MarshalJSON() ([]byte, error) {
    return json.Marshal(string(s))
}

// UnmarshalJSON implements json.Unmarshaler
func (s *Status) UnmarshalJSON(b []byte) error {
    var str string
    if err := json.Unmarshal(b, &str); err != nil {
        return err
    }
    
    status, err := ParseStatus(str)
    if err != nil {
        return err
    }
    
    *s = status
    return nil
}

// Values returns all valid status values
func StatusValues() []Status {
    return []Status{
        StatusPending,
        StatusInProgress,
        StatusComplete,
        StatusCancelled,
    }
}
```

## Integer Enum with iota

```go
type Priority int

const (
    PriorityUnknown Priority = iota
    PriorityLow
    PriorityMedium
    PriorityHigh
    PriorityCritical
)

var priorityNames = map[Priority]string{
    PriorityUnknown:  "unknown",
    PriorityLow:      "low",
    PriorityMedium:   "medium",
    PriorityHigh:     "high",
    PriorityCritical: "critical",
}

var priorityValues = map[string]Priority{
    "unknown":  PriorityUnknown,
    "low":      PriorityLow,
    "medium":   PriorityMedium,
    "high":     PriorityHigh,
    "critical": PriorityCritical,
}

func (p Priority) String() string {
    if name, ok := priorityNames[p]; ok {
        return name
    }
    return fmt.Sprintf("Priority(%d)", p)
}

func (p Priority) IsValid() bool {
    _, ok := priorityNames[p]
    return ok
}

func (p Priority) IsHigh() bool {
    return p >= PriorityHigh
}

func ParsePriority(s string) (Priority, error) {
    if p, ok := priorityValues[strings.ToLower(s)]; ok {
        return p, nil
    }
    return PriorityUnknown, fmt.Errorf("invalid priority: %q", s)
}

func (p Priority) MarshalJSON() ([]byte, error) {
    return json.Marshal(p.String())
}

func (p *Priority) UnmarshalJSON(b []byte) error {
    var s string
    if err := json.Unmarshal(b, &s); err != nil {
        // Try as integer
        var i int
        if err := json.Unmarshal(b, &i); err != nil {
            return err
        }
        *p = Priority(i)
        return nil
    }
    
    priority, err := ParsePriority(s)
    if err != nil {
        return err
    }
    *p = priority
    return nil
}
```

## Bit Flag Enum

```go
type Permission int

const (
    PermNone   Permission = 0
    PermRead   Permission = 1 << iota
    PermWrite
    PermDelete
    PermAdmin
    
    PermReadWrite = PermRead | PermWrite
    PermAll       = PermRead | PermWrite | PermDelete | PermAdmin
)

func (p Permission) Has(flag Permission) bool {
    return p&flag == flag
}

func (p Permission) Set(flag Permission) Permission {
    return p | flag
}

func (p Permission) Clear(flag Permission) Permission {
    return p &^ flag
}

func (p Permission) String() string {
    if p == PermNone {
        return "none"
    }
    
    var parts []string
    if p.Has(PermRead) {
        parts = append(parts, "read")
    }
    if p.Has(PermWrite) {
        parts = append(parts, "write")
    }
    if p.Has(PermDelete) {
        parts = append(parts, "delete")
    }
    if p.Has(PermAdmin) {
        parts = append(parts, "admin")
    }
    
    return strings.Join(parts, ",")
}

// Usage
perm := PermRead | PermWrite
if perm.Has(PermRead) {
    // Can read
}
perm = perm.Set(PermDelete)
perm = perm.Clear(PermWrite)
```

## Enum with Additional Data

```go
type ActionType struct {
    value       string
    displayName string
    isSystem    bool
}

var (
    ActionTypeCreate   = ActionType{"CREATE", "Created", false}
    ActionTypeUpdate   = ActionType{"UPDATE", "Updated", false}
    ActionTypeDelete   = ActionType{"DELETE", "Deleted", false}
    ActionTypeAssign   = ActionType{"ASSIGN", "Assigned", false}
    ActionTypeComplete = ActionType{"COMPLETE", "Completed", false}
    ActionTypeSystem   = ActionType{"SYSTEM", "System Action", true}
)

var actionTypes = map[string]ActionType{
    ActionTypeCreate.value:   ActionTypeCreate,
    ActionTypeUpdate.value:   ActionTypeUpdate,
    ActionTypeDelete.value:   ActionTypeDelete,
    ActionTypeAssign.value:   ActionTypeAssign,
    ActionTypeComplete.value: ActionTypeComplete,
    ActionTypeSystem.value:   ActionTypeSystem,
}

func (a ActionType) Value() string       { return a.value }
func (a ActionType) DisplayName() string { return a.displayName }
func (a ActionType) IsSystem() bool      { return a.isSystem }
func (a ActionType) String() string      { return a.value }

func ParseActionType(s string) (ActionType, error) {
    if at, ok := actionTypes[s]; ok {
        return at, nil
    }
    return ActionType{}, fmt.Errorf("invalid action type: %q", s)
}

func (a ActionType) MarshalJSON() ([]byte, error) {
    return json.Marshal(a.value)
}

func (a *ActionType) UnmarshalJSON(b []byte) error {
    var s string
    if err := json.Unmarshal(b, &s); err != nil {
        return err
    }
    at, err := ParseActionType(s)
    if err != nil {
        return err
    }
    *a = at
    return nil
}
```

## Proto-Compatible Enum

```go
// Matches proto enum
type EntityType int32

const (
    EntityTypeUnspecified EntityType = 0
    EntityTypeTask        EntityType = 1
    EntityTypeDocument    EntityType = 2
    EntityTypeCase        EntityType = 3
    EntityTypeEvidence    EntityType = 4
)

var entityTypeNames = map[EntityType]string{
    EntityTypeUnspecified: "ENTITY_TYPE_UNSPECIFIED",
    EntityTypeTask:        "ENTITY_TYPE_TASK",
    EntityTypeDocument:    "ENTITY_TYPE_DOCUMENT",
    EntityTypeCase:        "ENTITY_TYPE_CASE",
    EntityTypeEvidence:    "ENTITY_TYPE_EVIDENCE",
}

var entityTypeValues = map[string]EntityType{
    "ENTITY_TYPE_UNSPECIFIED": EntityTypeUnspecified,
    "ENTITY_TYPE_TASK":        EntityTypeTask,
    "ENTITY_TYPE_DOCUMENT":    EntityTypeDocument,
    "ENTITY_TYPE_CASE":        EntityTypeCase,
    "ENTITY_TYPE_EVIDENCE":    EntityTypeEvidence,
}

func (e EntityType) String() string {
    if name, ok := entityTypeNames[e]; ok {
        return name
    }
    return fmt.Sprintf("EntityType(%d)", e)
}

// ToProto converts to proto enum value
func (e EntityType) ToProto() pb.EntityType {
    return pb.EntityType(e)
}

// FromProto converts from proto enum value
func EntityTypeFromProto(p pb.EntityType) EntityType {
    return EntityType(p)
}
```
