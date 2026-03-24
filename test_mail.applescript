using terms from application "Mail"
tell application "Mail"
    set outMsg to make new outgoing message with properties {subject:"Test", content:"Hello", visible:false}
end tell
end using terms from
