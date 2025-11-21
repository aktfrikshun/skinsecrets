class CommandJob < ApplicationJob
  queue_as :default

  def perform(command)
    Rails.logger.info "CommandJob: Executing command: #{command}"

    begin
      result = system(command)
      if result
        Rails.logger.info "CommandJob: Command executed successfully: #{command}"
      else
        Rails.logger.error "CommandJob: Command failed: #{command}"
      end
    rescue => e
      Rails.logger.error "CommandJob: Error executing command '#{command}': #{e.message}"
      raise e
    end
  end
end
