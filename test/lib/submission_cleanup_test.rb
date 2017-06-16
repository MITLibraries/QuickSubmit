require 'test_helper'
require 'rake'

class RakeTaskTestCase < ActiveSupport::TestCase
  def setup
    Rake::Task.define_task :environment
    QuickSubmit::Application.load_tasks

    Timecop.freeze(Time.zone.local(1999))
    @sub_old_approved = create_subs('old and approved', 'approved')
    @sub_old_notapproved = create_subs('old and unapproved', '')
    Timecop.return

    @sub_new_approved = create_subs('new and approved', 'approved')
    @sub_new_notapproved = create_subs('new and unapproved', '')
  end

  def teardown
    Rake::Task.clear
  end

  def create_subs(title, status)
    Submission.create(
      title: title,
      documents: ['b_pdf.pdf'],
      user: users(:one),
      funders: ['Department of Energy (DOE)'],
      publication_year: 1.year.ago.strftime('%Y'),
      publication_month: 1.year.ago.strftime('%B'),
      status: status,
      handle: 'http://example.com'
    )
  end

  test 'submissions with approved and older than 1 month are deleted' do
    subs = Submission.count
    Rake::Task['submission:cleanup'].invoke
    assert_raises(ActiveRecord::RecordNotFound) do
      @sub_old_approved.reload
    end
    assert_equal(subs - 1, Submission.count)
  end

  test 'submissions without approved and older than 1 month are not deleted' do
    subs = Submission.count
    Rake::Task['submission:cleanup'].invoke
    @sub_old_notapproved.reload
    assert_equal(subs - 1, Submission.count)
  end

  test 'submissions with approved and newer than one month are not deleted' do
    subs = Submission.count
    Rake::Task['submission:cleanup'].invoke
    @sub_new_approved.reload
    assert_equal(subs - 1, Submission.count)
  end

  test 'submissions without approved and newer than 1 month are not deleted' do
    subs = Submission.count
    Rake::Task['submission:cleanup'].invoke
    @sub_new_notapproved.reload
    assert_equal(subs - 1, Submission.count)
  end
end
