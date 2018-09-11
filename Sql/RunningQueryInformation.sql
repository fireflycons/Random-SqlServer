/*
    Quick script to list currently active sessions and what they are doing
    It will tell you for each active query

    - What time it started
    - The database context
    - Command being executed
    - Percent complete
    - What time it is estimated to be finished
    - The query text
    - Any blocking session ID
*/

SELECT  [session_id] as [spid],
        [start_time],
        [status],
        [command],
        [percent_complete],
        DB_NAME([database_id]) as [running_in],
        [blocking_session_id],
        [wait_type],
        convert(varchar, dateadd(ms, [wait_time], 0),114) as [wait_time],
        convert(varchar, dateadd(ms, [total_elapsed_time], 0),114) as [elapsed_time],
        convert(varchar, dateadd(ms, [estimated_completion_time] + [total_elapsed_time], [start_time]),114) as [est_completed_by],
        text
FROM    [master].[sys].[dm_exec_requests] 
        CROSS APPLY [master].[sys].[dm_exec_sql_text]([sql_handle]) 
where [session_id] <> @@SPID
