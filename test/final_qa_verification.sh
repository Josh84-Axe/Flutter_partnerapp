#!/bin/bash

# Configuration
API_KEY="aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE"
BASE_URL="https://api.coleah.com/api/cases/external/cases"
TEST_EMAIL="verification@tiknetafrica.com"

echo "🧪 [QA] Final Verification of Support Ticket System..."

# 1. Fetch Tickets
echo "🚀 Step 1: Listing tickets for $TEST_EMAIL..."
LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/?contact_email=$TEST_EMAIL" -H "X-Api-Key: $API_KEY")
TICKET_ID=$(echo "$LIST_RESPONSE" | grep -o '"id":"[^"]*"' | head -n 1 | cut -d'"' -f4)

if [ -z "$TICKET_ID" ]; then
    echo "❌ FAILED: Could not retrieve a ticket ID."
    exit 1
fi
echo "✅ SUCCESS: Found Ticket $TICKET_ID"

# 2. Fetch Messages
echo "🚀 Step 2: Retrieving message history..."
MSG_RESPONSE=$(curl -s -X GET "$BASE_URL/$TICKET_ID/messages/" -H "X-Api-Key: $API_KEY")
MSG_COUNT=$(echo "$MSG_RESPONSE" | grep -o '{"id":' | wc -l)
echo "✅ SUCCESS: History contains $MSG_COUNT messages."

# 3. Send Reply
echo "🚀 Step 3: Verifying Reply capability..."
REPLY_CONTENT="Final QA Verification Reply $(date)"
REPLY_RESPONSE=$(curl -s -X POST "$BASE_URL/$TICKET_ID/reply/" \
    -H "X-Api-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"content\": \"$REPLY_CONTENT\"}")

if [[ "$REPLY_RESPONSE" == *"id"* ]]; then
    echo "✅ SUCCESS: Reply persisted to CRM."
else
    echo "❌ FAILED: CRITICAL - CRM rejected the reply."
    exit 1
fi

echo -e "\n🎉 Support Ticket System QA PASSED!"
