using terms from application "Mail"
	on perform mail action with messages theMessages for rule theRule
		set logFile to (POSIX path of (path to desktop)) & "mail_autoreply_log.txt"
		do shell script "echo '--- RUN '\"$(date)\"' ---' >> " & quoted form of logFile
		
		try
			-- log rule + message count
			do shell script "echo " & quoted form of ("RULE=" & (name of theRule) & " | COUNT=" & (count of theMessages)) & " >> " & quoted form of logFile
			
			if (count of theMessages) is 0 then
				do shell script "echo " & quoted form of "NO MESSAGES PASSED IN" & " >> " & quoted form of logFile
				return
			end if
			
			-- poems file
			set poemFile to (POSIX path of (path to desktop)) & "poems.txt"
			do shell script "test -f " & quoted form of poemFile
			do shell script "echo " & quoted form of ("POEMS FILE OK: " & poemFile) & " >> " & quoted form of logFile
			
			set poemText to do shell script "/bin/cat " & quoted form of poemFile
			if poemText is "" then
				do shell script "echo " & quoted form of "POEMS FILE IS EMPTY" & " >> " & quoted form of logFile
				return
			end if
			
			-- split poems by ---
			set AppleScript's text item delimiters to "---"
			set poemList to every text item of poemText
			set AppleScript's text item delimiters to ""
			
			-- pick newest message
			set newestMsg to missing value
			set newestDate to missing value
			
			repeat with mm in theMessages
				try
					set d to date received of mm
					if newestDate is missing value then
						set newestDate to d
						set newestMsg to mm
					else if d > newestDate then
						set newestDate to d
						set newestMsg to mm
					end if
				end try
			end repeat
			
			if newestMsg is missing value then
				do shell script "echo " & quoted form of "COULD NOT PICK NEWEST MESSAGE" & " >> " & quoted form of logFile
				return
			end if
			
			set m to newestMsg
			
			-- log message basics
			set theSubj to ""
			try
				set theSubj to subject of m
			end try
			
			set rawSender to ""
			try
				set rawSender to sender of m
			end try
			
			set senderAddr to rawSender
			try
				set senderAddr to extract address from rawSender
				if senderAddr is missing value or senderAddr is "" then set senderAddr to rawSender
			end try
			
			do shell script "echo " & quoted form of ("NEWEST subj=" & theSubj & " | rawSender=" & rawSender & " | addr=" & senderAddr) & " >> " & quoted form of logFile
			
			-- skip bounces
			if senderAddr contains "mailer-daemon" then
				do shell script "echo " & quoted form of "SKIP mailer-daemon" & " >> " & quoted form of logFile
				return
			end if
			if theSubj contains "Undelivered" then
				do shell script "echo " & quoted form of "SKIP undelivered subject" & " >> " & quoted form of logFile
				return
			end if
			
			-- compose
			set randomPoem to my trimText(some item of poemList)
			set replyText to randomPoem & return & return & "— auto reply"
			
			-- send fresh outgoing message (no quoting)
			tell application "Mail"
				set outMsg to make new outgoing message with properties {subject:"Re: " & theSubj, content:replyText, visible:false}
				tell outMsg
					make new to recipient at end of to recipients with properties {address:senderAddr}
				end tell
				send outMsg
			end tell
			
			do shell script "echo " & quoted form of ("SENT to " & senderAddr) & " >> " & quoted form of logFile
			
			-- mark processed (after we confirm send works)
			try
				tell application "Mail"
					set flagged status of m to true
					set read status of m to true
				end tell
			end try
			
		on error errMsg number errNum
			do shell script "echo " & quoted form of ("FATAL ERROR " & errNum & ": " & errMsg) & " >> " & quoted form of logFile
		end try
	end perform mail action with messages
	
	on trimText(t)
		set t to t as rich text
		repeat while (length of t) > 0 and (t begins with return or t begins with space or t begins with tab)
			if (length of t) < 2 then exit repeat
			set t to rich text 2 thru -1 of t
		end repeat
		repeat while (length of t) > 0 and (t ends with return or t ends with space or t ends with tab)
			if (length of t) < 2 then exit repeat
			set t to rich text 1 thru -2 of t
		end repeat
		return t
	end trimText
end using terms from
