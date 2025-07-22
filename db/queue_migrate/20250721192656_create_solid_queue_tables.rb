class CreateSolidQueueTables < ActiveRecord::Migration[8.0]
  def up
    load Rails.root.join("db", "queue_schema.rb")
  end

  def down
    # Drop all solid_queue tables
    tables = [
      "solid_queue_blocked_executions",
      "solid_queue_claimed_executions",
      "solid_queue_failed_executions",
      "solid_queue_jobs",
      "solid_queue_pauses",
      "solid_queue_processes",
      "solid_queue_ready_executions",
      "solid_queue_recurring_executions",
      "solid_queue_recurring_tasks",
      "solid_queue_scheduled_executions",
      "solid_queue_semaphores"
    ]

    tables.each do |table|
      drop_table table if table_exists?(table)
    end
  end
end
