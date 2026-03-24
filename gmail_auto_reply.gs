/**
 * Gmail Auto-Reply: Dynamic 3-Word List
 * This script extracts the 6th, 7th, and 8th word from every incoming email,
 * appends them to a file in your Google Drive, and then picks a random line 
 * from that Google Drive file to send as the auto-reply.
 */

// Name of the text file that will be automatically created in your Google Drive
const FILE_NAME = "My_Dynamic_Reply_List.txt"; 

function getDriveFile() {
  const files = DriveApp.getFilesByName(FILE_NAME);
  if (files.hasNext()) {
    return files.next();
  } else {
    // If the file doesn't exist yet, create it with one default starting line
    return DriveApp.createFile(FILE_NAME, "a small version\n");
  }
}

function autoReplyWithPoem() {
  // Search for any unread email in the inbox, but exclude common "no reply" addresses
  const searchQuery = "is:unread label:inbox -from:noreply -from:no-reply";
  
  const threads = GmailApp.search(searchQuery);
  if (threads.length === 0) return;
  
  // 1. Fetch our living list of 3-word strings from Google Drive
  const driveFile = getDriveFile();
  let currentFileText = driveFile.getBlob().getDataAsString();
  
  // 2. Process each unread matching email
  for (let i = 0; i < threads.length; i++) {
    const messages = threads[i].getMessages();
    
    for (let j = 0; j < messages.length; j++) {
      const message = messages[j];
      
      if (message.isUnread()) {
        // Read the plain text of the email they just sent us
        const bodyText = message.getPlainBody();
        
        // If the email is completely blank
        if (bodyText.trim() === "") {
          const replyText = "too lazy to write something ?\n\n— auto reply";
          Logger.log("Blank email detected. Sending lazy reply.");
          message.reply(replyText);
          message.markRead();
          continue; // Move to the next message without saving anything
        }
        
        // Split the email into individual words (skipping spaces/newlines)
        const words = bodyText.trim().split(/\s+/);
        
        let newThreeWords = "";
        
        // Check if the email actually has at least 8 words
        if (words.length >= 8) {
          // Arrays start at 0, so words[5] is the 6th word, [6] is 7th, [7] is 8th.
          newThreeWords = words[5] + " " + words[6] + " " + words[7];
        } else {
          // Fallback if they sent a very short email
          newThreeWords = "too short email";
        }
        
        // 3. Append these 3 new words to our Google Drive file
        currentFileText += newThreeWords + "\n";
        driveFile.setContent(currentFileText);
        
        // 4. Split the updated file back into a list of lines so we can pick one
        const linesArray = currentFileText.trim().split("\n");
        
        // 5. Pick a random line from the whole Google Drive file
        const randomIndex = Math.floor(Math.random() * linesArray.length);
        const randomPoemLine = linesArray[randomIndex];
        
        const replyText = randomPoemLine + "\n\n— auto reply";
        
        // 6. Send it back!
        Logger.log("Extracted words: '" + newThreeWords + "' | Sending reply: '" + randomPoemLine + "'");
        message.reply(replyText);
        message.markRead();
      }
    }
  }
}
