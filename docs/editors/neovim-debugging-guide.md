# 🐛 Neovim Debugging Guide for Beginners

## What is Debugging?

Debugging is like being a detective 🕵️ - you set "pause points" (breakpoints) in your code to stop execution and inspect what's happening. Think of it as hitting pause on a video to examine a specific frame.

## 🎯 Essential Debugging Concepts

### Breakpoints = Pause Points
- **Red dots** 🔴 in your code where execution will pause
- Set them on lines where you want to "stop and look around"
- Like placing a "STOP" sign in your code

### Stepping = Moving Line by Line
- **Step Over** ⬇️: Execute current line, don't enter functions
- **Step Into** ➡️: Go inside function calls to see what they do
- **Step Out** ⬅️: Exit current function and return to caller

### Variables = Data Inspection
- See what values your variables contain at any moment
- Watch how they change as your code executes

## 🚀 Quick Start Guide

### 1. Set Your First Breakpoint
```vim
" Navigate to any line in your Java code
" Press <Leader>db (usually <Space>db) to toggle a breakpoint
" You'll see a red circle 🔴 appear in the gutter
```

### 2. Start Debugging
```vim
" Press F5 to start debugging
" Your program will run until it hits the breakpoint
```

### 3. Explore While Paused
```vim
" When paused at a breakpoint:
" - Press <Leader>ds to see all current variables
" - Press F10 to move to the next line
" - Press F5 to continue to the next breakpoint
```

## 🎮 Complete Hotkey Reference

### 🔴 Breakpoint Management
| Key | Action | Beginner Tip |
|-----|--------|--------------|
| `<Leader>db` | Toggle breakpoint | Most important! Sets pause points |
| `F9` | Toggle breakpoint (alternative) | Same as above, common in IDEs |
| `<Leader>dB` | Conditional breakpoint | Advanced: pause only when condition is true |
| `<Leader>dC` | Clear all breakpoints | Remove all pause points |

### ▶️ Debug Session Control
| Key | Action | Beginner Tip |
|-----|--------|--------------|
| `F5` | Start/Continue debugging | **Start here!** Runs your program |
| `Shift+F5` | Stop debugging | End the debugging session |
| `Ctrl+F5` | Restart debugging | Start over from the beginning |

### 👣 Code Navigation (Stepping)
| Key | Action | Beginner Tip |
|-----|--------|--------------|
| `F10` | Step Over | **Most used!** Go to next line |
| `F11` | Step Into | Enter function calls (advanced) |
| `Shift+F11` | Step Out | Exit current function |
| `F6` | Pause | Pause execution manually |

### 🔍 Inspection Tools
| Key | Action | Beginner Tip |
|-----|--------|--------------|
| `<Leader>ds` | Show variables | **Essential!** See current variable values |
| `<Leader>dr` | Open debug console | Type expressions to evaluate |
| `<Leader>df` | Show call stack | See function call hierarchy |
| `<Leader>de` | Evaluate expression | Calculate custom expressions |
| `<Leader>dh` | Show debug help | Get this help anytime! |

## 📝 Step-by-Step Debugging Workflow

### For Java Code:

1. **Open your Java file**
   ```java
   public class HelloJava {
       public static void main(String[] args) {
           String message = "Hello World";  // <- Set breakpoint here
           System.out.println(message);     // <- Maybe here too
           int number = 42;
           System.out.println("Number: " + number);
       }
   }
   ```

2. **Set breakpoints** 🔴
   - Place cursor on line 3 (`String message = "Hello World";`)
   - Press `<Leader>b` to set a breakpoint
   - You'll see a red circle appear

3. **Start debugging** ▶️
   - Press `F5` to start debugging
   - Your program will compile and run
   - It will pause at the breakpoint (line 3)

