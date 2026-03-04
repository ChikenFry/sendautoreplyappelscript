# sendautoreplyappelscript

Automated out-of-office replies for Apple Mail that send random poems to incoming messages.

## Overview

This AppleScript integrates with Apple Mail's rules system to automatically reply to incoming emails with randomly selected poems. Perfect for creative out-of-office responses!

## Features

- 🎭 Sends random poems as auto-replies
- 📧 Works as a Mail rule action (triggers automatically)
- 🛡️ Skips bounce messages to prevent mail loops
- 📝 Detailed logging for debugging
- 🎯 Only replies to the newest message in batch

## Setup Instructions

### 1. Prepare the Poems File

Copy `poems_example.txt` to your Desktop and rename it to `poems.txt`:

```bash
cp poems_example.txt ~/Desktop/poems.txt
```

Edit `~/Desktop/poems.txt` to add your own poems. Separate each poem with `---` on its own line:

```
Your first poem
goes here
---
Second poem
can be multiple lines
---
Third poem...
```

### 2. Compile the Script

```bash
osacompile -o ~/Desktop/MailAutoReply.scpt mail_auto_reply.applescript
```

### 3. Create a Mail Rule

1. Open **Mail.app**
2. Go to **Mail > Preferences > Rules** (or Settings > Rules on newer macOS)
3. Click **Add Rule**
4. Set conditions for when to auto-reply (e.g., "From contains @example.com")
5. In "Perform the following actions", select **Run AppleScript**
6. Choose `~/Desktop/MailAutoReply.scpt`
7. Click **OK**

### 4. Test It

Send yourself a test email that matches your rule conditions. Check `~/Desktop/mail_autoreply_log.txt` for debug output.

## How It Works

1. Mail rule triggers when conditions match
2. Script reads all poems from `~/Desktop/poems.txt`
3. Selects the newest incoming message
4. Picks a random poem
5. Sends reply with poem + "— auto reply" signature
6. Marks message as flagged and read
7. Logs everything to `~/Desktop/mail_autoreply_log.txt`

## Troubleshooting

**Script doesn't run:**
- Verify the Mail rule is enabled
- Check System Preferences > Security & Privacy > Automation (Mail should have permissions)

**No replies sent:**
- Check `~/Desktop/mail_autoreply_log.txt` for errors
- Verify `~/Desktop/poems.txt` exists and has content
- Ensure poems are separated by `---`

**Replies look wrong:**
- Check for extra whitespace in poems.txt
- The script trims leading/trailing spaces automatically

## Files

- `mail_auto_reply.applescript` - Main script
- `poems_example.txt` - Sample poems file
- `.github/copilot-instructions.md` - AI coding assistant guide

## License

MIT 
