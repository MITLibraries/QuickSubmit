namespace :submission do
  desc 'Delete Deposited Submissions older than One Month'
  task cleanup: :environment do
    logger           = Logger.new(STDOUT)
    logger.level     = Logger::INFO
    old_submissions = Submission.where(status: 'approved')
                                .where('updated_at < ?', 1.month.ago)
    logger.debug("Deleting #{old_submissions.count} old Submissions")
    old_submissions.each(&:destroy)
  end
end
