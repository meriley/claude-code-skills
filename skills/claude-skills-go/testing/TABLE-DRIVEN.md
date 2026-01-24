# Table-Driven Test Templates

Templates for common table-driven test patterns.

## Basic Template

```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name     string
        input    InputType
        expected OutputType
        wantErr  bool
    }{
        {
            name:     "valid input",
            input:    validInput,
            expected: expectedOutput,
            wantErr:  false,
        },
        {
            name:    "invalid input returns error",
            input:   invalidInput,
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := FunctionName(tt.input)
            
            if tt.wantErr {
                assert.Error(t, err)
                return
            }
            
            assert.NoError(t, err)
            assert.Equal(t, tt.expected, got)
        })
    }
}
```

## Service Method Template

```go
func TestService_Method(t *testing.T) {
    tests := []struct {
        name       string
        args       MethodArgs
        setupMock  func(*MockDependency)
        want       *Result
        wantErr    bool
        wantErrIs  error
    }{
        {
            name: "success",
            args: MethodArgs{
                ID: "test-id",
            },
            setupMock: func(m *MockDependency) {
                m.On("Get", mock.Anything, "test-id").Return(&Entity{}, nil)
            },
            want:    &Result{Success: true},
            wantErr: false,
        },
        {
            name: "not found",
            args: MethodArgs{
                ID: "unknown",
            },
            setupMock: func(m *MockDependency) {
                m.On("Get", mock.Anything, "unknown").Return(nil, ErrNotFound)
            },
            wantErr:   true,
            wantErrIs: ErrNotFound,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mock := new(MockDependency)
            if tt.setupMock != nil {
                tt.setupMock(mock)
            }
            
            svc := NewService(mock)
            got, err := svc.Method(context.Background(), tt.args)
            
            if tt.wantErr {
                require.Error(t, err)
                if tt.wantErrIs != nil {
                    assert.ErrorIs(t, err, tt.wantErrIs)
                }
                return
            }
            
            require.NoError(t, err)
            assert.Equal(t, tt.want, got)
            mock.AssertExpectations(t)
        })
    }
}
```

## Validation Template

```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name       string
        input      *Entity
        wantErr    bool
        wantErrMsg string
    }{
        {
            name: "valid entity",
            input: &Entity{
                ID:    "id-1",
                Title: "Valid Title",
                Type:  "valid",
            },
            wantErr: false,
        },
        {
            name: "missing ID",
            input: &Entity{
                Title: "Valid Title",
                Type:  "valid",
            },
            wantErr:    true,
            wantErrMsg: "ID is required",
        },
        {
            name: "empty title",
            input: &Entity{
                ID:    "id-1",
                Title: "",
                Type:  "valid",
            },
            wantErr:    true,
            wantErrMsg: "title is required",
        },
        {
            name:       "nil entity",
            input:      nil,
            wantErr:    true,
            wantErrMsg: "entity is required",
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := Validate(tt.input)
            
            if tt.wantErr {
                require.Error(t, err)
                assert.Contains(t, err.Error(), tt.wantErrMsg)
                return
            }
            
            assert.NoError(t, err)
        })
    }
}
```

## HTTP Handler Template

```go
func TestHandler_HandleCreate(t *testing.T) {
    tests := []struct {
        name           string
        requestBody    string
        setupMock      func(*MockService)
        wantStatusCode int
        wantBody       string
    }{
        {
            name:        "success",
            requestBody: `{"title": "Test", "type": "task"}`,
            setupMock: func(m *MockService) {
                m.On("Create", mock.Anything, mock.Anything).Return(&Entity{ID: "new-id"}, nil)
            },
            wantStatusCode: http.StatusCreated,
            wantBody:       `"id":"new-id"`,
        },
        {
            name:           "invalid JSON",
            requestBody:    `{invalid}`,
            wantStatusCode: http.StatusBadRequest,
        },
        {
            name:        "service error",
            requestBody: `{"title": "Test", "type": "task"}`,
            setupMock: func(m *MockService) {
                m.On("Create", mock.Anything, mock.Anything).Return(nil, errors.New("db error"))
            },
            wantStatusCode: http.StatusInternalServerError,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockSvc := new(MockService)
            if tt.setupMock != nil {
                tt.setupMock(mockSvc)
            }
            
            handler := NewHandler(mockSvc)
            
            req := httptest.NewRequest(http.MethodPost, "/entities", strings.NewReader(tt.requestBody))
            req.Header.Set("Content-Type", "application/json")
            rec := httptest.NewRecorder()
            
            handler.HandleCreate(rec, req)
            
            assert.Equal(t, tt.wantStatusCode, rec.Code)
            if tt.wantBody != "" {
                assert.Contains(t, rec.Body.String(), tt.wantBody)
            }
            
            mockSvc.AssertExpectations(t)
        })
    }
}
```

## gRPC Handler Template

```go
func TestGRPCHandler_GetTask(t *testing.T) {
    tests := []struct {
        name      string
        request   *pb.GetTaskRequest
        setupMock func(*MockService)
        want      *pb.Task
        wantCode  codes.Code
    }{
        {
            name:    "success",
            request: &pb.GetTaskRequest{Id: "task-1"},
            setupMock: func(m *MockService) {
                m.On("Get", mock.Anything, rms.ID("task-1")).Return(&Task{
                    ID:    "task-1",
                    Title: "Test Task",
                }, nil)
            },
            want: &pb.Task{
                Id:    "task-1",
                Title: "Test Task",
            },
            wantCode: codes.OK,
        },
        {
            name:     "missing ID",
            request:  &pb.GetTaskRequest{Id: ""},
            wantCode: codes.InvalidArgument,
        },
        {
            name:    "not found",
            request: &pb.GetTaskRequest{Id: "unknown"},
            setupMock: func(m *MockService) {
                m.On("Get", mock.Anything, mock.Anything).Return(nil, ErrNotFound)
            },
            wantCode: codes.NotFound,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockSvc := new(MockService)
            if tt.setupMock != nil {
                tt.setupMock(mockSvc)
            }
            
            handler := NewGRPCHandler(mockSvc)
            got, err := handler.GetTask(context.Background(), tt.request)
            
            if tt.wantCode != codes.OK {
                require.Error(t, err)
                st, ok := status.FromError(err)
                require.True(t, ok)
                assert.Equal(t, tt.wantCode, st.Code())
                return
            }
            
            require.NoError(t, err)
            assert.Equal(t, tt.want.Id, got.Id)
            assert.Equal(t, tt.want.Title, got.Title)
            
            mockSvc.AssertExpectations(t)
        })
    }
}
```

## Parallel Test Template

```go
func TestConcurrentOperations(t *testing.T) {
    t.Parallel()
    
    tests := []struct {
        name  string
        input string
        want  string
    }{
        {"case 1", "input1", "output1"},
        {"case 2", "input2", "output2"},
        {"case 3", "input3", "output3"},
    }
    
    for _, tt := range tests {
        tt := tt  // Capture for parallel
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            
            got := ProcessInput(tt.input)
            assert.Equal(t, tt.want, got)
        })
    }
}
```

## Benchmark Template

```go
func BenchmarkFunction(b *testing.B) {
    // Setup
    input := createTestInput()
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        Function(input)
    }
}

func BenchmarkFunction_Parallel(b *testing.B) {
    input := createTestInput()
    
    b.ResetTimer()
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            Function(input)
        }
    })
}
```
