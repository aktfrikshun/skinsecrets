namespace :recurring_jobs do
  desc "Set up recurring jobs from config/recurring.yml"
  task setup: :environment do
    puts "Setting up recurring jobs..."

    recurring_jobs = YAML.load_file(Rails.root.join("config", "recurring.yml"))

    recurring_jobs[Rails.env]&.each do |job_name, job_config|
      puts "Setting up job: #{job_name}"

      if job_config["class"]
        # For class-based jobs
        job_class = job_config["class"].constantize
        queue = job_config["queue"] || "default"
        args = job_config["args"] || []
        schedule = job_config["schedule"]

        # Find existing recurring task or create new one
        recurring_task = SolidQueue::RecurringTask.find_or_initialize_by(key: job_name)
        recurring_task.update!(
          class_name: job_class.name,
          queue_name: queue,
          arguments: args,
          schedule: schedule
        )
        puts "  ✓ Set up class-based job: #{job_class.name}"

      elsif job_config["command"]
        # For command-based jobs
        command = job_config["command"]
        priority = job_config["priority"] || 0
        schedule = job_config["schedule"]

        # Find existing recurring task or create new one
        recurring_task = SolidQueue::RecurringTask.find_or_initialize_by(key: job_name)
        recurring_task.update!(
          class_name: "CommandJob",
          queue_name: "default",
          arguments: [ command ],
          priority: priority,
          schedule: schedule
        )
        puts "  ✓ Set up command-based job: #{command}"
      end
    end

    puts "Recurring jobs setup complete!"
  end

  desc "List all recurring jobs"
  task list: :environment do
    puts "Current recurring jobs:"
    SolidQueue::RecurringTask.all.each do |task|
      puts "  #{task.key}: #{task.class_name} (#{task.schedule})"
    end
  end
end