4. **Inspect variables** 🔍
   - Press `<Leader>ds` to see all variables
   - At this point, you might not see `message` yet (it's about to be created)

5. **Step through code** 👣
   - Press `F10` to execute the current line and move to the next
   - Now `message` variable exists with value "Hello World"
   - Press `<Leader>ds` again to see the variable

6. **Continue debugging** ⏭️
   - Press `F10` again to execute the print statement
   - See the output in your terminal
   - Continue stepping or press `F5` to run to the next breakpoint

7. **Stop debugging** ⏹️
   - Press `Shift+F5` when done
   - Or let the program finish naturally

## 🎯 Common Debugging Scenarios

### 🐞 "My variable has the wrong value"
```vim
" 1. Set breakpoint before the variable assignment
" 2. Start debugging (F5)
" 3. Step through (F10) and watch the variable change
" 4. Use <Leader>ds to see current values
```

### 🔍 "I don't understand what this function does"
```vim
" 1. Set breakpoint at the function call
" 2. When it pauses, use F11 (Step Into) to enter the function
" 3. Step through the function line by line with F10
" 4. Use Shift+F11 (Step Out) to return to the caller
```

### 🚨 "My program crashes"
```vim
" 1. Set breakpoints before the crash location
" 2. Step through slowly with F10
" 3. Watch variables with <Leader>ds
" 4. Find the exact line where things go wrong
```

### 🔁 "My loop doesn't work correctly"
```vim
" 1. Set breakpoint inside the loop
" 2. Each time it pauses, check variables with <Leader>ds
" 3. Use F5 to continue to next iteration
" 4. Watch how variables change each loop
```

## 💡 Pro Tips for Beginners

### Start Simple
- Begin with just `<Leader>b` (breakpoints) and `F5` (start/continue)
- Add `F10` (step over) and `<Leader>ds` (show variables)
- Learn more hotkeys gradually

### Best Practices
- **Set breakpoints strategically**: Before suspicious lines, not after
- **Use meaningful variable names**: Easier to spot in variable lists
- **Step slowly**: Don't rush - observe each step
- **Check variables frequently**: Use `<Leader>ds` often

### Visual Cues
- 🔴 **Red circles**: Your breakpoints
- ▶️ **Arrow**: Current execution line (where you're paused)
- **Highlighted line**: Where execution is currently stopped

## 🆘 Troubleshooting

### "F5 doesn't start debugging"
- Make sure you have Java files in your project
- Check that JDTLS is working (Java LSP should be active)
- Try `:DapContinue` command manually

### "No variables showing"
- Make sure you're paused at a breakpoint
- Variables only exist after they're declared
- Use `<Leader>ds` to refresh the view

### "Breakpoints not working"
- Ensure you're in a Java file
- Try clearing all breakpoints with `<Leader>bc` and set new ones
- Make sure your code is actually being executed

## 🎓 Learning Path

### Week 1: Master the Basics
- Learn `<Leader>b` (breakpoints) and `F5` (start)
- Practice setting breakpoints and starting debug sessions
- Get comfortable with `<Leader>ds` (show variables)

### Week 2: Add Stepping
- Learn `F10` (step over) for line-by-line execution
- Practice watching variables change as you step
- Experiment with different breakpoint locations

### Week 3: Advanced Navigation
- Learn `F11` (step into) and `Shift+F11` (step out)
- Practice debugging function calls
- Try conditional breakpoints with `<Leader>B`

### Week 4: Inspection Tools
- Master the debug console with `<Leader>dr`
- Learn to evaluate expressions with `<Leader>de`
- Explore call stacks with `<Leader>df`

## 🎯 Remember: Debugging is a Skill!

Like learning to drive or play an instrument, debugging takes practice. Start with simple programs and gradually work up to more complex code. The hotkeys will become second nature with time.

**Most Important**: Don't be afraid to experiment! You can't break anything by debugging - it's all about learning and understanding your code better.

---

*Happy debugging! 🐛✨*

*Use `<Leader>dh` anytime in Neovim to see a quick reference of all debugging hotkeys.*