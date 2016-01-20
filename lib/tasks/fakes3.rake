namespace :fakes3 do
  desc 'Starts a Fake S3 Server'
  task start: :environment do
    system("echo 'hi'")
    system('fakes3 -p 10001 -r tmp/s3 &')
  end

  desc 'Kills the Fake S3 Server'
  task stop: :environment do
    system("echo 'killing' `ps -A | grep fakes3 | grep -v rake |
      grep -v grep | awk '{print $1}'`")
    system("kill -9 `ps -A | grep fakes3 | grep -v grep | awk '{print $1}'`")
  end
end
