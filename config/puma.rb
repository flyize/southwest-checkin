threads 0,8
workers 2 unless Gem.win_platform?
preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
