# Copilot Instructions for sendautoreplyappelscript

## Project Overview
Apple Mail rule action handler that sends automated replies with random poems. Users configure a Mail rule to trigger this script, which responds to incoming messages with a randomly selected poem from a text file.

## Technology Stack
- **Implementation**: AppleScript Mail Rule Action (not standalone script)
- **Target Application**: Apple Mail only
- **Platform**: macOS only
- **Dependencies**: `poems.txt` file on user's Desktop

## Architecture

### Mail Rule Action Pattern
The script uses `using terms from application "Mail"` wrapper with the standard handler:
```applescript
on perform mail action with messages theMessages for rule theRule
```
This is **not a standalone script** - it must be saved as a compiled `.scpt` and attached to a Mail rule via Mail > Preferences > Rules.

### Core Components
1. **Message Selection**: Picks newest message from batch by `date received`
2. **Poem Randomization**: Reads `~/Desktop/poems.txt`, splits by `---` delimiters, picks random poem
3. **Reply Sending**: Creates fresh outgoing message (not quoted reply) with poem + "— auto reply" signature
4. **State Tracking**: Flags and marks processed messages as read

### Data Files
- **`~/Desktop/mail_autoreply_log.txt`**: Append-only log for debugging (includes timestamps, rule name, sender, errors)
- **`~/Desktop/poems.txt`**: Poem collection, separated by `---` on its own line

## Critical Implementation Details

### Why Fresh Messages vs Replies
Script uses `make new outgoing message` instead of `reply` to avoid quoting original content. This keeps responses clean and poem-focused.

### Email Address Extraction
Uses Mail's `extract address from` to parse sender strings like `"Name" <email@domain.com>`. Falls back to raw sender if extraction fails.

### Bounce Detection
Skips responses to:
- Senders containing "mailer-daemon"
- Subjects containing "Undelivered"

### Error Handling Philosophy
- Extensive `try-catch` blocks around every Mail interaction
- All errors logged to desktop log file with error number
- Script continues even if individual operations fail (graceful degradation)
- Marks message as processed only **after** successful send

## Development Workflow

### Testing the Rule Action
```bash
# Compile to script bundle (required for Mail rules)
osacompile -o ~/Desktop/AutoReply.scpt your_script.applescript

# Then in Mail.app:
# Preferences > Rules > Add Rule > Perform the following actions:
# "Run AppleScript" > Choose AutoReply.scpt
```

### Creating Test Poems File
```bash
cat > ~/Desktop/poems.txt << 'EOF'
Roses are red
Violets are blue
I'm away right now
I'll get back to you
---
Out of office today
Will respond when I may
---
EOF
```

### Debugging
- **Primary tool**: Check `~/Desktop/mail_autoreply_log.txt` after triggering rule
- Each run logs: timestamp, rule name, message count, newest message details, send status
- Fatal errors include error number and message
- **Test safely**: Create rule that matches specific subject line first

### Common Issues
- **Script not triggered**: Ensure rule is enabled and conditions match
- **Poems file not found**: Check exact path `~/Desktop/poems.txt` exists
- **Empty replies**: Verify poems.txt has content and uses `---` separators
- **Address extraction fails**: Log will show raw sender vs extracted address

## Code Conventions

### Logging Pattern
All significant events use:
```applescript
do shell script "echo " & quoted form of "MESSAGE" & " >> " & quoted form of logFile
```
Always use `quoted form of` for file paths and user data to handle spaces/special chars.

### Text Processing
- Use `set AppleScript's text item delimiters` to split strings (remember to reset after)
- `trimText()` handler strips leading/trailing whitespace using rich text manipulation
- Check for `missing value` when properties might be undefined

### Message Properties Used
- `date received` - Sorting to find newest
- `subject` - For "Re:" prefix and bounce detection
- `sender` - Raw sender string (may include name and brackets)
- `extract address from` - Mail-specific command to parse email addresses
- `flagged status` / `read status` - Mark processed messages

## Integration Points
- **Mail Rules Engine**: Triggered by user-defined conditions (from specific sender, subject contains, etc.)
- **Desktop Files**: Hardcoded to Desktop for simplicity (poems + log)
- **Shell Commands**: Uses `do shell script` for file I/O and logging

## Security & Privacy
- Never logs full message content (only subject and sender)
- Skip bounce messages to prevent mail loops
- User controls which messages trigger via Mail rule conditions
- Fresh messages (not replies) prevent accidental threading issues

## Extension Ideas
- Add reply-once tracking (check if sender in sent messages)
- Support multiple poem collections by subject/sender
- Configurable file paths via property list
- Add time-of-day restrictions
- Include original subject parsing for context-aware poems
