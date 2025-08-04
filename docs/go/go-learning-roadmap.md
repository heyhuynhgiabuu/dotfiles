# Go Learning Roadmap 🐹

A structured path to learn Go programming using your NvChad + tmux setup.

## Phase 1: Fundamentals (Week 1-2)

### Day 1-3: Basic Syntax

- [ ] Go Tour (<https://go.dev/tour/>)
  - Variables, constants, types
  - Functions, control flow
  - Pointers, structs, arrays, slices

- [ ] **Practice**: Create `hello-go` project

  ```bash
  go-new-project hello-go
  # Practice basic syntax in main.go
  ```

### Day 4-7: Core Concepts

- [ ] Go by Example: Methods, Interfaces
- [ ] Error handling patterns

- [ ] **Practice**: Build a calculator CLI

  ```bash
  go-new-project calculator
  # Implement basic arithmetic with error handling
  ```

## Phase 2: Intermediate Concepts (Week 3-4)

### Week 3: Concurrency Basics
- [ ] Goroutines and channels
- [ ] Select statements
- [ ] **Practice**: Build a concurrent file processor
  ```bash
  go-new-project file-processor
  # Process multiple files concurrently
  ```

### Week 4: Standard Library
- [ ] HTTP client/server
- [ ] JSON handling
- [ ] File I/O
- [ ] **Practice**: Build a REST API
  ```bash
  go-new-project simple-api
  ```

## Phase 3: Real-World Projects (Week 5-8)

### Project Ideas:
1. **CLI Tool** - File organizer, log parser
2. **Web API** - Todo API, URL shortener
3. **Microservice** - User authentication service
4. **DevOps Tool** - System monitor, deployment script

## Your Development Workflow

### 1. Start a new project:
```bash
go-new-project my-project
# Creates project structure, initializes git
```

### 2. Open development environment:
```bash
tmux-go-layout my-project ~/go/src/my-project
# Opens tmux with editor, terminal, and test panes
```

### 3. NvChad Go shortcuts (in .go files):
- `<leader>gr` - Run current project
- `<leader>gt` - Run tests
- `<leader>gb` - Build project
- `<leader>gf` - Format file
- `<leader>gl` - Run linter

### 4. Testing workflow:
```bash
# In tmux test pane:
go test -v ./...        # Run all tests
go test -cover ./...    # With coverage
go test -bench ./...    # Run benchmarks
```

## Learning Resources by Phase

### Beginner
- [Go Tour](https://go.dev/tour/) - Interactive tutorial
- [Go by Example](https://gobyexample.com/) - Practical examples
- [Go Playground](https://go.dev/play/) - Try code online

### Intermediate
- [Effective Go](https://go.dev/doc/effective_go) - Best practices
- [Go Blog](https://go.dev/blog/) - Official articles
- [pkg.go.dev](https://pkg.go.dev/) - Package documentation

### Advanced
- [Go Memory Model](https://go.dev/ref/mem) - Concurrency details
- [Go Proverbs](https://go-proverbs.github.io/) - Design philosophy
- [High Performance Go](https://dave.cheney.net/high-performance-go-workshop/dotgo-paris.html)

## Practice Projects

### Beginner Projects:
1. **Number Guessing Game** - Basic input/output, loops
2. **File Reader** - File I/O, error handling
3. **Word Counter** - String manipulation, maps

### Intermediate Projects:
1. **HTTP Server** - Web basics, routing
2. **JSON API Client** - HTTP client, JSON parsing
3. **Concurrent Downloader** - Goroutines, channels

### Advanced Projects:
1. **Web Framework** - HTTP handling, middleware
2. **Database ORM** - Reflection, interfaces
3. **Container Runtime** - System programming, low-level Go

## Daily Routine

1. **Start**: `tmux-go-layout go-learning`
2. **Code**: 30-60 minutes of focused coding
3. **Test**: Always write tests for your functions
4. **Review**: Read other people's Go code on GitHub
5. **Document**: Keep notes in your project README

## Go Community

- [r/golang](https://reddit.com/r/golang) - Reddit community
- [Gophers Slack](https://gophers.slack.com/) - Chat community
- [Go Forum](https://forum.golangbridge.org/) - Help forum
- [Awesome Go](https://awesome-go.com/) - Curated resources

## Tips for Success

1. **Write code daily** - Even 15 minutes helps
2. **Read the standard library** - Learn idiomatic Go
3. **Test everything** - Go has excellent testing tools
4. **Use gofmt** - Let the tools format your code
5. **Embrace errors** - Don't ignore error handling
6. **Think in Go** - Don't translate from other languages

Happy coding! 🚀
