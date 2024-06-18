/*Task 1: Write a SQL statement that would retrieve ticket_id, current and previous status, tags, and requester id.*/

-- Assigning row number to each event
WITH ranking AS (
SELECT ticket_id, status, event_id, ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY event_id DESC) AS rn
FROM [CyberCare].[dbo].[ticket_events] te
),

-- Finding current and previous status for each ticket based on the row number
CurrentPreviousStatus AS (
SELECT ticket_id,
MAX(CASE WHEN rn = 1 THEN status END) AS current_status,
MAX(CASE WHEN rn = 2 THEN status END) AS previous_status
FROM ranking
GROUP BY ticket_id
)

SELECT t.ticket_id, current_status, previous_status, tags, requester_id
FROM [CyberCare].[dbo].[tickets] t
JOIN CurrentPreviousStatus cps ON t.ticket_id = cps.ticket_id
;


/*Task 2: Write a SQL statement that would retrieve ticket_id, ticket creation date, count of user messages,
--count of agent messages, and ticket duration (ticket is considered active till its status becomes closed)*/

-- Calculating the MIN and MAX ticket creation date and identifies if and when the ticket was closed.
WITH EventTimes AS (
SELECT ticket_id,
    MIN(created_at) AS min_created_at,
    MAX(created_at) AS max_created_at,
    MAX(CASE WHEN status = 'closed' THEN created_at ELSE NULL END) AS closed_date
FROM ticket_events
GROUP BY ticket_id
)

-- Calculating duration of closed ticket. If not closed - ticket is considered still active.
SELECT t.ticket_id,
    t.created_at AS ticket_creation_date,
    SUM(CASE WHEN te.is_agent_msg = 0 THEN 1 ELSE 0 END) AS user_message_count,
    SUM(CASE WHEN te.is_agent_msg = 1 THEN 1 ELSE 0 END) AS agent_message_count,
    CASE 
        WHEN et.closed_date IS NOT NULL THEN FORMAT(DATEADD(SECOND,DATEDIFF(SECOND, et.min_created_at, et.max_created_at), '1900-01-01'),'HH:mm:ss')
        ELSE 'active'
    END AS ticket_duration
FROM tickets t
JOIN ticket_events te ON t.ticket_id = te.ticket_id
LEFT JOIN EventTimes et ON t.ticket_id = et.ticket_id
GROUP BY
t.ticket_id,
t.created_at,
et.min_created_at,
et.max_created_at,
et.closed_date
ORDER BY t.ticket_id;
